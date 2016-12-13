package myShopper.shopMgtModule.appForm.view 
{
	import myShopper.common.Config;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.shop.ShopNewsList;
	import myShopper.common.display.Menu;
	import myShopper.common.emun.MessageID;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.events.WindowEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.interfaces.IVO;
	import myShopper.common.text.Font;
	import myShopper.common.utils.TweenerEffect;
	import myShopper.fl.shopMgt.button.ShopMgtNewsButton;
	import myShopper.fl.shopMgt.NewsWindow;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtModule.appForm.enum.AssetClassID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.FormMain;
	import myShopper.shopMgtModule.appForm.view.component.ApplicationForm;
	import org.puremvc.as3.multicore.interfaces.IContainerMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class ShopNewsMediator extends ApplicationMediator implements IContainerMediator 
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
		private var _window:NewsWindow;
		//private var _bg:ApplicationDisplayObject;
		
		
		public function ShopNewsMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
		{
			super(inMediatorName, inViewComponent);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
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
		}
		
		override public function listNotificationInterests():Array 
		{
			return	[
						NotificationType.ADD_DISPLAY_NEWS, 
						NotificationType.RESULT_GET_NEWS, 
						NotificationType.UPDATE_NEWS_SUCCESS, //refresh list
						NotificationType.CREATE_NEWS_SUCCESS, //refresh list
						NotificationType.DELETE_NEWS_SUCCESS, //refresh list
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
				case NotificationType.ADD_DISPLAY_NEWS:
				{
					_window = vo.displayObject as NewsWindow;
					_shopInfoVO = vo.data as ShopInfoVO;
					
					if (_window)
					{
						//_window.txtTitle.embedFonts = true;
						//_window.txtTitle.defaultTextFormat = Font.getTextFormat( { size:18, letterSpacing:2, font:Font.getDefaultFontByLang(language) } );
						setTextField(_window.txtTitle, language == Config.LANG_CODE_EN);
						
						appForm.addApplicationChild(_window, vo.settingXML, false);
						_window.showPage(TweenerEffect.setAlpha(1));
						_window.setSize(300, 400);
						_window.x = mainStage.stageWidth - _window.width >> 1;
						_window.y = mainStage.stageHeight - _window.height >> 1;
						
						//shopInfo.productCategoryList.addEventListener(VOEvent.VO_ADDED, voEventHandler);
						//shopInfo.productCategoryList.addEventListener(VOEvent.VO_REMOVED, voEventHandler);
						
						startListener();
					}
					
					break;
				}
				case NotificationType.RESULT_GET_NEWS:
				case NotificationType.CREATE_NEWS_SUCCESS:
				case NotificationType.UPDATE_NEWS_SUCCESS:
				case NotificationType.DELETE_NEWS_SUCCESS:
				{
					refreshNewsPage(_shopInfoVO.newList);
					_window.mcScrollBar.refresh();
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
			
			_window.btnClose.addEventListener(ButtonEvent.CLICK, windownButtonEventHandler);
			_window.btnAdd.addEventListener(ButtonEvent.CLICK, windownButtonEventHandler);
		}
		
		override public function stopListener():void
		{
			if (!_window) return;
			
			_window.btnClose.removeEventListener(ButtonEvent.CLICK, windownButtonEventHandler);
			_window.btnAdd.removeEventListener(ButtonEvent.CLICK, windownButtonEventHandler);
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
					sendNotification(WindowEvent.CREATE, null, ShopMgtEvent.SHOP_CREATE_NEWS);
					break;
				}
			}
		}
		
		private function buttonEventHandler(e:ApplicationEvent):void 
		{
			trace(e.type);
			var selectedVO:IVO = e.data as IVO;
			
			/*if (selectedVO is ShopCategoryFormVO) 
			{
				_selectedCategoryVO = selectedVO;
			}*/
			
			switch(e.type)
			{
				case ApplicationEvent.DELETE:
				{
					sendNotification
					(
						WindowEvent.CREATE,
						selectedVO,
						ShopMgtEvent.SHOP_DELETE_NEWS
					);
					break;
				}
				case ApplicationEvent.MODIFY:
				{
					sendNotification
					(
						WindowEvent.CREATE,
						selectedVO,
						ShopMgtEvent.SHOP_UPDATE_NEWS
					);
					break;
				}
			}
			
		}
		
		
		private function refreshNewsPage(inNewsList:ShopNewsList):void 
		{
			if (_window.holder.content is Menu)
			{
				Menu(_window.holder.content).removeAllButton();
			}
			
			var numItem:int = inNewsList.length;
			if (numItem)
			{
				for (var i:int = 0; i < numItem; i++)
				{
					var b:ShopMgtNewsButton = assetManager.getData(AssetClassID.BTN_SHOP_NEWS, AssetLibID.AST_SHOP_MGT);
					
					if (b && b.setInfo(inNewsList.getVO(i)))
					{
						_window.holder.addApplicationChild(b, null, false);
						
						b.txtNo.text = String(i + 1) + '.';
						b.btnDelete.tooltip = getMessage(MessageID.tt1001);
						b.btnModify.tooltip = getMessage(MessageID.tt1002);
						b.addEventListener(ApplicationEvent.DELETE, buttonEventHandler, false, 0, true);
						b.addEventListener(ApplicationEvent.MODIFY, buttonEventHandler, false, 0, true);
						
						b.updateInfo();
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