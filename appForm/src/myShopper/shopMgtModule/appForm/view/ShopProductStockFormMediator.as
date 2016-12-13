package myShopper.shopMgtModule.appForm.view 
{
	import caurina.transitions.Tweener;
	import flash.display.DisplayObject;
	import myShopper.common.Config;
	import myShopper.common.data.AlerterVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.shop.ShopProductFormVO;
	import myShopper.common.data.shop.ShopProductStockVO;
	import myShopper.common.display.button.Button;
	import myShopper.common.display.Menu;
	import myShopper.common.emun.AlerterType;
	import myShopper.common.emun.MessageID;
	import myShopper.common.emun.SWFClassID;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.AlerterEvent;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.events.WindowEvent;
	import myShopper.common.interfaces.IForm;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.text.Font;
	import myShopper.common.utils.Alert;
	import myShopper.common.utils.DateUtil;
	import myShopper.common.utils.Tools;
	import myShopper.common.utils.TweenerEffect;
	import myShopper.fl.ConfirmAlerter;
	import myShopper.fl.FormAlerter;
	import myShopper.fl.shopMgt.button.ShopMgtStockButton;
	import myShopper.fl.shopMgt.form.ShopMgtStockForm;
	import myShopper.fl.shopMgt.ProductStockWindow;
	import myShopper.fl.ui.DialogManager;
	import myShopper.fl.window.BaseWindow;
	import myShopper.shopMgtCommon.data.ShopMgtStockVO;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtCommon.ShopMgtShopInfoVO;
	import myShopper.shopMgtModule.appForm.enum.AssetClassID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.FormMain;
	import myShopper.shopMgtModule.appForm.view.component.ApplicationForm;
	import org.puremvc.as3.multicore.interfaces.IContainerMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.interfaces.ITabFormMediator;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class ShopProductStockFormMediator extends ApplicationMediator implements IContainerMediator, ITabFormMediator 
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
		
		private var form:ShopMgtStockForm;
		private var _window:ProductStockWindow;
		private var _stockVO:ShopMgtStockVO;
		//private var _salesService:SalesVOService;
		
		
		public function ShopProductStockFormMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
		{
			super(inMediatorName, inViewComponent);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			_shopInfoVO = voManager.getAsset(VOID.MY_SHOP_INFO);
			
			if (!_shopInfoVO)
			{
				echo('onRegister : unable to get shop info vo/xml');
				throw(new UninitializedError('onRegister : unable to get shop info vo/xml'));
			}
			
			//_printService = new PrintVOService(assetManager as AssetManager,  appForm);
			//_salesService = new SalesVOService(_shopInfoVO.productCategoryList);
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
		}
		
		override public function listNotificationInterests():Array 
		{
			var arr:Array;
			
			arr = 	[
						NotificationType.ADD_DISPLAY_PRODUCT_STOCK,
						NotificationType.CREATE_PRODUCT_STOCK_SUCCESS,
						NotificationType.CREATE_PRODUCT_STOCK_FAIL,
						NotificationType.DELETE_PRODUCT_STOCK_FAIL,
						NotificationType.DELETE_PRODUCT_STOCK_SUCCESS,
						NotificationType.GET_PRODUCT_STOCK_HISTORY_SUCCESS,
						NotificationType.GET_PRODUCT_STOCK_HISTORY_FAIL
						
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
				case NotificationType.ADD_DISPLAY_PRODUCT_STOCK:
				{
					_window = vo.displayObject as ProductStockWindow;
					_stockVO = vo.data as ShopMgtStockVO;
					
					if (_window)
					{
						//_window.txtTitle.embedFonts = false;
						//_window.txtTitle.defaultTextFormat = Font.getTextFormat( { size:18, letterSpacing:2, font:SWFClassID.SANS } );
						setTextField(_window.txtTitle, language == Config.LANG_CODE_EN);
						
						appForm.addApplicationChild(_window, vo.settingXML, false);
						_window.showPage(TweenerEffect.setAlpha(1));
						
						form = _window.addApplicationChild(assetManager.getData(AssetClassID.FORM_SHOP_PRODUCT_STOCK, AssetLibID.AST_SHOP_MGT_FORM), null, false) as ShopMgtStockForm;
						form.setInfo(_stockVO);
						//orm.onStageResize(mainStage);
						
						//_window.setSize(form.width, form.height + 20);
						_window.x = mainStage.stageWidth - _window.width >> 1;
						_window.y = mainStage.stageHeight - _window.height >> 1;
						//_window.isBusy = true;
						
						CONFIG::mobile
						{
							new DialogManager().addHandler(form.txtFrom, form.txtFrom.text, DialogManager.TYPE_DATE);
							new DialogManager().addHandler(form.txtTo, form.txtTo.text, DialogManager.TYPE_DATE);
						}
						
						//TODO : mcPagingController / reference ShopClosedOrderMediator
						//_window.mcPagingController.addEventListener(ApplicationEvent.MORE, refreshOrderList, false, 0, true);
						startListener();
						
					}
					
					break;
				}
				case NotificationType.CREATE_PRODUCT_STOCK_SUCCESS:
				case NotificationType.CREATE_PRODUCT_STOCK_FAIL:
				{
					
					createFormAlert
					(
						getMessage(noteName == NotificationType.CREATE_PRODUCT_STOCK_SUCCESS ? MessageID.SUCCESS_SAVE : MessageID.ERROR_GET_DATA), 
						form.btnSend
					);
					startListener();
					_window.isBusy = false;
					break;
				}
				case NotificationType.DELETE_PRODUCT_STOCK_SUCCESS:
				case NotificationType.DELETE_PRODUCT_STOCK_FAIL:
				{
					createFormAlert
					(
						getMessage(noteName == NotificationType.DELETE_PRODUCT_STOCK_SUCCESS ? MessageID.SUCCESS_SAVE : MessageID.ERROR_GET_DATA), 
						form.btnSearch
					);
					startListener();
					_window.isBusy = false;
					break;
				}
				case NotificationType.GET_PRODUCT_STOCK_HISTORY_SUCCESS:
				//case NotificationType.GET_PRODUCT_STOCK_HISTORY_FAIL:
				{
					refreshHistory(note.getBody() as ShopProductFormVO);
					startListener();
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
			form.btnSend.alpha = 1;
			
			if (!_window.btnClose.hasEventListener(ButtonEvent.CLICK))
			{
				_window.btnClose.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
			}
			
			form.btnSend.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
			form.btnSearch.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
			
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
			
			form.btnSend.stopListener();
			form.btnSend.onMouseOver = null;
			form.btnSend.onMouseOut = null;
			
			
		}
		
		private function refreshHistory(inVO:ShopProductFormVO):void 
		{
			(form.holder.content as Menu).removeAllButton();
			
			var numItem:int = inVO.productStock.length;
			
			_window.txtFooter.text = numItem ? Tools.formatString(getMessage(myShopper.shopMgtCommon.emun.MessageID.NUM_RECORD, 'string', AssetLibID.XML_LANG_SHOP_MGT), [numItem]) : getMessage(MessageID.DATA_NOT_EXIST);
			
			for (var i:int = 0; i < numItem; i++)
			{
				var b:ShopMgtStockButton = form.holder.addApplicationChild(assetManager.getData(AssetClassID.BTN_SHOP_STOCK, AssetLibID.AST_SHOP_MGT_FORM), null, false) as ShopMgtStockButton;
				b.setInfo(inVO.productStock.getVO(i));
				b.txtNo.text = String(i + 1) + '.';
				b.btnDelete.addEventListener(ButtonEvent.CLICK, historyEventHandler, false, 0, true);
			}
		}
		
		private function historyEventHandler(e:ButtonEvent):void 
		{
			var b:ShopMgtStockButton = (e.targetButton as Button).parent as ShopMgtStockButton;
			if (b && b.vo is ShopProductStockVO)
			{
				var _alert:ConfirmAlerter = Alert.show
				(
					new AlerterVO
					(
						mediatorName, 
						AlerterType.CONFIRM, 
						'', 
						b.vo, 
						getMessage(MessageID.CONFIRM_TITLE),
						getMessage(MessageID.CONFIRM_DELETE)
					)
				) as ConfirmAlerter
				
				if (_alert)
				{
					_alert.addEventListener(AlerterEvent.CANCEL, alertEventHandler);
					_alert.addEventListener(AlerterEvent.CONFIRM, alertEventHandler);
					_alert.addEventListener(AlerterEvent.CLOSE, alertEventHandler);
				}
				else
				{
					echo('historyEventHandler : unknown data type : ' + e);
				}
			}
		}
		
		private function alertEventHandler(e:AlerterEvent):void 
		{
			if (e.type == AlerterEvent.CONFIRM)
			{
				stopListener();
				_window.isBusy = true;
				sendNotification(ShopMgtEvent.SHOP_DELETE_PRODUCT_STOCK, e.vo.data);
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
				
				case form.btnSend:
				{
					var result:* = form.isValid();
					if (result === true)
					{
						stopListener();
						if (_window) _window.isBusy = true;
						_window.txtFooter.text = '';
						sendNotification(ShopMgtEvent.SHOP_CREATE_PRODUCT_STOCK, _stockVO);
					}
					else
					{
						createFormAlert(getMessage(MessageID.FORM_MISSING_INFO), form.txtStock);
					}
					break;
				}
				case form.btnSearch:
				{
					//_window.mcPagingController.currPage = 0;
					
					stopListener();
					_window.isBusy = true;
					//_window.txtFooter.htmlText = '';
					form.mcDateChooser.visible = false;
					_stockVO.searchVO.fromDate = form.txtFrom.text; // DateUtil.dateToString( form.dateFrom);
					_stockVO.searchVO.toDate = form.txtTo.text;// DateUtil.dateToString( form.dateTo);
					_stockVO.searchVO.count = 0; //not used
					_stockVO.searchVO.index = 0; //not used
					//_stockVO.shippingMethod = _window.btnSales.alpha == 1 ? OrderShipmentID.SHOP_SALES : OrderShipmentID.NONE;
					sendNotification(ShopMgtEvent.SHOP_GET_PRODUCT_STOCK_HISTORY, _stockVO);
					break;
				}
			}
		}
		
		private function createFormAlert(inMessage:String, inItem:DisplayObject):void 
		{
			if (form)
			{
				_alert = form.addApplicationChild(Alert.create(new AlerterVO('', '', '', null, '', inMessage)), null) as FormAlerter;
				
				_alert.x = inItem.x + inItem.width;
				_alert.y = inItem.y - _alert.height;
				_alert.autoClose(5000);
				_alert = null;
			}
			
		}
		
	}
}