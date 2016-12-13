package myShopper.shopMgtModule.appForm.view 
{
	import caurina.transitions.Tweener;
	import fl.data.DataProvider;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import myShopper.common.Config;
	import myShopper.common.data.AlerterVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.service.ImageVOService;
	import myShopper.common.data.service.ShopVOService;
	import myShopper.common.data.service.UserVOService;
	import myShopper.common.data.shop.ShopCategoryFormVO;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.shop.ShopOrderExtraVO;
	import myShopper.common.data.shop.ShopProductFormVO;
	import myShopper.common.data.user.UserShoppingCartProductVO;
	import myShopper.common.data.VOList;
	import myShopper.common.display.ApplicationDisplayObject;
	import myShopper.common.display.button.Button;
	import myShopper.common.display.Menu;
	import myShopper.common.emun.AssetXMLNodeID;
	import myShopper.common.emun.FileType;
	import myShopper.common.emun.OrderExtraTypeID;
	import myShopper.common.emun.SWFClassID;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.events.VOEvent;
	import myShopper.common.events.WindowEvent;
	import myShopper.common.interfaces.IForm;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.interfaces.IVO;
	import myShopper.common.resources.AssetManager;
	import myShopper.common.text.Font;
	import myShopper.common.utils.Alert;
	import myShopper.common.utils.Tools;
	import myShopper.common.utils.TweenerEffect;
	import myShopper.fl.button.OrderExtraButton;
	import myShopper.fl.FormAlerter;
	import myShopper.fl.shopMgt.button.ShopMgtCategoryButton;
	import myShopper.fl.shopMgt.button.ShopMgtOrderProductButton;
	import myShopper.fl.shopMgt.button.ShopMgtProductButton;
	import myShopper.fl.shopMgt.button.ShopMgtSalesProductButton;
	import myShopper.fl.shopMgt.button.ShopMgtSProductButton;
	import myShopper.fl.shopMgt.form.ShopMgtSalesForm;
	import myShopper.fl.shopMgt.SalesWindow;
	import myShopper.fl.ui.DialogManager;
	import myShopper.shopMgtCommon.data.ShopMgtSalesVO;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.emun.MessageID;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtCommon.ShopMgtShopInfoVO;
	import myShopper.shopMgtModule.appForm.enum.AssetClassID;
	import myShopper.shopMgtModule.appForm.enum.MediatorID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.FormMain;
	import myShopper.shopMgtModule.appForm.model.service.PrintVOService;
	import myShopper.shopMgtModule.appForm.model.service.SalesVOService;
	import myShopper.shopMgtModule.appForm.view.component.ApplicationForm;
	import org.puremvc.as3.multicore.interfaces.IContainerMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.interfaces.ITabFormMediator;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class ShopSalesFormMediator extends ApplicationMediator implements IContainerMediator, ITabFormMediator
	{
		private var _appForm:ApplicationForm;
		public function get appForm():ApplicationForm 
		{
			if (!_appForm) _appForm = (container as FormMain).appForm;
			return _appForm;
		}
		
		public function getForm():IForm { return form; }
		
		private var _shopInfoVO:ShopMgtShopInfoVO;
		private var _alert:FormAlerter;
		
		private var form:ShopMgtSalesForm;
		private var _window:SalesWindow;
		private var _salesVO:ShopMgtSalesVO;
		private var _salesService:SalesVOService;
		private var _xmlPayType:XML;
		private var _xmlPrintType:XML;
		
		//used for remote for store product barcode/qrcode before product list downloaded
		private var _subscribedBarCode:Array
		//private var _printService:PrintVOService;
		
		public function ShopSalesFormMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
		{
			super(inMediatorName, inViewComponent);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			_shopInfoVO = voManager.getAsset(VOID.MY_SHOP_INFO);
			_xmlPayType = xmlManager.getData(AssetXMLNodeID.PAY_TYPE, AssetLibID.XML_LANG_COMMON)[0];
			_xmlPrintType = xmlManager.getData(AssetXMLNodeID.PRINT_TYPE, AssetLibID.XML_LANG_COMMON)[0];
			
			
			if (!_shopInfoVO || !_xmlPayType || !_xmlPrintType)
			{
				echo('onRegister : unable to get shop info vo/xml');
				throw(new UninitializedError('onRegister : unable to get shop info vo/xml'));
			}
			
			//_printService = new PrintVOService(assetManager as AssetManager,  appForm);
			_salesService = new SalesVOService(_shopInfoVO.productCategoryList);
			
			_subscribedBarCode = new Array();
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			_window.btnClose.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			if (_window) appForm.removeApplicationChild(_window, false);
			
			stopListener();
			_shopInfoVO = null;
			_window = null;
			form = null;
			_alert = null;
			_salesService.clear();
			_salesService = null;
			
			_subscribedBarCode.length = 0;
			_subscribedBarCode = null;
			//_printService.clear();
			//_printService = null;
		}
		
		override public function listNotificationInterests():Array 
		{
			var arr:Array;
			
			arr = 	[
						NotificationType.ADD_DISPLAY_SALES, 
						NotificationType.CREATE_SALES_SUCCESS, 
						NotificationType.CREATE_SALES_FAIL, 
						NotificationType.RESULT_GET_CATEGORY_PRODUCT,
						NotificationType.ADD_SALES_PRODUCT
					];
			
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
			var noteName:String = note.getName();
			var numItem:int = 0;
			var i:int = 0;
			switch(noteName)
			{
				case NotificationType.ADD_DISPLAY_SALES:
				{
					_window = vo.displayObject as SalesWindow;
					_salesVO = vo.data as ShopMgtSalesVO;
					
					if (_window)
					{
						//_window.txtTitle.embedFonts = false;
						//_window.txtTitle.defaultTextFormat = Font.getTextFormat( { size:18, letterSpacing:2, font:SWFClassID.SANS } );
						setTextField(_window.txtTitle, language == Config.LANG_CODE_EN);
						appForm.addApplicationChild(_window, vo.settingXML, false) as SalesWindow;
						_window.showPage(TweenerEffect.setAlpha(1));
						
						form = _window.addApplicationChild(assetManager.getData(AssetClassID.FORM_SHOP_SALES, AssetLibID.AST_SHOP_MGT), null, false) as ShopMgtSalesForm;
						form.setInfo(_salesVO);
						form.cbPayMethod.dataProvider = new DataProvider(_xmlPayType);
						form.cbPrintType.dataProvider = new DataProvider(_xmlPrintType);
						form.btnAddExtra.text = getMessage(myShopper.common.emun.MessageID.tt1027);
						form.onStageResize(mainStage);
						
						//TODO : print POS size
						//form.cbPrintType.enabled = false;
						
						_window.setSize(form.width, form.height + 20);
						_window.x = mainStage.stageWidth - _window.width >> 1;
						_window.y = mainStage.stageHeight - _window.height >> 1;
						_window.isBusy = true;
						
						startListener();
						saleFormHandler();
						
						CONFIG::mobile
						{
							new DialogManager().addHandler(form.cbPayMethod, _xmlPayType);
							new DialogManager().addHandler(form.cbPrintType, _xmlPrintType);
						}
					}
					
					break;
				}
				case NotificationType.CREATE_SALES_SUCCESS:
				case NotificationType.CREATE_SALES_FAIL:
				{
					startListener();
					_window.isBusy = false;
					
					if (noteName == NotificationType.CREATE_SALES_SUCCESS)
					{
						createFormAlert(getMessage(myShopper.common.emun.MessageID.SUCCESS_TITLE));
						refreshCategoryPage();
						(form.holder.content as Menu).removeAllButton()
						form.mcProductSearch.txtName.text = '';
						form.setInfo(_salesVO);
						form.cbPayMethod.selectedIndex = 0;
						saleFormHandler();
						
					}
					else
					{
						createFormAlert(getMessage(myShopper.common.emun.MessageID.ERROR_GET_DATA));
					}
					
					mainStage.focus = form.mcProductSearch.txtName;
					form.btnSend.onMouseOut();
					
					break;
				}
				case NotificationType.RESULT_GET_CATEGORY_PRODUCT:
				{
					refreshCategoryPage();
					
					_window.isBusy = false;
					
					if (_subscribedBarCode.length)
					{
						note.setBody(_subscribedBarCode.splice(0,1)[0]);
						_subscribedBarCode.length = 0;
						
					}
					else
					{
						break;
					}
				}
				case NotificationType.ADD_SALES_PRODUCT:
				{
					var barcode:String = String(note.getBody());
					
					
					if (_shopInfoVO.productCategoryList.length)
					{
						var voList:VOList = _salesService.getProductByKeyword(String(note.getBody()));
						numItem = voList.length;
						
						if (!numItem)
						{
							form.mcProductSearch.txtName.text = barcode;
						}
						else if (numItem == 1)
						{
							buttonEventHandler2(new ButtonEvent(ButtonEvent.CLICK, null, voList.getVO(0)));
						}
						else
						{
							refreshProductPage(voList);
						}
					}
					else
					{
						_subscribedBarCode[0] = barcode;
					}
					
					
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
			form.btnAddExtra.addEventListener(ButtonEvent.CLICK, buttonEventHandler, false, 0, true);
			
			form.mcProductSearch.btnClear.addEventListener(ButtonEvent.CLICK, searchFormButtonHandler, false, 0, true);
			form.mcProductSearch.btnBack.addEventListener(ButtonEvent.CLICK, searchFormButtonHandler, false, 0, true);
			form.mcProductSearch.txtName.addEventListener(Event.CHANGE, searchEventHandler, false, 0, true);
			form.txtPaid.addEventListener(Event.CHANGE, saleFormHandler, false, 0, true);
			form.txtShippingFee.addEventListener(Event.CHANGE, shippingFeeHandler, false, 0, true);
			
			_salesVO.extraList.addEventListener(VOEvent.VO_ADDED, voEventHandler, false, 0, true);
			_salesVO.extraList.addEventListener(VOEvent.VO_REMOVED, voEventHandler, false, 0, true);
		}
		
		private function shippingFeeHandler(e:Event):void 
		{
			saleFormHandler();
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
			
			form.mcProductSearch.btnClear.removeEventListener(ButtonEvent.CLICK, searchFormButtonHandler);
			form.mcProductSearch.btnBack.removeEventListener(ButtonEvent.CLICK, searchFormButtonHandler);
			form.mcProductSearch.txtName.removeEventListener(Event.CHANGE, searchEventHandler);
			form.txtPaid.removeEventListener(Event.CHANGE, saleFormHandler);
			form.txtShippingFee.removeEventListener(Event.CHANGE, shippingFeeHandler);
			
			_salesVO.extraList.removeEventListener(VOEvent.VO_ADDED, voEventHandler);
			_salesVO.extraList.removeEventListener(VOEvent.VO_REMOVED, voEventHandler);
		}
		
		private function voEventHandler(e:VOEvent):void 
		{
			var oVO:ShopOrderExtraVO = e.vo as ShopOrderExtraVO;
			
			if (e.type == VOEvent.VO_ADDED)
			{
				
				if (oVO)
				{
					var ob:OrderExtraButton = assetManager.getData(SWFClassID.BUTTON_ORDER_EXTRA, AssetLibID.AST_COMMON);
					form.holder.addApplicationChild(ob, null, false);
					
					var sign:String = oVO.type == OrderExtraTypeID.FEE ? '+' : '-';
					ob.btnClose.addEventListener(ButtonEvent.CLICK, orderExtraEventHandler, false, 0, true);
					ob.setInfo(oVO);
					ob.txtTotal.text = Tools.getCurrencyCodeByNo(_salesVO.shopCurrency) + ': ' + sign + oVO.total.toString();
					ob.stopListener();
					
				}
			}
			else
			{
				var numItem:int = form.holder.subDisplayObjectList.length;
				for (var i:int = 0; i < numItem; i++)
				{
					var b:Button = form.holder.subDisplayObjectList.getDisplayObjectByIndex(i) as Button;
					if (b && b is OrderExtraButton && OrderExtraButton(b).vo === oVO)
					{
						form.holder.removeApplicationChild(b, false);
						break;
					}
				}
			}
			
			form.mcScrollBar.refresh();
			saleFormHandler();
		}
		
		private function orderExtraEventHandler(e:ButtonEvent):void 
		{
			var b:OrderExtraButton = (e.targetButton as Button).parent as OrderExtraButton;
			if (b && b.vo is ShopOrderExtraVO)
			{
				_salesVO.extraList.removeVO(b.vo);
			}
		}
		
		private function searchEventHandler(e:Event):void 
		{
			var strSearch:String = form.mcProductSearch.txtName.text;
			if (strSearch && strSearch.length)
			{
				var voList:VOList = _salesService.getProductByKeyword(strSearch);
				var numItem:int = voList.length;
				//if (numItem)
				//{
					refreshProductPage(voList);
					
				//}
				form.mcProductSearch.txtRemark.text = Tools.formatString(getMessage(myShopper.shopMgtCommon.emun.MessageID.TOTAL_PRODUCT, 'string', AssetLibID.XML_LANG_SHOP_MGT), [numItem.toString()]);
				
			}
			else
			{
				refreshCategoryPage();
			}
		}
		
		private function searchFormButtonHandler(e:ButtonEvent):void 
		{
			var targetButton:Button = e.targetButton as Button;
			if (targetButton === form.mcProductSearch.btnClear || targetButton === form.mcProductSearch.btnBack)
			{
				form.mcProductSearch.txtName.text = '';
				refreshCategoryPage();
			}
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
				case form.btnAddExtra:
				{
					sendNotification
					(
						WindowEvent.CREATE,
						_salesVO,
						ShopMgtEvent.SHOP_ADD_SALES_EXTRA
					);
					break;
				}
				case form.btnSend:
				{
					var result:* = form.isValid();
					if (result === true)
					{
						stopListener();
						if (_window) _window.isBusy = true;
						
						//to be handled by proxy
						/*if (!CONFIG::mobile)
						{
							if (form.rbPrint.isSelcted)
							{
								_printService.order(_salesVO, _shopInfoVO, form.cbPrintType.selectedIndex + 1);
							}
						}*/
						
						
						sendNotification(ShopMgtEvent.SHOP_CREATE_SALES, _salesVO);
					}
					else
					{
						createFormAlert(getMessage(MessageID.ERROR_SALES_PAID, 'string', AssetLibID.XML_LANG_SHOP_MGT));
					}
					break;
				}
			}
		}
		
		private function createFormAlert(inMessage:String/*, inItem:DisplayObject*/):void 
		{
			if (form)
			{
				_alert = form.addApplicationChild(Alert.create(new AlerterVO('', '', '', null, '', inMessage)), null) as FormAlerter;
				
				_alert.x = form.width - _alert.width >> 1;
				_alert.y = form.height - _alert.width >> 1;
				_alert.autoClose(5000);
			}
			
		}
		
		private function refreshCategoryPage():void 
		{
			var searchMenu:Menu = form.mcProductSearch.holder.content as Menu;
			searchMenu.removeAllButton(); //refresh
			
			form.mcProductSearch.txtRemark.text = '';
			form.mcProductSearch.btnBack.alpha = .5;
			form.mcProductSearch.btnBack.mouseEnabled = false;
			
			var numItem:int = _shopInfoVO.productCategoryList.length;
			for (var i:int = 0; i < numItem; i++)
			{
				var b:ShopMgtCategoryButton = assetManager.getData(AssetClassID.BTN_SHOP_CATEGORY, AssetLibID.AST_SHOP_MGT);
				var categoryVO:ShopCategoryFormVO = _shopInfoVO.productCategoryList.getVO(i) as ShopCategoryFormVO;
				
				if (b && categoryVO && b.setInfo(categoryVO))
				{
					searchMenu.addApplicationChild(b, null, false);
					//b.mouseChildren = false;
					b.txtNo.text = String(i + 1) + '.';
					//b.txtTotal.embedFonts = false;
					//b.txtTotal.defaultTextFormat = Font.getTextFormat( { font:SWFClassID.SANS } );
					setTextField(b.txtTotal, false, Font.getTextFormat( { font:SWFClassID.SANS } ));
					b.txtTotal.autoSize = TextFieldAutoSize.LEFT;
					b.txtTotal.text = Tools.formatString(getMessage(myShopper.shopMgtCommon.emun.MessageID.TOTAL_PRODUCT, 'string', AssetLibID.XML_LANG_SHOP_MGT), [categoryVO.numberOfProduct.toString()]);
					b.btnDelete.visible = b.btnModify.visible = /*b.btnMore.visible =*/ false;
					b.btnMore.y -= 25;
					b.btnMore.scaleX = b.btnMore.scaleY = 1.3;
					b.addEventListener(ButtonEvent.UP, buttonEventHandler2, false, 0, true);
					
					b.updateInfo();
				}
				else
				{
					echo('listNotificationInterests : vo added : fail setting vo to button : ' + b);
				}
				
			}
			
			form.mcProductSearch.mcScrollBar.refresh();
		}
		
		private function refreshProductPage(inVOList:VOList):void 
		{
			var searchMenu:Menu = form.mcProductSearch.holder.content as Menu;
			searchMenu.removeAllButton(); //refresh
			
			form.mcProductSearch.btnBack.alpha = 1;
			form.mcProductSearch.btnBack.mouseEnabled = true;
			
			var numItem:int = inVOList.length;
			if (numItem)
			{
				for (var i:int = 0; i < numItem; i++)
				{
					var b:ShopMgtSProductButton = assetManager.getData(AssetClassID.BTN_SHOP_SEARCH_PRODUCT, AssetLibID.AST_SHOP_MGT_FORM);
					var productVO:ShopProductFormVO = inVOList.getVO(i) as ShopProductFormVO;
					
					if (b && productVO && b.setInfo(productVO))
					{
						searchMenu.addApplicationChild(b, null, false);
						//b.txtNo.text = String(i + 1) + '.';
						//b.btnClone.visible = b.btnDelete.visible = b.btnModify.visible = b.btnShare.visible = false;
						
						/*if (!productVO.getPhotoVO().data)
						{
							loadURLImage(b.logo, ImageVOService.getImageURL(httpHost, _shopInfoVO.shopNo, FileType.PATH_SHOP_PRODUCT, [productVO.productNo]), FileType.PATH_IMAGE_SIZE_100);
							Tweener.addTween(b.logo, TweenerEffect.setGlow(0, '', 0x000000, 10));
						}*/
						
						
						b.btnAdd.addEventListener(ButtonEvent.UP, buttonEventHandler2, false, 0, true);
					}
					else
					{
						echo('buttonEventHandler : vo added : fail setting vo to button : ' + b);
					}
					
				}
				
				form.mcProductSearch.mcScrollBar.refresh();
			}
		}
		
		private function buttonEventHandler2(e:ButtonEvent):void 
		{
			if (form.mcProductSearch.mcScrollBar.hasDraged) return;
			
			var targetButton:Button = e.targetButton as Button;
			
			if (targetButton is ShopMgtCategoryButton)
			{
				var categoryVO:ShopCategoryFormVO =  (targetButton as ShopMgtCategoryButton).vo as ShopCategoryFormVO;
				if (categoryVO)
				{
					refreshProductPage(categoryVO.productList);
				}
			}
			else if ((targetButton && targetButton.parent is ShopMgtSProductButton) || e.data is ShopProductFormVO)
			{
				var pButton:ShopMgtSProductButton = targetButton.parent as ShopMgtSProductButton;
				var pVO:ShopProductFormVO = ((e.data is ShopProductFormVO) ? e.data : pButton.vo) as ShopProductFormVO;
				var pIndex:int = _salesVO.isProductExist(pVO.productNo);
				var b:ShopMgtSalesProductButton;
				var cartVO:UserShoppingCartProductVO;
				if (pIndex == -1)
				{
					cartVO = UserVOService.getCartVOByProductVO(pVO, _shopInfoVO.shopNo);
					
					_salesVO.productList.addVO(cartVO);
					
					addProductButon(cartVO);
				}
				else
				{
					b = form.holder.subDisplayObjectList.getDisplayObjectByIndex(pIndex) as ShopMgtSalesProductButton;
					if (b)
					{
						cartVO = b.vo as UserShoppingCartProductVO;
						
						if (cartVO && cartVO.productNo == pVO.productNo)
						{
							cartVO.qty++;
							b.updateInfo();
						}
						else
						{
							echo('buttonEventHandler2 : product no doesnt matched with the one in list : ' + pIndex);
						}
					}
					else
					{
						echo('buttonEventHandler2 : unable to retrieve button : ' + pIndex);
					}
				}
				
				saleFormHandler();
			}
		}
		
		private function addProductButon(inVO:UserShoppingCartProductVO, inHasListener:Boolean = true):void
		{
			
			if (inVO)
			{
				var b:ShopMgtSalesProductButton = assetManager.getData(AssetClassID.BTN_SHOP_SALES_PRODUCT, AssetLibID.AST_SHOP_MGT_FORM);
				form.holder.addApplicationChild(b, null, false);
				
				/*if (!inVO.getPhotoVO().data)
				{
					loadURLImage(b.logo, ImageVOService.getImageURL(httpHost, _shopInfoVO.shopNo, FileType.PATH_SHOP_PRODUCT, [inVO.productNo]), FileType.PATH_IMAGE_SIZE_100);
				}*/
				/*if (!inVO.getPhotoVO().data || !inVO.getPhotoVO().data.bytesAvailable)
				{
					inVO.getPhotoVO().data = (assetManager.getData(SWFClassID.NO_IMAGE_50, AssetLibID.AST_COMMON) as ApplicationDisplayObject).cloneAsByte();
				}*/
				
				//var taxPrice:Number = myShopper.common.data.service.ShopVOService.getProductPriceWithTax(inVO);
				var taxPrice:Number = inVO.getPrice();
				
				b.setInfo(inVO);
				//b.logo.setInfo(inVO.getPhotoVO());
				b.txtPrice.text = Tools.getCurrencyCodeByNo(_shopInfoVO.currency) + taxPrice.toString() + ' (' + Tools.formatString(getMessage(myShopper.common.emun.MessageID.tt1033), [inVO.productTax]) + ')';
				
				if (inHasListener)
				{
					b.btnDelete.addEventListener(ButtonEvent.CLICK, productButtonEventHandler, false, 0, true);
					b.addEventListener(ApplicationEvent.CONTENT_CHANGED, productButtonEventHandler, false, 0, true);
				}
				
			}
		}
		
		private function productButtonEventHandler(e:ApplicationEvent):void 
		{
			if (e is ButtonEvent)
			{
				var targetButton:ShopMgtSalesProductButton = ((e as ButtonEvent).targetButton as Button).parent as ShopMgtSalesProductButton;
				if (targetButton && (form.holder.content as Menu).hasApplicationChild(targetButton))
				{
					_salesVO.productList.removeVO(targetButton.vo);
					form.holder.removeApplicationChild(targetButton, false);
					
				}
			}
			
			saleFormHandler();
		}
		
		private function saleFormHandler(e:Event = null):void 
		{
			
			var subTotal:Number = myShopper.common.data.service.ShopVOService.getOrderSubTotalByVO(_salesVO.productList);
			var extraTotal:Number = myShopper.common.data.service.ShopVOService.getOrderExtraTotalByVO(_salesVO.extraList);
			var finalTotal:Number = ShopVOService.getOrderFinalTotalByOrderVO(_salesVO);
			
			form.txtSubTotal.text = subTotal.toString();
			form.txtExtraTotal.text = extraTotal.toString();
			form.txtTotal.text = Tools.getCurrencyCodeByNo(_shopInfoVO.currency) + ':' + String(finalTotal);
			
			if (e)
			{
				form.txtChange.text = Number(Number(form.txtPaid.text) - finalTotal).toFixed(2);
			}
			else
			{
				form.txtPaid.text =  String(finalTotal);
				form.txtChange.text = '0';
			}
			
		}
	}
}