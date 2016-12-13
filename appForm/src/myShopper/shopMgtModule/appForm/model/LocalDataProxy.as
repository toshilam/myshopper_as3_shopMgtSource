package myShopper.shopMgtModule.appForm.model
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.Config;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.emun.AMFServicesErrorID;
	import myShopper.common.emun.RequestType;
	import myShopper.common.emun.ServiceID;
	import myShopper.common.emun.VOID;
	import myShopper.common.interfaces.IResponder;
	import myShopper.common.net.LocalDataService;
	import myShopper.common.net.LocalDataServiceRequest;
	import myShopper.common.net.ServiceRequest;
	import myShopper.common.net.ServiceResponse;
	import myShopper.common.server.AMFResultFactory;
	import myShopper.shopMgtCommon.emun.AMFShopManagementServicesType;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	
	CONFIG::air
	{
		import myShopper.common.air.net.LocalSalesDataService;
		import myShopper.common.air.net.LocalSalesDataServiceRequest;
	}
	
	
	public class LocalDataProxy extends ApplicationProxy implements IRemoteDataProxy, IResponder
	{
		private var _localService:LocalDataService;
		private var _myShopInfoVO:ShopInfoVO;
		private var _salesTimer:Timer;
		
		CONFIG::air
		private var _localDBService:LocalSalesDataService;
		
		private var _amf:AMFRemoteProxy;
		private function get amf():AMFRemoteProxy
		{
			if (!_amf) _amf = facade.retrieveProxy(ProxyID.AMF) as AMFRemoteProxy;
			return _amf;
		}
		
		public function LocalDataProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			
			_localService = serviceManager.getAsset(ServiceID.LOCAL_DATA);
			_myShopInfoVO = voManager.getAsset(VOID.MY_SHOP_INFO);
			
			if ( !_localService )
			{
				throw(new UninitializedError('LocalDataProxy : onRegister : unable to get LocalDataService'));
			}
			
			
			
			CONFIG::air
			{
				_localDBService = serviceManager.getAsset(ServiceID.LOCAL_DATA_DB);
				
				if ( !_localDBService )
				{
					throw(new UninitializedError('LocalDataProxy : onRegister : unable to get LocalSalesDataService'));
				}
				
				
			}
			
			_salesTimer = new Timer(1000 * 60 * 5, 1);
			_salesTimer.addEventListener(TimerEvent.TIMER_COMPLETE, salesTimerEventHandler);
		}
		
		public function salesTimerEventHandler(e:TimerEvent):void 
		{
			request(new LocalDataServiceRequest('', RequestType.LOCAL_DATA_GET_ORDERS, null, this));
			_salesTimer.reset();
			_salesTimer.start();
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			if (!_localService.init(_myShopInfoVO.shopNo))
			{
				//error handling
			}
			
			CONFIG::air
			{
				if (!_localDBService.init(Config.DB_SALES_DB, Config.DB_SALES_TABLE))
				{
					//error handling
				}
			}
			
			_salesTimer.start();
		}
		
		public function isReady():Boolean
		{
			CONFIG::air
			{
				return _localDBService.isReady();
			}
			
			return true;
		}
		
		CONFIG::web
		public function request(inRequest:LocalDataServiceRequest):Boolean
		{
			return _localService.request(inRequest);
		}
		
		CONFIG::air
		public function request(inRequest:LocalDataServiceRequest):Boolean
		{
			switch(inRequest.type)
			{
				case RequestType.LOCAL_DATA_SAVE_ORDER:
				case RequestType.LOCAL_DATA_REMOVE_ORDER:
				case RequestType.LOCAL_DATA_GET_ORDER_BY_NO:
				case RequestType.LOCAL_DATA_GET_ORDERS:
				{
					if (!isReady())
					{
						echo('request : service is not ready!');
						return false;
					}
					
					var req:LocalSalesDataServiceRequest = new LocalSalesDataServiceRequest(_myShopInfoVO.shopNo, inRequest.key, inRequest.type, inRequest.data, inRequest.requester);
					return _localDBService.request(req);
				}
			}
			
			return _localService.request(inRequest);
		}
		
		/* INTERFACE myShopper.common.interfaces.IResponder */
		
		public function result(inData:Object):void 
		{
			var response:ServiceResponse = inData as ServiceResponse;
			//localDB service callback
			if (response)
			{
				if (response.request.type == RequestType.LOCAL_DATA_GET_ORDERS && response.data)
				{
					var orderList:Object = response.data;
					
					for (var i:String in orderList)
					{
						var targetOrder:Object = orderList[i];
						if (targetOrder)
						{
							amf.directCall(AMFShopManagementServicesType.CREATE_SALES, targetOrder, this);
						}
					}
				}
				
			}
			//assume amf remote service callback
			else
			{
				var result:ResultVO = (!(inData is ResultVO)) ? AMFResultFactory.convert(inData) : inData as ResultVO;
				
				if (result)
				{
					if (result.service == AMFShopManagementServicesType.CREATE_SALES)
					{
						setRemoteData(result.service, result);
					}
				}
			}
		}
		
		public function fault(info:Object):void 
		{
			echo('fault : ' + info);
			//do nothing for fail calling createSales? as it will be retried later
		}
		
		/* INTERFACE org.puremvc.as3.multicore.interfaces.IRemoteDataProxy */
		
		public function getRemoteData(inService:String, inData:Object = null):Boolean 
		{
			return false;
		}
		
		public function setRemoteData(inService:String, inData:Object):Boolean 
		{
			if (inService == AMFShopManagementServicesType.CREATE_SALES)
			{
				var resultVO:ResultVO = inData as ResultVO;
				var invoiceNo:String = resultVO.result['o_invoice_no'];
				
				if ( resultVO.code != AMFServicesErrorID.NONE /*&& resultVO.result !== true*/ )
				{
					//if fail saving sales on server and local, popup
					//else retry later
					if (!request(new LocalDataServiceRequest(invoiceNo, RequestType.LOCAL_DATA_GET_ORDER_BY_NO)))
					//if (!_localDataService.request(new LocalDataServiceRequest(invoiceNo, RequestType.LOCAL_DATA_GET_ORDER_BY_NO)))
					{
						//TODO : if fail saving data in local and server
						echo('setRemoteData : fail getting data from server : ' + inService);
						//sendNotificationToMediator(MediatorID.SHOP_MGT_SALES, NotificationType.CREATE_SALES_FAIL, _currVO);
						return false;
					}
				}
				else
				{
					request(new LocalDataServiceRequest(invoiceNo, RequestType.LOCAL_DATA_REMOVE_ORDER))
				}
				
				
				
			}
			
			return true;
		}
	}
}