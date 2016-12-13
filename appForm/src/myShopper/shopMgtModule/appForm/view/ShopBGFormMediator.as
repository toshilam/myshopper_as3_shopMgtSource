package myShopper.shopMgtModule.appForm.view 
{
	import fl.data.DataProvider;
	import caurina.transitions.Tweener;
	import flash.display.DisplayObject;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.Config;
	import myShopper.common.data.AlerterVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.FileImageVO;
	import myShopper.common.display.ApplicationDisplayObject;
	import myShopper.common.display.Image;
	import myShopper.common.emun.AMFServicesErrorID;
	import myShopper.common.emun.AssetXMLNodeID;
	import myShopper.common.emun.FileType;
	import myShopper.common.emun.MessageID;
	import myShopper.common.emun.SWFClassID;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.events.FileEvent;
	import myShopper.common.events.WindowEvent;
	import myShopper.common.interfaces.IForm;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.interfaces.IVO;
	import myShopper.common.text.Font;
	import myShopper.common.utils.Alert;
	import myShopper.common.utils.TweenerEffect;
	import myShopper.fl.ApplicationBG;
	import myShopper.fl.button.SelectButton;
	import myShopper.fl.FormAlerter;
	import myShopper.fl.shopMgt.form.ShopMgtBGForm;
	import myShopper.fl.ui.DialogManager;
	import myShopper.fl.window.BaseWindow;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.FormMain;
	import myShopper.shopMgtModule.appForm.view.component.ApplicationForm;
	import org.puremvc.as3.multicore.interfaces.IContainerMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.interfaces.ITabFormMediator;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class ShopBGFormMediator extends ApplicationMediator implements IContainerMediator, ITabFormMediator 
	{
		private var _appForm:ApplicationForm;
		public function get appForm():ApplicationForm 
		{
			if (!_appForm) _appForm = (container as FormMain).appForm;
			return _appForm;
		}
		
		public function getForm():IForm { return form; }
		
		//a list of bg id
		private var arrDefaultBGID:Vector.<String>
		//the bg id which is selected by user, null if no bg is selected
		private var selectedDefaultBGID:String;
		
		private var _alert:FormAlerter;
		
		private var form:ShopMgtBGForm;
		private var _window:BaseWindow;
		
		public function ShopBGFormMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
		{
			super(inMediatorName, inViewComponent);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			arrDefaultBGID = new Vector.<String>();
			arrDefaultBGID.push(SWFClassID.BG0, SWFClassID.BG1, SWFClassID.BG2, SWFClassID.BG3, SWFClassID.BG4, SWFClassID.BG5, SWFClassID.BG7, SWFClassID.BG8);
			
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			_window.btnClose.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			if (_window) appForm.removeApplicationChild(_window, false);
			
			stopListener();
			selectedDefaultBGID = null;
			arrDefaultBGID.length = 0;
			arrDefaultBGID = null;
			_window = null;
			form = null;
			_alert = null;
		}
		
		override public function listNotificationInterests():Array 
		{
			return [NotificationType.ADD_FORM_SHOP_BG, NotificationType.UPDATE_BG_FAIL, NotificationType.UPDATE_BG_SUCCESS];
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
				case NotificationType.ADD_FORM_SHOP_BG:
				{
					_window = assetManager.getData(SWFClassID.WINDOW_BASE, AssetLibID.AST_COMMON);
					var bgVO:FileImageVO = vo.data as FileImageVO;
					
					if (_window && bgVO)
					{
						
						//_window.txtTitle.embedFonts = false;
						//_window.txtTitle.defaultTextFormat = Font.getTextFormat( { size:18, letterSpacing:2, font:SWFClassID.SANS } );
						setTextField(_window.txtTitle, language == Config.LANG_CODE_EN);
						
						appForm.addApplicationChild(_window, vo.settingXML, false) as BaseWindow;
						_window.showPage(TweenerEffect.setAlpha(1));
						
						form = _window.addApplicationChild(vo.displayObject, null) as ShopMgtBGForm;
						
						
						var xmlDisplayType:XML = xmlManager.getData(AssetXMLNodeID.IMAGE_POS_TYPE, AssetLibID.XML_LANG_COMMON)[0];
						if (xmlDisplayType)
						{
							form.cbDisplayType.dataProvider = new DataProvider(xmlDisplayType);
							
							CONFIG::mobile
							{
								new DialogManager().addHandler(form.cbDisplayType, (xmlDisplayType));
							}
						}
						else
						{
							echo('unable to retrieve xmlDisplayType list!');
						}
						form.setInfo(bgVO);
						//has selected default bg previously?
						var hasSelected:Boolean = false;
						
						//default bg
						for (var i:int = 0; i < arrDefaultBGID.length; i++)
						{
							var id:String = arrDefaultBGID[i];
							var b:SelectButton = assetManager.getData(SWFClassID.BUTTON_SELECT, AssetLibID.AST_COMMON);
							var bg:ApplicationDisplayObject = assetManager.getData(id, AssetLibID.AST_COMMON);
							
							if (b && bg)
							{
								b.id = bg.id = id;
								bg.height = 40;
								bg.width = 50;
								bg.x = 30;
								bg.y = 5;
								
								b.addEventListener(ButtonEvent.CLICK, defaultBGEventHandler, false, 0, true);
								b.addApplicationChild(bg, null, false);
								form.holder.addApplicationChild(b, null, false);
								
								Tweener.addTween(bg, TweenerEffect.setGlow(0, 'easeOutSine', 0x000000));
								
								//set first one is selected
								if (bgVO.name == id)
								{
									hasSelected = true;
									//if bg image was selected previously, check on default, else custom one
									b.dispatchEvent(new ButtonEvent(ButtonEvent.CLICK, b));
									form.rbDefault.dispatchEvent(new ButtonEvent(ButtonEvent.CLICK, form.rbDefault));
								}
							}
						}
						
						_window.x = mainStage.stageWidth - _window.width >> 1;
						_window.y = mainStage.stageHeight - _window.height >> 1;
						//_window.setSize(_window.width, 350);
						
						//if default bg was not selected previously, check on custom one
						if (!hasSelected)
						{
							form.rbDefault.dispatchEvent(new ButtonEvent(ButtonEvent.CLICK, form.rbCustom));
						}
						
						startListener();
					}
					
					break;
				}
				case NotificationType.UPDATE_BG_SUCCESS:
				{
					createFormAlert(getMessage(MessageID.SUCCESS_SAVE), form.mcFileLoader as ApplicationDisplayObject);
					startListener();
					break;
				}
				case NotificationType.UPDATE_BG_FAIL:
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
		
		private function defaultBGEventHandler(e:ButtonEvent):void 
		{
			var b:SelectButton
			var numItem:int = form.holder.subDisplayObjectList.length;
			
			//unselect all previous select button
			//NOTE : have to directly set value in r_select object, as no vo set into button
			for (var i:int = 0; i < numItem; i++)
			{
				b = form.holder.subDisplayObjectList.getDisplayObjectByIndex(i) as SelectButton;
				if (b)
				{
					
					b.r_select.isSelcted = false;
				}
			}
			
			b = e.targetButton as SelectButton;
			if (b)
			{
				b.r_select.isSelcted = true;
				selectedDefaultBGID = e.targetButton.id;
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
						
						
						var fVO:FileImageVO;
						//use custom bg
						if (form.rbCustom.isSelcted)
						{
							//var fileRef:FileReference = form.uploadFile;
							var bgVO:FileImageVO = form.vo as FileImageVO;
							fVO = new FileImageVO
							(
								mediatorName, 
								bgVO.data, 
								bgVO.name, 
								bgVO.type, 
								bgVO.size.toString(), 
								FileType.PATH_SHOP_BG,
								'',
								'',
								form.cbDisplayType.selectedIndex
							)
						}
						//user default bg
						else
						{
							if (selectedDefaultBGID && assetManager.hasData(selectedDefaultBGID, AssetLibID.AST_COMMON))
							{
								var bgByte:ByteArray = (assetManager.getData(selectedDefaultBGID, AssetLibID.AST_COMMON) as ApplicationDisplayObject).cloneAsByte();
								fVO = new FileImageVO
								(
									mediatorName, 
									bgByte, 
									selectedDefaultBGID, 
									'.jpg', 
									bgByte.bytesAvailable.toString(),
									FileType.PATH_SHOP_BG,
									'',
									'',
									ApplicationBG.POS_TYPE_FILL //for default bg, it always fill 
								)
							}
							else
							{
								createFormAlert(getMessage(MessageID.FORM_MISSING_INFO), (form.rbDefault));
								return;
							}
						}
						
						stopListener();
						_window.isBusy = true;
						
						sendNotification
						(
							ShopMgtEvent.SHOP_UPDATE_BG, 
							fVO
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