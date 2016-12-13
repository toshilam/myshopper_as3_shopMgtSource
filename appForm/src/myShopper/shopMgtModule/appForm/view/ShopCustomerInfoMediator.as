package myShopper.shopMgtModule.appForm.view 
{
	import caurina.transitions.Tweener;
	import flash.display.DisplayObject;
	import flash.text.TextFieldAutoSize;
	import myShopper.common.Config;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.service.ImageVOService;
	import myShopper.common.data.service.ShopperVOService;
	import myShopper.common.display.button.Button;
	import myShopper.common.emun.FileType;
	import myShopper.common.emun.SWFClassID;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.events.WindowEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.interfaces.IVO;
	import myShopper.common.text.Font;
	import myShopper.common.utils.TweenerEffect;
	import myShopper.fl.button.ArrowTextButton;
	import myShopper.fl.shopMgt.ShopMgtCustomerInfo;
	import myShopper.fl.window.BaseWindow;
	import myShopper.shopMgtCommon.data.ShopMgtUserInfoVO;
	import myShopper.shopMgtCommon.emun.AssetID;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.emun.MessageID;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.FormMain;
	import myShopper.shopMgtModule.appForm.view.component.ApplicationForm;
	import org.puremvc.as3.multicore.interfaces.IContainerMediator;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	/**
	 * NOTE: if mediator class will be used create multiple instance, be sure to check notification is sent by the relate proxy
	 * as notification name is shared among mediator
	 */
	public class ShopCustomerInfoMediator extends ApplicationMediator implements IContainerMediator 
	{
		private var _appForm:ApplicationForm;
		public function get appForm():ApplicationForm 
		{
			if (!_appForm) _appForm = (container as FormMain).appForm;
			return _appForm;
		}
		
		//private var _messageService:MessageService;
		//private var _alert:FormAlerter;
		
		private var form:ShopMgtCustomerInfo;
		private var _window:BaseWindow;
		private var _userInfo:ShopMgtUserInfoVO;
		private var _xmlAgeRang:XML;
		//private var _bg:ApplicationDisplayObject;
		
		public function ShopCustomerInfoMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
		{
			super(inMediatorName, inViewComponent);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			_xmlAgeRang = xmlManager.getData('ageRange', AssetLibID.XML_LANG_COMMON)[0];
			
			if (!_xmlAgeRang)
			{
				throw(new UninitializedError(multitonKey + ' : ' + mediatorName + ' : unable to get xml'));
			}
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			_window.btnClose.removeEventListener(ButtonEvent.CLICK, buttonEventHandler2);
			if (_window) appForm.removeApplicationChild(_window, false);
			
			stopListener()
			_window = null;
			form = null;
			_appForm = null;
			_userInfo = null;
		}
		
		override public function listNotificationInterests():Array 
		{
			return [NotificationType.ADD_FORM_SHOP_CUSTOMER_INFO, NotificationType.GET_CUSTOMER_INFO_FAIL, NotificationType.GET_CUSTOMER_INFO_SUCCESS];
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
				case NotificationType.ADD_FORM_SHOP_CUSTOMER_INFO:
				{
					//check if the data is sent by the related object, as this mediator is used multiple time, check if vo is already set
					if (!_userInfo)
					{
						_userInfo = vo.data as ShopMgtUserInfoVO;
						_window = assetManager.getData(SWFClassID.WINDOW_BASE, AssetLibID.AST_COMMON);
						
						if (_window)
						{
							var menuXML:XML = vo.settingXML;
							
							
							//_window.txtTitle.embedFonts = true;
							//_window.txtTitle.defaultTextFormat = Font.getTextFormat( { size:18, letterSpacing:2, font:Font.getDefaultFontByLang(language) } );
							setTextField(_window.txtTitle, language == Config.LANG_CODE_EN);
							
							//_window.txtTitle.text = getMessage(MessageID.WINDOW_CUSTOMER_INFO_TITLE, 'string', AssetLibID.XML_LANG_SHOP_MGT);
							
							appForm.addApplicationChild(_window, menuXML, false) as BaseWindow;
							_window.showPage(TweenerEffect.setAlpha(1));
							
							form = _window.addApplicationChild(vo.displayObject, null) as ShopMgtCustomerInfo;
							form.setInfo(_userInfo);
							
							_window.x = mainStage.stageWidth - _window.width >> 1;
							_window.y = mainStage.stageHeight - _window.height >> 1;
							_window.setSize(_window.width, _window.height + 30);
							
							
							var numItem:int = menuXML..button.length();
							for (var i:int = 0; i < numItem; i++)
							{
								var targetNode:XML = menuXML..button[i];
								if (targetNode && targetNode.@Class.length())
								{
									var b:ArrowTextButton = assetManager.getData(targetNode.@Class.toString(), AssetLibID.AST_COMMON);
									if (b)
									{
										b.txt.embedFonts = true;
										b.txt.defaultTextFormat = Font.getTextFormat({ size:14, letterSpacing:2, font:Font.getDefaultFontByLang(language) }) ;
										b.txt.textColor = 0xFFFFFF;
										b.txt.autoSize = TextFieldAutoSize.LEFT;
										
										Tweener.addTween(b, TweenerEffect.setGlow(0, '', 0x000000, 3, 5, 1) );
										
										b.addEventListener(ButtonEvent.CLICK, buttonEventHandler, false, 0, true);
										b.addEventListener(ButtonEvent.OVER, buttonEventHandler, false, 0, true);
										b.addEventListener(ButtonEvent.OUT, buttonEventHandler, false, 0, true);
										
										form.mcMenu.addApplicationChild(b, targetNode);
									}
								}
								
							}
							
							startListener();
							
							_window.isBusy = true;
						}
					}
					
					
					break;
				}
				case NotificationType.GET_CUSTOMER_INFO_SUCCESS:
				{
					form.updateInfo();
					form.txtAgeRange.text = _xmlAgeRang.*[int(_userInfo.ageRange)].@label;
					form.logo.x = 60;
					Tweener.addTween(form.logo, TweenerEffect.setGlow(1, 'easeOutSine', 0x000000));
					loadURLImage(form.logo, ImageVOService.getImageURL(httpHost, _userInfo.uid, FileType.PATH_USER_LOGO), FileType.PATH_IMAGE_SIZE_100);
					
					//no break needed
				}
				case NotificationType.GET_CUSTOMER_INFO_FAIL:
				{
					_window.isBusy = false;
					break;
				}
			}
			
			
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
			
			if (!_window.btnClose.hasEventListener(ButtonEvent.CLICK))
			{
				_window.btnClose.addEventListener(ButtonEvent.CLICK, buttonEventHandler2);
			}
		}
		
		override public function stopListener():void 
		{
			if (!form || !_window) return;
			
			form.mouseChildren = false;
			
			//_window.btnClose.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			
		}
		
		private function buttonEventHandler(e:ButtonEvent):void 
		{
			switch(e.type)
			{
				case ButtonEvent.OVER:
				case ButtonEvent.OUT:
				{
					var color:uint = e.type == ButtonEvent.OVER ? 0x009999 : 0x000000;
					Tweener.addTween(e.targetButton as DisplayObject, TweenerEffect.setGlow(1, 'easeOutSine', color, 3, 5, 1) );
					break;
				}
				case ButtonEvent.CLICK:
				{
					var b:Button = e.targetButton as Button;
					
					if (b.id == AssetID.BTN_CUSTOMER_CHAT)
					{
						sendNotification(WindowEvent.CREATE, form.vo, ShopMgtEvent.CUSTOMER_CHAT);
					}
					break;
				}
			}
		}
		
		private function buttonEventHandler2(e:ButtonEvent):void 
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
					//appForm.removeApplicationChild(form);
					//sendNotification(WindowEvent.CLOSE, form);
					sendNotification(WindowEvent.CLOSE, mediatorName);
					break;
				}
				/*case form.btnSend:
				{
					var result:* = form.isValid();
					if (result === true)
					{
						stopButtonListener();
						sendNotification(ShopMgtEvent.SHOP_UPDATE_ABOUT);
					}
					else
					{
						createFormAlert(MessageID.FORM_MISSING_INFO, (result as Vector.<DisplayObject>)[0]);
						
					}
					break;
				}*/
			}
		}
		
		private function createFormAlert(inMessageID:String, inItem:DisplayObject):void 
		{
			/*if (form)
			{
				_alert = form.addApplicationChild(Alert.create(new AlerterVO('', '', '', null, '', getMessage(inMessageID))), null) as FormAlerter;
				
				_alert.x = inItem.x + inItem.width;
				_alert.y = inItem.y - _alert.height;
			}*/
			
		}
		
		
	}
}