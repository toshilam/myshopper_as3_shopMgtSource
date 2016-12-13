package myShopper.shopMgtModule.appSystem.model 
{
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	import myShopper.common.Config;
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.AlerterVO;
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
	import myShopper.common.server.AMFResultFactory;
	import myShopper.common.utils.Alert;
	import myShopper.common.utils.Tracer;
	import myShopper.shopMgtModule.appSystem.Config;
	import myShopper.shopMgtModule.appSystem.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	public class FMSRemoteProxy extends ApplicationProxy implements IResponder 
	{
		//public static const NAME:String = "AMFRemoteProxy";
		
		private var _service:RemoteService;
		private var _xmlConfig:XML;
		private var _myUserVO:UserInfoVO;
		
		/*private var _comm:CommunicationProxy;
		private function get comm():CommunicationProxy
		{
			if (!_comm) _comm = facade.retrieveProxy(ProxyID.COMMUNICATION) as CommunicationProxy;
			return _comm;
		}*/
		
		public function FMSRemoteProxy(inName:String, inData:Object = null) 
		{
			super(inName, inData);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			_myUserVO = voManager.getAsset(VOID.MY_USER_INFO);
			
			if (!_myUserVO)
			{
				echo('onRegister : unable to get my user vo from voManager');
			}
			
			_service = new RemoteService( new FMSServiceConnection(new NetConnection()) );
			if ( !serviceManager.addAsset(_service, ServiceID.FMS_SHOP) )
			{
				echo('initAsset : unable to create service controller!', this, 0xff0000);
			}
			
			FMSServiceConnection(_service.serviceConnection).addEventListener(ServiceEvent.RESPONSE, fmsEventHandler);
			FMSServiceConnection(_service.serviceConnection).addEventListener(ServiceEvent.CONNECT_FAIL, fmsEventHandler);
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			echo('initAsset');
			
			if (!_myUserVO)
			{
				echo('initAsset : unable to get my user vo from voManager');
				return;
			}
			
			data = xmlManager.getAsset(AssetLibID.XML_COMMON);
			var xml:XML = data..services[0];
			
			var _xmlConfig:XML = xml..element.(@id == ServiceID.FMS)[0];
			if (_xmlConfig)
			{
				var rtmpHost:String = _xmlConfig.@host.toString();
				
				if (!rtmpHost.length)
				{
					echo('initAsset : no host url found!', this, 0xff0000);
					return;
				}
				
				if (myShopper.common.Config.IS_TEST_MODE)
				{
					rtmpHost += '/' + myShopper.shopMgtModule.appSystem.Config.FMS_APPLICATION_TEST;
				}
				else
				{
					rtmpHost += '/' + myShopper.shopMgtModule.appSystem.Config.FMS_APPLICATION;
				}
				
				_service.connect
				(
					rtmpHost, 
					{
						//service:FMSServicesType.USER_IS_LOGGED, 
						u_id:_myUserVO.uid, 
						u_token:_myUserVO.token, 
						//isShop:_myUserVO.isShopExist
						isShop:true
					} 
				);
			}
			else
			{
				Tracer.echo(multitonKey + ' : ' + getProxyName() + ' : initAsset : no matched node found!', this, 0xff0000);
			}
		}
		
		public function tearDownAsset():void
		{
			echo('tearDownAsset : disconnecting : ' + myShopper.shopMgtModule.appSystem.Config.FMS_APPLICATION + '...');
			_service.disconnect();
		}
		
		private function fmsEventHandler(e:ServiceEvent):void 
		{
			if (e.type == ServiceEvent.CONNECT_FAIL)
			{
				Alert.show( new AlerterVO('', '', '', null, getMessage(MessageID.ERROR_TITLE), getMessage(MessageID.ERROR_CONNECT)) );
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
								//nothing need to be handled. as each module will handle each fms event by themselves
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