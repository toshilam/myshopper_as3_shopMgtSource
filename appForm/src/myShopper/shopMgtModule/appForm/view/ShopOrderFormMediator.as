package myShopper.shopMgtModule.appForm.view 
{
	import caurina.transitions.Tweener;
	import fl.data.DataProvider;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.Config;
	import myShopper.common.data.AlerterVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.service.ImageVOService;
	import myShopper.common.data.service.ShopVOService;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.shop.ShopOrderExtraVO;
	import myShopper.common.data.shop.ShopOrderVO;
	import myShopper.common.data.user.UserShoppingCartProductVO;
	import myShopper.common.display.ApplicationDisplayObject;
	import myShopper.common.display.button.Button;
	import myShopper.common.display.Menu;
	import myShopper.common.emun.AlerterType;
	import myShopper.common.emun.AssetXMLNodeID;
	import myShopper.common.emun.FileType;
	import myShopper.common.emun.MessageID;
	import myShopper.common.emun.OrderExtraTypeID;
	import myShopper.common.emun.OrderShipmentID;
	import myShopper.common.emun.OrderStatusID;
	import myShopper.common.emun.SWFClassID;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.AlerterEvent;
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
	import myShopper.fl.ConfirmAlerter;
	import myShopper.fl.FormAlerter;
	import myShopper.fl.shopMgt.button.ShopMgtOrderProductButton;
	import myShopper.fl.shopMgt.form.ShopMgtOrderForm;
	import myShopper.fl.shopMgt.form.ShopMgtShippingForm;
	import myShopper.fl.ui.DialogManager;
	import myShopper.fl.window.BaseWindow;
	import myShopper.fl.window.MultiPageWindow;
	import myShopper.shopMgtCommon.data.service.ShopVOService;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
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
	
	
	public class ShopOrderFormMediator extends ApplicationMediator implements IContainerMediator, ITabFormMediator 
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
		
		private var form:ShopMgtOrderForm;
		//private var form2:ShopMgtShippingForm;
		private var _window:MultiPageWindow;
		private var _selectedOrderVO:ShopOrderVO;
		private var _statusXML:XML;
		private var arrOrderStatus:Array;
		private var orderStateusDP:DataProvider;
		
		//private var _printService:PrintVOService;
		
		public function ShopOrderFormMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
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
				throw(new UninitializedError('ShopOrderMediator : onRegister : unable to retreve shop vo'));
			}
			
			//_printService = new PrintVOService(assetManager as AssetManager, appForm);
			
			arrOrderStatus = myShopper.shopMgtCommon.data.service.ShopVOService.getArrayCBOrderStatusByXML(_statusXML);
			if (arrOrderStatus && arrOrderStatus.length)
			{
				arrOrderStatus.unshift( { data:'-1', label:getMessage(MessageID.PLEASE_SELECT) } );
				orderStateusDP = new DataProvider(arrOrderStatus);
			}
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			//_window.mcScrollBar.scrollTarget = null;
			if (_window) appForm.removeApplicationChild(_window, false);
			
			stopListener();
			_alert = null;
			_appForm = null;
			form = null;
			_window = null;
			_shopInfoVO = null;
			_selectedOrderVO = null;
			_statusXML = null;
			//_printService.clear();
			//_printService = null;
		}
		
		override public function listNotificationInterests():Array 
		{
			return	[
						NotificationType.ADD_FORM_SHOP_ORDER, 
						NotificationType.RESULT_GET_ORDER_PRODUCT,
						NotificationType.RESULT_GET_ORDER_EXTRA,
						NotificationType.SEND_ORDER_INVOICE_FAIL,
						NotificationType.SEND_ORDER_INVOICE_SUCCESS,
						NotificationType.UPDATE_ORDER_SHIPMENT_FAIL,
						NotificationType.UPDATE_ORDER_SHIPMENT_SUCCESS
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
				case NotificationType.ADD_FORM_SHOP_ORDER:
				{
					_window = vo.displayObject as MultiPageWindow;
					_selectedOrderVO = vo.data as ShopOrderVO;
					
					if (_window && _selectedOrderVO)
					{
						form = assetManager.getData(AssetClassID.FORM_SHOP_ORDER, AssetLibID.AST_SHOP_MGT) as ShopMgtOrderForm;
						
						//_window.txtTitle.embedFonts = false;
						//_window.txtTitle.defaultTextFormat = Font.getTextFormat( { size:18, letterSpacing:2, font:SWFClassID.SANS } );
						setTextField(_window.txtTitle, language == Config.LANG_CODE_EN);
						
						appForm.addApplicationChild(_window, vo.settingXML, false);
						
						_window.showPage(TweenerEffect.setAlpha(1));
						_window.setSize(700, form.height + 50);
						_window.addPage(0);
						
						_window.addItem(0, form);
						_window.currPageIndex = 0;
						_window.x = mainStage.stageWidth - _window.width >> 1;
						_window.y = mainStage.stageHeight - _window.height >> 1;
						//_window.mcScrollBar.scrollTarget = null;
						_window.mcScrollBar.visible = false;
						
						loadURLImage(form.logo, ImageVOService.getImageURL(httpHost, _selectedOrderVO.userInfoVO.uid, FileType.PATH_USER_LOGO), FileType.PATH_IMAGE_SIZE_100);
						Tweener.addTween(form.logo, TweenerEffect.setGlow(0, '', 0x000000, 10));
						
						if (orderStateusDP)
						{
							form.cbOrderStatus.dataProvider = orderStateusDP;
							
							CONFIG::mobile
							{
								new DialogManager().addHandler(form.cbOrderStatus, arrOrderStatus);
							}
						}
						
						form.setInfo(_selectedOrderVO);
						form.btnAddExtra.text = getMessage(MessageID.tt1027);
						form.txtShippingFee.addEventListener(Event.CHANGE, textFieldEventHandler);
						form.txtSubTotal.text = _selectedOrderVO.total.toString();
						form.btnPrint.visible = false;
						form.onStageResize(mainStage);
						priceHandler();
						refreshForm();
						
						if 
						(
							_selectedOrderVO.status == OrderStatusID.ORDER_PAID || 
							_selectedOrderVO.status == OrderStatusID.ORDER_PREPARE_DELIVERY
						)
						{
							
							//_window.addPage(1);
							//form2 = assetManager.getData(AssetClassID.FORM_SHOP_SHIPPING, AssetLibID.AST_SHOP_MGT) as ShopMgtShippingForm;
							//_window.addItem(1, form2);
							//form2.setInfo(_selectedOrderVO);
							
						}
						
						statusHandler();
						
						_window.isBusy = true;
						startListener();
					}
					
					break;
				}
				case NotificationType.RESULT_GET_ORDER_PRODUCT:
				case NotificationType.RESULT_GET_ORDER_EXTRA:
				{
					refreshOrderProduct();
					break;
				}
				case NotificationType.SEND_ORDER_INVOICE_SUCCESS:
				case NotificationType.UPDATE_ORDER_SHIPMENT_SUCCESS:
				{
					refreshForm();
					statusHandler();
					stopListener(); //stop again as refreshForm() may have enabled some of displayobject
					createFormAlert(getMessage(MessageID.SUCCESS_SAVE), form.btnSend, false);
					break;
				}
				
				case NotificationType.SEND_ORDER_INVOICE_FAIL:
				//case NotificationType.UPDATE_ORDER_SHIPMENT_FAIL:
				{
					var result:ResultVO = note.getBody() as ResultVO;
					Alert.show
					(
						new AlerterVO
						(
							'', 
							'', 
							'', 
							null, 
							getMessage(MessageID.ERROR_TITLE), 
							getMessage(MessageID.ERROR_GET_DATA) + '\nCODE:(' + result.code + ')\n' + getMessage(MessageID.CONTACT_US)
						) 
					);
					sendNotification(WindowEvent.CLOSE, mediatorName);
					//startListener();
					break;
				}
				
			}
			
			if (note.getName() != NotificationType.ADD_FORM_SHOP_ORDER)
			{
				if(_window) _window.isBusy = false;
			}
		}
		
		private function refreshForm():void
		{
			if (!form) return;
			
			form.txtShippingFee.mouseEnabled = _selectedOrderVO.status == OrderStatusID.ORDER_ORDER;
			form.btnAddExtra.visible = _selectedOrderVO.status == OrderStatusID.ORDER_ORDER;
			form.holder.mouseChildren = _selectedOrderVO.status == OrderStatusID.ORDER_ORDER;
			form.cbOrderStatus.mouseEnabled = form.cbOrderStatus.mouseChildren = _selectedOrderVO.status != OrderStatusID.ORDER_ORDER && _selectedOrderVO.status != OrderStatusID.ORDER_WAITING_PAYMENT;
			form.btnSend.visible = _selectedOrderVO.status == OrderStatusID.ORDER_ORDER || _selectedOrderVO.status == OrderStatusID.ORDER_PAID || _selectedOrderVO.status == OrderStatusID.ORDER_PREPARE_DELIVERY || _selectedOrderVO.status == OrderStatusID.ORDER_DELIVERING;
			//no more editing if waiting payment
			form.mouseChildren = form.btnSend.visible;
		}
		
		private function refreshOrderProduct():void 
		{
			if (!form) return;
			form.btnPrint.visible = true;
			
			(form.holder.content as Menu).removeAllButton();
			
			//product
			var numItem:int = _selectedOrderVO.productList.length;
			var i:int = 0;
			for (i = 0; i < numItem; i++)
			{
				var b:ShopMgtOrderProductButton = assetManager.getData(AssetClassID.BTN_SHOP_ORDER_PRODUCT, AssetLibID.AST_SHOP_MGT);
				if (b)
				{
					form.holder.addApplicationChild(b, null, false);
					
					var pVO:UserShoppingCartProductVO = _selectedOrderVO.productList.getVO(i) as UserShoppingCartProductVO;
					if (pVO)
					{
						if (!pVO.getPhotoVO().data || !pVO.getPhotoVO().data.bytesAvailable)
						{
							pVO.getPhotoVO().data = (assetManager.getData(SWFClassID.NO_IMAGE_50, AssetLibID.AST_COMMON) as ApplicationDisplayObject).cloneAsByte();
						}
						
						
						b.setInfo(pVO);
						b.logo.setInfo(pVO.getPhotoVO());
						//b.txtPrice.text = Tools.getCurrencyCodeByNo(_selectedOrderVO.shopCurrency) + myShopper.common.data.service.ShopVOService.getDiscountedPrice(Number(pVO.productPrice), pVO.productDiscount).toString();
						b.txtPrice.text = Tools.getCurrencyCodeByNo(_selectedOrderVO.shopCurrency) + pVO.getPrice();
						b.stopListener();
						//b.txtNo.text = String(i + 1) + '.';
						//b.addEventListener(ButtonEvent.CLICK, buttonEventHandler, false, 0, true);
					}
					
				}
			}
			//extra item
			numItem = _selectedOrderVO.extraList.length;
			for (i = 0; i < numItem; i++)
			{
				var ob:OrderExtraButton = assetManager.getData(SWFClassID.BUTTON_ORDER_EXTRA, AssetLibID.AST_COMMON);
				if (ob)
				{
					form.holder.addApplicationChild(ob, null, false);
					
					var oVO:ShopOrderExtraVO = _selectedOrderVO.extraList.getVO(i) as ShopOrderExtraVO
					if (oVO)
					{
						var sign:String = oVO.type == OrderExtraTypeID.FEE ? '+' : '-';
						ob.btnClose.addEventListener(ButtonEvent.CLICK, orderExtraEventHandler, false, 0, true);
						ob.setInfo(oVO);
						ob.txtTotal.text = Tools.getCurrencyCodeByNo(_selectedOrderVO.shopCurrency) + ': ' + sign + oVO.total.toString();
						ob.stopListener();
						
					}
					
				}
			}
			
			priceHandler();
			//form.mcScrollBar.refresh();
		}
		
		private function orderExtraEventHandler(e:ButtonEvent):void 
		{
			var b:OrderExtraButton = (e.targetButton as Button).parent as OrderExtraButton;
			if (b && b.vo is ShopOrderExtraVO)
			{
				_selectedOrderVO.extraList.removeVO(b.vo);
			}
		}
		
		private function statusHandler():void 
		{
			var targetStatusNode:XML = _statusXML.*.(@data == _selectedOrderVO.status)[0];
			if (targetStatusNode && _window)
			{
				var title:String = getMessage(_window.XMLSetting.@text);
				var status:String = ' (' + targetStatusNode.@label.toString() + ')';
				_window.txtTitle.text = title +  status ;
				_window.txtTitle.setTextFormat(Font.getTextFormat( { color:0xff0000, size:13, font:SWFClassID.SANS } ), _window.txtTitle.length - status.length, _window.txtTitle.length) ;
				//form.cbOrderStatus.dataProvider = new DataProvider(xmlOrderStatus);
				//form.cbOrderStatus.addEventListener(Event.CHANGE, cbEventHandler, false, 0, true);
				//form.cbOrderStatus.selectedIndex = int(_selectedOrderVO.status);
			}
			else
			{
				echo('unable to retrieve xml order status list!');
			}
		}
		
		private function textFieldEventHandler(e:Event):void 
		{
			priceHandler();
		}
		
		private function priceHandler():Boolean 
		{
			if (!form && !_selectedOrderVO) return false;
			
			var finalTotal:Number = myShopper.common.data.service.ShopVOService.getOrderFinalTotalByOrderVO(_selectedOrderVO);
			var extraTotal:Number = myShopper.common.data.service.ShopVOService.getOrderExtraTotalByVO(_selectedOrderVO.extraList);
			
			form.txtExtraTotal.text = extraTotal.toString();
			form.txtTotal.text = Tools.getCurrencyCodeByNo(_selectedOrderVO.shopCurrency) + ':' + finalTotal.toString();
			
			return true;
		}
		
		/*private function cbEventHandler(e:Event):void 
		{
			if (_alert)
			{
				form.removeApplicationChild(_alert);
				_alert = null;
			}
			
			if (form.cbOrderStatus.selectedIndex > 3)
			{
				createFormAlert(MessageID.FORM_MISSING_INFO, form.cbOrderStatus);
				
				form.cbOrderStatus.selectedIndex = int(_selectedOrderVO.status);
			}
		}*/
		
		
		
		//set window display object to the top of appFrom container
		public function setIndex(inIndex:int = -1):void 
		{
			if (!_window) return;
			
			appForm.setChildIndex(_window, inIndex == -1 ? appForm.numChildren - 1 : inIndex);
		}
		
		override public function startListener():void 
		{
			if (!form || !_window || !_selectedOrderVO) return;
			
			form.btnSend.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
			form.btnAddExtra.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
			
			_selectedOrderVO.extraList.addEventListener(VOEvent.VO_ADDED, voEventHandler, false, 0, true);
			_selectedOrderVO.extraList.addEventListener(VOEvent.VO_REMOVED, voEventHandler, false, 0, true);
			
			form.btnSend.startListener();
			form.btnSend.onMouseOver = function():void
			{
				Tweener.addTween(form.btnSend, TweenerEffect.setGlow(1, 'easeOutSine', 0xFF0000, 10, 5, 1));
			}
			form.btnSend.onMouseOut = function():void
			{
				Tweener.addTween(form.btnSend, TweenerEffect.resetGlow());
			}
			
			/*if (form2)
			{
				form2.mouseChildren = true;
				form2.btnSend.alpha = 1;
				form2.btnSend.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
				form2.btnBack.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
				
				form2.btnSend.startListener();
				form2.btnSend.onMouseOver = function():void
				{
					Tweener.addTween(form2.btnSend, TweenerEffect.setGlow(1, 'easeOutSine', 0xFF0000, 10, 5, 1));
				}
				form2.btnSend.onMouseOut = function():void
				{
					Tweener.addTween(form2.btnSend, TweenerEffect.resetGlow());
				}
			}*/
			
			
			if (!_window.btnClose.hasEventListener(ButtonEvent.CLICK))
			{
				_window.btnClose.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
			}
			
			form.btnPrint.addEventListener(ButtonEvent.CLICK, printEventHandler, false, 0, true);
		}
		
		override public function stopListener():void
		{
			if (!form || !_window) return;
			
			form.btnSend.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			form.btnAddExtra.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			form.mouseChildren = false;
			
			_selectedOrderVO.extraList.removeEventListener(VOEvent.VO_ADDED, voEventHandler, false);
			_selectedOrderVO.extraList.removeEventListener(VOEvent.VO_REMOVED, voEventHandler, false);
			
			Tweener.addTween(form.btnSend, TweenerEffect.resetGlow());
			form.btnSend.stopListener();
			form.btnSend.onMouseOver = null;
			form.btnSend.onMouseOut = null;
			
			/*if (form2)
			{
				form2.mouseChildren = false;
				form2.btnSend.alpha = .6;
				Tweener.addTween(form2.btnSend, TweenerEffect.resetGlow());
				form2.btnSend.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
				form2.btnBack.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
				
				form2.btnSend.stopListener();
				form2.btnSend.onMouseOver = null;
				form2.btnSend.onMouseOut = null;
			}*/
			
			
			//_window.btnClose.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			
		}
		
		private function voEventHandler(e:VOEvent):void 
		{
			refreshOrderProduct();
		}
		
		private function printEventHandler(e:ButtonEvent):void 
		{
			e.event.stopImmediatePropagation();
			
			//TODO : alert an option for user choosing print size
			sendNotification(ApplicationEvent.PRINT, _selectedOrderVO, String(PrintVOService.SIZE_80MM));
			//_printService.order(_selectedOrderVO, _shopInfoVO);
			
		}
		
		/*private function windownButtonEventHandler(e:ButtonEvent):void 
		{
			switch(e.targetButton)
			{
				
			}
		}*/
		
		private function buttonEventHandler(e:ButtonEvent):void 
		{
			switch(e.targetButton)
			{
				case _window.btnClose:
				{
					//sendNotification(WindowEvent.CLOSE, _window);
					sendNotification(WindowEvent.CLOSE, mediatorName);
					break;
				}
				//case form.btnSend:
				/*case form2.btnBack:
				{
					if (_selectedOrderVO.status == OrderStatusID.ORDER_ORDER)
					{
						//no break needed, show alert to confirm send invoice to user
					}
					else
					{
						_window.currPageIndex = e.targetButton === form.btnSend ? 1 : 0;
						break;
					}
					
					
				}*/
				case form.btnAddExtra:
				{
					sendNotification
					(
						WindowEvent.CREATE,
						_selectedOrderVO,
						ShopMgtEvent.SHOP_ADD_ORDER_EXTRA
					);
					break;
				}
				case form.btnSend:
				//case form2.btnSend:
				{
					var message:String;
					
					if (_selectedOrderVO.status == OrderStatusID.ORDER_ORDER)
					{
						message = Tools.formatString(getMessage(myShopper.shopMgtCommon.emun.MessageID.CONFIRM_SEND_INVOICE, 'string', AssetLibID.XML_LANG_SHOP_MGT), [_selectedOrderVO.userInfoVO.firstName, form.txtTotal.text] );
						
						
						var ca:ConfirmAlerter = Alert.show
						( 
							new AlerterVO
							(
								'', 
								AlerterType.CONFIRM, 
								'', 
								null, 
								getMessage(MessageID.CONFIRM_TITLE), 
								message
							)
						) as ConfirmAlerter;
						
						
						if (ca)
						{
							ca.addEventListener(AlerterEvent.CANCEL, confirmAlerterHandler);
							ca.addEventListener(AlerterEvent.CONFIRM, confirmAlerterHandler);
							ca.addEventListener(AlerterEvent.CLOSE, confirmAlerterHandler);
						}
					}
					else
					{
						//message = getMessage(myShopper.shopMgtCommon.emun.MessageID.CONFIRM_SHIPPING_METHOD, 'string', AssetLibID.XML_LANG_SHOP_MGT);
						
						if 
						(
							_selectedOrderVO.status == OrderStatusID.ORDER_PAID || 
							_selectedOrderVO.status == OrderStatusID.ORDER_PREPARE_DELIVERY || 
							_selectedOrderVO.status == OrderStatusID.ORDER_DELIVERING
						)
						{
							var result:* = form.isValid();
							if (result === true && form.cbOrderStatus.selectedItem.data != '-1')
							{
								stopListener();
								sendNotification(ShopMgtEvent.SHOP_UPDATE_ORDER_SHIPMENT, _selectedOrderVO);
							}
							else
							{
								createFormAlert(getMessage(MessageID.FORM_MISSING_INFO), form.cbOrderStatus);
							}
							
						}
					}
					
					
					
					break;
				}
			}
		}
		
		private function confirmAlerterHandler(e:AlerterEvent):void 
		{
			e.targetDisplayObject.removeEventListener(AlerterEvent.CANCEL, confirmAlerterHandler);
			e.targetDisplayObject.removeEventListener(AlerterEvent.CONFIRM, confirmAlerterHandler);
			e.targetDisplayObject.removeEventListener(AlerterEvent.CLOSE, confirmAlerterHandler);
			
			switch(e.type)
			{
				case AlerterEvent.CONFIRM:
				{
					//var result:* = form2.isValid();
					var result:* = form.isValid();
					if (result === true && myShopper.common.data.service.ShopVOService.getOrderFinalTotalByOrderVO(_selectedOrderVO) > 0) //check the total is greater than 0
					{
						
						stopListener();
						if (_window) _window.isBusy = true;
						//2 = 已安排送貨, shop has no right to change the status, once shop confirmed arrage shipping, set status to 2
						
						if (_selectedOrderVO.status == OrderStatusID.ORDER_ORDER)
						{
							sendNotification(ShopMgtEvent.SHOP_SEND_INVOICE, _selectedOrderVO);
						}
						
						
					}
					else
					{
						createFormAlert(getMessage(MessageID.FORM_MISSING_INFO), form.txtShippingFee);
					}
					break;
				}
			}
		}
		
		private function createFormAlert(inMessage:String, inItem:DisplayObject, inAutoClose:Boolean = true):void 
		{
			//var _form:ApplicationDisplayObject = _window.currPageIndex == 0 ? form : form2;
			if (form)
			{
				_alert = form.addApplicationChild(Alert.create(new AlerterVO('', '', '', null, '', inMessage)), null) as FormAlerter;
				
				_alert.x = inItem.x - _alert.width;
				_alert.y = inItem.y - _alert.height;
				if(inAutoClose) _alert.autoClose(3000);
			}
			
		}
	}
}