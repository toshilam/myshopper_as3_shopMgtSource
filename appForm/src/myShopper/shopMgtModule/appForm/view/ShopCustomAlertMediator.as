package myShopper.shopMgtModule.appForm.view 
{
	import flash.events.MouseEvent;
	import myShopper.common.data.AlerterVO;
	import myShopper.common.display.ApplicationDisplayObject;
	import myShopper.common.emun.AlerterType;
	import myShopper.common.emun.MessageID;
	import myShopper.common.events.AlerterEvent;
	import myShopper.common.events.WindowEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.utils.Alert;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import org.puremvc.as3.multicore.interfaces.IContainerMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class ShopCustomAlertMediator extends ApplicationMediator implements IContainerMediator 
	{
		private var _alert:ApplicationDisplayObject;
		
		public function ShopCustomAlertMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
		{
			super(inMediatorName, inViewComponent);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			//_messageService = new MessageService(xmlManager as XMLManager, AssetLibID.XML_LANG_COMMON, 'string');
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			
			_alert = null;
		}
		
		override public function listNotificationInterests():Array 
		{
			return [NotificationType.ADD_ALERT_SHOP_CUSTOM, NotificationType.DELETE_CUSTOM_FAIL, NotificationType.DELETE_CUSTOM_SUCCESS];
		}

		override public function handleNotification(note:INotification):void 
		{
			
			switch(note.getName())
			{
				case NotificationType.ADD_ALERT_SHOP_CUSTOM:
				{
					_alert = Alert.show
					(
						new AlerterVO
						(
							mediatorName, 
							AlerterType.CONFIRM, 
							'', 
							null, 
							getMessage(MessageID.CONFIRM_TITLE),
							getMessage(MessageID.CONFIRM_DELETE)
						)
					)
					
					if (_alert)
					{
						_alert.addEventListener(AlerterEvent.CANCEL, alertEventHandler);
						_alert.addEventListener(AlerterEvent.CONFIRM, alertEventHandler);
						_alert.addEventListener(AlerterEvent.CLOSE, alertEventHandler);
					}
					else
					{
						echo('listNotificationInterests : ' + note.getName() + ' : unknown data type : ' + _alert);
					}
					break;
				}
				case NotificationType.DELETE_CUSTOM_FAIL:
				case NotificationType.DELETE_CUSTOM_SUCCESS:
				{
					//var result:ResultVO = note.getBody() as ResultVO;
					
					var title:String = note.getName() == NotificationType.DELETE_CUSTOM_FAIL ? getMessage(MessageID.ERROR_TITLE) : getMessage(MessageID.SUCCESS_TITLE);
					var message:String = note.getName() == NotificationType.DELETE_CUSTOM_FAIL ? getMessage(MessageID.ERROR_GET_DATA) + '<br />' + getMessage(MessageID.ERROR_TRY_LATER) : getMessage(MessageID.SUCCESS_SAVE);
					
					_alert = Alert.show
					(
						new AlerterVO
						(
							'', 
							'', 
							'', 
							null, 
							title, 
							message
						) 
					);
					
					mainStage.addEventListener(MouseEvent.CLICK, mouseEventHandler);
					
					break;
				}
			}
			
			
		}
		
		private function mouseEventHandler(e:MouseEvent):void 
		{
			sendNotification(WindowEvent.CLOSE, mediatorName);
		}
		
		private function alertEventHandler(e:AlerterEvent):void 
		{
			_alert.removeEventListener(AlerterEvent.CANCEL, alertEventHandler);
			_alert.removeEventListener(AlerterEvent.CONFIRM, alertEventHandler);
			_alert.removeEventListener(AlerterEvent.CLOSE, alertEventHandler);
			
			if (e.type == AlerterEvent.CONFIRM)
			{
				sendNotification(ShopMgtEvent.SHOP_DELETE_CUSTOM);
			}
			else
			{
				sendNotification(WindowEvent.CLOSE, mediatorName);
			}
		}
		
		//set window display object to the top of appFrom container
		public function setIndex(inIndex:int = -1):void 
		{
			return;
		}
		
		
		
	}
}