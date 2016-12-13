package myShopper.shopMgtModule.appForm.view 
{
	import flash.events.Event;
	import flash.printing.PrintJob;
	import myShopper.common.Config;
	import myShopper.common.data.AlerterVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.service.ShopVOService;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.shop.ShopOrderVO;
	import myShopper.common.display.ApplicationDisplayObject;
	import myShopper.common.display.button.Button;
	import myShopper.common.display.Menu;
	import myShopper.common.emun.AlerterType;
	import myShopper.common.emun.AssetXMLNodeID;
	import myShopper.common.emun.MessageID;
	import myShopper.common.emun.OrderShipmentID;
	import myShopper.common.emun.SWFClassID;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.AlerterEvent;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.events.WindowEvent;
	import myShopper.common.interfaces.IDataDisplayObject;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.text.Font;
	import myShopper.common.utils.Alert;
	import myShopper.common.utils.DateUtil;
	import myShopper.common.utils.Tools;
	import myShopper.common.utils.TweenerEffect;
	import myShopper.fl.FormAlerter;
	import myShopper.fl.shopMgt.button.ShopMgtOrderButton;
	import myShopper.fl.shopMgt.order.ShopMgtOrderInfo;
	import myShopper.fl.shopMgt.print.ShopMgtInvoiceA4;
	import myShopper.fl.shopMgt.SalesCheckWindow;
	import myShopper.fl.ui.DialogManager;
	import myShopper.fl.window.BaseWindow;
	import myShopper.shopMgtCommon.data.SalesCheckVO;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtCommon.ShopMgtShopInfoVO;
	import myShopper.shopMgtModule.appForm.enum.AssetClassID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.FormMain;
	import myShopper.shopMgtModule.appForm.view.component.ApplicationForm;
	import org.puremvc.as3.multicore.interfaces.IContainerMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	
	public class ShopClosedOrderMediator extends ApplicationMediator implements IContainerMediator 
	{
		private var _appForm:ApplicationForm;
		public function get appForm():ApplicationForm 
		{
			if (!_appForm) _appForm = (container as FormMain).appForm;
			return _appForm;
		}
		
		private var _numPageData:int = 100;
		private var _shopInfoVO:ShopMgtShopInfoVO;
		private var _statusXML:XML;
		//private var _alert:FormAlerter;
		
		//private var _content:ShopMgtOrderInfo;
		private var _window:SalesCheckWindow;
		private var _salesCheckVO:SalesCheckVO;
		//private var _bg:ApplicationDisplayObject;
		
		
		public function ShopClosedOrderMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
		{
			super(inMediatorName, inViewComponent);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			_shopInfoVO = voManager.getAsset(VOID.MY_SHOP_INFO);
			_statusXML = xmlManager.getData(AssetXMLNodeID.ORDER_STATUS, AssetLibID.XML_LANG_COMMON)[0];
			
			if (!_shopInfoVO || !_statusXML)
			{
				throw(new UninitializedError('ShopClosedOrderMediator : onRegister : unable to retreve shop vo/xml'));
			}
			
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			//_window.mcScrollBar.scrollTarget = null;
			if (_window) appForm.removeApplicationChild(_window, false);
			_window.btnClose.removeEventListener(ButtonEvent.CLICK, windownButtonEventHandler);
			stopListener();
			_appForm = null;
			//_content = null;
			_window = null;
			_shopInfoVO = null;
		}
		
		override public function listNotificationInterests():Array 
		{
			return	[
						NotificationType.ADD_DISPLAY_ORDER, 
						NotificationType.REFRESH_DISPLAY_ORDER, 
						NotificationType.DELETE_SALES_SUCCESS, 
						NotificationType.DELETE_SALES_FAIL
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
			var noteName:String = note.getName();
			switch(noteName)
			{
				case NotificationType.ADD_DISPLAY_ORDER:
				{
					_window = vo.displayObject as SalesCheckWindow;
					
					_salesCheckVO = vo.data as SalesCheckVO;
					
					if (_window)
					{
						//_window.txtTitle.embedFonts = false;
						//_window.txtTitle.defaultTextFormat = Font.getTextFormat( { color:0xffffff, size:18, letterSpacing:2, font:SWFClassID.SANS } ) ;
						setTextField(_window.txtTitle, language == Config.LANG_CODE_EN);
						
						var windowNode:XML = vo.settingXML;
						
						appForm.addApplicationChild(_window, windowNode, false);
						//_content = _window.addApplicationChild(assetManager.getData(AssetClassID.FORM_SHOP_ORDER_INFO, AssetLibID.AST_SHOP_MGT), null, false) as ShopMgtOrderInfo;
						
						_window.showPage(TweenerEffect.setAlpha(1));
						if (language == Config.LANG_CODE_CHS || language == Config.LANG_CODE_CHT)
						{
							_window.btnHolder.setLayout(Menu.LAYOUT_HORIZONTAL, 35);
							_window.btnHolder.x += 14;
							//_window.mcDateChooser.months = getMessage(MessageID.MONTHS).split(',');
							//_window.mcDateChooser.days = getMessage(MessageID.DAYS).split(',');
						}
						
						_window.x = mainStage.stageWidth - _window.width >> 1;
						_window.y = mainStage.stageHeight - _window.height >> 1;
						_window.setSize(/*560*/ 520, 480);
						_window.mcPagingController.visible = false;
						_window.btnSales.text = getMessage(MessageID.tt1029);
						_window.btnOrder.text = getMessage(MessageID.tt1020);
						_window.mcPagingController.addEventListener(ApplicationEvent.MORE, refreshOrderList, false, 0, true);
						
						CONFIG::mobile
						{
							new DialogManager().addHandler(_window.txtFrom, _window.txtFrom.text, DialogManager.TYPE_DATE);
							new DialogManager().addHandler(_window.txtTo, _window.txtTo.text, DialogManager.TYPE_DATE);
						}
						
						_window.refresh();
						//refreshOrderList();
						startListener();
					}
					
					break;
				}
				case NotificationType.REFRESH_DISPLAY_ORDER:
				{
					if (_window) 
					{
						_window.isBusy = false;
						_window.mcPagingController.initController(_shopInfoVO.shopClosedOrderList.length, _numPageData);
						refreshOrderList();
						startListener();
					}
					break;
				}
				case NotificationType.DELETE_SALES_SUCCESS:
				case NotificationType.DELETE_SALES_FAIL:
				{
					//refreshOrderList();
					createFormAlert(noteName == NotificationType.DELETE_SALES_SUCCESS ?  getMessage(MessageID.SUCCESS_TITLE) : getMessage(MessageID.ERROR_TITLE) + getMessage(MessageID.ERROR_TRY_LATER));
					startListener();
					_window.isBusy = false;
					//_window.mcScrollBar.refresh();
					break;
				}
				
			}
			
			
		}
		
		private function createFormAlert(inMessage:String):void 
		{
			/*if (_window)
			{
				_alert = _window.addApplicationChild(Alert.create(new AlerterVO('', '', '', null, '', inMessage)), null) as FormAlerter;
				
				_alert.x = _window.mcBG.width - _alert.width >> 1;
				_alert.y = _window.mcBG.height - _alert.width >> 1;
				_alert.autoClose(5000);
			}*/
			
		}
		
		private function refreshOrderList(e:Event = null):void 
		{
			if (/*_content && _content.holder.content is Menu*/_window)
			{
				//clear all previous added button
				(_window.holder.content as Menu).removeAllButton();
				
				var numItem:int = _shopInfoVO.shopClosedOrderList.length;
				
				var dataIndex:int = _window.mcPagingController.currPage * _numPageData;
				var numRecord:int = numItem;
				var strFooter:String = '';
				
				if (numRecord)
				{
					/*strFooter = Tools.formatString	(
														getMessage(MessageID.T0020), 
														[
															numRecord.toString(), 
															_playCheckResultVO.totalBet, 
															Tools.formatString('<font color="#{0}">{1}</font>', [(_playCheckResultVO.totalWin >= 0 ? '006600' : 'ff0000'), _playCheckResultVO.totalWin]), 
															_playCheckResultVO.totalRolling
														]
													);*/
				}
				else
				{
					strFooter = getMessage(MessageID.DATA_NOT_EXIST);
				}
				
				_window.txtFooter.htmlText = strFooter;
				
				_window.mcPagingController.visible = numRecord > _numPageData;
				
				for (var i:int = dataIndex; i < numRecord; i++)
				//for (var i:int = numItem - 1; i >= 0; i--)
				{
					if (i > dataIndex + _numPageData - 1) 
					{
						break;
					}
					
					var b:ShopMgtOrderButton = assetManager.getData(AssetClassID.BTN_SHOP_ORDER, AssetLibID.AST_SHOP_MGT);
					if (b)
					{
						//b.btnText.txt.embedFonts = true;
						//b.btnText.txt.defaultTextFormat = Font.getTextFormat( { size:15, letterSpacing:2, font:Font.getDefaultFontByLang(language) } );
						
						_window.holder.addApplicationChild(b, null, false);
						var oVO:ShopOrderVO = _shopInfoVO.shopClosedOrderList.getVO(i) as ShopOrderVO;
						var targetStatusNode:XML = _statusXML.*.(@data == oVO.status)[0];
						
						if (targetStatusNode)
						{
							var strStatus:String = oVO.shippingMethod == OrderShipmentID.SHOP_SALES ? '' : '(' + targetStatusNode.@label.toString() + ')';
							
							b.setInfo(oVO);
							b.txtNo.text = String(i + 1) + '.';
							b.txtInvoiceNo.text = oVO.invoiceNo ;
							b.txtTotal.text = Tools.getCurrencyCodeByNo(oVO.shopCurrency) + ' : ' + oVO.total + strStatus;
							b.addEventListener(ButtonEvent.CLICK, buttonEventHandler, false, 0, true);
							b.btnDelete.addEventListener(ButtonEvent.CLICK, deleteEventHandler, false, 0, true);
							//b.btnPrint.addEventListener(ButtonEvent.CLICK, printEventHandler, false, 0, true);
						}
						else
						{
							echo('handleNotification : unable to retreve status xml');
						}
						
						
					}
				}
				
				_window.mcScrollBar.refresh();
			}
			
		}
		
		//set window display object to the top of appFrom container
		public function setIndex(inIndex:int = -1):void 
		{
			if (!_window) return;
			
			appForm.setChildIndex(_window, inIndex == -1 ? appForm.numChildren - 1 : inIndex);
		}
		
		override public function startListener():void 
		{
			if (!_window) return;
			
			_window.btnClose.addEventListener(ButtonEvent.CLICK, windownButtonEventHandler, false, 0, true);
			_window.btnSearch.addEventListener(ButtonEvent.CLICK, windownButtonEventHandler, false, 0, true);
			_window.holder.mouseChildren = true;
		}
		
		override public function stopListener():void
		{
			if (!_window) return;
			
			//_window.btnClose.removeEventListener(ButtonEvent.CLICK, windownButtonEventHandler);
			_window.btnSearch.removeEventListener(ButtonEvent.CLICK, windownButtonEventHandler);
			_window.holder.mouseChildren = false;
			
		}
		
		
		private function windownButtonEventHandler(e:ButtonEvent):void 
		{
			switch(e.targetButton)
			{
				case _window.btnClose:
				{
					//sendNotification(WindowEvent.CLOSE, _window);
					sendNotification(WindowEvent.CLOSE, mediatorName);
					break;
				}
				case _window.btnSearch:
				{
					_window.mcPagingController.currPage = 0;
					
					stopListener();
					_window.isBusy = true;
					_window.txtFooter.htmlText = '';
					_window.mcDateChooser.visible = false;
					_salesCheckVO.searchVO.fromDate = DateUtil.dateToString( _window.dateFrom);
					_salesCheckVO.searchVO.toDate = DateUtil.dateToString( _window.dateTo);
					_salesCheckVO.searchVO.count = 0; //not used
					_salesCheckVO.searchVO.index = 0; //not used
					_salesCheckVO.shippingMethod = _window.btnSales.alpha == 1 ? OrderShipmentID.SHOP_SALES : OrderShipmentID.NONE;
					sendNotification(ShopMgtEvent.SHOP_GET_ORDER, _salesCheckVO);
					break;
				}
			}
		}
		
		private function buttonEventHandler(e:ButtonEvent):void 
		{
			trace(e.type);
			
			switch(e.type)
			{
				case ButtonEvent.CLICK:
				{
					var vo:ShopOrderVO = (e.targetButton as IDataDisplayObject).vo as ShopOrderVO;
					
					
					sendNotification
					(
						WindowEvent.CREATE,
						vo,
						//vo.shippingMethod === OrderShipmentID.SHOP_SALES ? ShopMgtEvent.SHOP_VIEW_SALES : ShopMgtEvent.SHOP_VIEW_ORDER
						ShopMgtEvent.SHOP_VIEW_SALES_HISTORY
					);
					
					break;
				}
			}
		}
		
		private function deleteEventHandler(e:ButtonEvent):void 
		{
			e.event.stopImmediatePropagation();
			
			var vo:ShopOrderVO = ((e.targetButton as Button).parent as IDataDisplayObject).vo as ShopOrderVO;
			var alert:ApplicationDisplayObject = Alert.show
			(
				new AlerterVO
				(
					mediatorName, 
					AlerterType.CONFIRM, 
					'', 
					vo, 
					getMessage(MessageID.CONFIRM_TITLE),
					getMessage(myShopper.shopMgtCommon.emun.MessageID.SALES_DELETE, 'string', AssetLibID.XML_LANG_SHOP_MGT)
				)
			)
			
			if (alert)
			{
				alert.addEventListener(AlerterEvent.CANCEL, alertEventHandler, false, 0, true);
				alert.addEventListener(AlerterEvent.CONFIRM, alertEventHandler, false, 0, true);
				alert.addEventListener(AlerterEvent.CLOSE, alertEventHandler, false, 0, true);
			}
			else
			{
				echo('deleteEventHandler : unknown data type : ' + alert);
			}
		}
		
		/*private function printEventHandler(e:ButtonEvent):void 
		{
			
		}*/
		
		private function alertEventHandler(e:AlerterEvent):void 
		{
			e.targetDisplayObject.removeEventListener(AlerterEvent.CANCEL, alertEventHandler);
			e.targetDisplayObject.removeEventListener(AlerterEvent.CONFIRM, alertEventHandler);
			e.targetDisplayObject.removeEventListener(AlerterEvent.CLOSE, alertEventHandler);
			
			if (e.type == AlerterEvent.CONFIRM)
			{
				_window.isBusy = true;
				stopListener();
				sendNotification(ShopMgtEvent.SHOP_DELETE_SALES, e.vo.data);
			}
		}
		
		private function getEventTypeByAssetID(inID:String):String
		{
			/*if 		(inID == AssetID.BTN_SHOP_S_PASSWORD) 	return ShopMgtEvent.SHOP_UPDATE_PASSWORD;
			else if (inID == AssetID.BTN_SHOP_S_LOGO) 		return ShopMgtEvent.SHOP_UPDATE_LOGO;
			else if (inID == AssetID.BTN_SHOP_S_BG) 		return ShopMgtEvent.SHOP_UPDATE_BG;*/
			
			return '';
		}
		
	}
}