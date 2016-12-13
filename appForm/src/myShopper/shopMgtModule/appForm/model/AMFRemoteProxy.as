package myShopper.shopMgtModule.appForm.model 
{
	import flash.net.Responder;
	import flash.utils.Dictionary;
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.AlerterVO;
	import myShopper.common.emun.AMFCommServicesType;
	import myShopper.common.emun.AMFPayPalServicesType;
	import myShopper.common.emun.AMFServicesErrorID;
	import myShopper.common.emun.AMFShopperServicesType;
	import myShopper.common.emun.AMFShopServicesType;
	import myShopper.common.emun.AMFUserManagementServicesType;
	import myShopper.common.emun.AMFUserServicesType;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.MessageID;
	import myShopper.common.emun.RequestType;
	import myShopper.common.emun.ServiceID;
	import myShopper.common.interfaces.IResponder;
	import myShopper.common.net.LocalDataService;
	import myShopper.common.net.LocalDataServiceRequest;
	import myShopper.common.net.RemoteService;
	import myShopper.common.net.ServiceConnection;
	import myShopper.common.net.ServiceRequest;
	import myShopper.common.server.AMFResultFactory;
	import myShopper.common.utils.Alert;
	import myShopper.common.utils.Tracer;
	import myShopper.shopMgtCommon.emun.AMFShopManagementServicesType;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	public class AMFRemoteProxy extends ApplicationProxy implements IResponder 
	{
		//public static const NAME:String = "AMFRemoteProxy";
		
		
		private var _service:RemoteService;
		private var _responder:Responder;
		private var _arrReqObj:Dictionary;
		
		public function AMFRemoteProxy(inName:String, inData:Object = null) 
		{
			super(inName, inData);
		}
		
		override public function onRegister():void 
		{
			_service = serviceManager.getAsset(ServiceID.AMF);
			
			_responder = new Responder(result, fault);
			_arrReqObj = new Dictionary();
			
			if (!_service)
			{
				throw(new UninitializedError(multitonKey + ' : onRegister : unable to get AMF connection'));
			}
		}
		
		
		override public function initAsset(inAsset:Object = null):void 
		{
			echo('initAsset', this, 0xff0000);
		}
		
		
		public function call(inService:String, inData:Object = null, inReqObj:IRemoteDataProxy = null):Boolean
		{
			echo('calling : ' + inService, this, 0xFF0000);
			
			remoteCall(inService, inData, inReqObj);
			return true;
		}
		
		/**
		 * directly callback to the request object
		 * things to be handled by the request object itself
		 * @param	inService - type of request
		 * @param	inData - request data
		 * @param	inReqObj - the object to be handled callback
		 * @return
		 */
		public function directCall(inService:String, inData:Object, inReqObj:IResponder):Boolean
		{
			return _service.request(new ServiceRequest(inService, inData, inReqObj, true));
		}
		
		private function remoteCall(inService:String, inData:Object, inReqObj:IRemoteDataProxy = null):void 
		{
			
			var req:ServiceRequest = new ServiceRequest(inService, inData, this);
			_service.request(req);
			
			//added on 06112013
			//an unique id will be added in inData object when .request() is called
			//if inReqObj is set, a callback will be force on that request object
			if (inReqObj)
			{
				_arrReqObj[req.data[ServiceConnection.UNIQUE_ID_PN]] = inReqObj;
			}
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
					
					var uniqueID:String = result.uniqueID;
					var targetRemoteProxy:IRemoteDataProxy = _arrReqObj[uniqueID];
					
					if (targetRemoteProxy)
					{
						delete _arrReqObj[uniqueID];
						try
						{
							//an error may throw, if user remove the proxy/mediator before call back
							targetRemoteProxy.setRemoteData(result.service, result);
						}
						catch (e:Error)
						{
							echo('result : fail calling setRemoteData : target proxy may have removed : ' + result.service);
						}
						
					}
					else
					{
						resultHandler(result);
					}
					
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
				case AMFPayPalServicesType.GET_ACC_VERIFY_STATUS:
				case AMFShopManagementServicesType.USER_LOGIN:
				case AMFShopManagementServicesType.USER_AUTO_LOGIN:
				case AMFShopServicesType.DOWNLOAD_IMAGE:
				case AMFShopServicesType.GET_AREA:
				case AMFUserManagementServicesType.UPDATE_PASSWORD: //user serivce
				case AMFShopManagementServicesType.UPDATE_LOGO:
				case AMFShopManagementServicesType.UPDATE_BG:
				case AMFShopManagementServicesType.UPDATE_CURRENCY:
				case AMFShopManagementServicesType.CREATE_INFO:
				case AMFShopManagementServicesType.UPDATE_INFO:
				case AMFShopManagementServicesType.DELETE_INFO:
				case AMFShopManagementServicesType.GET_ABOUT:
				case AMFShopManagementServicesType.GET_NEWS:
				case AMFShopManagementServicesType.GET_CUSTOM:
				
				//only for completed order, for incomplete order will be dl be shopMgt
				case AMFShopManagementServicesType.GET_ORDER: 
				
				case AMFShopManagementServicesType.UPDATE_ABOUT:
				case AMFShopManagementServicesType.GET_CATEGORY_PRODUCT:
				case AMFShopManagementServicesType.CREATE_NEWS:
				case AMFShopManagementServicesType.UPDATE_NEWS:
				case AMFShopManagementServicesType.DELETE_NEWS:
				case AMFShopManagementServicesType.CREATE_CUSTOM:
				case AMFShopManagementServicesType.UPDATE_CUSTOM:
				case AMFShopManagementServicesType.DELETE_CUSTOM:
				case AMFShopManagementServicesType.GET_CUSTOM_BY_NO:
				case AMFShopManagementServicesType.CREATE_CATEGORY:
				case AMFShopManagementServicesType.UPDATE_CATEGORY:
				case AMFShopManagementServicesType.DELETE_CATEGORY:
				case AMFShopManagementServicesType.GET_PRODUCT_BY_NO:
				case AMFShopManagementServicesType.GET_PRODUCT_STOCK:
				case AMFShopManagementServicesType.CREATE_PRODUCT:
				case AMFShopManagementServicesType.CREATE_PRODUCT_FBID:
				case AMFShopManagementServicesType.UPDATE_PRODUCT:
				case AMFShopManagementServicesType.DELETE_PRODUCT:
				case AMFShopManagementServicesType.GET_ORDER_PRODUCT:
				case AMFShopManagementServicesType.GET_ORDER_EXTRA:
				case AMFShopManagementServicesType.SEND_ORDER_INVOICE:
				case AMFShopManagementServicesType.UPDATE_ORDER_SHIPMENT:
				case AMFShopManagementServicesType.IS_SHOP_INFO_APPROVED:
				case AMFShopManagementServicesType.GET_CUSTOMER_INFO_BY_UID:
				case AMFShopManagementServicesType.GET_ACC_VERIFY_STATUS:
				case AMFShopManagementServicesType.GET_ACC_VERIFIED:
				case AMFShopManagementServicesType.DELETE_SALES:
					
				case AMFCommServicesType.READ_USER_SHOP_MESSAGE:
				case AMFCommServicesType.SEND_USER_SHOP_MESSAGE:
				case AMFCommServicesType.GET_USER_SHOP_MESSAGE_USER_LIST:
				case AMFCommServicesType.GET_USER_SHOP_MESSAGE_BY_UID:
					
				case AMFUserServicesType.USER_FORGOT_PASSWORD:
					
				case AMFShopperServicesType.CONTACT_US_SHOP:
				case AMFShopperServicesType.GET_STATE_BY_COUNTRY_ID:
				case AMFShopperServicesType.GET_CITY_BY_STATE_ID:
				case AMFShopperServicesType.GET_CITY_AREA:
				{
					//proxy can be null, as user may had closed the window before data downloaded
					var proxy:IRemoteDataProxy = getRemoteDataProxy(getProxyIDByServiceType(result.service));
					if (proxy)
					{
						proxy.setRemoteData(result.service, result);
					}
					else
					{
						echo('result : target proxy not found : ' + result.service);
					}
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
			if 		(inService == AMFShopManagementServicesType.USER_LOGIN) 			return ProxyID.USER_LOGIN;
			if 		(inService == AMFShopManagementServicesType.USER_AUTO_LOGIN) 		return ProxyID.ASSET;
			else if (inService == AMFShopServicesType.DOWNLOAD_IMAGE) 					return ProxyID.FILE_INFO;
			else if (inService == AMFShopServicesType.GET_AREA) 						return ProxyID.ASSET;
			else if	(inService == AMFShopManagementServicesType.UPDATE_INFO) 			return ProxyID.SHOP_MGT_PROFILE_UPDATE;
			else if	(inService == AMFShopManagementServicesType.CREATE_INFO) 			return ProxyID.SHOP_MGT_PROFILE_CREATE;
			else if	(inService == AMFShopManagementServicesType.DELETE_INFO) 			return ProxyID.SHOP_MGT_PROFILES;
			else if	(inService == AMFShopManagementServicesType.IS_SHOP_INFO_APPROVED) 	return ProxyID.SHOP_MGT_PROFILE_UPDATE;
			else if	(inService == AMFUserManagementServicesType.UPDATE_PASSWORD) 		return ProxyID.SHOP_MGT_PASSWORD_UPDATE;
			else if	(inService == AMFShopManagementServicesType.UPDATE_LOGO) 			return ProxyID.SHOP_MGT_LOGO_UPDATE;
			else if	(inService == AMFShopManagementServicesType.UPDATE_CURRENCY) 		return ProxyID.SHOP_MGT_CURRENCY_UPDATE;
			else if	(inService == AMFShopManagementServicesType.UPDATE_BG) 				return ProxyID.SHOP_MGT_BG_UPDATE;
			else if	(inService == AMFShopManagementServicesType.GET_ABOUT) 				return ProxyID.SHOP_MGT_ABOUT;
			else if	(inService == AMFShopManagementServicesType.GET_NEWS) 				return ProxyID.SHOP_MGT_NEWS;
			else if	(inService == AMFShopManagementServicesType.GET_CUSTOM) 			return ProxyID.SHOP_MGT_CUSTOM;
			else if	(inService == AMFShopManagementServicesType.GET_ORDER) 				return ProxyID.SHOP_MGT_CLOSED_ORDER; 
			else if	(inService == AMFShopManagementServicesType.UPDATE_ABOUT) 			return ProxyID.SHOP_MGT_ABOUT;
			else if	(inService == AMFShopManagementServicesType.GET_CATEGORY_PRODUCT) 	return ProxyID.SHOP_MGT_PRODUCT;
			else if	(inService == AMFShopManagementServicesType.CREATE_NEWS) 			return ProxyID.SHOP_MGT_NEWS_CREATE;
			else if	(inService == AMFShopManagementServicesType.UPDATE_NEWS) 			return ProxyID.SHOP_MGT_NEWS_UPDATE;
			else if	(inService == AMFShopManagementServicesType.DELETE_NEWS) 			return ProxyID.SHOP_MGT_NEWS_DELETE;
			else if	(inService == AMFShopManagementServicesType.CREATE_CUSTOM) 			return ProxyID.SHOP_MGT_CUSTOM_CREATE;
			else if	(inService == AMFShopManagementServicesType.GET_CUSTOM_BY_NO) 		return ProxyID.SHOP_MGT_CUSTOM_UPDATE; //only custom update call GET_CUSTOM_BY_NO
			else if	(inService == AMFShopManagementServicesType.UPDATE_CUSTOM) 			return ProxyID.SHOP_MGT_CUSTOM_UPDATE; 
			else if	(inService == AMFShopManagementServicesType.DELETE_CUSTOM) 			return ProxyID.SHOP_MGT_CUSTOM_DELETE;
			else if	(inService == AMFShopManagementServicesType.CREATE_CATEGORY) 		return ProxyID.SHOP_MGT_CATEGORY_CREATE;
			else if	(inService == AMFShopManagementServicesType.UPDATE_CATEGORY) 		return ProxyID.SHOP_MGT_CATEGORY_UPDATE;
			else if	(inService == AMFShopManagementServicesType.DELETE_CATEGORY) 		return ProxyID.SHOP_MGT_CATEGORY_DELETE;
			else if	(inService == AMFShopManagementServicesType.CREATE_PRODUCT_FBID) 	return ProxyID.FB_SHARE_PRODUCT;
			else if	(inService == AMFShopManagementServicesType.CREATE_PRODUCT) 		return ProxyID.SHOP_MGT_PRODUCT_CREATE;
			else if	(inService == AMFShopManagementServicesType.UPDATE_PRODUCT) 		return ProxyID.SHOP_MGT_PRODUCT_UPDATE;
			else if	(inService == AMFShopManagementServicesType.GET_PRODUCT_BY_NO) 		return ProxyID.SHOP_MGT_PRODUCT_UPDATE; //only product update call GET_PRODUCT_BY_NO
			else if	(inService == AMFShopManagementServicesType.GET_PRODUCT_STOCK) 		return ProxyID.SHOP_MGT_PRODUCT_UPDATE;
			else if	(inService == AMFShopManagementServicesType.DELETE_PRODUCT) 		return ProxyID.SHOP_MGT_PRODUCT_DELETE;
			else if	(inService == AMFShopManagementServicesType.GET_ORDER_PRODUCT) 		return ProxyID.SHOP_MGT_ORDER_DETAIL;
			else if	(inService == AMFShopManagementServicesType.GET_ORDER_EXTRA) 		return ProxyID.SHOP_MGT_ORDER_DETAIL;
			else if	(inService == AMFShopManagementServicesType.SEND_ORDER_INVOICE) 	return ProxyID.SHOP_MGT_ORDER_DETAIL;
			else if	(inService == AMFShopManagementServicesType.UPDATE_ORDER_SHIPMENT) 	return ProxyID.SHOP_MGT_ORDER_DETAIL;
			else if	(inService == AMFShopManagementServicesType.GET_CUSTOMER_INFO_BY_UID) 	return ProxyID.ASSET;
			else if	(inService == AMFShopManagementServicesType.GET_ACC_VERIFY_STATUS) 	return ProxyID.SHOP_MGT_ACC_VERIFY;
			else if	(inService == AMFShopManagementServicesType.GET_ACC_VERIFIED) 		return ProxyID.SHOP_MGT_ACC_VERIFY;
			else if	(inService == AMFShopManagementServicesType.DELETE_SALES) 			return ProxyID.SHOP_MGT_CLOSED_ORDER;
			
			else if	(inService == AMFCommServicesType.READ_USER_SHOP_MESSAGE)			return ProxyID.SHOP_MGT_USER_MESSAGE;
			else if	(inService == AMFCommServicesType.GET_USER_SHOP_MESSAGE_USER_LIST)	return ProxyID.SHOP_MGT_USER_MESSAGE;
			else if	(inService == AMFCommServicesType.GET_USER_SHOP_MESSAGE_BY_UID)		return ProxyID.SHOP_MGT_USER_MESSAGE;
			else if	(inService == AMFCommServicesType.SEND_USER_SHOP_MESSAGE)			return ProxyID.SHOP_MGT_USER_MESSAGE_CREATE;
			else if	(inService == AMFPayPalServicesType.GET_ACC_VERIFY_STATUS)			return ProxyID.SHOP_MGT_PAYPAL_ACC_VERIFY;
			else if	(inService == AMFShopperServicesType.CONTACT_US_SHOP)				return ProxyID.SHOPPER_CONTACT_US;
			else if	(inService == AMFShopperServicesType.GET_STATE_BY_COUNTRY_ID) 		return ProxyID.ASSET;
			else if	(inService == AMFShopperServicesType.GET_CITY_BY_STATE_ID) 			return ProxyID.ASSET;
			else if	(inService == AMFShopperServicesType.GET_CITY_AREA) 				return ProxyID.ASSET;
			else if	(inService == AMFUserServicesType.USER_FORGOT_PASSWORD)				return ProxyID.USER_FORGOT_PASSWORD;
			
			return 	null;
		}
		
		private function getRemoteDataProxy(inName:String):IRemoteDataProxy
		{
			return facade.retrieveProxy(inName) as IRemoteDataProxy
		}
		
	}
}