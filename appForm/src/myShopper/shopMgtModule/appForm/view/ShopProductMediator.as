package myShopper.shopMgtModule.appForm.view 
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import myShopper.common.Config;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.shop.ShopCategoryFormVO;
	import myShopper.common.data.shop.ShopCategoryList;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.shop.ShopProductFormVO;
	import myShopper.common.data.VOList;
	import myShopper.common.display.button.Button;
	import myShopper.common.emun.SWFClassID;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.events.VOEvent;
	import myShopper.common.events.WindowEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.interfaces.IVO;
	import myShopper.common.text.Font;
	import myShopper.common.utils.Tools;
	import myShopper.common.utils.Tracer;
	import myShopper.common.utils.TweenerEffect;
	import myShopper.fl.FormAlerter;
	import myShopper.fl.shopMgt.button.ShopMgtCategoryButton;
	import myShopper.fl.shopMgt.button.ShopMgtProductButton;
	import myShopper.fl.shopMgt.ProductWindow;
	import myShopper.fl.window.MultiPageWindow;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.emun.MessageID;
	import myShopper.common.emun.MessageID;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtModule.appForm.enum.AssetClassID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.FormMain;
	import myShopper.shopMgtModule.appForm.model.service.SalesVOService;
	import myShopper.shopMgtModule.appForm.view.component.ApplicationForm;
	import org.puremvc.as3.multicore.interfaces.IContainerMediator;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class ShopProductMediator extends ApplicationMediator implements IContainerMediator 
	{
		private var _appForm:ApplicationForm;
		public function get appForm():ApplicationForm 
		{
			if (!_appForm) _appForm = (container as FormMain).appForm;
			return _appForm;
		}
		
		private var _shopInfoVO:ShopInfoVO;
		//private var _alert:FormAlerter;
		
		//private var form:ShopMgtAboutForm;
		private var _window:ProductWindow;
		//private var _bg:ApplicationDisplayObject;
		
		private var _selectedCategoryVO:IVO;
		private var _salesService:SalesVOService;
		
		public function ShopProductMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
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
			_window.mcScrollBar.scrollTarget = null;
			if (_window) appForm.removeApplicationChild(_window, false);
			
			stopListener();
			_appForm = null;
			_window = null;
			_shopInfoVO = null;
			
			if (_salesService)
			{
				_salesService.clear();
				_salesService = null;
			}
			
		}
		
		override public function listNotificationInterests():Array 
		{
			return	[
						NotificationType.ADD_DISPLAY_PRODUCT, 
						NotificationType.RESULT_GET_CATEGORY_PRODUCT, 
						NotificationType.UPDATE_CATEGORY_SUCCESS, //refresh category list
						NotificationType.CREATE_CATEGORY_SUCCESS, //refresh category list
						NotificationType.DELETE_CATEGORY_SUCCESS, //refresh category list
						NotificationType.CREATE_PRODUCT_SUCCESS, //refresh product list
						NotificationType.DELETE_PRODUCT_SUCCESS, //refresh product list
						NotificationType.UPDATE_PRODUCT_SUCCESS //refresh product list
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
				case NotificationType.ADD_DISPLAY_PRODUCT:
				{
					_window = vo.displayObject as ProductWindow;
					_shopInfoVO = vo.data as ShopInfoVO;
					_salesService = new SalesVOService(_shopInfoVO.productCategoryList);
					
					if (_window)
					{
						//_window.txtTitle.embedFonts = false;
						//_window.txtTitle.defaultTextFormat = Font.getTextFormat( { size:18, letterSpacing:2, font:SWFClassID.SANS } );
						setTextField(_window.txtTitle, language == Config.LANG_CODE_EN);
						
						appForm.addApplicationChild(_window, vo.settingXML, false);
						_window.showPage(TweenerEffect.setAlpha(1));
						_window.addPage(0);
						_window.setSize(300, 430);
						_window.x = mainStage.stageWidth - _window.width >> 1;
						_window.y = mainStage.stageHeight - _window.height >> 1;
						
						//shopInfo.productCategoryList.addEventListener(VOEvent.VO_ADDED, voEventHandler);
						//shopInfo.productCategoryList.addEventListener(VOEvent.VO_REMOVED, voEventHandler);
						
						_window.isBusy = true;
						startListener();
					}
					
					break;
				}
				case NotificationType.RESULT_GET_CATEGORY_PRODUCT:
				case NotificationType.UPDATE_CATEGORY_SUCCESS:
				case NotificationType.CREATE_CATEGORY_SUCCESS:
				case NotificationType.DELETE_CATEGORY_SUCCESS:
				{
					refreshCategoryPage();
					_window.mcScrollBar.refresh();
					_window.currPageIndex = 0;
					
					_window.isBusy = false;
					break;
				}
				
				case NotificationType.CREATE_PRODUCT_SUCCESS:
				case NotificationType.UPDATE_PRODUCT_SUCCESS:
				case NotificationType.DELETE_PRODUCT_SUCCESS:
				{
					if (_window.currPageIndex == 1) 
					{
						refreshCategoryPage(); //refresh number of product
						refreshProductPage((_selectedCategoryVO as ShopCategoryFormVO).productList);
						_window.mcScrollBar.refresh();
						
						_window.isBusy = false;
					}
					break;
				}
				
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
			_window.btnBack.addEventListener(ButtonEvent.CLICK, windownButtonEventHandler, false, 0, true);
			_window.btnAdd.addEventListener(ButtonEvent.CLICK, windownButtonEventHandler, false, 0, true);
			_window.txtName.addEventListener(Event.CHANGE, searchEventHandler, false, 0, true);
			_window.btnClear.addEventListener(ButtonEvent.CLICK, searchFormButtonHandler, false, 0, true);
		}
		
		override public function stopListener():void
		{
			if (_window) return;
			
			_window.btnClose.removeEventListener(ButtonEvent.CLICK, windownButtonEventHandler);
			_window.btnBack.removeEventListener(ButtonEvent.CLICK, windownButtonEventHandler);
			_window.btnAdd.removeEventListener(ButtonEvent.CLICK, windownButtonEventHandler);
			_window.txtName.removeEventListener(Event.CHANGE, searchEventHandler);
			_window.btnClear.removeEventListener(ButtonEvent.CLICK, searchFormButtonHandler);
		}
		
		private function searchEventHandler(e:Event):void 
		{
			var numItem:int = 0;
			numItem = _shopInfoVO.productCategoryList.length;
			var strSearch:String = _window.txtName.text;
			
			if (numItem && strSearch && strSearch.length)
			{
				var voList:VOList = _salesService.getProductByKeyword(strSearch);
				numItem = voList.length;
				//if (numItem)
				//{
					refreshProductPage(voList);
					_window.currPageIndex = 1;
				//}
				_window.txtFooter.text = Tools.formatString(getMessage(myShopper.shopMgtCommon.emun.MessageID.TOTAL_PRODUCT, 'string', AssetLibID.XML_LANG_SHOP_MGT), [numItem.toString()]);
				
			}
			else
			{
				refreshCategoryPage();
			}
		}
		
		private function searchFormButtonHandler(e:ButtonEvent):void 
		{
			var targetButton:Button = e.targetButton as Button;
			if (targetButton === _window.btnClear)
			{
				refreshCategoryPage();
				_window.txtName.text = '';
				_window.mcScrollBar.refresh();
				_window.currPageIndex = 0;
			}
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
				case _window.btnAdd:
				{
					sendNotification(WindowEvent.CREATE, _selectedCategoryVO, _window.currPageIndex == 0 ? ShopMgtEvent.SHOP_CREATE_CATEGORY : ShopMgtEvent.SHOP_CREATE_PRODUCT);
					break;
				}
				case _window.btnBack:
				{
					if (_window.currPageIndex > 0)
					{
						_window.currPageIndex--;
					}
					break;
				}
			}
		}
		
		private function buttonEventHandler(e:ApplicationEvent):void 
		{
			trace(e.type);
			var selectedVO:IVO = e.data as IVO;
			
			if (selectedVO is ShopCategoryFormVO) 
			{
				_selectedCategoryVO = selectedVO;
			}
			
			switch(e.type)
			{
				case ApplicationEvent.MORE:
				{
					var categoryVO:ShopCategoryFormVO = _selectedCategoryVO as ShopCategoryFormVO;
					if (categoryVO)
					{
						refreshProductPage(categoryVO.productList);
						_window.currPageIndex = 1;
					}
					
					break;
				}
				case ApplicationEvent.DELETE:
				{
					sendNotification
					(
						WindowEvent.CREATE,
						selectedVO,
						_window.currPageIndex == 0 ? ShopMgtEvent.SHOP_DELETE_CATEGORY : ShopMgtEvent.SHOP_DELETE_PRODUCT
					);
					break;
				}
				case ApplicationEvent.MODIFY:
				{
					sendNotification
					(
						WindowEvent.CREATE,
						selectedVO,
						_window.currPageIndex == 0 ? ShopMgtEvent.SHOP_UPDATE_CATEGORY : ShopMgtEvent.SHOP_UPDATE_PRODUCT
					);
					break;
				}
				case ApplicationEvent.CLONE:
				{
					if (_window.currPageIndex == 1)
					{
						sendNotification(WindowEvent.CREATE, selectedVO, ShopMgtEvent.SHOP_CLONE_PRODUCT);
					}
					break;
				}
				case ApplicationEvent.SHARE:
				{
					if (_window.currPageIndex == 1)
					{
						sendNotification(WindowEvent.CREATE, selectedVO, ApplicationEvent.SHARE);
					}
					break;
				}
			}
			
		}
		
		private function refreshCategoryPage():void 
		{
			_window.removeAllItem(0); //refresh
			_window.txtFooter.text = '';
			
			var numItem:int = _shopInfoVO.productCategoryList.length;
			for (var i:int = 0; i < numItem; i++)
			{
				var b:ShopMgtCategoryButton = assetManager.getData(AssetClassID.BTN_SHOP_CATEGORY, AssetLibID.AST_SHOP_MGT);
				var categoryVO:ShopCategoryFormVO = _shopInfoVO.productCategoryList.getVO(i) as ShopCategoryFormVO;
				
				if (b && categoryVO && b.setInfo(categoryVO))
				{
					_window.addItem(0, b);
					b.txtNo.text = String(i + 1) + '.';
					//b.txtTotal.embedFonts = false;
					//b.txtTotal.defaultTextFormat = Font.getTextFormat( { font:SWFClassID.SANS } );
					setTextField(b.txtTotal, false, Font.getTextFormat( { font:SWFClassID.SANS } ));
					b.txtTotal.autoSize = TextFieldAutoSize.LEFT;
					b.txtTotal.text = Tools.formatString(getMessage(myShopper.shopMgtCommon.emun.MessageID.TOTAL_PRODUCT, 'string', AssetLibID.XML_LANG_SHOP_MGT), [categoryVO.numberOfProduct.toString()]);
					b.addEventListener(ApplicationEvent.DELETE, buttonEventHandler, false, 0, true);
					b.addEventListener(ApplicationEvent.MODIFY, buttonEventHandler, false, 0, true);
					b.addEventListener(ApplicationEvent.MORE, buttonEventHandler, false, 0, true);
					
					b.btnDelete.tooltip = getMessage(myShopper.common.emun.MessageID.tt1001);
					b.btnModify.tooltip = getMessage(myShopper.common.emun.MessageID.tt1002);
					b.btnMore.tooltip = getMessage(myShopper.common.emun.MessageID.tt1003);
					
					b.updateInfo();
				}
				else
				{
					echo('listNotificationInterests : vo added : fail setting vo to button : ' + b);
				}
				
			}
		}
		
		private function refreshProductPage(inCategoryVO:VOList/*ShopCategoryFormVO*/):void 
		{
			if (!_window.hasPage(1)) _window.addPage(1);
			_window.removeAllItem(1);
			
			//var numItem:int = inCategoryVO.productList.length;
			var numItem:int = inCategoryVO.length;
			if (numItem)
			{
				for (var i:int = 0; i < numItem; i++)
				{
					var b:ShopMgtProductButton = assetManager.getData(AssetClassID.BTN_SHOP_PRODUCT, AssetLibID.AST_SHOP_MGT);
					//var productVO:ShopProductFormVO = inCategoryVO.productList.getVO(i) as ShopProductFormVO;
					var productVO:ShopProductFormVO = inCategoryVO.getVO(i) as ShopProductFormVO;
					
					if (b && productVO && b.setInfo(productVO))
					{
						_window.addItem(1, b);
						b.txtNo.text = String(i + 1) + '.';
						b.addEventListener(ApplicationEvent.DELETE, buttonEventHandler, false, 0, true);
						b.addEventListener(ApplicationEvent.MODIFY, buttonEventHandler, false, 0, true);
						b.addEventListener(ApplicationEvent.SHARE, buttonEventHandler, false, 0, true);
						b.addEventListener(ApplicationEvent.CLONE, buttonEventHandler, false, 0, true);
						
						b.btnDelete.tooltip = getMessage(myShopper.common.emun.MessageID.tt1001);
						b.btnModify.tooltip = getMessage(myShopper.common.emun.MessageID.tt1002);
						b.btnClone.tooltip = getMessage(myShopper.common.emun.MessageID.tt1004);
						b.btnShare.tooltip = getMessage(myShopper.common.emun.MessageID.tt1005);
						
						b.updateInfo();
						
						CONFIG::air
						{
							b.btnShare.visible = false;
						}
					}
					else
					{
						echo('buttonEventHandler : vo added : fail setting vo to button : ' + b);
					}
					
				}
				
			}
		}
		
		
		
	}
}