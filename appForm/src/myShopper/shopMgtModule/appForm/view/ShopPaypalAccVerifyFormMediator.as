package myShopper.shopMgtModule.appForm.view 
{
	import caurina.transitions.Tweener;
	import flash.display.DisplayObject;
	import myShopper.common.Config;
	import myShopper.common.data.AlerterVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.emun.MessageID;
	import myShopper.common.emun.SWFClassID;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.events.VOEvent;
	import myShopper.common.events.WindowEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.interfaces.IVO;
	import myShopper.common.text.Font;
	import myShopper.common.utils.Alert;
	import myShopper.common.utils.TweenerEffect;
	import myShopper.fl.FormAlerter;
	import myShopper.fl.shopMgt.form.ShopMgtPaypalAccVerifyForm;
	import myShopper.fl.window.BaseWindow;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.FormMain;
	import myShopper.shopMgtModule.appForm.view.component.ApplicationForm;
	import org.puremvc.as3.multicore.interfaces.IContainerMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class ShopPaypalAccVerifyFormMediator extends ApplicationMediator implements IContainerMediator 
	{
		private var _appForm:ApplicationForm;
		public function get appForm():ApplicationForm 
		{
			if (!_appForm) _appForm = (container as FormMain).appForm;
			return _appForm;
		}
		
		//private var _messageService:MessageService;
		private var _alert:FormAlerter;
		
		private var form:ShopMgtPaypalAccVerifyForm;
		private var _window:BaseWindow;
		private var _shopVO:ShopInfoVO;
		
		public function ShopPaypalAccVerifyFormMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
		{
			super(inMediatorName, inViewComponent);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			
			_shopVO = voManager.getAsset(VOID.MY_SHOP_INFO);
			if (!(_shopVO is ShopInfoVO))
			{
				throw(new UninitializedError('ShopProfileFormMediator : onRegister : unable to retreve shopInfo vo'));
			}
			_shopVO.addEventListener(VOEvent.VALUE_CHANGED, voEventHandler, false, 0, true);
			
		}
		
		private function voEventHandler(e:VOEvent, inForceCheck:Boolean = false):void 
		{
			if (e.propertyName == 'paypalAccVerified' && _window && _window.XMLSetting is XML)
			{
				updateWindowTitle();
			}
		}
		
		private function updateWindowTitle():void
		{
			var title:String = getMessage(_window.XMLSetting.@text);
			var messageID:String = _shopVO.paypalAccVerified ? myShopper.shopMgtCommon.emun.MessageID.SHOP_PAYPAL_ACC_VERIFIED : myShopper.shopMgtCommon.emun.MessageID.SHOP_PAYPAL_ACC_NOT_VERIFIED;
			var str:String = '(' + getMessage(messageID, 'string', AssetLibID.XML_LANG_SHOP_MGT) + ')';
			
			_window.txtTitle.text = title + str;
			_window.txtTitle.setTextFormat(Font.getTextFormat({ color:0xff0000, size:12, font:SWFClassID.SANS }), _window.txtTitle.length - str.length, _window.txtTitle.length) ;
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			_window.btnClose.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			if (_window) appForm.removeApplicationChild(_window, false);
			
			_shopVO.removeEventListener(VOEvent.VALUE_CHANGED, voEventHandler);
			_shopVO = null;
			
			stopListener()
			_window = null;
			form = null;
			_alert = null;
		}
		
		override public function listNotificationInterests():Array 
		{
			return [NotificationType.ADD_FORM_PAYPAL_ACC_VERIFY, NotificationType.PAYPAL_ACC_VERIFY_FAIL, NotificationType.PAYPAL_ACC_VERIFY_SUCCESS];
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
				case NotificationType.ADD_FORM_PAYPAL_ACC_VERIFY:
				{
					_window = assetManager.getData(SWFClassID.WINDOW_BASE, AssetLibID.AST_COMMON);
					
					if (_window)
					{
						
						
						
						//_window.txtTitle.embedFonts = false;
						//_window.txtTitle.defaultTextFormat = Font.getTextFormat( { size:18, letterSpacing:2, font:SWFClassID.SANS } );
						//TODO : embed font cannot format string?
						setTextField(_window.txtTitle/*, language == Config.LANG_CODE_EN*/);
						
						appForm.addApplicationChild(_window, vo.settingXML, false) as BaseWindow;
						_window.showPage(TweenerEffect.setAlpha(1));
						
						form = _window.addApplicationChild(vo.displayObject, null) as ShopMgtPaypalAccVerifyForm;
						//this is a cloned shop vo (not the orgrinal one)
						form.setInfo(vo.data as ShopInfoVO);
						
						//_window.setSize(
						_window.x = mainStage.stageWidth - _window.width >> 1;
						_window.y = mainStage.stageHeight - _window.height >> 1;
						
						updateWindowTitle();
						startListener();
					}
					
					break;
				}
				case NotificationType.PAYPAL_ACC_VERIFY_SUCCESS:
				{
					createFormAlert(MessageID.SUCCESS_SAVE, form.txtPayPalEmail);
					//startListener();
					break;
				}
				case NotificationType.PAYPAL_ACC_VERIFY_FAIL:
				{
					createFormAlert(MessageID.ERROR_SHOP_PAYPAL_ACC, form.txtPayPalEmail);
					startListener()
					break;
				}
			}
			
			if (_window) _window.isBusy = false;
		}
		
		
		
		//set window display object to the top of appFrom container
		public function setIndex(inIndex:int = -1):void 
		{
			if (!form || !_window) return;
			
			appForm.setChildIndex(_window, inIndex == -1 ? appForm.numChildren - 1 : inIndex);
		}
		
		override public function startListener():void 
		{
			if (!form || !_window) return;
			form.mouseChildren = true;
			form.btnSend.alpha = 1;
			
			if (!_window.btnClose.hasEventListener(ButtonEvent.CLICK))
			{
				_window.btnClose.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
			}
			
			
			form.btnSend.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
			
			//form.addEventListener(ApplicationEvent.PAGE_CLOSED, formEventHandler);
			form.btnSend.startListener();
			form.btnSend.onMouseOver = function():void
			{
				Tweener.addTween(form.btnSend, TweenerEffect.setGlow(1, 'easeOutSine', 0xFF0000, 10, 5, 1));
			}
			form.btnSend.onMouseOut = function():void
			{
				Tweener.addTween(form.btnSend, TweenerEffect.resetGlow());
			}
		}
		
		override public function stopListener():void 
		{
			if (!form || !_window) return;
			
			form.mouseChildren = false;
			form.btnSend.alpha = .6;
			Tweener.addTween(form.btnSend, TweenerEffect.resetGlow());
			
			//_window.btnClose.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			
			form.btnSend.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			
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
		
		private function buttonEventHandler(e:ButtonEvent):void 
		{
			if (_alert)
			{
				form.removeApplicationChild(_alert);
				_alert = null;
			}
			
			switch(e.targetButton)
			{
				case _window.btnClose:
				{
					//appForm.removeApplicationChild(form);
					//sendNotification(WindowEvent.CLOSE, form);
					stopListener();
					sendNotification(WindowEvent.CLOSE, mediatorName);
					break;
				}
				case form.btnSend:
				{
					var result:* = form.isValid();
					if (result === true)
					{
						stopListener();
						if (_window) _window.isBusy = true;
						sendNotification(ShopMgtEvent.SHOP_VERIFY_PAYPAL_ACC, form.vo);
					}
					else
					{
						createFormAlert(getMessage(MessageID.FORM_MISSING_INFO), (result as Vector.<DisplayObject>)[0]);
						
					}
					break;
				}
			}
		}
		
		private function createFormAlert(inMessage:String, inItem:DisplayObject):void 
		{
			if (form)
			{
				_alert = form.addApplicationChild(Alert.create(new AlerterVO('', '', '', null, '', inMessage)), null) as FormAlerter;
				_alert.autoClose();
				_alert.x = inItem.x + inItem.width;
				_alert.y = inItem.y - _alert.height;
				_alert = null;
			}
			
		}
		
		
	}
}