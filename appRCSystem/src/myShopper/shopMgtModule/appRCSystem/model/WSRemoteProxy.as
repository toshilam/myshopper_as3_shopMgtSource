package myShopper.shopMgtModule.appRCSystem.model 
{
	import com.pnwrain.flashsocket.events.FlashSocketEvent;
	import flash.events.TimerEvent;
	import flash.system.Security;
	import flash.utils.Timer;
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.FMS.FMSRequestVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.data.AlerterVO;
	import myShopper.common.emun.CommunicationType;
	import myShopper.common.emun.FMSServicesType;
	import myShopper.common.emun.MessageID;
	import myShopper.common.emun.ServiceID;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.ServiceEvent;
	import myShopper.common.interfaces.IResponder;
	import myShopper.common.net.RemoteService;
	import myShopper.common.net.ServiceRequest;
	import myShopper.common.net.WSServiceConnection;
	import myShopper.common.server.AMFResultFactory;
	import myShopper.common.utils.Alert;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtModule.appRCSystem.Config;
	import myShopper.shopMgtModule.appRCSystem.enum.ProxyID;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	
	public class WSRemoteProxy extends ApplicationProxy implements IResponder 
	{
		//public static const NAME:String = "AMFRemoteProxy";
		
		private var _heartbeatInterval:int = 4000; //send heartbeat to server in every 1sec
		private var _connectNumRetried:int = 0; //number of time retried to connect server
		private var _connectNumRetry:int = 15*5;//retry for 5min //number of time retry to connect server
		private var _arrHeartbeat:Array; //contains requested heartbeat request to server
		private var _heartbeatTimer:Timer;
		private var _isRelogin:Boolean;
		
		private var _service:RemoteService;
		private var _xmlConfig:XML;
		private var _myUserVO:UserInfoVO;
		
		private var _comm:CommunicationProxy;
		private function get comm():CommunicationProxy
		{
			if (!_comm) _comm = facade.retrieveProxy(ProxyID.COMMUNICATION) as CommunicationProxy;
			return _comm;
		}
		
		public function WSRemoteProxy(inName:String, inData:Object = null) 
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
			
			_service = new RemoteService( new WSServiceConnection() );
			if ( !serviceManager.addAsset(_service, ServiceID.WS) || !serviceManager.addAsset(_service, ServiceID.WS_SHOP) )
			{
				throw('initAsset : unable to create service controller!', this, 0xff0000);
			}
			
			_isRelogin = false;
			_arrHeartbeat = new Array();
			_heartbeatTimer = new Timer(_heartbeatInterval);
			_heartbeatTimer.addEventListener(TimerEvent.TIMER, timerEventHandler);
			
			WSServiceConnection(_service.serviceConnection).addEventListener(FlashSocketEvent.CONNECT, connect);
			WSServiceConnection(_service.serviceConnection).addEventListener(ServiceEvent.RESPONSE, fmsEventHandler);
			WSServiceConnection(_service.serviceConnection).addEventListener(ServiceEvent.CONNECT_FAIL, fmsEventHandler);
			WSServiceConnection(_service.serviceConnection).addEventListener(ServiceEvent.DISCONNECTED, fmsEventHandler);
		}
		
		private function timerEventHandler(e:TimerEvent):void 
		{
			//execute when user is logged in
			if (_myUserVO.isLogged)
			{
				if (!WSServiceConnection(_service.serviceConnection).isConnected())
				{
					if (++_connectNumRetried <= _connectNumRetry)
					{
						tearDownAsset();
						initAsset(true);
					}
					
					/*else
					{
						echo('timerEventHandler : over retry time!');
						fmsEventHandler(new ServiceEvent(ServiceEvent.CONNECT_FAIL));
						tearDownAsset();
						//TODO : notify other module?
					}*/
					
				}
				else
				{
					//re-connect, if previous req has not removed (no response from server within _heartbeatInterval) as assume disconnected from server
					if (_arrHeartbeat.length)
					{
						echo('timerEventHandler : re-connect!');
						tearDownAsset();
						initAsset(true);
					}
					else
					{
						echo('timerEventHandler : ' + FMSServicesType.HEART_BEAT);
						
						_heartbeatTimer.reset();
						_heartbeatTimer.start();
						
						var req:ServiceRequest = new ServiceRequest(WSServiceConnection.FMS_METHOD_NAME, new FMSRequestVO(FMSServicesType.HEART_BEAT, null, {id:_arrHeartbeat.length }), this);
						_arrHeartbeat.push(req);
						_service.request(req);
					}
				}
				
				
			}
			else
			{
				tearDownAsset();
			}
		}
		
		//to be called by controller once xml common loaded
		override public function initAsset(inAsset:Object = null):void 
		{
			echo('initAsset');
			
			_isRelogin = inAsset === true;
			data = xmlManager.getAsset(AssetLibID.XML_COMMON);
			
			var xml:XML = data..services[0];
			var _xmlConfig:XML = xml..element.(@id == ServiceID.WS)[0];
			
			if (!_xmlConfig || !_xmlConfig.@host.toString())
			{
				throw(new UninitializedError(multitonKey + ' : onRegister : unable to reetreve data!'));
			}
			
			comm.request(CommunicationType.USER_DISCONNECTING);
			
			var host:String = _xmlConfig.@host.toString();
			
			/*CONFIG::web
			{
				var crossdomain:String = host + '/crossdomain.xml';
				Security.loadPolicyFile(crossdomain);
				Security.allowDomain(crossdomain);
				Security.allowInsecureDomain(crossdomain);
			}*/
			
			WSServiceConnection(_service.serviceConnection).init( _xmlConfig.@host.toString() );
			
		}
		
		//to be called by comm controller or FlashSocketEvent
		public function connect(e:FlashSocketEvent = null):void
		{
			if (!_myUserVO.isLogged || !WSServiceConnection(_service.serviceConnection).isConnected())
			{
				echo('connect : WS connection is not ready to be connected!');
				return;
			}
			
			_service.connect
			(
				FMSServicesType.USER_IS_LOGGED, 
				{
					service:FMSServicesType.USER_IS_LOGGED, 
					isRelogin:_isRelogin == true,
					u_id:_myUserVO.uid, 
					u_token:_myUserVO.token, 
					//isShop:_myUserVO.isShopExist
					isShop:true
				} 
			);
		}
		
		public function tearDownAsset():void
		{
			echo('tearDownAsset : disconnecting : ' + myShopper.shopMgtModule.appRCSystem.Config.FMS_APPLICATION + '...');
			_service.disconnect();
			
			_arrHeartbeat.length = 0;
			_heartbeatTimer.reset();
		}
		
		private function fmsEventHandler(e:ServiceEvent):void 
		{
			if (e.type == ServiceEvent.CONNECT_FAIL)
			{
				//Alert.show( new AlerterVO('', '', '', null, getMessage(MessageID.ERROR_TITLE), getMessage(MessageID.ERROR_CONNECT)) );
				
				if (_myUserVO.isLogged && !_heartbeatTimer.running) 
				{
					_heartbeatTimer.start();
				}
			}
			else if (e.type == ServiceEvent.DISCONNECTED)
			{
				if (_myUserVO.isLogged && !_heartbeatTimer.running) 
				{
					_heartbeatTimer.start();
					
				}
				
				comm.request(CommunicationType.USER_DISCONNECTED);
			}
			else if (e.type == ServiceEvent.RESPONSE)
			{
				if (e.data)
				{
					var result:ResultVO = AMFResultFactory.convert(e.data);
					
					if (result)
					{
						switch(result.service)
						{
							case FMSServicesType.USER_IS_LOGGED:
							{
								_connectNumRetried = 0;
								_heartbeatTimer.reset();
								_heartbeatTimer.start();
								
								comm.request(CommunicationType.USER_CONNECTED);
							}
							case FMSServicesType.HEART_BEAT:
							{
								//var data:Object = result.result;
								//var index:int = int(data.id);
								if (!_arrHeartbeat.length)
								{
									echo('fmsEventHandler : ' + result.service + ' : unknown data!');
								}
								else
								{
									//echo('fmsEventHandler : ' + result.service + ' : received!');
									_arrHeartbeat.splice(0, 1);
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
		
		public function result(data:Object):void 
		{
		
		}
		
		public function fault(info:Object):void 
		{
		
		}
		
	}
}