package myShopper.shopMgtModule.appForm.view 
{
	import caurina.transitions.Tweener;
	import flash.events.KeyboardEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	import myShopper.common.Config;
	import myShopper.common.data.AlerterVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.user.UserLoginFormVO;
	import myShopper.common.display.ApplicationDisplayObject;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.MessageID;
	import myShopper.common.emun.SWFClassID;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.ApplicationUserEvent;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.events.WindowEvent;
	import myShopper.common.interfaces.IForm;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.interfaces.IVO;
	import myShopper.common.resources.XMLManager;
	import myShopper.common.ui.TabbingManager;
	import myShopper.common.utils.Alert;
	import myShopper.common.utils.TweenerEffect;
	import myShopper.fl.form.user.UserLoginForm;
	import myShopper.fl.FormAlerter;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtModule.appForm.enum.AssetID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.FormMain;
	import myShopper.shopMgtModule.appForm.model.service.MessageService;
	import myShopper.shopMgtModule.appForm.view.component.ApplicationForm;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.interfaces.ITabFormMediator;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class UserLoginFormMediator extends ApplicationMediator implements IMediator, ITabFormMediator 
	{
		private var _appForm:ApplicationForm;
		public function get appForm():ApplicationForm 
		{
			if (!_appForm) _appForm = (container as FormMain).appForm;
			return _appForm;
		}
		
		public function getForm():IForm { return form; }
		
		private var _messageService:MessageService;
		private var _alert:FormAlerter;
		
		private var form:UserLoginForm;
		private var _bg:ApplicationDisplayObject;
		
		public function UserLoginFormMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
		{
			super(inMediatorName, inViewComponent);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			_messageService = new MessageService(xmlManager as XMLManager, AssetLibID.XML_LANG_COMMON, 'string');
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			
			if (form) appForm.removeApplicationChild(form);
			if (_bg) appForm.removeApplicationChild(_bg);
			
			stopListener()
			form = null;
			_messageService = null;
			_alert = null;
		}
		
		override public function listNotificationInterests():Array 
		{
			return [NotificationType.ADD_FORM_USER_LOGIN, NotificationType.USER_LOGIN_FAIL, NotificationType.USER_LOGIN_SUCCESS];
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
				case NotificationType.ADD_FORM_USER_LOGIN:
				{
					_bg = appForm.addApplicationChild(assetManager.getData(SWFClassID.BG0, AssetLibID.AST_COMMON), null, false) as ApplicationDisplayObject;
					_bg.width = mainStage.stageWidth;
					_bg.height = mainStage.stageHeight;
					_bg.alpha = .95;
					
					var loginVO:UserLoginFormVO = vo.data as UserLoginFormVO;
					
					form =  appForm.addApplicationChild(vo.displayObject, vo.settingXML) as UserLoginForm;
					form.setInfo(loginVO);
					form.dpiScale = Config.DEFAULT_APP_DPI;
					/*form.btnForgotPassword.visible = form.btnRegister.visible = */form.btnClose.visible = false;
					TabbingManager.getInstance().setTabForm(form);
					startListener();
					
					//if login info exist (means trying autoLogin), stopListener and wait for response
					if (loginVO.email.length && loginVO.password.length)
					{
						stopListener();
					}
					break;
				}
				case NotificationType.USER_LOGIN_SUCCESS:
				{
					sendNotification(WindowEvent.CLOSE, mediatorName);
					break;
				}
				case NotificationType.USER_LOGIN_FAIL:
				{
					createFormAlert(getMessage(MessageID.ERROR_USER_LOGIN));
					startListener()
					break;
				}
			}
			
			
		}
		
		override public function startListener():void 
		{
			if (!form) return;
			
			
			//form.btnClose.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
			form.btnForgotPassword.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
			form.btnLogin.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
			form.btnRegister.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
			
			form.txtPassword.addEventListener(KeyboardEvent.KEY_UP, keyboardEventHandler);
			
			//form.addEventListener(ApplicationEvent.PAGE_CLOSED, formEventHandler);
			form.btnLogin.startListener();
			form.btnLogin.onMouseOver = function():void
			{
				Tweener.addTween(form.btnLogin, TweenerEffect.setGlow(1, 'easeOutSine', 0xFF0000, 10, 5, .5));
			}
			form.btnLogin.onMouseOut = function():void
			{
				Tweener.addTween(form.btnLogin, TweenerEffect.resetGlow());
			}
		}
		
		override public function stopListener():void
		{
			if (!form) return;
			
			//form.btnClose.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			form.btnForgotPassword.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			form.btnLogin.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			form.btnRegister.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			
			form.txtPassword.removeEventListener(KeyboardEvent.KEY_UP, keyboardEventHandler);
			
			//form.removeEventListener(ApplicationEvent.PAGE_CLOSED, formEventHandler);
			form.btnLogin.stopListener();
			form.btnLogin.onMouseOver = null;
			form.btnLogin.onMouseOut = null;
		}
		
		private function keyboardEventHandler(e:KeyboardEvent):void 
		{
			if (e.keyCode == Keyboard.ENTER && form)
			{
				buttonEventHandler(new ButtonEvent(ButtonEvent.CLICK, form.btnLogin));
			}
		}
		
		//??
		/*private function formEventHandler(e:ApplicationEvent):void 
		{
			form.removeEventListener(ApplicationEvent.PAGE_CLOSED, formEventHandler);
			
			sendNotification(FormEvent.CLOSED, e.targetDisplayObject);
		}*/
		
		private function buttonEventHandler(e:ButtonEvent):void 
		{
			if (_alert)
			{
				form.removeApplicationChild(_alert);
				_alert = null;
			}
			
			switch(e.targetButton)
			{
				case form.btnClose:
				{
					//appForm.removeApplicationChild(form);
					//sendNotification(WindowEvent.CLOSE, form);
					sendNotification(WindowEvent.CLOSE, mediatorName);
					break;
				}
				case form.btnLogin:
				{
					if (form.isValid() === true)
					{
						stopListener();
						sendNotification(ShopMgtEvent.LOGIN);
					}
					else
					{
						createFormAlert(getMessage(MessageID.FORM_MISSING_INFO));
						
					}
					break;
				}
				case form.btnForgotPassword:
				{
					sendNotification
					(
						WindowEvent.CREATE,
						AssetID.BTN_FORGOT_PASSWORD,
						ApplicationUserEvent.FORGOT_PASSWORD
					);
					break;
				}
				case form.btnRegister:
				{
					navigateToURL(new URLRequest(Config.URL_SHOPPER_ABOUT), "_blank"); 
					break;
				}
			}
		}
		
		private function createFormAlert(inMessage:String):void 
		{
			if (form)
			{
				_alert = Alert.create(new AlerterVO('', '', '', null, '', inMessage)) as FormAlerter;
				form.addApplicationChild(_alert, null);
				_alert.autoClose(5000);
				_alert.x = form.txtEmail.x + form.txtEmail.width;
				_alert.y = form.txtEmail.y - _alert.height;
				_alert = null;
			}
			
		}
		
		
	}
}