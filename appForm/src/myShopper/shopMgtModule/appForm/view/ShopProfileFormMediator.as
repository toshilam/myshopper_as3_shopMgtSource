package myShopper.shopMgtModule.appForm.view 
{
	import fl.data.DataProvider;
	import caurina.transitions.Tweener;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextFieldType;
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.Config;
	import myShopper.common.data.AlerterVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.service.ShopperVOService;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.shopper.ShopperCategoryList;
	import myShopper.common.data.shopper.ShopperCategoryVO;
	import myShopper.common.emun.AlerterType;
	import myShopper.common.emun.AssetXMLNodeID;
	import myShopper.common.emun.MessageID;
	import myShopper.common.emun.SWFClassID;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.events.ShopEvent;
	import myShopper.common.events.VOEvent;
	import myShopper.common.events.WindowEvent;
	import myShopper.common.interfaces.IForm;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.interfaces.IVO;
	import myShopper.common.text.Font;
	import myShopper.common.utils.Alert;
	import myShopper.common.utils.TweenerEffect;
	import myShopper.fl.button.SelectButton;
	import myShopper.fl.FormAlerter;
	import myShopper.fl.shopMgt.form.ShopMgtProfileForm;
	import myShopper.fl.ui.DialogManager;
	import myShopper.fl.window.BaseWindow;
	import myShopper.fl.window.ScrollWindow;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtModule.appForm.enum.MediatorID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.FormMain;
	import myShopper.shopMgtModule.appForm.view.component.ApplicationForm;
	import org.puremvc.as3.multicore.interfaces.IContainerMediator;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.interfaces.ITabFormMediator;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class ShopProfileFormMediator extends ApplicationMediator implements IContainerMediator, ITabFormMediator
	{
		private var _appForm:ApplicationForm;
		public function get appForm():ApplicationForm 
		{
			if (!_appForm) _appForm = (container as FormMain).appForm;
			return _appForm;
		}
		
		public function getForm():IForm { return form; }
		
		//private var _messageService:MessageService;
		private var _alert:FormAlerter;
		
		private var form:ShopMgtProfileForm;
		private var _window:BaseWindow;
		private var _shopVO:ShopInfoVO;
		private var _cateogryWindow:ScrollWindow;
		private var _categoryList:ShopperCategoryList;
		
		private var _selectedCountryID:String;
		private var _selectedStateID:String;
		private var _selectedCityID:String;
		
		public function ShopProfileFormMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
		{
			super(inMediatorName, inViewComponent);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			
			var categoryList:ShopperCategoryList = voManager.getAsset(VOID.SHOPPER_PRODUCT_CATEGORY);
			
			//_shopVO = voManager.getAsset(VOID.MY_SHOP_INFO);
			
			if (/*!(_shopVO is ShopInfoVO) ||*/ !categoryList)
			{
				throw(new UninitializedError('ShopProfileFormMediator : onRegister : unable to retreve shopInfo vo'));
			}
			
			//_shopVO.addEventListener(VOEvent.VALUE_CHANGED, voEventHandler);
			_categoryList = categoryList.clone() as ShopperCategoryList;
		}
		
		private function voEventHandler(e:VOEvent):void 
		{
			if (e.propertyName == 'infoApproved' && _window && _window.XMLSetting is XML)
			{
				var title:String = getMessage(_window.XMLSetting.@text);
				if (mediatorName == MediatorID.SHOP_MGT_PROFILE_UPDATE)
				{
					title += ' (' + _shopVO.shopNo + ')';
				}
				
				if (_shopVO.infoApproved)
				{
					_window.txtTitle.text = title;
				}
				else
				{
					var str:String = '(' + getMessage(myShopper.shopMgtCommon.emun.MessageID.SHOP_INFO_BEING_APPROVED, 'string', AssetLibID.XML_LANG_SHOP_MGT) + ')';
					_window.txtTitle.text = title + str;
					_window.txtTitle.setTextFormat(Font.getTextFormat({ color:0xff0000, size:12, font:SWFClassID.SANS }), _window.txtTitle.length - str.length, _window.txtTitle.length) ;
				}
			}
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			_window.btnClose.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			if (_window) appForm.removeApplicationChild(_window, false);
			
			_shopVO.removeEventListener(VOEvent.VALUE_CHANGED, voEventHandler);
			stopListener()
			_window = null;
			form = null;
			_alert = null;
			_shopVO = null;
		}
		
		override public function listNotificationInterests():Array 
		{
			var arr:Array = new Array
			(
				NotificationType.ADD_FORM_SHOP_PROFILE, 
				NotificationType.GET_COUNTRY_FAIL,
				NotificationType.GET_COUNTRY_SUCCESS,
				NotificationType.GET_STATE_FAIL,
				NotificationType.GET_STATE_SUCCESS,
				NotificationType.GET_CITY_FAIL,
				NotificationType.GET_CITY_SUCCESS,
				NotificationType.GET_AREA_FAIL,
				NotificationType.GET_AREA_SUCCESS
			);
			
			if (mediatorName == MediatorID.SHOP_MGT_PROFILE_CREATE)
			{
				arr.push(NotificationType.CREATE_PROFILE_FAIL, NotificationType.CREATE_PROFILE_SUCCESS);
			}
			else if (mediatorName == MediatorID.SHOP_MGT_PROFILE_UPDATE)
			{
				arr.push(NotificationType.UPDATE_PROFILE_FAIL, NotificationType.UPDATE_PROFILE_SUCCESS);
			}
			
			return arr;
			
		}

		override public function handleNotification(note:INotification):void 
		{
			var body:Object = note.getBody();
			var vo:DisplayObjectVO = body as DisplayObjectVO;
			
			var arrData:Array;
			var numItem:int;
			var i:int;
			var item:Object;
			var data:String;
			
			/*if (!vo)
			{
				echo('handleNotification : unknown data type : ' + body);
			}*/
			
			switch(note.getName())
			{
				case NotificationType.ADD_FORM_SHOP_PROFILE:
				{
					_window = assetManager.getData(SWFClassID.WINDOW_BASE, AssetLibID.AST_COMMON);
					_shopVO = vo.data as ShopInfoVO;
					
					if (_window && _shopVO)
					{
						//var shopInfo:ShopInfoVO = vo.data as ShopInfoVO;
						_shopVO.addEventListener(VOEvent.VALUE_CHANGED, voEventHandler);
						
						//_window.txtTitle.embedFonts = false;
						//_window.txtTitle.defaultTextFormat = Font.getTextFormat( { size:18, letterSpacing:2, font:SWFClassID.SANS } );
						setTextField(_window.txtTitle, language == Config.LANG_CODE_EN);
						
						appForm.addApplicationChild(_window, vo.settingXML, false) as BaseWindow;
						_window.showPage(TweenerEffect.setAlpha(1));
						
						if (mediatorName == MediatorID.SHOP_MGT_PROFILE_CREATE)
						{
							_window.txtTitle.appendText(' (' + getMessage(myShopper.shopMgtCommon.emun.MessageID.PROFILE_CREATE, 'string', AssetLibID.XML_LANG_SHOP_MGT) + ')');
						}
						
						form = _window.addApplicationChild(vo.displayObject, null) as ShopMgtProfileForm;
						form.setInfo(/*vo.data as IVO*/ _shopVO);
						form.txtProduct.type = TextFieldType.DYNAMIC;
						form.txtProduct.addEventListener(FocusEvent.FOCUS_IN, productEventHandler, false, 0, true);
						form.txtProduct.addEventListener(MouseEvent.CLICK, productEventHandler, false, 0, true);
						
						_window.x = mainStage.stageWidth - _window.width >> 1;
						_window.y = mainStage.stageHeight - _window.height >> 1;
						
						
						startListener();
						
						
						/////////////////////////////////////////////////////////////
						//CHANGED : 26/03/2014
						//add all countries, instead of active countries
						//disable state, and city
						
						//_window.isBusy = true;
						
						//form.cbCountry.addEventListener(Event.CHANGE, cbEventHandler, false, 0, true);
						//form.cbState.addEventListener(Event.CHANGE, cbEventHandler, false, 0, true);
						//form.cbCity.addEventListener(Event.CHANGE, cbEventHandler, false, 0, true);
						
						//sendNotification(ShopEvent.GET_COUNTRY);
						
						form.cbState.enabled = form.cbCity.enabled = form.cbArea.enabled = false;
						var xmlCountry:XML = xmlManager.getData(AssetXMLNodeID.COUNTRIES, myShopper.common.emun.AssetLibID.XML_LANG_COMMON)[0];
						
						form.cbCountry.dataProvider = new DataProvider(xmlCountry);
						//var targetCountryXML:XML = xmlCountry..item.(@data == _shopVO.country)[0];
						//form.cbCountry.selectedLabel = targetCountryXML.@label;
						
						numItem = xmlCountry..item.length();
						for (i = 0; i < numItem; i++)
						{
							var targetXML:XML = xmlCountry..item[i];
							if (targetXML.@data == _shopVO.country)
							{
								form.cbCountry.selectedIndex = i;
							}
						}
						
						
						CONFIG::mobile
						{
							new DialogManager().addHandler(form.cbCountry, xmlCountry);
						}
						////////////////////////////////////////////////////////////
						return;
					}
					
					break;
				}
				case NotificationType.GET_COUNTRY_SUCCESS:
				{
					arrData = note.getBody() as Array;
					if (arrData)
					{
						numItem = arrData.length;
						
						form.cbCountry.dataProvider = new DataProvider(arrData);
						
						if (numItem)
						{
							stopListener();
							
							for (i = 0; i < numItem; i++)
							{
								item = arrData[i];
								data = item['data'];
								if (data == _shopVO.country)
								{
									form.cbCountry.selectedItem = item;
									_selectedCountryID = data;
									sendNotification(ShopEvent.GET_STATE, _selectedCountryID);
									return;
									
								}
							}
							
							
							//if no matched data, get the first item data
							_selectedCountryID = arrData[0].data;
							sendNotification(ShopEvent.GET_STATE, _selectedCountryID);
							return;
						}
						
						
						
					}
					break;
				}
				case NotificationType.GET_STATE_SUCCESS:
				{
					arrData = note.getBody() as Array;
					if (arrData)
					{
						numItem = arrData.length;
						
						form.cbState.dataProvider = new DataProvider(arrData);
						
						if (numItem)
						{
							stopListener();
							
							for (i = 0; i < numItem; i++)
							{
								item = arrData[i];
								data = item['data'];
								if (data == _shopVO.state)
								{
									form.cbState.selectedItem = item;
									_selectedStateID = data;
									sendNotification(ShopEvent.GET_CITY, [_selectedCountryID, _selectedStateID]);
									return;
								}
							}
							
							
							
							//if no matched data, get the first item data
							_selectedStateID = arrData[0].data;
							sendNotification(ShopEvent.GET_CITY, [_selectedCountryID, _selectedStateID]);
							return;
						}
						
					}
					break;
				}
				case NotificationType.GET_CITY_SUCCESS:
				{
					arrData = note.getBody() as Array;
					if (arrData)
					{
						numItem = arrData.length;
						
						form.cbCity.dataProvider = new DataProvider(arrData);
						
						if (numItem)
						{
							stopListener();
							
							for (i = 0; i < numItem; i++)
							{
								item = arrData[i];
								data = item['data'];
								if (data == _shopVO.city)
								{
									form.cbCity.selectedItem = item;
									_selectedCityID = data;
									sendNotification(ShopEvent.GET_AREA, [_selectedCountryID, _selectedStateID, _selectedCityID]);
									return;
								}
							}
							
							//if no matched data, get the first item data
							_selectedCityID = arrData[0].data;
							sendNotification(ShopEvent.GET_AREA, [_selectedCountryID, _selectedStateID, _selectedCityID]);
							return;
						}
						
					}
					else
					{
						Alert.show(new AlerterVO('', AlerterType.MESSAGE, '', null, getMessage(MessageID.ERROR_TITLE), getMessage(MessageID.ERROR_GET_DATA)));
					}
					break;
				}
				case NotificationType.GET_AREA_SUCCESS:
				{
					arrData = note.getBody() as Array;
					if (arrData)
					{
						numItem = arrData.length;
						form.cbArea.alpha = 1;
						form.cbArea.dataProvider = new DataProvider(arrData);
						
						startListener();
						
						for (i = 0; i < numItem; i++)
						{
							item = arrData[i];
							data = item['data'];
							if (data == _shopVO.area)
							{
								form.cbArea.selectedItem = item;
								break;
							}
						}
					}
					break;
				}
				case NotificationType.GET_AREA_FAIL: //if get area fail, it means no area data exist under this city
				{
					form.cbArea.dataProvider = new DataProvider();
					form.cbArea.alpha = .5;
					startListener();
					break;
				}
				case NotificationType.UPDATE_PROFILE_SUCCESS:
				case NotificationType.CREATE_PROFILE_SUCCESS:
				{
					createFormAlert(getMessage(MessageID.SUCCESS_SAVE), form.txtPayPalEmail);
					startListener();
					break;
				}
				case NotificationType.GET_COUNTRY_FAIL:
				case NotificationType.GET_STATE_FAIL:
				case NotificationType.GET_CITY_FAIL:
				case NotificationType.UPDATE_PROFILE_FAIL:
				case NotificationType.CREATE_PROFILE_FAIL:
				{
					//var result:ResultVO = note.getBody() as ResultVO;
					/*Alert.show
					(
						new AlerterVO
						(
							'', 
							'', 
							'', 
							null, 
							getMessage(MessageID.ERROR_TITLE), 
							getMessage(MessageID.ERROR_GET_DATA) 
						) 
					);*/
					createFormAlert(getMessage(MessageID.ERROR_GET_DATA) + '\n' + getMessage(MessageID.ERROR_TRY_LATER), form.txtPayPalEmail);
					startListener()
					break;
				}
			}
			
			if (!_shopVO.infoApproved)
			{
				voEventHandler(new VOEvent(VOEvent.VALUE_CHANGED, null, null, 'infoApproved'));
			}
			
			if (_window) _window.isBusy = false;
		}
		
		private function cbEventHandler(e:Event):void 
		{
			if (form)
			{
				switch(e.target)
				{
					case form.cbCountry:
					{
						stopListener();
						_selectedCountryID = form.cbCountry.selectedItem.data;
						sendNotification(ShopEvent.GET_STATE, _selectedCountryID);
						break;
					}
					case form.cbState:
					{
						stopListener();
						_selectedStateID = form.cbState.selectedItem.data;
						sendNotification(ShopEvent.GET_CITY, [_selectedCountryID, _selectedStateID]);
						break;
					}
					case form.cbCity:
					{
						stopListener();
						_selectedCityID = form.cbCity.selectedItem.data;
						sendNotification(ShopEvent.GET_AREA, [_selectedCountryID, _selectedStateID, _selectedCityID]);
						break;
					}
				}
			}
		}
		
		private function productEventHandler(e:Event):void 
		{
			e.stopPropagation();
			
			if (!_cateogryWindow)
			{
				form.txtProduct.removeEventListener(FocusEvent.FOCUS_IN, productEventHandler);
				
				_cateogryWindow = Alert.show(new AlerterVO('', AlerterType.DISPLAY_OBJECT, '', assetManager.getData(SWFClassID.WINDOW_SCROLL, AssetLibID.AST_COMMON),'','',null, false)) as ScrollWindow;
				//_cateogryWindow = appForm.addApplicationChild(assetManager.getData(SWFClassID.WINDOW_SCROLL, AssetLibID.AST_COMMON), null, true) as ScrollWindow;
				_cateogryWindow.setSize(300, 350);
				_cateogryWindow.txtTitle.text = getMessage(MessageID.tt0017);
				_cateogryWindow.x = mainStage.stageWidth - _cateogryWindow.width >> 1;
				_cateogryWindow.y = mainStage.stageHeight - 350 >> 1;
				_cateogryWindow.isDragable = false;
				_cateogryWindow.btnClose.addEventListener(ButtonEvent.CLICK, categoryWindowEventHandler);
				_cateogryWindow.dpiScale = Config.DEFAULT_APP_DPI;
				stopListener();
				form.mouseChildren = false;
				
				var numItem:int = _categoryList.length;
				for (var i:int = 0; i < numItem; i++)
				{
					var cVO:ShopperCategoryVO = _categoryList.getVO(i) as ShopperCategoryVO;
					var b:SelectButton = assetManager.getData(SWFClassID.BUTTON_SELECT, AssetLibID.AST_COMMON);
					
					if (cVO && b)
					{
						b.setInfo(cVO)
						b.txt.text = cVO.categoryName;
						
						if(_shopVO.productTypeList.getVOByCategoryNo(cVO.categoryNo) != null)
						{
							b.isSelected = true;
						}
						
						
						
						_cateogryWindow.holder.addApplicationChild(b, null, false);
					}
					
				}
			}
			
			
			
		}
		
		private function categoryWindowEventHandler(e:ButtonEvent):void 
		{
			_cateogryWindow.btnClose.removeEventListener(ButtonEvent.CLICK, categoryWindowEventHandler);
			
			Alert.close();
			_cateogryWindow = null;
			
			startListener();
			form.mouseChildren = true;
			form.txtProduct.addEventListener(FocusEvent.FOCUS_IN, productEventHandler, false, 0, true);
			
			//remove all previous selected
			_shopVO.productTypeList.clear();
			var numItem:int = _categoryList.length;
			for (var i:int = 0; i < numItem; i++)
			{
				var cVO:ShopperCategoryVO = _categoryList.getVO(i) as ShopperCategoryVO;
				if (cVO && cVO.isSelected)
				{
					_shopVO.productTypeList.addVO( cVO );
				}
			}
			
			form.txtProduct.text = ShopperVOService.getCategoryStringBySelectedShopperCategory(_shopVO.productTypeList);
			
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
			//form.cbArea.enabled = form.cbCity.enabled = form.cbCountry.enabled = form.cbState.enabled = true;
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
			//form.cbArea.enabled = form.cbCity.enabled = form.cbCountry.enabled = form.cbState.enabled = false;
			
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
						sendNotification(mediatorName == MediatorID.SHOP_MGT_PROFILE_UPDATE ? ShopMgtEvent.SHOP_UPDATE_PROFILE : ShopMgtEvent.SHOP_CREATE_PROFILE);
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
				_alert.mouseEnabled = _alert.mouseChildren = false;
				
				_alert.x = inItem.x + inItem.width;
				_alert.y = inItem.y - _alert.height;
			}
			
		}
		
		
	}
}