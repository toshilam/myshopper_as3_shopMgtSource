package myShopper.shopMgtModule.appForm.view 
{
	import flash.events.MouseEvent;
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.AlerterVO;
	import myShopper.common.display.ApplicationDisplayObject;
	import myShopper.common.emun.AlerterType;
	import myShopper.common.events.AlerterEvent;
	import myShopper.common.events.WindowEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.utils.Alert;
	import myShopper.fl.ConfirmAlerter;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.common.emun.MessageID;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import org.puremvc.as3.multicore.interfaces.IContainerMediator;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class ShopCategoryAlertMediator extends ApplicationMediator implements IContainerMediator 
	{
		private var _alert:ApplicationDisplayObject;
		
		public function ShopCategoryAlertMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
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
			return [NotificationType.ADD_ALERT_SHOP_CATEGORY, NotificationType.DELETE_CATEGORY_FAIL, NotificationType.DELETE_CATEGORY_SUCCESS];
		}

		override public function handleNotification(note:INotification):void 
		{
			
			switch(note.getName())
			{
				case NotificationType.ADD_ALERT_SHOP_CATEGORY:
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
							getMessage(myShopper.shopMgtCommon.emun.MessageID.CATEGORY_DELETE, 'string', AssetLibID.XML_LANG_SHOP_MGT)
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
				case NotificationType.DELETE_CATEGORY_FAIL:
				case NotificationType.DELETE_CATEGORY_SUCCESS:
				{
					var result:ResultVO = note.getBody() as ResultVO;
					
					var title:String = note.getName() == NotificationType.DELETE_CATEGORY_FAIL ? getMessage(MessageID.ERROR_TITLE) : getMessage(MessageID.SUCCESS_TITLE);
					var message:String = note.getName() == NotificationType.DELETE_CATEGORY_FAIL ? getMessage(MessageID.ERROR_GET_DATA) + '\nCODE:(' + result.code + ')\n' + getMessage(MessageID.CONTACT_US) : getMessage(myShopper.shopMgtCommon.emun.MessageID.CATEGORY_DELETE_SUCCESS, 'string', AssetLibID.XML_LANG_SHOP_MGT);
					
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
				sendNotification(ShopMgtEvent.SHOP_DELETE_CATEGORY);
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