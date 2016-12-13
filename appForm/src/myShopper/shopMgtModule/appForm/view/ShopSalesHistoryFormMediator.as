package myShopper.shopMgtModule.appForm.view 
{
	import fl.data.DataProvider;
	import flash.events.Event;
	import flash.printing.PrintJob;
	import myShopper.common.Config;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.shop.ShopOrderExtraVO;
	import myShopper.common.data.shop.ShopOrderVO;
	import myShopper.common.data.shop.ShopProductShoppingCartVO;
	import myShopper.common.data.user.UserShoppingCartProductVO;
	import myShopper.common.display.ApplicationDisplayObject;
	import myShopper.common.emun.AssetXMLNodeID;
	import myShopper.common.emun.MessageID;
	import myShopper.common.emun.OrderExtraTypeID;
	import myShopper.common.emun.OrderShipmentID;
	import myShopper.common.emun.SWFClassID;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.events.VOEvent;
	import myShopper.common.events.WindowEvent;
	import myShopper.common.interfaces.IForm;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.resources.AssetManager;
	import myShopper.common.text.Font;
	import myShopper.common.utils.Tools;
	import myShopper.common.utils.TweenerEffect;
	import myShopper.fl.button.OrderExtraButton;
	import myShopper.fl.shopMgt.button.ShopMgtOrderProductButton;
	import myShopper.fl.shopMgt.form.ShopMgtSalesHistoryForm;
	import myShopper.fl.shopMgt.print.ShopMgtInvoiceA4;
	import myShopper.fl.shopMgt.print.ShopMgtInvoiceItemA4;
	import myShopper.fl.ui.DialogManager;
	import myShopper.fl.window.BaseWindow;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.ShopMgtShopInfoVO;
	import myShopper.shopMgtModule.appForm.enum.AssetClassID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.FormMain;
	import myShopper.shopMgtModule.appForm.model.service.PrintVOService;
	import myShopper.shopMgtModule.appForm.view.component.ApplicationForm;
	import org.puremvc.as3.multicore.interfaces.IContainerMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.interfaces.ITabFormMediator;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	import myShopper.common.data.service.ShopVOService;
	import myShopper.shopMgtCommon.data.service.ShopVOService;
	
	public class ShopSalesHistoryFormMediator extends ApplicationMediator implements IContainerMediator, ITabFormMediator 
	{
		private var _appForm:ApplicationForm;
		public function get appForm():ApplicationForm 
		{
			if (!_appForm) _appForm = (container as FormMain).appForm;
			return _appForm;
		}
		public function getForm():IForm { return form; }
		
		private var _shopInfoVO:ShopMgtShopInfoVO;
		
		private var form:ShopMgtSalesHistoryForm;
		private var _window:BaseWindow;
		private var _salesVO:ShopOrderVO;
		private var _xmlPayType:XML;
		private var _xmlStatus:XML;
		
		//private var _printService:PrintVOService;
		
		public function ShopSalesHistoryFormMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
		{
			super(inMediatorName, inViewComponent);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			_shopInfoVO = voManager.getAsset(VOID.MY_SHOP_INFO);
			_xmlPayType = xmlManager.getData(AssetXMLNodeID.PAY_TYPE, AssetLibID.XML_LANG_COMMON)[0];
			_xmlStatus = xmlManager.getData(AssetXMLNodeID.ORDER_STATUS, AssetLibID.XML_LANG_COMMON)[0];
			//_printService = new PrintVOService(assetManager as AssetManager, appForm);
			
			if (!_shopInfoVO || !_xmlPayType || !_xmlStatus)
			{
				echo('onRegister : unable to get shop info vo/xml');
				throw(new UninitializedError('onRegister : unable to get shop info vo/xml'));
			}
			
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
			
			//_printService.clear();
			//_printService = null;
		}
		
		override public function listNotificationInterests():Array 
		{
			return [NotificationType.ADD_DISPLAY_SALES_HISTORY];
		}

		override public function handleNotification(note:INotification):void 
		{
			var body:Object = note.getBody();
			var vo:DisplayObjectVO = body as DisplayObjectVO;
			
			var noteName:String = note.getName();
			var numItem:int;
			var i:int;
			
			switch(noteName)
			{
				case NotificationType.ADD_DISPLAY_SALES_HISTORY:
				{
					_window = vo.displayObject as BaseWindow;
					_salesVO = vo.data as ShopOrderVO;
					
					if (_window)
					{
						//_window.txtTitle.embedFonts = false;
						//_window.txtTitle.defaultTextFormat = Font.getTextFormat( { size:18, letterSpacing:2, font:SWFClassID.SANS } );
						setTextField(_window.txtTitle, language == Config.LANG_CODE_EN);
						
						appForm.addApplicationChild(_window, vo.settingXML, false) as BaseWindow;
						_window.showPage(TweenerEffect.setAlpha(1));
						
						form = _window.addApplicationChild(assetManager.getData(AssetClassID.FORM_SHOP_SALES_HISTORY, AssetLibID.AST_SHOP_MGT), null, false) as ShopMgtSalesHistoryForm;
						form.cbOrderStatus.dataProvider = new DataProvider(_xmlStatus);
						form.cbPayMethod.dataProvider = new DataProvider(_xmlPayType);
						form.setInfo(_salesVO);
						
						CONFIG::mobile
						{
							new DialogManager().addHandler(form.cbOrderStatus, _xmlStatus);
							new DialogManager().addHandler(form.cbPayMethod, _xmlPayType);
						}
						
						_window.setSize(form.width + 20, form.height + 20);
						_window.x = mainStage.stageWidth - _window.width >> 1;
						_window.y = mainStage.stageHeight - _window.height >> 1;
						_window.isBusy = true;
						
						var title:String = getMessage(_window.XMLSetting.@text);
						var str:String = ' [' + (_salesVO.shippingMethod == OrderShipmentID.SHOP_SALES ? getMessage(MessageID.tt1029) : getMessage(MessageID.tt1020)) + ']';
						str += ' (' + _salesVO.dateTime + ')';
						
						_window.txtTitle.text = title + str;
						_window.txtTitle.setTextFormat(Font.getTextFormat({ color:0xffffff, size:12, font:SWFClassID.SANS }), _window.txtTitle.length - str.length, _window.txtTitle.length) ;
						
						startListener();
						saleFormHandler();
					}
					
					break;
				}
				
				case NotificationType.RESULT_GET_SALES_PRODUCT:
				{
					numItem = _salesVO.productList.length;
					for (i = 0; i < numItem; i++)
					{
						addProductButon(_salesVO.productList.getVO(i) as UserShoppingCartProductVO, false);
					}
					saleFormHandler();
					break;
				}
				case NotificationType.RESULT_GET_SALES_EXTRA:
				{
					numItem = _salesVO.extraList.length;
					for (i = 0; i < numItem; i++)
					{
						addExtraButon( _salesVO.extraList.getVO(i) as ShopOrderExtraVO );
					}
					saleFormHandler();
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
				_window.btnClose.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
			}
			
			form.btnPrint.addEventListener(ButtonEvent.CLICK, printEventHandler, false, 0, true);
			
		}
		
		override public function stopListener():void 
		{
			if (!form || !_window) return;
			
			form.mouseChildren = false;
			form.btnPrint.removeEventListener(ButtonEvent.CLICK, printEventHandler);
		}
		
		private function printEventHandler(e:ButtonEvent):void 
		{
			e.event.stopImmediatePropagation();
			
			//TODO : alert an option for user choosing print size
			sendNotification(ApplicationEvent.PRINT, _salesVO, String(PrintVOService.SIZE_80MM));
			//_printService.order(_salesVO, _shopInfoVO);
			
		}
		
		private function addExtraButon(inVO:ShopOrderExtraVO):void 
		{
			var oVO:ShopOrderExtraVO = inVO as ShopOrderExtraVO;
			
			if (oVO)
			{
				var ob:OrderExtraButton = assetManager.getData(SWFClassID.BUTTON_ORDER_EXTRA, AssetLibID.AST_COMMON);
				form.holder.addApplicationChild(ob, null, false);
				
				var sign:String = oVO.type == OrderExtraTypeID.FEE ? '+' : '-';
				//ob.btnClose.addEventListener(ButtonEvent.CLICK, orderExtraEventHandler, false, 0, true);
				ob.setInfo(oVO);
				ob.txtTotal.text = Tools.getCurrencyCodeByNo(_salesVO.shopCurrency) + ': ' + sign + oVO.total.toString();
				ob.stopListener();
				
			}
			
			form.mcScrollBar.refresh();
			
		}
		
		
		private function buttonEventHandler(e:ButtonEvent):void 
		{
			switch(e.targetButton)
			{
				case _window.btnClose:
				{
					sendNotification(WindowEvent.CLOSE, mediatorName);
					break;
				}
				
			}
		}
		
		private function addProductButon(inVO:UserShoppingCartProductVO, inHasListener:Boolean = true):void
		{
			
			if (inVO)
			{
				var b:ShopMgtOrderProductButton = assetManager.getData(AssetClassID.BTN_SHOP_ORDER_PRODUCT, AssetLibID.AST_SHOP_MGT);
				form.holder.addApplicationChild(b, null, false);
				
				if (!inVO.getPhotoVO().data || !inVO.getPhotoVO().data.bytesAvailable)
				{
					inVO.getPhotoVO().data = (assetManager.getData(SWFClassID.NO_IMAGE_50, AssetLibID.AST_COMMON) as ApplicationDisplayObject).cloneAsByte();
				}
				
				//var taxPrice:Number = myShopper.common.data.service.ShopVOService.getProductPriceWithTax(inVO);
				var taxPrice:Number = inVO.getPrice();
				
				b.setInfo(inVO);
				b.logo.setInfo(inVO.getPhotoVO());
				b.txtPrice.text = Tools.getCurrencyCodeByNo(_shopInfoVO.currency) + taxPrice.toString() + ' (' + Tools.formatString(getMessage(myShopper.common.emun.MessageID.tt1033), [inVO.productTax]) + ')';
				
			}
		}
		
		private function saleFormHandler(e:Event = null):void 
		{
			
			var subTotal:Number = myShopper.common.data.service.ShopVOService.getOrderSubTotalByVO(_salesVO.productList);
			var extraTotal:Number = myShopper.common.data.service.ShopVOService.getOrderExtraTotalByVO(_salesVO.extraList);
			var finalTotal:Number =  myShopper.common.data.service.ShopVOService.getOrderFinalTotalByOrderVO(_salesVO); //Number(_salesVO.finalTotal);
			
			form.txtSubTotal.text = subTotal.toString();
			form.txtExtraTotal.text = extraTotal.toString();
			form.txtTotal.text = Tools.getCurrencyCodeByNo(_shopInfoVO.currency) + ':' + finalTotal.toString();
			
			if (_salesVO.shippingMethod != OrderShipmentID.SHOP_SALES)
			{
				form.txtPaid.text = finalTotal.toString();
				form.txtChange.text = '0';
			}
			else
			{
				form.txtChange.text = String(Number(form.txtPaid.text) - finalTotal);
			}
			
			
			
		}
	}
}