package myShopper.shopMgtModule.appForm.view 
{
	import caurina.transitions.Tweener;
	import flash.display.DisplayObject;
	import flash.printing.PrintJob;
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.Config;
	import myShopper.common.data.AlerterVO;
	import myShopper.common.data.DataVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.PrinterVO;
	import myShopper.common.data.service.PrinterVOService;
	import myShopper.common.emun.AlerterType;
	import myShopper.common.emun.AMFServicesErrorID;
	import myShopper.common.emun.MessageID;
	import myShopper.common.emun.SWFClassID;
	import myShopper.common.events.AlerterEvent;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.events.GoogleEvent;
	import myShopper.common.events.WindowEvent;
	import myShopper.common.interfaces.IForm;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.utils.Alert;
	import myShopper.common.utils.Tools;
	import myShopper.common.utils.TweenerEffect;
	import myShopper.fl.button.SelectButton;
	import myShopper.fl.button.SelectButton;
	import myShopper.fl.ConfirmAlerter;
	import myShopper.fl.FormAlerter;
	import myShopper.fl.shopMgt.form.ShopMgtPrintForm;
	import myShopper.fl.window.BaseWindow;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtModule.appForm.enum.AssetID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.FormMain;
	import myShopper.shopMgtModule.appForm.view.component.ApplicationForm;
	import org.puremvc.as3.multicore.interfaces.IContainerMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.interfaces.ITabFormMediator;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class ShopPrintFormMediator extends ApplicationMediator implements IContainerMediator, ITabFormMediator 
	{
		private var _appForm:ApplicationForm;
		public function get appForm():ApplicationForm 
		{
			if (!_appForm) _appForm = (container as FormMain).appForm;
			return _appForm;
		}
		
		public function getForm():IForm { return form; }
		
		
		private var _alert:FormAlerter;
		private var _confirmAlert:ConfirmAlerter;
		
		private var form:ShopMgtPrintForm;
		private var _window:BaseWindow;
		private var _printerVO:PrinterVO;
		
		public function ShopPrintFormMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
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
			_alert = null;
			_confirmAlert = null;
		}
		
		override public function listNotificationInterests():Array 
		{
			return	[
						NotificationType.ADD_FORM_SHOP_PRINT, 
						NotificationType.USER_GOOGLE_LOGIN_SUCCESS, 
						NotificationType.USER_GOOGLE_LOGIN_FAIL, 
						NotificationType.SEARCH_PRINTER_SUCCESS, 
						NotificationType.SEARCH_PRINTER_FAIL, 
						NotificationType.SET_PRINT_FAIL, 
						NotificationType.SET_PRINT_SUCCESS
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
				case NotificationType.ADD_FORM_SHOP_PRINT:
				{
					_window = assetManager.getData(SWFClassID.WINDOW_BASE, AssetLibID.AST_COMMON);
					_printerVO = vo.data as PrinterVO;
					
					if (_window && _printerVO)
					{
						//_window.txtTitle.embedFonts = false;
						//_window.txtTitle.defaultTextFormat = Font.getTextFormat( { size:18, letterSpacing:2, font:SWFClassID.SANS } );
						setTextField(_window.txtTitle, language == Config.LANG_CODE_EN);
						
						appForm.addApplicationChild(_window, vo.settingXML, false) as BaseWindow;
						_window.showPage(TweenerEffect.setAlpha(1));
						
						form = _window.addApplicationChild(vo.displayObject, null) as ShopMgtPrintForm;
						
						form.setInfo(_printerVO);
						
						_window.x = mainStage.stageWidth - _window.width >> 1;
						_window.y = mainStage.stageHeight - _window.height >> 1;
						//_window.setSize(_window.width, 350);
						_window.isBusy = true;
						
						refreshSystemPrinter();
						
						startListener();
						stopListener();
						
						//wait for search google print result
						return;
					}
					
					break;
				}
				case NotificationType.USER_GOOGLE_LOGIN_SUCCESS:
				{
					_window.isBusy = true;
					stopListener();
					sendNotification(GoogleEvent.PRINTER_SEARCH);
					break;
				}
				case NotificationType.SEARCH_PRINTER_SUCCESS:
				case NotificationType.USER_GOOGLE_LOGIN_FAIL:
				case NotificationType.SEARCH_PRINTER_FAIL:
				{
					_window.isBusy = false;
					startListener();
					refreshCloudPrinter();
					break;
				}
				case NotificationType.SET_PRINT_SUCCESS:
				{
					_window.isBusy = false;
					createFormAlert(getMessage(MessageID.SUCCESS_SAVE), form.btnSend);
					startListener();
					break;
				}
				case NotificationType.SET_PRINT_FAIL:
				{
					_window.isBusy = false;
					var result:ResultVO = note.getBody() as ResultVO;
					var code:String = result ? result.code : AMFServicesErrorID.DB_GET_DATA;
					//
					createFormAlert(getMessageByErrorCode(code) + '\n' + getMessage(MessageID.ERROR_TRY_LATER), form.btnSend);
					startListener()
					break;
				}
			}
			
			//if (_window) _window.isBusy = false;
		}
		
		private function refreshCloudPrinter():void 
		{
			if (_printerVO.isLogged)
			{
				var b:SelectButton;
				var numItem:int = PrinterVOService.getNumCloudPrinter(_printerVO);
				for (var i:int = 0; i < numItem; i++)
				{
					var pName:String = PrinterVOService.getCloudPrinterNameByIndex(_printerVO, i);
					var pID:String = PrinterVOService.getCloudPrinterIDByIndex(_printerVO, i);
					
					if (pName && pID)
					{
						b = form.cloudholder.addApplicationChild(assetManager.getData(SWFClassID.BUTTON_SELECT, AssetLibID.AST_COMMON), null, false) as SelectButton;
						
						b.setInfo(new DataVO(pID, pID, pName));
						b.txt.text = pName;
						
						if (_printerVO.selectedPrinterID == pID)
						{
							b.isSelected = true;
						}
					}
				}
				
				form.txtCloud.text = Tools.formatString( getMessage(MessageID.tt1037), [numItem]);
				
				if(!numItem) form.rbSystem.dispatchEvent(new ButtonEvent(ButtonEvent.CLICK, form.rbSystem));
			}
			else
			{
				form.txtCloud.text = Tools.formatString( getMessage(MessageID.tt1037), [0]) + '/' + getMessage(MessageID.tt1036);
				form.rbSystem.dispatchEvent(new ButtonEvent(ButtonEvent.CLICK, form.rbSystem));
			}
		}
		
		private function refreshSystemPrinter():void 
		{
			
				if (PrintJob.isSupported)
				{
					CONFIG::desktop
					{
						var numItem:int = PrintJob.printers.length;
						var selectedPrinterID:String = '';
						var b:SelectButton;
						
						for (var i:int = 0; i < numItem; i++)
						{
							var pName:String = PrintJob.printers[i];
							b = form.systemholder.addApplicationChild(assetManager.getData(SWFClassID.BUTTON_SELECT, AssetLibID.AST_COMMON), null, false) as SelectButton;
							
							b.setInfo(new DataVO(pName, pName, pName));
							b.txt.text = pName;
							
							if (_printerVO.selectedPrinterID == pName)
							{
								selectedPrinterID = pName;
								b.isSelected = true;
							}
						}
						
						//by default select first one if nothing selected
						if (!selectedPrinterID)
						{
							b = form.systemholder.subDisplayObjectList.getDisplayObjectByIndex(0) as SelectButton;
							if (b)
							{
								b.isSelected = true;
							}
						}
						
						form.txtSystem.text = Tools.formatString( getMessage(MessageID.tt1037), [numItem]);
					}
					
					echo('');
				}
				
				//CONFIG::web
				//{
					//form.txtSystem.text = 
				//}
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
			
			form.btnSend.startListener();
			form.btnSend.onMouseOver = function():void
			{
				Tweener.addTween(form.btnSend, TweenerEffect.setGlow(1, 'easeOutSine', 0xFF0000, 10, 5, 1));
			}
			form.btnSend.onMouseOut = function():void
			{
				Tweener.addTween(form.btnSend, TweenerEffect.resetGlow());
			}
			
			form.rbCloud.addEventListener(ButtonEvent.CLICK, rbEventHandler);
		}
		
		
		
		override public function stopListener():void
		{
			if (!form || !_window) return;
			
			form.mouseChildren = false;
			form.btnSend.alpha = .6;
			Tweener.addTween(form.btnSend, TweenerEffect.resetGlow());
			
			form.btnSend.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			form.btnSend.stopListener();
			form.btnSend.onMouseOver = null;
			form.btnSend.onMouseOut = null;
			
			form.rbCloud.removeEventListener(ButtonEvent.CLICK, rbEventHandler);
		}
		
		private function rbEventHandler(e:ButtonEvent):void 
		{
			if (e.targetButton === form.rbCloud)
			{
				if (!_printerVO.isLogged)
				{
					_confirmAlert = Alert.show
					(
						new AlerterVO
						(
							mediatorName, 
							AlerterType.CONFIRM, 
							'', 
							null, 
							getMessage(MessageID.CONFIRM_TITLE),
							getMessage(MessageID.tt1035)
						)
					) as ConfirmAlerter;
					
					if (_confirmAlert)
					{
						_confirmAlert.addEventListener(AlerterEvent.CANCEL, alertEventHandler);
						_confirmAlert.addEventListener(AlerterEvent.CONFIRM, alertEventHandler);
						_confirmAlert.addEventListener(AlerterEvent.CLOSE, alertEventHandler);
					}
					else
					{
						echo('rbEventHandler : fail creating Alert');
					}
				}
			}
		}
		
		private function alertEventHandler(e:AlerterEvent):void 
		{
			_confirmAlert.removeEventListener(AlerterEvent.CANCEL, alertEventHandler);
			_confirmAlert.removeEventListener(AlerterEvent.CONFIRM, alertEventHandler);
			_confirmAlert.removeEventListener(AlerterEvent.CLOSE, alertEventHandler);
			
			if (e.type == AlerterEvent.CONFIRM)
			{
				sendNotification
				(
					WindowEvent.CREATE,
					AssetID.BTN_GOOGLE_LOGIN,
					GoogleEvent.LOGIN
				);
			}
			else
			{
				form.rbSystem.dispatchEvent(new ButtonEvent(ButtonEvent.CLICK, form.rbSystem));
			}
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