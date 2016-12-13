package myShopper.shopMgtModule.appForm.view 
{
	import myShopper.common.Config;
	import myShopper.common.data.AlerterVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.shop.ShopInfoList;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.display.Menu;
	import myShopper.common.emun.AlerterType;
	import myShopper.common.emun.MessageID;
	import myShopper.common.events.AlerterEvent;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.events.WindowEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.text.Font;
	import myShopper.common.utils.Alert;
	import myShopper.common.utils.TweenerEffect;
	import myShopper.fl.Alerter;
	import myShopper.fl.ConfirmAlerter;
	import myShopper.fl.shop.ShopNewsButton;
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
	
	public class ShopProfilesMediator extends ApplicationMediator implements IContainerMediator 
	{
		private var _appForm:ApplicationForm;
		public function get appForm():ApplicationForm 
		{
			if (!_appForm) _appForm = (container as FormMain).appForm;
			return _appForm;
		}
		
		private var _shopList:ShopInfoList;
		//private var _alert:FormAlerter;
		
		//private var form:ShopMgtAboutForm;
		private var _window:NewsWindow;
		//private var _bg:ApplicationDisplayObject;
		
		
		public function ShopProfilesMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
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
			_shopList.clear();
			_shopList = null;
		}
		
		override public function listNotificationInterests():Array 
		{
			return	[
						NotificationType.ADD_DISPLAY_PROFILES,
						NotificationType.DELETE_PROFILE_FAIL,
						NotificationType.DELETE_PROFILE_SUCCESS, //refresh list
						NotificationType.CREATE_PROFILE_SUCCESS //refresh list
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
				case NotificationType.ADD_DISPLAY_PROFILES:
				{
					_window = vo.displayObject as NewsWindow;
					_shopList = vo.data as ShopInfoList;
					
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
						
						_window.btnAdd.tooltip = getMessage(myShopper.shopMgtCommon.emun.MessageID.PROFILE_CREATE, 'string', AssetLibID.XML_LANG_SHOP_MGT);
						
						//shopInfo.productCategoryList.addEventListener(VOEvent.VO_ADDED, voEventHandler);
						//shopInfo.productCategoryList.addEventListener(VOEvent.VO_REMOVED, voEventHandler);
						
						startListener();
						refreshPage();
						_window.mcScrollBar.refresh();
					}
					
					break;
				}
				case NotificationType.CREATE_PROFILE_SUCCESS:
				case NotificationType.DELETE_PROFILE_SUCCESS:
				{
					_shopList = note.getBody() as ShopInfoList
					refreshPage();
					_window.mcScrollBar.refresh();
					break;
				}
				case NotificationType.DELETE_PROFILE_FAIL:
				{
					Alert.show(new AlerterVO('', AlerterType.MESSAGE, '', null, getMessage(MessageID.ERROR_TITLE), getMessage(MessageID.ERROR_GET_DATA)));
					sendNotification(WindowEvent.CLOSE, mediatorName);
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
					sendNotification(WindowEvent.CLOSE, mediatorName);
					break;
				}
				case _window.btnAdd:
				{
					sendNotification(WindowEvent.CREATE, null, ShopMgtEvent.SHOP_CREATE_PROFILE);
					break;
				}
			}
		}
		
		private function buttonEventHandler(e:ApplicationEvent):void 
		{
			trace(e.type);
			
			var selectedVO:ShopInfoVO = e.data as ShopInfoVO;
			
			/*if (selectedVO is ShopCategoryFormVO) 
			{
				_selectedCategoryVO = selectedVO;
			}*/
			
			switch(e.type)
			{
				/*case ApplicationEvent.DELETE:
				{
					sendNotification
					(
						WindowEvent.CREATE,
						selectedVO,
						ShopMgtEvent.SHOP_DELETE_NEWS
					);
					break;
				}*/
				case ApplicationEvent.MODIFY:
				{
					sendNotification
					(
						WindowEvent.CREATE,
						selectedVO,
						ShopMgtEvent.SHOP_UPDATE_PROFILE
					);
					break;
				}
			}
			
		}
		
		
		private function refreshPage():void 
		{
			if (_window.holder.content is Menu)
			{
				Menu(_window.holder.content).removeAllButton();
			}
			
			var numItem:int = _shopList.length;
			if (numItem)
			{
				for (var i:int = 0; i < numItem; i++)
				{
					var b:ShopMgtNewsButton = assetManager.getData(AssetClassID.BTN_SHOP_NEWS, AssetLibID.AST_SHOP_MGT);
					var vo:ShopInfoVO = _shopList.getVO(i) as ShopInfoVO;
					if (b && vo)
					{
						_window.holder.addApplicationChild(b, null, false);
						
						b.setInfo(vo);
						b.txtNo.text = String(i + 1) + '.';
						b.txtName.text = vo.name;
						b.txtDate.text = vo.shopNo;
						b.stopListener();
						b.btnModify.tooltip = getMessage(MessageID.tt1002);
						b.btnDelete.tooltip = getMessage(MessageID.tt1001);
						b.addEventListener(ApplicationEvent.DELETE, shopDeletionHandler, false, 0, true);
						b.addEventListener(ApplicationEvent.MODIFY, buttonEventHandler, false, 0, true);
						//head shop should never be deleted
						b.btnDelete.visible = i > 0;
					}
					else
					{
						echo('buttonEventHandler : vo added : fail setting vo to button : ' + b);
					}
					
				}
				
			}
		}
		
		private function shopDeletionHandler(e:ApplicationEvent):void
		{
			if (e.type == ApplicationEvent.DELETE && e.data is ShopInfoVO)
			{
				var title:String = getMessage(MessageID.CONFIRM_TITLE);
				var content:String = getMessage(MessageID.CONFIRM_DELETE);
				var ca:ConfirmAlerter = Alert.show(new AlerterVO('', AlerterType.CONFIRM, '', e.data, title, content)) as ConfirmAlerter;
				
				if (ca)
				{
					ca.addEventListener(AlerterEvent.CANCEL, alterDeleteEventHandler, false, 0, true);
					ca.addEventListener(AlerterEvent.CLOSE, alterDeleteEventHandler, false, 0, true);
					ca.addEventListener(AlerterEvent.CONFIRM, alterDeleteEventHandler, false, 0, true);
				}
			}
		}
		
		private function alterDeleteEventHandler(e:AlerterEvent):void 
		{
			e.targetDisplayObject.removeEventListener(AlerterEvent.CANCEL, alterDeleteEventHandler);
			e.targetDisplayObject.removeEventListener(AlerterEvent.CLOSE, alterDeleteEventHandler);
			e.targetDisplayObject.removeEventListener(AlerterEvent.CONFIRM, alterDeleteEventHandler);
			
			var alerterVO:AlerterVO = e.data as AlerterVO;
			if (e.type == AlerterEvent.CONFIRM && alerterVO && alerterVO.data is ShopInfoVO)
			{
				sendNotification(ShopMgtEvent.SHOP_DELETE_PROFILE, alerterVO.data);
			}
		}
		
	}
}