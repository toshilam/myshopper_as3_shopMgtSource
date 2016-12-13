package myShopper.shopMgtModule.appSystem.model
{
	import myShopper.common.Config;
	import myShopper.common.data.AlerterVO;
	import myShopper.common.emun.AlerterType;
	import myShopper.common.emun.CommunicationType;
	import myShopper.common.emun.MessageID;
	import myShopper.common.emun.ServiceID;
	import myShopper.common.events.AlerterEvent;
	import myShopper.common.net.FacebookService;
	import myShopper.common.utils.Alert;
	import myShopper.fl.ConfirmAlerter;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	
	public class FacebookProxy extends ApplicationProxy
	{
		protected var _service:FacebookService;
		protected var _permission:Array = new Array('read_stream', 'publish_stream');
		
		
		public function FacebookProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			
			//fb permission
			//var permission:Array = new Array(ExtendedPermission.READ_STREAM, ExtendedPermission.PUBLISH_STREAM);
			
			_service = FacebookService.getInstance(Config.FACEBOOK_KEY, _permission);
			if 
			( 
				!_service ||
				!serviceManager.addAsset(_service, ServiceID.FACEBOOK) 
			)
			{
				throw(new UninitializedError(multitonKey + ' : onRegister : unable to register service'));
			}
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			var ca:ConfirmAlerter;
			
			if (inAsset === CommunicationType.FB_LOGIN_OUT)
			{
				if (_service.isConnected())
				{
					ca = Alert.show(new AlerterVO('', AlerterType.CONFIRM, '', inAsset, getMessage(MessageID.CONFIRM_TITLE), getMessage(MessageID.CONFIRM_LOGOUT_FB))) as ConfirmAlerter;
					
				}
				else
				{
					_service.connect('', _permission);
				}
			}
			else if (inAsset === CommunicationType.FB_REQUEST_PERMISSION)
			{
				ca = Alert.show(new AlerterVO('', AlerterType.CONFIRM, '', inAsset, getMessage(MessageID.ERROR_TITLE), getMessage(MessageID.ERROR_FB_PERMISSION))) as ConfirmAlerter;
			}
			
			if (ca)
			{
				ca.addEventListener(AlerterEvent.CONFIRM, alerterEventHandler);
				ca.addEventListener(AlerterEvent.CLOSE, alerterEventHandler);
				ca.addEventListener(AlerterEvent.CANCEL, alerterEventHandler);
			}
			
		}
		
		private function alerterEventHandler(e:AlerterEvent):void 
		{
			e.targetDisplayObject.removeEventListener(AlerterEvent.CONFIRM, alerterEventHandler);
			e.targetDisplayObject.removeEventListener(AlerterEvent.CLOSE, alerterEventHandler);
			e.targetDisplayObject.removeEventListener(AlerterEvent.CANCEL, alerterEventHandler);
			
			if (e.type == AlerterEvent.CONFIRM)
			{
				var vo:AlerterVO = e.data as AlerterVO;
				if (vo)
				{
					if (vo.data === CommunicationType.FB_LOGIN_OUT)
					{
						_service.disconnect();
					}
					else if (vo.data === CommunicationType.FB_REQUEST_PERMISSION)
					{
						if (!_service.connect('', null, true))
						{
							echo('alerterEventHandler : unable to connect to fb service');
						}
					}
				}
				
				
			}
		}
		
		
	}
}