package myShopper.shopMgtModule.appRCShopMgt.model 
{
	import com.greygreen.net.p2p.events.P2PEvent;
	import com.greygreen.net.p2p.model.P2PPacket;
	import flash.events.TimerEvent;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.FMS.FMSRequestVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.RTMFPServicesType;
	import myShopper.common.emun.ServiceID;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.ServiceEvent;
	import myShopper.common.interfaces.IResponder;
	import myShopper.common.net.RemoteService;
	import myShopper.common.net.RTMFPServiceConnection;
	import myShopper.common.net.ServiceRequest;
	import myShopper.common.server.AMFResultFactory;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtModule.appRCShopMgt.enum.AssetClassID;
	import myShopper.shopMgtModule.appRCShopMgt.enum.NotificationType;
	import myShopper.shopMgtModule.appRCShopMgt.enum.PageID;
	import myShopper.shopMgtModule.appRCShopMgt.enum.ProxyID;
	import myShopper.shopMgtModule.appRCShopMgt.model.vo.PageVO;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	
	
	public class LoginScanPageProxy extends ApplicationProxy implements IResponder 
	{
		private var _autoRefreshInterval:int = 1000 * 120;
		
		private var _service:RemoteService;
		private var _rtmfp:RTMFPServiceConnection;
		private var _myUserInfo:UserInfoVO;
		private var _loginTimer:Timer;
		
		public function LoginScanPageProxy(inName:String, inData:Object = null) 
		{
			super(inName, inData);
		}
		
		private function get asset():AssetProxy
		{
			return facade.retrieveProxy(ProxyID.ASSET) as AssetProxy
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
			_service = serviceManager.getAsset(ServiceID.RTMFP);
			if (!_service || !(_service is RemoteService))
			{
				echo('onRegister : unable to get remote service from serviceManager');
				return;
			}
			
			_rtmfp = _service.serviceConnection as RTMFPServiceConnection;
			_rtmfp.addEventListener(ServiceEvent.CONNECT_SUCCESS, rtmfpEventHandler);
			_rtmfp.addEventListener(ServiceEvent.CONNECT_FAIL, rtmfpEventHandler);
			_rtmfp.addEventListener(ServiceEvent.DISCONNECTED, rtmfpEventHandler);
			_rtmfp.addEventListener(ServiceEvent.RESPONSE, rtmfpEventHandler);
			
			//NOTE : should wait for peer connect event before send request (rtmfp connect add reqest to subscribe list if no peer connected)
			//_rtmfp.rtmfpConnection.addEventListener(P2PEvent.PEER_CONNECTED, p2pEventHandler);
			
			_loginTimer = new Timer(1000 * 8, 1);
			_loginTimer.addEventListener(TimerEvent.TIMER_COMPLETE, loginTimerEventHandler);
		}
		
		
		
		private function p2pEventHandler(e:P2PEvent):void 
		{
			
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			echo('initAsset : ' + inAsset);
			
			_myUserInfo.token = String(inAsset);
			_rtmfp.connect( _myUserInfo.token );
		}
		
		public function tearDownAsset():void
		{
			_myUserInfo.clear();
			_rtmfp.disconnect();
		}
		
		private function rtmfpEventHandler(e:ServiceEvent):void 
		{
			echo(e.data);
			var event:P2PEvent = e.data as P2PEvent;
			
			if (e.type == ServiceEvent.CONNECT_SUCCESS)
			{
				setTimeout(connect, 1000, e.data);
				_rtmfp.autoRefreshConnection(_autoRefreshInterval);
			}
			else if (e.type == ServiceEvent.CONNECT_FAIL)
			{
				tearDownAsset();
				sendNotification(NotificationType.LOGIN_FAIL);
				asset.changePage(PageID.LOGIN, true);
				
			}
			else if (e.type == ServiceEvent.DISCONNECTED)
			{
				
			}
			else if (e.type == ServiceEvent.RESPONSE)
			{
				var packet:P2PPacket = e.data as P2PPacket;
				
				if (!packet)
				{
					echo('rtmfpEventHandler : ' + e.type + ' : unknown data!' );
					return;
				}
				
				var resultVO:ResultVO = AMFResultFactory.convert(packet.data);
				
				if (!resultVO)
				{
					echo('rtmfpEventHandler : ' + e.type + ' : unknown data : ' + packet.data );
					return;
				}
				
				switch(resultVO.service)
				{
					case RTMFPServicesType.RC_LOGIN:
					{
						if (resultVO.result === true)
						{
							_loginTimer.reset();
							_loginTimer.stop();
							
							_myUserInfo.isLogged = true;
							sendNotification(NotificationType.LOGIN_SUCCESS);
							asset.changePage(PageID.MAIN_MENU);
						}
						
						break;
					}
				}
			}
		}
		
		private function connect(data:Object):void 
		{
			//_rtmfp.request(new FMSRequestVO(RTMFPServicesType.RC_LOGIN, '', _myUserInfo.token));
			call(RTMFPServicesType.RC_LOGIN);
		}
		
		/*private function getProxyIDByServiceType(inService:String):String 
		{
			if 		(inService == FMSServicesType.USER_WALK_IN_SHOP) 		return ProxyID.USER;
			if 		(inService == FMSServicesType.USER_WALK_OUT_SHOP) 		return ProxyID.USER;
			return 	null;
		}*/
		
		public function call(inServiceName:String, inData:Object = null):void
		{
			echo('calling : ' + inServiceName, this, 0xFF0000);
			
			var data:Object = inData;
			
			/*if (!_myUserInfo.isLogged)
			{
				echo('calling : ' + inServiceName + ' : Error! user is not logged yet!');
				return;
			}*/
			
			switch(inServiceName)
			{
				case RTMFPServicesType.RC_LOGIN:
				{
					//_rtmfp.rtmfpConnection.send( { u_token:_myUserInfo.token }, RTMFPServiceConnection.METHOD_NAME);
					inData = new FMSRequestVO(inServiceName, null, { u_token:_myUserInfo.token } );
					
					//start counting, assume login fail if no response in period of time 
					_loginTimer.start();
					break;
				}
				
			}
			
			remoteCall('', inData);
		}
		
		private function remoteCall(inService:String, inData:Object):void 
		{
			_service.request(new ServiceRequest(inService, inData, this));
		}
		
		private function loginTimerEventHandler(e:TimerEvent):void 
		{
			rtmfpEventHandler(new ServiceEvent(ServiceEvent.CONNECT_FAIL));
		}
		
		//NOTE : no call back from service for FMS currently
		public function result(data:Object):void 
		{
			
		}
		
		public function fault(info:Object):void 
		{
		
		}
		
		
		
		/*private function getMapDataProxy(inName:String):IRemoteDataProxy
		{
			return facade.retrieveProxy(inName) as IRemoteDataProxy
		}*/
	}
}