package myShopper.shopMgtModule.appForm.model
{
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.shop.ShopOrderVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.AMFServicesErrorID;
	import myShopper.common.emun.VOID;
	import myShopper.common.interfaces.ICommServiceRequest;
	import myShopper.shopMgtCommon.data.SalesCheckVO;
	import myShopper.shopMgtCommon.data.service.ShopVOService;
	import myShopper.shopMgtCommon.emun.AMFShopManagementServicesType;
	import myShopper.shopMgtCommon.emun.AssetID;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.ShopMgtShopInfoVO;
	import myShopper.shopMgtModule.appForm.enum.MediatorID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationRemoteProxy;
	
	public class ShopClosedOrderInfoProxy extends ApplicationRemoteProxy //ApplicationProxy implements IRemoteDataProxy
	{
		/*private var _amf:AMFRemoteProxy;
		private function get amf():AMFRemoteProxy
		{
			if (!_amf) _amf = facade.retrieveProxy(ProxyID.AMF) as AMFRemoteProxy;
			return _amf;
		}*/
		
		public function ShopClosedOrderInfoProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		//private var _voService:UserVOService;
		private var _shopInfoVO:ShopMgtShopInfoVO;
		private var _targetNode:XML;
		private var _shopVOService:ShopVOService;
		private var _salesCheckVO:SalesCheckVO;
		
		override public function onRegister():void
		{
			super.onRegister();
			
			_shopInfoVO = voManager.getAsset(VOID.MY_SHOP_INFO);
			var xml:XML = xmlManager.getAsset(AssetLibID.XML_SHOP_MGT);
			
			if (!_shopInfoVO || !xml)
			{
				echo('onRegister : unable to get shop info vo/xml');
				throw(new UninitializedError('onRegister : unable to get shop info vo/xml'));
			}
			
			_shopVOService = new ShopVOService(_shopInfoVO);
			_salesCheckVO = new SalesCheckVO('','','',0,0, '');
			
			var windowNode:XML = xml..windowElements[0];
			_targetNode = windowNode.*.(@id == AssetID.BTN_Q_CLOSED_ORDER)[0];
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			
			_shopInfoVO = null;
			//_comm = null;
			//_amf = null;
			_targetNode = null;
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			if (inAsset is ICommServiceRequest)
			{
				//var classID:String = getAssetIDByCommType(ICommServiceRequest(inAsset).communicationType);
				var classID:String = _targetNode.@Class.toString();
				if (classID)
				{
					
					if (_shopInfoVO)
					{
						sendNotificationToMediator
						(
							MediatorID.SHOP_MGT_CLOSED_ORDER,
							NotificationType.ADD_DISPLAY_ORDER, 
							new DisplayObjectVO(classID, assetManager.getData(classID, AssetLibID.AST_COMMON), _targetNode, _salesCheckVO) 
						);
						
						//getRemoteData(AMFShopManagementServicesType.GET_ORDER);
					}
					else
					{
						echo('initAsset : unable to get user login vo');
					}
					
				}
				else
				{
					echo('initAsset : unknow page id : ' + ICommServiceRequest(inAsset).communicationType);
				}
			}
		}
		
		/*private function getAssetIDByCommType(inID:String):String
		{
			switch(inID)
			{
				case CommunicationType.SHOP_MGT_NEWS: return AssetClassID.FORM_SHOP_ABOUT;
			}
			
			return null;
		}*/
		
		
		/* INTERFACE org.puremvc.as3.multicore.interfaces.IRemoteDataProxy */
		
		override public function getRemoteData(inService:String, inData:Object = null):Boolean
		{
			var requestData:Object;
			var userInfo:UserInfoVO = voManager.getAsset(VOID.MY_USER_INFO);
			
			if (userInfo && userInfo.isLogged && _shopInfoVO)
			{
				if (inService == AMFShopManagementServicesType.GET_ORDER)
				{
					if (inData !== _salesCheckVO) return false;
					
					//requestData = { o_shop_id:userInfo.uid, o_is_complete:true  }
					requestData = 	{ 
										o_shop_id:userInfo.uid,
										o_from_date:_salesCheckVO.searchVO.fromDate + " 00:00:00",
										o_to_date:_salesCheckVO.searchVO.toDate + " 23:59:59",
										o_shipping_method:_salesCheckVO.shippingMethod,
										o_is_complete:true
										//count:playCheckVO.count,
										//count:PlayCheckVO.DEFAULT_RECORD_COUNT,
										//index:_salesCheckVO.index
									}
				}
				else if (inService == AMFShopManagementServicesType.DELETE_SALES)
				{
					var orderVO:ShopOrderVO = inData as ShopOrderVO;
					
					if (!orderVO)
					{
						return false;
					}
					
					//TODO : product inventory
					requestData = 	{ 
										o_shop_id:userInfo.uid,
										o_no:orderVO.orderNo
									}
				}
				else
				{
					echo('getRemoteData : : unknown service type ' + inService, this, 0xff0000);
					return false;
				}
			}
			else
			{
				echo('getRemoteData : unable to get user/shop vo');
				return false;
			}
			
			//amf.call(inService, requestData);
			call(inService, requestData);
			return true;
		}
		
		override public function setRemoteData(inService:String, inData:Object):Boolean
		{
			var resultVO:ResultVO = inData as ResultVO;
			
			if (resultVO)
			{
				if (inService == AMFShopManagementServicesType.GET_ORDER)
				{
					if ( resultVO.code != AMFServicesErrorID.NONE )
					{
						echo('setRemoteData : fail getting data from server');
						return false;
					}
					
					if ( !_shopVOService.setShopOrder(resultVO.result, true) )
					{
						echo('setRemoteData : fail setting data into vo');
					}
					else
					{
						sendNotificationToMediator(MediatorID.SHOP_MGT_CLOSED_ORDER, NotificationType.REFRESH_DISPLAY_ORDER);
					}
				}
				else if (inService == AMFShopManagementServicesType.DELETE_SALES)
				{
					if ( resultVO.code != AMFServicesErrorID.NONE )
					{
						sendNotificationToMediator(MediatorID.SHOP_MGT_CLOSED_ORDER, NotificationType.DELETE_SALES_FAIL);
						return false;
					}
					
					//TODO : SERVER SIDE
					sendNotificationToMediator
					(
						MediatorID.SHOP_MGT_CLOSED_ORDER,
						_shopVOService.setDeleteSales(resultVO.result) ? NotificationType.DELETE_SALES_SUCCESS : NotificationType.DELETE_SALES_FAIL,
						resultVO.result
					);
				}
				
				return true;
			}
			
			
			return false;
		}
		
	}
}