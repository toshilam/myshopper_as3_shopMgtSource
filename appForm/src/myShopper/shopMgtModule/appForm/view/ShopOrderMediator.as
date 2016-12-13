package myShopper.shopMgtModule.appForm.view 
{
	import myShopper.common.Config;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.shop.ShopOrderVO;
	import myShopper.common.display.Menu;
	import myShopper.common.emun.AssetXMLNodeID;
	import myShopper.common.emun.SWFClassID;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.events.VOEvent;
	import myShopper.common.events.WindowEvent;
	import myShopper.common.interfaces.IDataDisplayObject;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.text.Font;
	import myShopper.common.utils.Tools;
	import myShopper.common.utils.TweenerEffect;
	import myShopper.fl.shopMgt.button.ShopMgtOrderButton;
	import myShopper.fl.shopMgt.order.ShopMgtOrderInfo;
	import myShopper.fl.window.BaseWindow;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtModule.appForm.enum.AssetClassID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.FormMain;
	import myShopper.shopMgtModule.appForm.view.component.ApplicationForm;
	import org.puremvc.as3.multicore.interfaces.IContainerMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class ShopOrderMediator extends ApplicationMediator implements IContainerMediator 
	{
		private var _appForm:ApplicationForm;
		public function get appForm():ApplicationForm 
		{
			if (!_appForm) _appForm = (container as FormMain).appForm;
			return _appForm;
		}
		
		private var _shopInfoVO:ShopInfoVO;
		private var _statusXML:XML;
		//private var _alert:FormAlerter;
		
		private var _content:ShopMgtOrderInfo;
		private var _window:BaseWindow;
		//private var _bg:ApplicationDisplayObject;
		
		
		public function ShopOrderMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
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
				throw(new UninitializedError('ShopOrderMediator : onRegister : unable to retreve shop vo/xml'));
			}
			
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			//_window.mcScrollBar.scrollTarget = null;
			if (_window) appForm.removeApplicationChild(_window, false);
			
			stopListener();
			_appForm = null;
			_content = null;
			_window = null;
			_shopInfoVO = null;
			_statusXML = null;
		}
		
		override public function listNotificationInterests():Array 
		{
			return	[
						NotificationType.ADD_DISPLAY_ORDER, NotificationType.REFRESH_DISPLAY_ORDER
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
				case NotificationType.ADD_DISPLAY_ORDER:
				{
					_window = vo.displayObject as BaseWindow;
					
					if (_window)
					{
						//_window.txtTitle.embedFonts = false;
						//_window.txtTitle.defaultTextFormat = Font.getTextFormat( { size:18, letterSpacing:2, font:SWFClassID.SANS } );
						setTextField(_window.txtTitle, language == Config.LANG_CODE_EN);
						
						var windowNode:XML = vo.settingXML;
						
						appForm.addApplicationChild(_window, windowNode, false);
						_content = _window.addApplicationChild(assetManager.getData(AssetClassID.FORM_SHOP_ORDER_INFO, AssetLibID.AST_SHOP_MGT), null, false) as ShopMgtOrderInfo;
						
						_window.showPage(TweenerEffect.setAlpha(1));
						_window.setSize(_window.mcBG.width, _window.mcBG.height + _window.mcHeader.height);
						_content.holder.setMask(0, 0, _window.mcBG.width, _window.mcBG.height - _window.mcHeader.height - _window.mcFooter.height- 10);
						_content.mcScrollBar.height = _window.height - _window.mcHeader.height - _window.mcFooter.height;
						
						_window.x = mainStage.stageWidth - _window.width >> 1;
						_window.y = mainStage.stageHeight - (_window.mcBG.height + _window.mcHeader.height) >> 1;
						
						
						_content.refresh();
						refreshOrderList();
						startListener();
					}
					
					break;
				}
				case NotificationType.REFRESH_DISPLAY_ORDER:
				{
					if (_window) refreshOrderList();
					break;
				}
				
			}
			
			
		}
		
		private function refreshOrderList():void 
		{
			if (_content && _content.holder.content is Menu)
			{
				//clear all previous added button
				(_content.holder.content as Menu).removeAllButton();
				
				var numItem:int = _shopInfoVO.shopOrderList.length;
				for (var i:int = numItem - 1; i >= 0; i--)
				{
					var b:ShopMgtOrderButton = assetManager.getData(AssetClassID.BTN_SHOP_ORDER, AssetLibID.AST_SHOP_MGT);
					if (b)
					{
						//b.btnText.txt.embedFonts = true;
						//b.btnText.txt.defaultTextFormat = Font.getTextFormat( { size:15, letterSpacing:2, font:Font.getDefaultFontByLang(language) } );
						
						_content.holder.addApplicationChild(b, null, false);
						var oVO:ShopOrderVO = _shopInfoVO.shopOrderList.getVO(i) as ShopOrderVO;
						var targetStatusNode:XML = _statusXML.*.(@data == oVO.status)[0];
						
						oVO.addEventListener(VOEvent.VALUE_CHANGED, voStatusHandler, false, 0, true);
						
						if (targetStatusNode)
						{
							b.setInfo(oVO);
							b.txtNo.text = String(i + 1) + '.';
							b.txtInvoiceNo.text = oVO.invoiceNo;
							b.txtTotal.text = '(' + targetStatusNode.@label.toString() + ')';
							//b.txtTotal.text = Tools.getCurrencyCodeByNo(oVO.shopCurrency) + ' : ' + oVO.total;
							b.addEventListener(ButtonEvent.CLICK, buttonEventHandler, false, 0, true);
						}
						else
						{
							echo('handleNotification : unable to retreve status xml');
						}
						
						
					}
				}
				
				_content.mcScrollBar.refresh();
			}
			
		}
		
		private function voStatusHandler(e:VOEvent):void 
		{
			if (e.data is ShopOrderVO) 
			{
				refreshOrderList();
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
			
			_window.btnClose.addEventListener(ButtonEvent.CLICK, windownButtonEventHandler);
		}
		
		override public function stopListener():void
		{
			if (_window) return;
			
			_window.btnClose.removeEventListener(ButtonEvent.CLICK, windownButtonEventHandler);
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
						ShopMgtEvent.SHOP_VIEW_ORDER
					);
					
					break;
				}
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