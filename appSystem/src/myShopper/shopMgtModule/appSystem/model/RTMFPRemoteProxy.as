package myShopper.shopMgtModule.appSystem.model 
{
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.ServiceID;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.ServiceEvent;
	import myShopper.common.interfaces.IResponder;
	import myShopper.common.net.RemoteService;
	import myShopper.common.net.RTMFPServiceConnection;
	import myShopper.shopMgtModule.appSystem.enum.ProxyID;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	
	public class RTMFPRemoteProxy extends ApplicationProxy implements IResponder 
	{
		//public static const NAME:String = "AMFRemoteProxy";
		
		private var _autoRefreshInterval:int = 1000 * 120; //disconnect and connect in every 2min
		//private var _heartbeatInterval:int = 4000; //send heartbeat to server in every 1sec
		//private var _connectNumRetried:int = 0; //number of time retried to connect server
		//private var _connectNumRetry:int = 15*5;//retry for 5min //number of time retry to connect server
		//private var _arrHeartbeat:Array; //contains requested heartbeat request to server
		//private var _heartbeatTimer:Timer;
		//private var _isRelogin:Boolean;
		
		private var _service:RemoteService;
		private var _xmlConfig:XML;
		private var _myUserVO:UserInfoVO;
		
		private var _comm:CommunicationProxy;
		private function get comm():CommunicationProxy
		{
			if (!_comm) _comm = facade.retrieveProxy(ProxyID.COMMUNICATION) as CommunicationProxy;
			return _comm;
		}
		
		public function RTMFPRemoteProxy(inName:String, inData:Object = null) 
		{
			super(inName, inData);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			_myUserVO = voManager.getAsset(VOID.MY_USER_INFO);
			if (!_myUserVO)
			{
				throw(new UninitializedError(multitonKey + ' : onRegister : unable to reetreve data!'));
			}
			
			_service = new RemoteService( new RTMFPServiceConnection() );
			if ( !serviceManager.addAsset(_service, ServiceID.RTMFP) )
			{
				throw('initAsset : unable to create service controller!', this, 0xff0000);
			}
			
			//_isRelogin = false;
			//_arrHeartbeat = new Array();
			//_heartbeatTimer = new Timer(_heartbeatInterval);
			//_heartbeatTimer.addEventListener(TimerEvent.TIMER, timerEventHandler);
			
			RTMFPServiceConnection(_service.serviceConnection).addEventListener(ServiceEvent.CONNECT_SUCCESS, connect);
			RTMFPServiceConnection(_service.serviceConnection).addEventListener(ServiceEvent.CONNECT_FAIL, fmsEventHandler);
			RTMFPServiceConnection(_service.serviceConnection).addEventListener(ServiceEvent.DISCONNECTED, fmsEventHandler);
		}
		
		
		//to be called by controller once xml common loaded
		override public function initAsset(inAsset:Object = null):void 
		{
			echo('initAsset');
			
			//_isRelogin = inAsset === true;
			//data = xmlManager.getAsset(AssetLibID.XML_COMMON);
			//
			//var xml:XML = data..services[0];
			//var _xmlConfig:XML = xml..element.(@id == ServiceID.WS)[0];
			//
			//if (!_xmlConfig || !_xmlConfig.@host.toString())
			//{
				//throw(new UninitializedError(multitonKey + ' : onRegister : unable to reetreve data!'));
			//}
			//
			//comm.request(CommunicationType.USER_DISCONNECTING);
			//
			//var host:String = _xmlConfig.@host.toString();
			
			if (!_myUserVO.isLogged)
			{
				echo('initAsset : user is not logged in yet!');
				return;
			}
			
			RTMFPServiceConnection(_service.serviceConnection).connect( _myUserVO.token );
			
			
		}
		
		public function connect(e:ServiceEvent):void
		{
			echo('connect : connected!');
			RTMFPServiceConnection(_service.serviceConnection).autoRefreshConnection(_autoRefreshInterval);
		}
		
		public function tearDownAsset():void
		{
			echo('tearDownAsset : disconnecting!');
			_service.disconnect();
			
			//_arrHeartbeat.length = 0;
			//_heartbeatTimer.reset();
		}
		
		private function fmsEventHandler(e:ServiceEvent):void 
		{
			if (e.type == ServiceEvent.CONNECT_FAIL)
			{
				//Alert.show( new AlerterVO('', '', '', null, getMessage(MessageID.ERROR_TITLE), getMessage(MessageID.ERROR_CONNECT)) );
				echo('fmsEventHandler : ' + e.type);
				
				initAsset();
			}
			else if (e.type == ServiceEvent.DISCONNECTED)
			{
				echo('fmsEventHandler : ' + e.type);
			}
			
		}
		
		public function result(data:Object):void 
		{
		
		}
		
		public function fault(info:Object):void 
		{
		
		}
		
	}
}