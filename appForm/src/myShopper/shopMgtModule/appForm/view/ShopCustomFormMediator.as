package myShopper.shopMgtModule.appForm.view 
{
	import fl.controls.ComboBox;
	import fl.data.DataProvider;
	import caurina.transitions.Tweener;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import myShopper.common.Config;
	import myShopper.common.data.AlerterVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.emun.AlerterType;
	import myShopper.common.emun.AssetXMLNodeID;
	import myShopper.common.emun.MessageID;
	import myShopper.common.emun.SWFClassID;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.events.WindowEvent;
	import myShopper.common.interfaces.IForm;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.interfaces.IVO;
	import myShopper.common.text.Font;
	import myShopper.common.utils.Alert;
	import myShopper.common.utils.TweenerEffect;
	import myShopper.fl.FormAlerter;
	import myShopper.fl.shopMgt.form.ShopMgtCustomPageForm;
	import myShopper.fl.ui.DialogManager;
	import myShopper.fl.window.BaseWindow;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtModule.appForm.enum.MediatorID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.FormMain;
	import myShopper.shopMgtModule.appForm.view.component.ApplicationForm;
	import org.puremvc.as3.multicore.interfaces.IContainerMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.interfaces.ITabFormMediator;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class ShopCustomFormMediator extends ApplicationMediator implements IContainerMediator, ITabFormMediator
	{
		private var _appForm:ApplicationForm;
		public function get appForm():ApplicationForm 
		{
			if (!_appForm) _appForm = (container as FormMain).appForm;
			return _appForm;
		}
		
		public function getForm():IForm { return form; }
		
		private var _alert:FormAlerter;
		
		private var form:ShopMgtCustomPageForm;
		private var _window:BaseWindow;
		//private var _bg:ApplicationDisplayObject;
		
		public function ShopCustomFormMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
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
			_window.btnClose.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			if (_window) appForm.removeApplicationChild(_window, false);
			
			stopListener()
			_window = null;
			form = null;
			_alert = null;
		}
		
		override public function listNotificationInterests():Array 
		{
			var arr:Array = new Array();
			
			if (mediatorName == MediatorID.SHOP_MGT_CUSTOM_CREATE)
			{
				arr.push(NotificationType.ADD_FORM_SHOP_CUSTOM, NotificationType.CREATE_CUSTOM_FAIL, NotificationType.CREATE_CUSTOM_SUCCESS);
			}
			else if (mediatorName == MediatorID.SHOP_MGT_CUSTOM_UPDATE)
			{
				arr.push
				(
					NotificationType.ADD_FORM_SHOP_CUSTOM, 
					NotificationType.UPDATE_CUSTOM_FAIL, 
					NotificationType.UPDATE_CUSTOM_SUCCESS,
					NotificationType.GET_CUSTOM_BY_NO_SUCCESS, //lang
					NotificationType.GET_CUSTOM_BY_NO_FAIL
				);
			}
			
			return arr;
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
				case NotificationType.ADD_FORM_SHOP_CUSTOM:
				{
					_window = assetManager.getData(SWFClassID.WINDOW_BASE, AssetLibID.AST_COMMON);
					
					if (_window)
					{
						//_window.txtTitle.embedFonts = false;
						//_window.txtTitle.defaultTextFormat = Font.getTextFormat( { size:18, letterSpacing:2, font:SWFClassID.SANS } );
						setTextField(_window.txtTitle, language == Config.LANG_CODE_EN);
						
						appForm.addApplicationChild(_window, vo.settingXML, false) as BaseWindow;
						_window.showPage(TweenerEffect.setAlpha(1));
						
						form = _window.addApplicationChild(vo.displayObject, null) as ShopMgtCustomPageForm;
						form.setInfo(vo.data as IVO);
						
						//_window.setSize(
						_window.x = mainStage.stageWidth - _window.width >> 1;
						_window.y = mainStage.stageHeight - _window.height >> 1;
						//_window.setSize(form.width, form.height);
						
						var xmlLang:XML = xmlManager.getData(AssetXMLNodeID.LANGUAGES, AssetLibID.XML_LANG_COMMON)[0];
						if (xmlLang)
						{
							form.cbLang.dataProvider = new DataProvider(xmlLang);
							
							CONFIG::mobile
							{
								new DialogManager().addHandler(form.cbLang, xmlLang);
							}
							
							var numItem:int = xmlLang.*.length();
							for (var i:int = 0; i < numItem; i++)
							{
								if (xmlLang.*[i].@data.toString() == language)
								{
									form.cbLang.selectedIndex = i;
									break;
								}
							}
							
							getDataByLang(language);
						}
						else
						{
							echo('unable to retrieve xml country list!');
							stopListener();
							Alert.show(new AlerterVO('', AlerterType.MESSAGE, '', null, getMessage(MessageID.ERROR_TITLE), getMessage(MessageID.ERROR_GET_DATA)));
						}
						
						startListener();
					}
					
					break;
				}
				case NotificationType.CREATE_CUSTOM_SUCCESS:
				case NotificationType.UPDATE_CUSTOM_SUCCESS:
				{
					createFormAlert(getMessage(MessageID.SUCCESS_SAVE), form.txtTitle);
					//startButtonListener();
					break;
				}
				case NotificationType.CREATE_CUSTOM_FAIL:
				case NotificationType.UPDATE_CUSTOM_FAIL:
				{
					//var result:ResultVO = note.getBody() as ResultVO;
					/*Alert.show
					(
						new AlerterVO
						(
							'', 
							AlerterType.MESSAGE, 
							'', 
							null, 
							getMessage(MessageID.ERROR_TITLE), 
							getMessage(MessageID.ERROR_GET_DATA) + '<br />' + getMessage(MessageID.ERROR_TRY_LATER)
						) 
					);*/
					createFormAlert(getMessage(MessageID.ERROR_GET_DATA) + '\n' + getMessage(MessageID.ERROR_TRY_LATER), form.txtTitle);
					startListener()
					break;
				}
				case NotificationType.GET_CUSTOM_BY_NO_SUCCESS:
				{
					startListener();
					break;
				}
				case NotificationType.GET_CUSTOM_BY_NO_FAIL:
				{
					//Alert.show(new AlerterVO('', AlerterType.MESSAGE, '', null, getMessage(MessageID.ERROR_TITLE), getMessage(MessageID.ERROR_GET_DATA)));
					createFormAlert(getMessage(MessageID.ERROR_GET_DATA) + '\n' + getMessage(MessageID.ERROR_TRY_LATER), form.txtTitle);
					break;
				}
			}
			
			if (_window) _window.isBusy = false;
		}
		
		private function languageEventHandler(e:Event):void 
		{
			if (e.target is ComboBox)
			{
				getDataByLang((e.target as ComboBox).selectedItem.data);
			}
		}
		
		private function getDataByLang(inLangCode:String):void 
		{
			if (_window)
			{
				form.vo.selectedLangCode = inLangCode;
				
				if (mediatorName == MediatorID.SHOP_MGT_CUSTOM_UPDATE)
				{
					stopListener();
					_window.isBusy = true;
					
					//no data need to be sent, as proxy already hold the vo object
					sendNotification( ShopMgtEvent.SHOP_GET_CUSTOM_BY_NO, form.vo, mediatorName );
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
			form.btnSend.alpha = 1;
			
			//form.cbLang.enabled = true;
			form.cbLang.addEventListener(Event.CHANGE, languageEventHandler, false, 0, true);
			
			if (!_window.btnClose.hasEventListener(ButtonEvent.CLICK))
			{
				_window.btnClose.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
			}
			
			form.btnSend.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
			
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
			
			//form.cbLang.enabled = false;
			form.cbLang.removeEventListener(Event.CHANGE, languageEventHandler);
			
			//_window.btnClose.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			form.btnSend.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			
			form.btnSend.stopListener();
			form.btnSend.onMouseOver = null;
			form.btnSend.onMouseOut = null;
		}
		
		
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
						if (mediatorName == MediatorID.SHOP_MGT_CUSTOM_CREATE)
						{
							sendNotification(ShopMgtEvent.SHOP_CREATE_CUSTOM);
						}
						else if (mediatorName == MediatorID.SHOP_MGT_CUSTOM_UPDATE)
						{
							sendNotification(ShopMgtEvent.SHOP_UPDATE_CUSTOM);
						}
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
				_alert.updateInfo();
				_alert.x = inItem.x + inItem.width;
				_alert.y = inItem.y - _alert.height;
				_alert = null;
			}
			
		}
		
		
	}
}