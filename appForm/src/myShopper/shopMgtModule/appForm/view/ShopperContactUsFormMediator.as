package myShopper.shopMgtModule.appForm.view 
{
	import caurina.transitions.Tweener;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import myShopper.common.data.AlerterVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.shopper.ContactUsVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.display.ApplicationDisplayObject;
	import myShopper.common.emun.AlerterType;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.MessageID;
	import myShopper.common.emun.SWFClassID;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.events.ShopperEvent;
	import myShopper.common.events.WindowEvent;
	import myShopper.common.interfaces.IForm;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.utils.Alert;
	import myShopper.common.utils.Tools;
	import myShopper.common.utils.TweenerEffect;
	import myShopper.fl.ApplicationBG;
	import myShopper.fl.form.shopper.ShopperContactUsForm;
	import myShopper.fl.FormAlerter;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.FormMain;
	import myShopper.shopMgtModule.appForm.view.component.ApplicationForm;
	import org.puremvc.as3.multicore.interfaces.IContainerMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.interfaces.ITabFormMediator;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class ShopperContactUsFormMediator extends ApplicationMediator implements IContainerMediator, ITabFormMediator
	{
		private var _appForm:ApplicationForm;
		public function get appForm():ApplicationForm 
		{
			if (!_appForm) _appForm = (container as FormMain).appForm;
			return _appForm;
		}
		
		public function getForm():IForm { return form; }
		
		private var _alert:FormAlerter;
		private var _userInfo:UserInfoVO;
		private var form:ShopperContactUsForm;
		//private var _bg:ApplicationBG;
		private var _contactVO:ContactUsVO;
		
		public function ShopperContactUsFormMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
		{
			super(inMediatorName, inViewComponent);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			//_messageService = new MessageService(xmlManager as XMLManager, AssetLibID.XML_LANG_COMMON, 'string');
			
			_userInfo = voManager.getAsset(VOID.MY_USER_INFO);
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			
			if (form) appForm.removeApplicationChild(form);
			//if (_bg) appForm.removeApplicationChild(_bg);
			/*if (form.txtEmail.hasEventListener(FocusEvent.FOCUS_IN))
			{
				form.txtEmail.removeEventListener(FocusEvent.FOCUS_IN, buttonEventHandler, false);
				form.txtPassword.removeEventListener(FocusEvent.FOCUS_IN, buttonEventHandler, false);
			}*/
			
			stopListener()
			form = null;
			_userInfo = null;
			//_messageService = null;
			_alert = null;
			_contactVO = null;
		}
		
		override public function listNotificationInterests():Array 
		{
			return [NotificationType.ADD_FORM_SHOPPER_CONTACT_US, NotificationType.SHOPPER_CONTACT_US_FAIL, NotificationType.SHOPPER_CONTACT_US_SUCCESS];
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
				case NotificationType.ADD_FORM_SHOPPER_CONTACT_US:
				{
					_contactVO = vo.data as ContactUsVO;
					
					if (_contactVO)
					{
						//_bg = appForm.addApplicationChild(assetManager.getData(SWFClassID.BG7, AssetLibID.AST_COMMON), null) as ApplicationBG;
						form =  appForm.addApplicationChild(vo.displayObject, vo.settingXML) as ShopperContactUsForm;
						form.setInfo(_contactVO);
						
						
						
						if (_userInfo)
						{
							form.txtEmail.text = _userInfo.email;
							form.txtName.text = _userInfo.firstName;
						}
						
						startListener();
						
						break;
					}
					
					//if shop info and product info not found, alert + remove mediator and proxy
					//so no "break" needed.
					
				}
				case NotificationType.SHOPPER_CONTACT_US_FAIL:
				case NotificationType.SHOPPER_CONTACT_US_SUCCESS:
				{
					var title:String = note.getName() == NotificationType.SHOPPER_CONTACT_US_SUCCESS ? getMessage(MessageID.SUCCESS_TITLE) : getMessage(MessageID.ERROR_TITLE);
					var message:String = note.getName() == NotificationType.SHOPPER_CONTACT_US_SUCCESS ? getMessage(MessageID.SUCCESS_SEND) : getMessage(MessageID.ERROR_GET_DATA) + '<br />' + getMessage(MessageID.ERROR_TRY_LATER);
					Alert.show(new AlerterVO('', AlerterType.MESSAGE, '', null, title, message));
					
					sendNotification(WindowEvent.CLOSE, mediatorName);
					
					//createFormAlert(note.getName() == NotificationType.USER_QUESTION_SHOP_FAIL ? MessageID.ERROR_GET_DATA : MessageID.SUCCESS_SAVE);
					//form.clear();
					//startListener();
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
						var result:* = form.isValid();
						if (result === true)
						{
							stopListener();
							sendNotification(ShopperEvent.CONTACT_US, form.vo);
						}
						else
						{
							createFormAlert(getMessage(MessageID.FORM_MISSING_INFO), (result as Vector.<DisplayObject>)[0]);
						}
						break;
					}
				}
			}
			
		}
		
		private function createFormAlert(inMessage:String, inItem:DisplayObject):void 
		{
			if (form)
			{
				_alert = Alert.create(new AlerterVO('', '', '', null, '', inMessage)) as FormAlerter;
				form.addApplicationChild(_alert, null);
				_alert.x = inItem.x + inItem.width;
				_alert.y = inItem.y - _alert.height;
				_alert.autoClose();
				_alert = null;
			}
			
		}
		
		
	}
}