package myShopper.shopMgtModule.appForm.view 
{
	import caurina.transitions.Tweener;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.net.FileReference;
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.Config;
	import myShopper.common.data.AlerterVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.FileImageVO;
	import myShopper.common.display.ApplicationDisplayObject;
	import myShopper.common.emun.AMFServicesErrorID;
	import myShopper.common.emun.FileType;
	import myShopper.common.emun.MessageID;
	import myShopper.common.emun.SWFClassID;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.events.FileEvent;
	import myShopper.common.events.WindowEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.interfaces.IVO;
	import myShopper.common.text.Font;
	import myShopper.common.utils.Alert;
	import myShopper.common.utils.TweenerEffect;
	import myShopper.fl.FormAlerter;
	import myShopper.fl.shopMgt.form.ShopMgtLogoForm;
	import myShopper.fl.window.BaseWindow;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.FormMain;
	import myShopper.shopMgtModule.appForm.view.component.ApplicationForm;
	import org.puremvc.as3.multicore.interfaces.IContainerMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class ShopLogoFormMediator extends ApplicationMediator implements IContainerMediator 
	{
		private var _appForm:ApplicationForm;
		public function get appForm():ApplicationForm 
		{
			if (!_appForm) _appForm = (container as FormMain).appForm;
			return _appForm;
		}
		
		private var _alert:FormAlerter;
		
		private var form:ShopMgtLogoForm;
		private var _window:BaseWindow;
		
		public function ShopLogoFormMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
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
			
			stopListener();
			
			_window = null;
			form = null;
			_alert = null;
		}
		
		override public function listNotificationInterests():Array 
		{
			return [NotificationType.ADD_FORM_SHOP_LOGO, NotificationType.UPDATE_LOGO_FAIL, NotificationType.UPDATE_LOGO_SUCCESS];
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
				case NotificationType.ADD_FORM_SHOP_LOGO:
				{
					_window = assetManager.getData(SWFClassID.WINDOW_BASE, AssetLibID.AST_COMMON);
					
					if (_window)
					{
						//_window.txtTitle.embedFonts = false;
						//_window.txtTitle.defaultTextFormat = Font.getTextFormat( { size:18, letterSpacing:2, font:SWFClassID.SANS } );
						setTextField(_window.txtTitle, language == Config.LANG_CODE_EN);
						
						appForm.addApplicationChild(_window, vo.settingXML, false) as BaseWindow;
						_window.showPage(TweenerEffect.setAlpha(1));
						
						form = _window.addApplicationChild(vo.displayObject, null) as ShopMgtLogoForm;
						form.setInfo(vo.data as IVO);
						
						_window.x = mainStage.stageWidth - _window.width >> 1;
						_window.y = mainStage.stageHeight - _window.height >> 1;
						_window.setSize(_window.width, 350);
						
						startListener();
					}
					
					break;
				}
				case NotificationType.UPDATE_LOGO_SUCCESS:
				{
					createFormAlert(getMessage(MessageID.SUCCESS_SAVE), form.mcFileLoader as ApplicationDisplayObject);
					startListener();
					break;
				}
				case NotificationType.UPDATE_LOGO_FAIL:
				{
					var result:ResultVO = note.getBody() as ResultVO;
					var code:String = result ? result.code : AMFServicesErrorID.DB_GET_DATA;
					/*Alert.show
					(
						new AlerterVO
						(
							'', 
							'', 
							'', 
							null, 
							getMessage(MessageID.ERROR_TITLE), 
							getMessageByErrorCode(code) + '\nCODE:(' + code + ')\n' + getMessage(MessageID.CONTACT_US)
						) 
					);*/
					createFormAlert(getMessageByErrorCode(code) + '\n' + getMessage(MessageID.ERROR_TRY_LATER), form.mcFileLoader as ApplicationDisplayObject);
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
			//form.btnBrowse.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
			(form.mcFileLoader as ApplicationDisplayObject).addEventListener(FileEvent.SIZE_OVER, fileEventHandler);
			
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
			//form.btnBrowse.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			(form.mcFileLoader as ApplicationDisplayObject).removeEventListener(FileEvent.SIZE_OVER, fileEventHandler);
			form.btnSend.stopListener();
			form.btnSend.onMouseOver = null;
			form.btnSend.onMouseOut = null;
		}
		
		private function fileEventHandler(e:FileEvent):void 
		{
			if (!form || !_window) return;
			createFormAlert(getMessage(MessageID.ERROR_UPLOAD_IMAGE_OVER_SIZE), form.mcFileLoader as ApplicationDisplayObject);
			
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
						//var fileRef:FileReference = form.uploadFile;
						var bgVO:FileImageVO = form.vo as FileImageVO;
						sendNotification
						(
							ShopMgtEvent.SHOP_UPDATE_LOGO, 
							new FileImageVO
							(
								mediatorName, 
								bgVO.data, 
								bgVO.name, 
								bgVO.type, 
								bgVO.size.toString(), 
								FileType.PATH_SHOP_LOGO
							)
						);
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