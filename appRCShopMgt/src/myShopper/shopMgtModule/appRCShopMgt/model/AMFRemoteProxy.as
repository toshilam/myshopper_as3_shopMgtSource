package myShopper.shopMgtModule.appRCShopMgt.model 
{
	import flash.net.Responder;
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.AlerterVO;
	import myShopper.common.emun.AMFCommServicesType;
	import myShopper.common.emun.AMFServicesErrorID;
	import myShopper.common.emun.AMFShopServicesType;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.MessageID;
	import myShopper.common.emun.ServiceID;
	import myShopper.common.interfaces.IResponder;
	import myShopper.common.net.RemoteService;
	import myShopper.common.net.ServiceRequest;
	import myShopper.common.server.AMFResultFactory;
	import myShopper.common.utils.Alert;
	import myShopper.common.utils.Tracer;
	import myShopper.shopMgtCommon.emun.AMFShopManagementServicesType;
	import myShopper.shopMgtModule.appRCShopMgt.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	public class AMFRemoteProxy extends ApplicationProxy implements IResponder 
	{
		//public static const NAME:String = "AMFRemoteProxy";
		
		private var _service:RemoteService;
		private var _responder:Responder;
		
		public function AMFRemoteProxy(inName:String, inData:Object = null) 
		{
			super(inName, inData);
		}
		
		override public function onRegister():void 
		{
			_service = serviceManager.getAsset(ServiceID.AMF);
			_responder = new Responder(result, fault);
			
			if (!_service)
			{
				echo('onRegister : unable to get AMF connection', this, 0xff0000);
			}
		}
		
		
		override public function initAsset(inAsset:Object = null):void 
		{
			('initAsset', this, 0xff0000);
		}
		
		
		public function call(inService:String, inData:Object = null):Boolean
		{
			echo('calling : ' + inService, this, 0xFF0000);
			
			
			remoteCall(inService, inData);
			return true;
		}
		
		private function remoteCall(inService:String, inData:Object):void 
		{
			_service.request(new ServiceRequest(inService, inData, this));
		}
		
		public function result(inData:Object):void 
		{
			echo('result : ' + inData, this, 0x000000);
			
			if (inData)
			{
				var result:ResultVO = (!(inData is ResultVO)) ? AMFResultFactory.convert(inData) : inData as ResultVO;
				
				if (result)
				{
					echo('result : handling : ' + result.service, this, 0x000000);
					resultHandler(result);
				}
				else
				{
					echo('result : unknown data type : ' + inData, this, 0xFF0000);
				}
			}
			
		}
		
		public function fault(info:Object):void 
		{
			echo('fault : ' + info, this, 0xFF0000);
		}
		
		private function resultHandler(result:ResultVO):void 
		{
			//to be handled by each proxy
			/*if (result.code != AMFServicesErrorID.NONE)
			{
				//TO DO : define a function for every module call when there is an error.
				var arrService:Array = result.service.split('.');
				Alert.show( new AlerterVO('', '', '', null, getMessage(MessageID.ERROR_TITLE), getMessage(MessageID.ERROR_GET_DATA) + '\n' + result.code + '\n' + arrService[arrService.length - 1]) );
				echo('resultHandler : error getting data from server : ' + result.code, this, 0xff0000);
				return;
			}*/
			
			//var arrResult:Array;
			//var i:int;
			
			switch(result.service)
			{
				//shop info
				case AMFShopServicesType.DOWNLOAD_IMAGE:
				case AMFShopManagementServicesType.GET_INFO_BY_USER_ID:
				//case AMFShopManagementServicesType.GET_CUSTOMERS_INFO_BY_ID:
				case AMFShopManagementServicesType.GET_ORDER:
				case AMFShopManagementServicesType.UPDATE_STATUS:
				case AMFCommServicesType.GET_NUM_UNREAD_USER_SHOP_MESSAGE:
				//case AMFShopManagementServicesType.GET_ORDER_SINCE:
				{	
					getRemoteDataProxy(getProxyIDByServiceType(result.service)).setRemoteData(result.service, result);
					
					break;
				}
				
				
				default:
				{
					echo('result : no matched action found : ' + result.service);
				}
			}
		}
		
		private function getProxyIDByServiceType(inService:String):String 
		{
			if 		(inService == AMFShopManagementServicesType.GET_INFO_BY_USER_ID) 		return ProxyID.SHOP_DATA;
			//else if	(inService == AMFShopManagementServicesType.GET_CUSTOMERS_INFO_BY_ID) 	return ProxyID.USER;
			else if	(inService == AMFShopManagementServicesType.GET_ORDER) 					return ProxyID.SHOP_DATA;
			else if	(inService == AMFShopManagementServicesType.UPDATE_STATUS) 				return ProxyID.SHOP_DATA;
			else if	(inService == AMFCommServicesType.GET_NUM_UNREAD_USER_SHOP_MESSAGE) 	return ProxyID.SHOP_DATA;
			//else if	(inService == AMFShopManagementServicesType.GET_ORDER_SINCE) 			return ProxyID.SHOP_DATA;
			else if	(inService == AMFShopServicesType.DOWNLOAD_IMAGE) 						return ProxyID.FILE_INFO;
			return 	null;
		}
		
		private function getRemoteDataProxy(inName:String):IRemoteDataProxy
		{
			return facade.retrieveProxy(inName) as IRemoteDataProxy
		}
		
	}
}