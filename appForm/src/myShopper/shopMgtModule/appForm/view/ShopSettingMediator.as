package myShopper.shopMgtModule.appForm.view 
{
	import myShopper.common.Config;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.shop.ShopNewsList;
	import myShopper.common.display.Menu;
	import myShopper.common.emun.SWFClassID;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.events.WindowEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.interfaces.IVO;
	import myShopper.common.text.Font;
	import myShopper.common.utils.TweenerEffect;
	import myShopper.fl.shopMgt.button.ShopMgtSettingButton;
	import myShopper.fl.window.ScrollWindow;
	import myShopper.shopMgtCommon.emun.AssetID;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtModule.appForm.enum.AssetClassID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.FormMain;
	import myShopper.shopMgtModule.appForm.view.component.ApplicationForm;
	import org.puremvc.as3.multicore.interfaces.IContainerMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class ShopSettingMediator extends ApplicationMediator implements IContainerMediator 
	{
		private var _appForm:ApplicationForm;
		public function get appForm():ApplicationForm 
		{
			if (!_appForm) _appForm = (container as FormMain).appForm;
			return _appForm;
		}
		
		private var _shopInfoVO:ShopInfoVO;
		//private var _alert:FormAlerter;
		
		//private var form:ShopMgtAboutForm;
		private var _window:ScrollWindow;
		//private var _bg:ApplicationDisplayObject;
		
		
		public function ShopSettingMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
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
			_window.mcScrollBar.scrollTarget = null;
			if (_window) appForm.removeApplicationChild(_window, false);
			
			stopListener();
			_appForm = null;
			_window = null;
			_shopInfoVO = null;
		}
		
		override public function listNotificationInterests():Array 
		{
			return	[
						NotificationType.ADD_DISPLAY_SETTING
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
				case NotificationType.ADD_DISPLAY_SETTING:
				{
					_window = vo.displayObject as ScrollWindow;
					_shopInfoVO = vo.data as ShopInfoVO;
					
					if (_window)
					{
						//_window.txtTitle.embedFonts = true;
						//_window.txtTitle.defaultTextFormat = Font.getTextFormat( { size:18, letterSpacing:2, font:Font.getDefaultFontByLang(language) } );
						setTextField(_window.txtTitle, language == Config.LANG_CODE_EN);
						
						var windowNode:XML = vo.settingXML;
						
						appForm.addApplicationChild(_window, windowNode, false);
						_window.showPage(TweenerEffect.setAlpha(1));
						_window.setSize(300, 400);
						_window.x = mainStage.stageWidth - _window.width >> 1;
						_window.y = mainStage.stageHeight - _window.height >> 1;
						
						var numItem:int = windowNode..button.length();
						for (var i:int = 0; i < numItem; i++)
						{
							var b:ShopMgtSettingButton = assetManager.getData(AssetClassID.BTN_SHOP_SETTING, AssetLibID.AST_SHOP_MGT);
							if (b)
							{
								//b.btnText.txt.embedFonts = false;
								//b.btnText.txt.defaultTextFormat = Font.getTextFormat( { size:15, letterSpacing:2, font:SWFClassID.SANS } );
								setTextField(b.btnText.txt, language == Config.LANG_CODE_EN, Font.getTextFormat( { size:15, letterSpacing:2, font:SWFClassID.SANS } ));
								_window.holder.addApplicationChild(b, windowNode..button[i], false);
								b.addEventListener(ButtonEvent.CLICK, buttonEventHandler, false, 0, true);
							}
						}
						
						_window.mcScrollBar.refresh();
						
						startListener();
					}
					
					break;
				}
				
			}
			
			
		}
		
		
		
		//set window display object to the top of appFrom container
		public function setIndex(inIndex:int = -1):void 
		{
			if (!_window) return;
			
			appForm.setChildIndex(_window, inIndex == -1 ? appForm.numChildren - 1 : inIndex);
		}
		
		override public function startListener():void 
		{
			if (!_window) return;
			
			_window.btnClose.addEventListener(ButtonEvent.CLICK, windownButtonEventHandler);
		}
		
		override public function stopListener():void
		{
			if (_window) return;
			
			_window.btnClose.removeEventListener(ButtonEvent.CLICK, windownButtonEventHandler);
		}
		
		
		private function windownButtonEventHandler(e:ButtonEvent):void 
		{
			switch(e.targetButton)
			{
				case _window.btnClose:
				{
					//sendNotification(WindowEvent.CLOSE, _window);
					sendNotification(WindowEvent.CLOSE, mediatorName);
					break;
				}
			}
		}
		
		private function buttonEventHandler(e:ButtonEvent):void 
		{
			trace(e.type);
			
			switch(e.targetButton.id)
			{
				case AssetID.BTN_SHOP_S_PAYPAL_ACC_VERIFY:
				case AssetID.BTN_SHOP_S_ACC_VERIFY:
				case AssetID.BTN_SHOP_S_CURRENCY:
				case AssetID.BTN_SHOP_S_TAX:
				case AssetID.BTN_SHOP_S_PASSWORD:
				case AssetID.BTN_SHOP_S_LOGO:
				case AssetID.BTN_SHOP_S_BG:
				case AssetID.BTN_SHOP_S_PRINT:
				case AssetID.BTN_SHOP_S_REMOTE:
				{
					sendNotification
					(
						WindowEvent.CREATE,
						e.targetButton.id,
						getEventTypeByAssetID(e.targetButton.id)
					);
					
					break;
				}
			}
		}
		
		private function getEventTypeByAssetID(inID:String):String
		{
			if 		(inID == AssetID.BTN_SHOP_S_PASSWORD) 			return ShopMgtEvent.SHOP_UPDATE_PASSWORD;
			else if (inID == AssetID.BTN_SHOP_S_PAYPAL_ACC_VERIFY) 	return ShopMgtEvent.SHOP_VERIFY_PAYPAL_ACC;
			else if (inID == AssetID.BTN_SHOP_S_ACC_VERIFY) 		return ShopMgtEvent.SHOP_VERIFY_ACC;
			else if (inID == AssetID.BTN_SHOP_S_CURRENCY) 			return ShopMgtEvent.SHOP_UPDATE_CURRENCY;
			else if (inID == AssetID.BTN_SHOP_S_TAX) 				return ShopMgtEvent.SHOP_UPDATE_TAX;
			else if (inID == AssetID.BTN_SHOP_S_LOGO) 				return ShopMgtEvent.SHOP_UPDATE_LOGO;
			else if (inID == AssetID.BTN_SHOP_S_BG) 				return ShopMgtEvent.SHOP_UPDATE_BG;
			else if (inID == AssetID.BTN_SHOP_S_PRINT) 				return ShopMgtEvent.SHOP_SET_PRINT;
			else if (inID == AssetID.BTN_SHOP_S_REMOTE) 			return ShopMgtEvent.SHOP_CONNECT_REMOTE;
			
			return '';
		}
		
	}
}