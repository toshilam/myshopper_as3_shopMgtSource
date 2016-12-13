package myShopper.shopMgtModule.appForm.view 
{
	import caurina.transitions.Tweener;
	import flash.events.Event;
	import myShopper.common.data.AlerterVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.emun.AlerterType;
	import myShopper.common.emun.MessageID;
	import myShopper.common.events.ApplicationUserEvent;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.events.WindowEvent;
	import myShopper.common.interfaces.IForm;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.interfaces.IVO;
	import myShopper.common.utils.Alert;
	import myShopper.common.utils.TweenerEffect;
	import myShopper.fl.form.user.UserForgotPasswordForm;
	import myShopper.fl.FormAlerter;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.FormMain;
	import myShopper.shopMgtModule.appForm.view.component.ApplicationForm;
	import org.puremvc.as3.multicore.interfaces.IContainerMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.interfaces.ITabFormMediator;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	
	public class UserForgotPasswordFormMediator extends ApplicationMediator implements IContainerMediator, ITabFormMediator 
	{
		private var _appForm:ApplicationForm;
		public function get appForm():ApplicationForm 
		{
			if (!_appForm) _appForm = (container as FormMain).appForm;
			return _appForm;
		}
		
		public function getForm():IForm { return form; }
		
		private var _alert:FormAlerter;
		
		private var form:UserForgotPasswordForm;
		
		public function UserForgotPasswordFormMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
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
			
			if (form) appForm.removeApplicationChild(form);
			
			/*if (form.txtEmail.hasEventListener(FocusEvent.FOCUS_IN))
			{
				form.txtEmail.removeEventListener(FocusEvent.FOCUS_IN, buttonEventHandler, false);
				form.txtPassword.removeEventListener(FocusEvent.FOCUS_IN, buttonEventHandler, false);
			}*/
			
			stopListener()
			form = null;
			//_messageService = null;
			_alert = null;
		}
		
		override public function listNotificationInterests():Array 
		{
			return [NotificationType.ADD_FORM_USER_FORGOT_PASSWORD, NotificationType.USER_FORGOT_PASSWORD_FAIL, NotificationType.USER_FORGOT_PASSWORD_SUCCESS];
		}

		override public function handleNotification(note:INotification):void 
		{
			var body:Object = note.getBody();
			var vo:DisplayObjectVO = body as DisplayObjectVO;
			
			/*if (!vo)
			{
				echo('handleNotification : unknown data type : ' + body);
			}*/
			
			switch(note.getName())
			{
				case NotificationType.ADD_FORM_USER_FORGOT_PASSWORD:
				{
					form =  appForm.addApplicationChild(vo.displayObject, vo.settingXML) as UserForgotPasswordForm;
					form.setInfo(vo.data as IVO);
					startListener();
					break;
				}
				case NotificationType.USER_FORGOT_PASSWORD_SUCCESS:
				case NotificationType.USER_FORGOT_PASSWORD_FAIL:
				{
					var title:String = note.getName() == NotificationType.USER_FORGOT_PASSWORD_SUCCESS ? getMessage(MessageID.SUCCESS_TITLE) : getMessage(MessageID.ERROR_TITLE);
					var message:String = note.getName() == NotificationType.USER_FORGOT_PASSWORD_SUCCESS ? getMessage(MessageID.SUCCESS_USER_FORGOT_PASSWORD) : getMessage(MessageID.ERROR_GET_DATA) + '<br />' + getMessage(MessageID.ERROR_TRY_LATER);
					Alert.show(new AlerterVO('', AlerterType.MESSAGE, '', null, title, message));
					
					sendNotification(WindowEvent.CLOSE, mediatorName);
					
					break;
				}
				
			}
			
			
		}
		
		public function setIndex(inIndex:int = -1):void 
		{
			if (!form) return;
			
			appForm.setChildIndex(form, inIndex == -1 ? appForm.numChildren - 1 : inIndex);
		}
		
		override public function startListener():void 
		{
			if (!form) return;
			
			
			form.btnClose.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
			form.btnSend.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
			
			/*if (!form.txtEmail.hasEventListener(FocusEvent.FOCUS_IN))
			{
				form.txtEmail.addEventListener(FocusEvent.FOCUS_IN, buttonEventHandler, false, 0, true);
				form.txtPassword.addEventListener(FocusEvent.FOCUS_IN, buttonEventHandler, false, 0, true);
			}*/
			
			
			//form.addEventListener(ApplicationEvent.PAGE_CLOSED, formEventHandler);
			form.btnSend.startListener();
			form.btnSend.onMouseOver = function():void
			{
				Tweener.addTween(form.btnSend, TweenerEffect.setGlow(1, 'easeOutSine', 0xFF0000, 10, 5, .5));
			}
			form.btnSend.onMouseOut = function():void
			{
				Tweener.addTween(form.btnSend, TweenerEffect.resetGlow());
			}
		}
		
		override public function stopListener():void 
		{
			if (!form) return;
			
			form.btnClose.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			form.btnSend.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			
			//form.removeEventListener(ApplicationEvent.PAGE_CLOSED, formEventHandler);
			form.btnSend.stopListener();
			form.btnSend.onMouseOver = null;
			form.btnSend.onMouseOut = null;
		}
		
		//??
		/*private function formEventHandler(e:ApplicationEvent):void 
		{
			form.removeEventListener(ApplicationEvent.PAGE_CLOSED, formEventHandler);
			
			sendNotification(FormEvent.CLOSED, e.targetDisplayObject);
		}*/
		
		private function buttonEventHandler(e:Event):void 
		{
			if (_alert)
			{
				form.removeApplicationChild(_alert);
				_alert = null;
			}
			if (e is ButtonEvent)
			{
				switch(ButtonEvent(e).targetButton)
				{
					case form.btnClose:
					{
						sendNotification(WindowEvent.CLOSE, mediatorName);
						break;
					}
					case form.btnSend:
					{
						if (form.isValid() === true)
						{
							stopListener();
							sendNotification(ApplicationUserEvent.FORGOT_PASSWORD, form.vo);
						}
						else
						{
							createFormAlert(getMessage(MessageID.FORM_MISSING_INFO));
						}
						break;
					}
				}
			}
			
		}
		
		private function createFormAlert(inMessage:String):void 
		{
			if (form)
			{
				_alert = Alert.create(new AlerterVO('', '', '', null, '', inMessage)) as FormAlerter;
				form.addApplicationChild(_alert, null);
				_alert.autoClose();
				_alert.x = form.txtEmail.x + form.txtEmail.width;
				_alert.y = form.txtEmail.y - _alert.height;
				_alert = null;
				
			}
			
		}
		
		
	}
}