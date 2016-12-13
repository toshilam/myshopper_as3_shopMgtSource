package myShopper.shopMgtModule.appShopMgt.model 
{
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.AlerterVO;
	import myShopper.common.data.FMS.FMSRequestVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.FMSServicesType;
	import myShopper.common.emun.MessageID;
	import myShopper.common.emun.ServiceID;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.ServiceEvent;
	import myShopper.common.interfaces.IResponder;
	import myShopper.common.net.FMSServiceConnection;
	import myShopper.common.net.RemoteService;
	import myShopper.common.net.ServiceRequest;
	import myShopper.common.net.WSServiceConnection;
	import myShopper.common.server.AMFResultFactory;
	import myShopper.common.utils.Alert;
	import myShopper.common.utils.Tracer;
	import myShopper.shopMgtModule.appShopMgt.enum.ProxyID;
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
			
			if (!_myUserInfo || !(_myUserInfo is UserInfoVO))
			{
				throw(new UninitializedError("unable to get asset mapInfo/myUser VO or user info list"));
			}
			
			//_service = serviceManager.getAsset(ServiceID.FMS_SHOP);
			_service = serviceManager.getAsset(ServiceID.WS_SHOP);
			if (!_service || !(_service is RemoteService))
			{
				echo('onRegister : unable to get remote service from serviceManager');
				return;
			}
			
			//FMSServiceConnection(_service.serviceConnection).addEventListener(ServiceEvent.RESPONSE, fmsEventHandler);
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
							case FMSServicesType.USER_WALK_IN_SHOP:
							case FMSServicesType.USER_WALK_OUT_SHOP:
							{
								if ( getMapDataProxy(getProxyIDByServiceType(result.service)).setRemoteData(result.service, result) )
								{
									//sendNotification(e.type, result);
								}
								
								break;
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
			if 		(inService == FMSServicesType.USER_WALK_IN_SHOP) 		return ProxyID.USER;
			if 		(inService == FMSServicesType.USER_WALK_OUT_SHOP) 		return ProxyID.USER;
			return 	null;
		}
		
		public function call(inServiceName:String, inData:Object = null):void
		{
			echo('calling : ' + inServiceName, this, 0xFF0000);
			
			/*var data:Object = inData;
			
			if (!_myUserInfo.isLogged)
			{
				echo('calling : ' + inServiceName + ' : Error! user is not logged yet!');
				return;
			}
			
			switch(inServiceName)
			{
				case FMSServicesType.USER_UPDATE_LAT_LNG:
				{
					var latlng:LatLng = data as LatLng;
					
					if (latlng)
					{
						//update logged user latlng
						inData = new FMSRequestVO(inServiceName, null, { u_id:_myUserInfo.uid, u_lat:latlng.lat(), u_lng:latlng.lng() } );
					}
					else
					{
						echo("USER_UPDATE_LAT_LNG : missing data", this, 0xff0000);
						return;
					}
					break;
				}
				
			}
			
			echo(inData);
			
			remoteCall(FMS_METHOD_NAME, inData);*/
		}
		
		private function remoteCall(inService:String, inData:Object):void 
		{
			//_service.request(new ServiceRequest(inService, inData, this));
		}
		
		
		//NOTE : no call back from service for FMS currently
		public function result(data:Object):void 
		{
			
		}
		
		public function fault(info:Object):void 
		{
		
		}
		
		
		
		private function getMapDataProxy(inName:String):IRemoteDataProxy
		{
			return facade.retrieveProxy(inName) as IRemoteDataProxy
		}
	}
}