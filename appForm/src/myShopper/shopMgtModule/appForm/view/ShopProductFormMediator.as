package myShopper.shopMgtModule.appForm.view 
{
	import fl.controls.ComboBox;
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
	import myShopper.common.data.FileImageVO;
	import myShopper.common.data.service.ShopperVOService;
	import myShopper.common.data.service.ShopVOService;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.shop.ShopProductFormVO;
	import myShopper.common.data.shopper.ShopperCategoryList;
	import myShopper.common.data.shopper.ShopperCategoryVO;
	import myShopper.common.data.shopper.ShopperProductList;
	import myShopper.common.data.shopper.ShopperProductTypeVO;
	import myShopper.common.data.shopper.ShopperProductVO;
	import myShopper.common.data.VO;
	import myShopper.common.display.ApplicationDisplayObject;
	import myShopper.common.display.FullscreenDisplayObject;
	import myShopper.common.display.Holder;
	import myShopper.common.display.Image;
	import myShopper.common.emun.AlerterType;
	import myShopper.common.emun.AssetXMLNodeID;
	import myShopper.common.emun.MessageID;
	import myShopper.common.emun.SWFClassID;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.events.FileEvent;
	import myShopper.common.events.WindowEvent;
	import myShopper.common.interfaces.IForm;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.interfaces.IVO;
	import myShopper.common.text.Font;
	import myShopper.common.utils.Alert;
	import myShopper.common.utils.TweenerEffect;
	import myShopper.fl.button.SelectButton;
	import myShopper.fl.FormAlerter;
	import myShopper.fl.shopMgt.form.ShopMgtProductForm;
	import myShopper.fl.shopper.ShopperProductWindow;
	import myShopper.fl.SystemFileLoader;
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
	
	public class ShopProductFormMediator extends ApplicationMediator implements IContainerMediator, ITabFormMediator 
	{
		private var _appForm:ApplicationForm;
		public function get appForm():ApplicationForm 
		{
			if (!_appForm) _appForm = (container as FormMain).appForm;
			return _appForm;
		}
		
		public function getForm():IForm { return form; }
		
		private var _alert:FormAlerter;
		
		private var form:ShopMgtProductForm;
		private var _window:BaseWindow;
		
		private var _cateogryWindow:ShopperProductWindow;
		private var _categoryList:ShopperCategoryList;
		
		private var _shopInfoVO:ShopInfoVO;
		
		public function ShopProductFormMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
		{
			super(inMediatorName, inViewComponent);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			var categoryList:ShopperCategoryList = voManager.getAsset(VOID.SHOPPER_PRODUCT_CATEGORY);
			_shopInfoVO = voManager.getAsset(VOID.MY_SHOP_INFO);
			
			if (!categoryList || !_shopInfoVO)
			{
				throw(new UninitializedError('ShopProfileFormMediator : onRegister : unable to retreve shopInfo vo'));
			}
			
			_categoryList = categoryList.clone() as ShopperCategoryList;
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
			var arr:Array = new Array();
			arr.push(NotificationType.ADD_FORM_SHOP_PRODUCT);
			
			if 		(mediatorName == MediatorID.SHOP_MGT_PRODUCT_CREATE /*|| mediatorName == MediatorID.SHOP_MGT_PRODUCT_CLONE*/)
			{
				arr.push(
							NotificationType.CREATE_PRODUCT_FAIL, 
							NotificationType.CREATE_PRODUCT_SUCCESS
						);
			}
			else if (mediatorName == MediatorID.SHOP_MGT_PRODUCT_UPDATE)
			{
				arr.push(
							NotificationType.UPDATE_PRODUCT_FAIL, 
							NotificationType.UPDATE_PRODUCT_SUCCESS,
							NotificationType.GET_PRODUCT_BY_NO_SUCCESS, //lang
							NotificationType.GET_PRODUCT_BY_NO_FAIL
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
				case NotificationType.ADD_FORM_SHOP_PRODUCT:
				{
					_window = assetManager.getData(SWFClassID.WINDOW_BASE, AssetLibID.AST_COMMON);
					
					if (_window)
					{
						var productVO:ShopProductFormVO = vo.data as ShopProductFormVO;
						
						//_window.txtTitle.embedFonts = true;
						//_window.txtTitle.defaultTextFormat = Font.getTextFormat( { size:18, letterSpacing:2, font:Font.getDefaultFontByLang(language) } );
						setTextField(_window.txtTitle, language == Config.LANG_CODE_EN);
						
						appForm.addApplicationChild(_window, vo.settingXML, false) as BaseWindow;
						_window.showPage(TweenerEffect.setAlpha(1));
						
						form = _window.addApplicationChild(vo.displayObject, null) as ShopMgtProductForm;
						form.setInfo(productVO);
						
						form.txtCategory.type = TextFieldType.DYNAMIC;
						form.txtCategory.addEventListener(FocusEvent.FOCUS_IN, productEventHandler, false, 0, true);
						form.txtCategory.addEventListener(MouseEvent.CLICK, productEventHandler, false, 0, true);
						form.txtCategory.text = ShopperVOService.getCategoryProductStringByNO(productVO.shopperCategoryNo, productVO.shopperProductNo, productVO.shopperProductTypeNo, _categoryList);
						form.txtTax.text = _shopInfoVO.tax.toString();
						
						if (mediatorName == MediatorID.SHOP_MGT_PRODUCT_CREATE && form.txtID.text)
						{
							//clear product id for clone mediator
							form.txtID.text = '';
						}
						
						form.btnStock.text = getMessage(MessageID.tt1030);
						form.btnStock.mouseEnabled = mediatorName == MediatorID.SHOP_MGT_PRODUCT_UPDATE;
						form.btnStock.alpha = form.btnStock.mouseEnabled ? 1 : .6;
						
						form.cbCurrency.enabled = false;
						var xmlCurrency:XML = xmlManager.getData(AssetXMLNodeID.CURRENCY, AssetLibID.XML_LANG_COMMON)[0];
						if (xmlCurrency)
						{
							var arrCBObject:Array = ShopperVOService.getArrayCBObjectByXML(xmlCurrency);
							
							form.cbCurrency.dataProvider = new DataProvider( arrCBObject );
						}
						else
						{
							stopListener();
							createFormAlert(getMessage(MessageID.ERROR_GET_DATA), form.cbCurrency);
							echo('unable to retrieve xmlDisplayType list!');
							return;
						}
						
						var numItem:int = 0;
						var i:int = 0;
						
						var xmlUnits:XML = xmlManager.getData(AssetXMLNodeID.UNITS, AssetLibID.XML_LANG_COMMON)[0];
						if (xmlUnits)
						{
							form.cbUnit.dataProvider = new DataProvider(xmlUnits);
							
							numItem = xmlUnits.item.length();
							for (i = 0; i < numItem; i++)
							{
								if (xmlUnits.item[i].@data.toString() == productVO.productUnit)
								{
									form.cbUnit.selectedIndex = i;
									break;
								}
							}
						}
						
						//select currency / by default HKD will be selected
						numItem = arrCBObject.length;
						for (i = 0; i < numItem; i++)
						{
							var node:Object = arrCBObject[i];
							if (node && String(node.data) == String(_shopInfoVO.currency))
							{
								form.cbCurrency.selectedItem = node;
								break;
							}
							
						}
						
						//set disoucnt
						var arrDiscountCBObject:Array = ShopperVOService.getArrayDiscountCBObject(0, 99);
						form.cbDiscount.dataProvider = new DataProvider( arrDiscountCBObject );
						form.cbDiscount.selectedIndex = productVO.productDiscount;
						discountEventHandler(null);
						
						CONFIG::mobile
						{
							new DialogManager().addHandler(form.cbDiscount, arrDiscountCBObject);
							new DialogManager().addHandler(form.cbUnit, xmlUnits);
						}
						
						//_window.setSize(
						_window.x = mainStage.stageWidth - _window.width >> 1;
						_window.y = mainStage.stageHeight - _window.height >> 1;
						//_window.setSize(form.width, form.height);
						
						startListener();
						
						var xmlLang:XML = xmlManager.getData(AssetXMLNodeID.LANGUAGES, AssetLibID.XML_LANG_COMMON)[0];
						if (xmlLang)
						{
							form.cbLang.dataProvider = new DataProvider(xmlLang);
							
							CONFIG::mobile
							{
								new DialogManager().addHandler(form.cbLang, xmlLang);
							}
							
							numItem = xmlLang.*.length();
							for (i = 0; i < numItem; i++)
							{
								if (xmlLang.*[i].@data.toString() == language)
								{
									form.cbLang.selectedIndex = i;
									break;
								}
							}
							
							getDataByLang(language);
							return;
						}
						else
						{
							echo('unable to retrieve xml country list!');
							stopListener();
							Alert.show(new AlerterVO('', AlerterType.MESSAGE, '', null, getMessage(MessageID.ERROR_TITLE), getMessage(MessageID.ERROR_GET_DATA)));
						}
					}
					
					break;
				}
				case NotificationType.GET_PRODUCT_BY_NO_SUCCESS:
				{
					startListener();
					break;
				}
				case NotificationType.GET_PRODUCT_BY_NO_FAIL:
				{
					Alert.show(new AlerterVO('', AlerterType.MESSAGE, '', null, getMessage(MessageID.ERROR_TITLE), getMessage(MessageID.ERROR_GET_DATA)));
					break;
				}
				
				case NotificationType.CREATE_PRODUCT_SUCCESS:
				{
					sendNotification(WindowEvent.CLOSE, mediatorName);
					break;
				}
				case NotificationType.UPDATE_PRODUCT_SUCCESS:
				{
					createFormAlert(getMessage(MessageID.SUCCESS_SAVE), form.txtID);
					startListener();
					break;
				}
				case NotificationType.CREATE_PRODUCT_FAIL:
				case NotificationType.UPDATE_PRODUCT_FAIL:
				{
					var result:ResultVO = note.getBody() as ResultVO;
					/*Alert.show
					(
						new AlerterVO
						(
							'', 
							'', 
							'', 
							null, 
							getMessage(MessageID.ERROR_TITLE), 
							getMessageByErrorCode(result.code) + '\nCODE:(' + result.code + ')\n' + getMessage(MessageID.CONTACT_US)
						) 
					);*/
					createFormAlert(getMessageByErrorCode(result.code) + '\n' + getMessage(MessageID.ERROR_TRY_LATER), form.txtID);
					startListener()
					break;
				}
			}
			
			if (_window) _window.isBusy = false;
		}
		
		private function getDataByLang(inLangCode:String):void 
		{
			if (_window)
			{
				form.vo.selectedLangCode = inLangCode;
				
				if (mediatorName == MediatorID.SHOP_MGT_PRODUCT_UPDATE)
				{
					stopListener();
					_window.isBusy = true;
					
					//no data need to be sent, as proxy already hold the vo object
					sendNotification( ShopMgtEvent.SHOP_GET_PRODUCT_BY_NO, form.vo, mediatorName );
				}
				
				
			}
		}
		
		private function productEventHandler(e:Event):void 
		{
			e.stopPropagation();
			
			if (!_cateogryWindow)
			{
				form.txtCategory.removeEventListener(FocusEvent.FOCUS_IN, productEventHandler);
				
				_cateogryWindow = assetManager.getData(SWFClassID.WINDOW_SHOPPER_PRODUCT, AssetLibID.AST_COMMON);
				Alert.show(new AlerterVO('', AlerterType.DISPLAY_OBJECT, '', _cateogryWindow,'','',null,false));
				
				_cateogryWindow.setSize(300, 350);
				_cateogryWindow.addPage(0);
				_cateogryWindow.addPage(1);
				_cateogryWindow.addPage(2);
				_cateogryWindow.currPageIndex = 0;
				_cateogryWindow.txtTitle.text = getMessage(MessageID.tt0017);
				_cateogryWindow.x = mainStage.stageWidth - _cateogryWindow.width >> 1;
				_cateogryWindow.y = mainStage.stageHeight - 350 >> 1;
				_cateogryWindow.isDragable = false;
				_cateogryWindow.dpiScale = Config.DEFAULT_APP_DPI;
				_cateogryWindow.btnClose.addEventListener(ButtonEvent.CLICK, categoryWindowEventHandler);
				_cateogryWindow.btnBack.addEventListener(ButtonEvent.CLICK, categoryWindowEventHandler);
				
				
				stopListener();
				form.mouseChildren = false;
				
				var numItem:int = _categoryList.length;
				for (var i:int = 0; i < numItem; i++)
				{
					var cVO:ShopperCategoryVO = _categoryList.getVO(i) as ShopperCategoryVO;
					var b:SelectButton = assetManager.getData(SWFClassID.BUTTON_SELECT, AssetLibID.AST_COMMON);
					
					if (cVO && b)
					{
						
						b.setInfo(cVO);
						b.addEventListener(ButtonEvent.CLICK, productCategoryEventHandler, false, 0, true);
						b.txt.text = cVO.categoryName;
						_cateogryWindow.addItem(0, b, null);
					}
					
				}
			}
			
			
			
		}
		
		private function productCategoryEventHandler(e:ButtonEvent):void 
		{
			var b:SelectButton;
			var cVO:ShopperCategoryVO;
			
			var holder:Holder = _cateogryWindow.getPage(0);
			var numItem:int = holder.subDisplayObjectList.length;
			var i:int = 0;
			
			//clear all previous select
			for (i = 0; i < numItem; i++)
			{
				b = holder.subDisplayObjectList.getDisplayObjectByIndex(i) as SelectButton;
				
				if (b)
				{
					b.isSelected = false;
				}
			}
			
			b = e.targetButton as SelectButton;
			b.isSelected = true;
			
			cVO = b.vo as ShopperCategoryVO;
			numItem = cVO.productList.length;
			_cateogryWindow.removeAllItem(1);
			for (i = 0; i < numItem; i++)
			{
				var pVO:ShopperProductVO = cVO.productList.getVO(i) as ShopperProductVO;
				b = assetManager.getData(SWFClassID.BUTTON_SELECT, AssetLibID.AST_COMMON);
				
				if (pVO && b)
				{
					b.setInfo(pVO);
					b.txt.text = pVO.productName;
					_cateogryWindow.addItem(1, b, null);
					
					if (pVO.productTypeList.length)
					{
						b.addEventListener(ButtonEvent.CLICK, productProductEventHandler, false, 0, true);
					}
					//if no product type vo exist, directly go to window event, and close window
					else
					{
						b.addEventListener(ButtonEvent.CLICK, categoryWindowEventHandler, false, 0, true);
					}
				}
			}
			
			_cateogryWindow.currPageIndex = 1;
		}
		
		private function productProductEventHandler(e:ButtonEvent):void 
		{
			var b:SelectButton;
			var pVO:ShopperProductVO;
			
			var holder:Holder = _cateogryWindow.getPage(1);
			var numItem:int = holder.subDisplayObjectList.length;
			var i:int = 0;
			
			//clear all previous select
			for (i = 0; i < numItem; i++)
			{
				b = holder.subDisplayObjectList.getDisplayObjectByIndex(i) as SelectButton;
				
				if (b)
				{
					b.isSelected = false;
				}
			}
			
			b = e.targetButton as SelectButton;
			b.isSelected = true;
			
			pVO = b.vo as ShopperProductVO;
			numItem = pVO.productTypeList.length;
			_cateogryWindow.removeAllItem(2);
			for (i = 0; i < numItem; i++)
			{
				var pTypeVO:ShopperProductTypeVO = pVO.productTypeList.getVO(i) as ShopperProductTypeVO;
				b = assetManager.getData(SWFClassID.BUTTON_SELECT, AssetLibID.AST_COMMON);
				
				if (pTypeVO && b)
				{
					b.setInfo(pTypeVO);
					b.addEventListener(ButtonEvent.CLICK, categoryWindowEventHandler, false, 0, true);
					b.txt.text = pTypeVO.productTypeName;
					_cateogryWindow.addItem(2, b, null);
				}
			}
			
			_cateogryWindow.currPageIndex = 2;
		}
		
		private function categoryWindowEventHandler(e:ButtonEvent):void 
		{
			if (!_cateogryWindow) return;
			
			var selectedVO:IVO;
			
			switch(e.targetButton)
			{
				case _cateogryWindow.btnClose:
				{
					_cateogryWindow.btnClose.removeEventListener(ButtonEvent.CLICK, categoryWindowEventHandler);
					
					
					break;
				}
				case _cateogryWindow.btnBack:
				{
					if (_cateogryWindow.currPageIndex)
					{
						_cateogryWindow.currPageIndex--;
					}
					
					return;
					break;
				}
				default:
				{
					var b:SelectButton = e.targetButton as SelectButton;
					if (b)
					{
						selectedVO = b.vo;
					}
				}
			}
			
			Alert.close();
			_cateogryWindow = null;
			
			startListener();
			form.mouseChildren = true;
			form.txtCategory.addEventListener(FocusEvent.FOCUS_IN, productEventHandler, false, 0, true);
			
			if (selectedVO)
			{
				
				form.txtCategory.text = ShopperVOService.getCategoryProductStringByVO(selectedVO);
				
				if (selectedVO is ShopperProductVO)
				{
					var pVO:ShopperProductVO = selectedVO as ShopperProductVO;
					ShopProductFormVO(form.vo).shopperCategoryNo = pVO.categoryVO.categoryNo;
					ShopProductFormVO(form.vo).shopperProductNo = pVO.productNo;
				}
				else if (selectedVO is ShopperProductTypeVO)
				{
					var pTypeVO:ShopperProductTypeVO = selectedVO as ShopperProductTypeVO;
					ShopProductFormVO(form.vo).shopperCategoryNo = pTypeVO.productVO.categoryVO.categoryNo;
					ShopProductFormVO(form.vo).shopperProductNo = pTypeVO.productVO.productNo;
					ShopProductFormVO(form.vo).shopperProductTypeNo = pTypeVO.productTypeNo;
					
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
			
			if (!_window.btnClose.hasEventListener(ButtonEvent.CLICK))
			{
				_window.btnClose.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
			}
			
			var mcFileLoader1:ApplicationDisplayObject = form.mcFileLoader1 as ApplicationDisplayObject;
			var mcFileLoader2:ApplicationDisplayObject = form.mcFileLoader2 as ApplicationDisplayObject;
			var mcFileLoader3:ApplicationDisplayObject = form.mcFileLoader3 as ApplicationDisplayObject;
			
			//form.cbLang.enabled = true;
			form.cbLang.addEventListener(Event.CHANGE, languageEventHandler, false, 0, true);
			
			form.cbDiscount.addEventListener(Event.CHANGE, discountEventHandler, false, 0, true);
			form.txtPrice.addEventListener(Event.CHANGE, discountEventHandler, false, 0, true);
			form.txtTax.addEventListener(Event.CHANGE, discountEventHandler, false, 0, true);
			
			form.btnSend.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
			form.btnStock.addEventListener(ButtonEvent.CLICK, buttonEventHandler, false, 0, true);
			
			mcFileLoader1.addEventListener(FileEvent.SIZE_OVER, fileEventHandler, false, 0, true);
			mcFileLoader2.addEventListener(FileEvent.SIZE_OVER, fileEventHandler, false, 0, true);
			mcFileLoader3.addEventListener(FileEvent.SIZE_OVER, fileEventHandler, false, 0, true);
			form.mcFileLoader1.logo.addEventListener(MouseEvent.CLICK, logoEventHandler, false, 0, true);
			form.mcFileLoader2.logo.addEventListener(MouseEvent.CLICK, logoEventHandler, false, 0, true);
			form.mcFileLoader3.logo.addEventListener(MouseEvent.CLICK, logoEventHandler, false, 0, true);
			form.mcFileLoader1.logo.useHandCursor = form.mcFileLoader2.logo.useHandCursor = form.mcFileLoader3.logo.useHandCursor = true;
			form.mcFileLoader1.logo.buttonMode = form.mcFileLoader2.logo.buttonMode = form.mcFileLoader3.logo.buttonMode = true;
			
			
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
		
		private function discountEventHandler(e:Event):void 
		{
			if (!form) return;
			
			var discount:int = form.cbDiscount.selectedIndex;
			var price:Number = isNaN(Number(form.txtPrice.text)) ? 0 : Number(form.txtPrice.text);
			var tax:Number = isNaN(Number(form.txtTax.text)) ? 0 : Number(form.txtTax.text);
			
			var discountedPrice:Number = ShopVOService.getDiscountedPrice(price, discount);
			var taxPrice:Number = ShopVOService.getTaxPrice(discountedPrice, tax);
			
			form.txtDiscountedPrice.text = discountedPrice.toString();
			form.txtTaxPrice.text = taxPrice.toString();
		}
		
		private function logoEventHandler(e:MouseEvent):void 
		{
			var image:Image = e.currentTarget as Image;
			if (image)
			{
				var iVO:FileImageVO = image.vo as FileImageVO;
				if (iVO && iVO.data)
				{
					var fsObject:FullscreenDisplayObject = new FullscreenDisplayObject();
					var tempImage:Image = new Image();
					tempImage.setInfo(iVO.clone());
					fsObject.addApplicationChild(tempImage, null, false);
					
					mainStage.addEventListener(MouseEvent.MOUSE_UP, stageEventHandler, false, 0, true);
					
					Alert.show
					(
						new AlerterVO
						(
							image.id,
							AlerterType.DISPLAY_OBJECT,
							'',
							fsObject
						)
					);
				}
			}
		}
		
		private function stageEventHandler(e:MouseEvent):void 
		{
			mainStage.removeEventListener(MouseEvent.MOUSE_UP, stageEventHandler);
			Alert.close();
		}
		
		override public function stopListener():void
		{
			if (!form || !_window) return;
			
			form.mouseChildren = false;
			form.btnSend.alpha = .6;
			Tweener.addTween(form.btnSend, TweenerEffect.resetGlow());
			
			//form.cbLang.enabled = false;
			form.cbLang.removeEventListener(Event.CHANGE, languageEventHandler);
			
			form.cbDiscount.removeEventListener(Event.CHANGE, discountEventHandler);
			form.txtPrice.removeEventListener(Event.CHANGE, discountEventHandler);
			form.txtTax.removeEventListener(Event.CHANGE, discountEventHandler);
			
			//_window.btnClose.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			
			var mcFileLoader1:ApplicationDisplayObject = form.mcFileLoader1 as ApplicationDisplayObject;
			var mcFileLoader2:ApplicationDisplayObject = form.mcFileLoader2 as ApplicationDisplayObject;
			var mcFileLoader3:ApplicationDisplayObject = form.mcFileLoader3 as ApplicationDisplayObject;
			
			
			form.btnSend.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			form.btnStock.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			
			mcFileLoader1.removeEventListener(FileEvent.SIZE_OVER, fileEventHandler);
			mcFileLoader2.removeEventListener(FileEvent.SIZE_OVER, fileEventHandler);
			mcFileLoader3.removeEventListener(FileEvent.SIZE_OVER, fileEventHandler);
			form.mcFileLoader1.logo.removeEventListener(MouseEvent.CLICK, logoEventHandler);
			form.mcFileLoader2.logo.removeEventListener(MouseEvent.CLICK, logoEventHandler);
			form.mcFileLoader3.logo.removeEventListener(MouseEvent.CLICK, logoEventHandler);
			form.mcFileLoader1.logo.useHandCursor = form.mcFileLoader2.logo.useHandCursor = form.mcFileLoader3.logo.useHandCursor = false;
			form.mcFileLoader1.logo.buttonMode = form.mcFileLoader2.logo.buttonMode = form.mcFileLoader3.logo.buttonMode = false;
			
			form.btnSend.stopListener();
			form.btnSend.onMouseOver = null;
			form.btnSend.onMouseOut = null;
		}
		
		private function languageEventHandler(e:Event):void 
		{
			if (e.target is ComboBox)
			{
				getDataByLang((e.target as ComboBox).selectedItem.data);
			}
		}
		
		private function fileEventHandler(e:FileEvent):void 
		{
			if (!form || !_window) return;
			var loader:SystemFileLoader = e.loader as SystemFileLoader;
			if (loader)
			{
				createFormAlert(getMessage(MessageID.ERROR_UPLOAD_IMAGE_OVER_SIZE), loader);
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
				case form.btnStock:
				{
					sendNotification(WindowEvent.CREATE, form.vo, ShopMgtEvent.SHOP_CREATE_PRODUCT_STOCK);
					break;
				}
				case form.btnSend:
				{
					var result:* = form.isValid();
					if (result === true)
					{
						stopListener();
						if (_window) _window.isBusy = true;
						if (mediatorName == MediatorID.SHOP_MGT_PRODUCT_CREATE)
						{
							sendNotification(ShopMgtEvent.SHOP_CREATE_PRODUCT);
						}
						/*else if (mediatorName == MediatorID.SHOP_MGT_PRODUCT_CLONE)
						{
							sendNotification(ShopMgtEvent.SHOP_CLONE_PRODUCT);
						}*/
						else if (mediatorName == MediatorID.SHOP_MGT_PRODUCT_UPDATE)
						{
							sendNotification(ShopMgtEvent.SHOP_UPDATE_PRODUCT);
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
				_alert.x = inItem.x + inItem.width;
				_alert.y = inItem.y - _alert.height;
				_alert = null;
			}
			
		}
		
		
	}
}