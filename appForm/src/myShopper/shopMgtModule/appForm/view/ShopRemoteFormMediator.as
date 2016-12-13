package myShopper.shopMgtModule.appForm.view 
{
	import flash.display.Bitmap;
	import myShopper.common.Config;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.emun.SWFClassID;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.events.WindowEvent;
	import myShopper.common.interfaces.IForm;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.utils.TweenerEffect;
	import myShopper.fl.shopMgt.form.ShopMgtRemoteForm;
	import myShopper.fl.window.BaseWindow;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.FormMain;
	import myShopper.shopMgtModule.appForm.view.component.ApplicationForm;
	import org.puremvc.as3.multicore.interfaces.IContainerMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.interfaces.ITabFormMediator;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class ShopRemoteFormMediator extends ApplicationMediator implements IContainerMediator, ITabFormMediator 
	{
		private var _appForm:ApplicationForm;
		public function get appForm():ApplicationForm 
		{
			if (!_appForm) _appForm = (container as FormMain).appForm;
			return _appForm;
		}
		
		public function getForm():IForm { return form; }
		
		
		//private var _alert:FormAlerter;
		//private var _confirmAlert:ConfirmAlerter;
		
		private var form:ShopMgtRemoteForm;
		private var _window:BaseWindow;
		
		public function ShopRemoteFormMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
		{
			super(inMediatorName, inViewComponent);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			_window.btnClose.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			if (_window) appForm.removeApplicationChild(_window, false);
			
			stopListener();
			
			_window = null;
			form = null;
			//_alert = null;
			//_confirmAlert = null;
		}
		
		override public function listNotificationInterests():Array 
		{
			return	[
						NotificationType.ADD_FORM_SHOP_REMOTE
					];
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
				case NotificationType.ADD_FORM_SHOP_REMOTE:
				{
					_window = assetManager.getData(SWFClassID.WINDOW_BASE, AssetLibID.AST_COMMON);
					var bmpQRCode:Bitmap = vo.data as Bitmap;
					
					if (_window && bmpQRCode)
					{
						//_window.txtTitle.embedFonts = false;
						//_window.txtTitle.defaultTextFormat = Font.getTextFormat( { size:18, letterSpacing:2, font:SWFClassID.SANS } );
						setTextField(_window.txtTitle, language == Config.LANG_CODE_EN);
						
						appForm.addApplicationChild(_window, vo.settingXML, false) as BaseWindow;
						_window.showPage(TweenerEffect.setAlpha(1));
						
						form = _window.addApplicationChild(vo.displayObject, null) as ShopMgtRemoteForm;
						form.mcImage.addChild(bmpQRCode);
						//form.setInfo(_printerVO);
						
						_window.mcBG.alpha = 1;
						_window.x = mainStage.stageWidth - _window.width >> 1;
						_window.y = mainStage.stageHeight - _window.height >> 1;
						_window.setSize(350, 450);
						
						startListener();
					}
					
					break;
				}
				
			}
			
			//if (_window) _window.isBusy = false;
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
			//form.btnSend.alpha = 1;
			
			if (!_window.btnClose.hasEventListener(ButtonEvent.CLICK))
			{
				_window.btnClose.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
			}
			
			//form.btnSend.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
			//
			//form.btnSend.startListener();
			//form.btnSend.onMouseOver = function():void
			//{
				//Tweener.addTween(form.btnSend, TweenerEffect.setGlow(1, 'easeOutSine', 0xFF0000, 10, 5, 1));
			//}
			//form.btnSend.onMouseOut = function():void
			//{
				//Tweener.addTween(form.btnSend, TweenerEffect.resetGlow());
			//}
			
		}
		
		override public function stopListener():void
		{
			if (!form || !_window) return;
			
			form.mouseChildren = false;
			//form.btnSend.alpha = .6;
			//Tweener.addTween(form.btnSend, TweenerEffect.resetGlow());
			//
			//form.btnSend.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			//form.btnSend.stopListener();
			//form.btnSend.onMouseOver = null;
			//form.btnSend.onMouseOut = null;
			
		}
		
		private function buttonEventHandler(e:ButtonEvent):void 
		{
			/*if (_alert)
			{
				form.removeApplicationChild(_alert);
				_alert = null;
			}*/
			
			switch(e.targetButton)
			{
				case _window.btnClose:
				{
					sendNotification(WindowEvent.CLOSE, mediatorName);
					break;
				}
				/*case form.btnSend:
				{
					var result:* = form.isValid();
					if (result === true)
					{
						stopListener();
						_window.isBusy = true;
						
						sendNotification
						(
							ShopMgtEvent.SHOP_SET_PRINT, 
							_printerVO
						);
					}
					else
					{
						createFormAlert(getMessage(MessageID.FORM_MISSING_INFO), form.txtSystem);
						
					}
					break;
				}*/
			}
		}
		
		/*private function createFormAlert(inMessage:String, inItem:DisplayObject):void 
		{
			if (form)
			{
				_alert = form.addApplicationChild(Alert.create(new AlerterVO('', '', '', null, '', inMessage)), null) as FormAlerter;
				_alert.autoClose();
				_alert.x = inItem.x + inItem.width;
				_alert.y = inItem.y - _alert.height;
				_alert = null;
			}
			
		}*/
		
		
	}
}