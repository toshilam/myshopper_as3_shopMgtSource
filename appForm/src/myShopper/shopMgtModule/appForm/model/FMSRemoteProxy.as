package myShopper.shopMgtModule.appForm.model 
{
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.AlerterVO;
	import myShopper.common.data.FMS.FMSRequestVO;
	import myShopper.common.data.service.CommVOService;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.FMSServicesType;
	import myShopper.common.emun.MessageID;
	import myShopper.common.emun.ServiceID;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.ChatEvent;
	import myShopper.common.events.ServiceEvent;
	import myShopper.common.interfaces.IResponder;
	import myShopper.common.net.FMSServiceConnection;
	import myShopper.common.net.RemoteService;
	import myShopper.common.net.ServiceRequest;
	import myShopper.common.net.WSServiceConnection;
	import myShopper.common.server.AMFResultFactory;
	import myShopper.common.utils.Alert;
	import myShopper.common.utils.Tracer;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	public class FMSRemoteProxy extends ApplicationProxy implements IResponder 
	{
		private const FMS_METHOD_NAME:String = 'request'; 
		
		private var _service:RemoteService;
		private var _myUserInfo:UserInfoVO;
		
		public function FMSRemoteProxy(inName:String, inData:Object = null) 
		{
			super(inName, inData);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			
			_myUserInfo = voManager.getAsset(VOID.MY_USER_INFO);
			//_service = serviceManager.getAsset(ServiceID.FMS_SHOP);
			_service = serviceManager.getAsset(ServiceID.WS_SHOP);
			
			if (!_myUserInfo || !(_myUserInfo is UserInfoVO))
			{
				throw(new UninitializedError("unable to get VO/service"));
			}
			
			WSServiceConnection(_service.serviceConnection).addEventListener(ServiceEvent.RESPONSE, fmsEventHandler);
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			echo('initAsset');
		}
		
		private function fmsEventHandler(e:ServiceEvent):void 
		{
			if (e.type == ServiceEvent.RESPONSE)
			{
				if (e.result is ResultVO)
				{
					var result:ResultVO = e.result;
					
					if (result)
					{
						switch(result.service)
						{
							case FMSServicesType.RECEIVE_SHOP_CHAT_MESSAGE:
							{
								sendNotification(ChatEvent.RECEIVE_SHOP_MESSAGE, result);
								//NOTE : for chat proxy, its name is combined with customer FMS ID
								//CHANGED on : 02/01/2012 : check by command as target proxy may not be created
								/*var targetProxy:IRemoteDataProxy = getDataProxy(getProxyIDByServiceType(result.service) + CommVOService.getFromIDByFMSDataObj(result.result));
								if ( targetProxy )
								{
									targetProxy.setRemoteData(result.service, result);
								}
								else
								{
									echo('unable to retrieve target proxy for : ' + result.service);
								}*/
								break;
							}
							case FMSServicesType.USER_WALK_OUT_SHOP:
							{
								sendNotification(ChatEvent.END_SHOP_CHAT, result);
							}
						}
					}
					else
					{
						echo('fmsEventHandler : fail convert object data object result vo');
					}
				}
				else
				{
					echo('fmsEventHandler : unknown data type!');
				}
			}
		}
		
		private function getProxyIDByServiceType(inService:String):String 
		{
			if 		(inService == FMSServicesType.RECEIVE_SHOP_CHAT_MESSAGE) 	return ProxyID.SHOP_MGT_CUSTOMER_CHAT; 
			return 	null;
		}
		
		public function call(inServiceName:String, inData:Object = null):void
		{
			echo('calling : ' + inServiceName, this, 0xFF0000);
			
			var fmsRequestVO:FMSRequestVO;;
			
			if (!_myUserInfo.isLogged)
			{
				echo('calling : ' + inServiceName + ' : Error! user is not logged yet!');
				return;
			}
			
			switch(inServiceName)
			{
				case FMSServicesType.SEND_SHOP_CHAT_MESSAGE:
				{
					fmsRequestVO = new FMSRequestVO(inServiceName, null, inData );
					break;
				}
				default:
				{
					echo('unknown service type : ' + inServiceName);
					return;
				}
				
			}
			
			echo(inData);
			
			remoteCall(FMS_METHOD_NAME, fmsRequestVO);
		}
		
		private function remoteCall(inService:String, inData:Object):void 
		{
			_service.request(new ServiceRequest(inService, inData, this));
		}
		
		
		//NOTE : no call back from service for FMS currently
		public function result(data:Object):void 
		{
			
		}
		
		public function fault(info:Object):void 
		{
		
		}
		
		private function getDataProxy(inName:String):IRemoteDataProxy
		{
			return facade.retrieveProxy(inName) as IRemoteDataProxy
		}
	}
}