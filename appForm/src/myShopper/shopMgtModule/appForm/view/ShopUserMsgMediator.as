package myShopper.shopMgtModule.appForm.view 
{
	import myShopper.common.Config;
	import myShopper.common.data.AlerterVO;
	import myShopper.common.data.communication.CommList;
	import myShopper.common.data.communication.UserShopCommVO;
	import myShopper.common.data.communication.UserShopCommVOList;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.emun.AlerterType;
	import myShopper.common.emun.SWFClassID;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.events.WindowEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.interfaces.IVO;
	import myShopper.common.text.Font;
	import myShopper.common.utils.Alert;
	import myShopper.common.utils.Tools;
	import myShopper.common.utils.TweenerEffect;
	import myShopper.fl.shopMgt.button.ShopMgtUserMsgUserButton;
	import myShopper.fl.shopMgt.button.ShopMgtUserMsgUserMsgButton;
	import myShopper.fl.shopMgt.UserMessageWindow;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.emun.MessageID;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtModule.appForm.enum.AssetClassID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.FormMain;
	import myShopper.shopMgtModule.appForm.view.component.ApplicationForm;
	import org.puremvc.as3.multicore.interfaces.IContainerMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class ShopUserMsgMediator extends ApplicationMediator implements IContainerMediator 
	{
		private var _appForm:ApplicationForm;
		public function get appForm():ApplicationForm 
		{
			if (!_appForm) _appForm = (container as FormMain).appForm;
			return _appForm;
		}
		
		private var _commList:CommList;
		//private var _alert:FormAlerter;
		
		//private var form:ShopMgtAboutForm;
		private var _window:UserMessageWindow;
		//private var _bg:ApplicationDisplayObject;
		
		private var _selectedVO:UserShopCommVOList;
		
		public function ShopUserMsgMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
		{
			super(inMediatorName, inViewComponent);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			//_messageService = new MessageService(xmlManager as XMLManager, AssetLibID.XML_LANG_COMMON, 'string');
			_commList = voManager.getAsset(VOID.COMM_SHOP_USER_INFO);
			
			if (!_commList)
			{
				throw(new UninitializedError('unable to retreve vo!') );
			}
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			_window.mcScrollBar.scrollTarget = null;
			if (_window) appForm.removeApplicationChild(_window, false);
			
			stopListener();
			_appForm = null;
			_window = null;
			//_shopInfoVO = null;
		}
		
		override public function listNotificationInterests():Array 
		{
			return	[
						NotificationType.ADD_DISPLAY_USER_MESSAGE,
						NotificationType.GET_USER_SHOP_MESSAGE_LIST_SUCCESS, 
						NotificationType.GET_USER_SHOP_MESSAGE_LIST_FAIL,
						NotificationType.GET_USER_SHOP_MESSAGE_BY_UID_SUCCESS,
						NotificationType.GET_USER_SHOP_MESSAGE_BY_UID_FAIL,
						NotificationType.CREATE_USER_MSG_SUCCESS //refresh list
						//NotificationType.CREATE_USER_MSG_FAIL //refresh list
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
				case NotificationType.ADD_DISPLAY_USER_MESSAGE:
				{
					_window = vo.displayObject as UserMessageWindow;
					//_shopInfoVO = vo.data as ShopInfoVO;
					
					if (_window)
					{
						//_window.txtTitle.embedFonts = false;
						//_window.txtTitle.defaultTextFormat = Font.getTextFormat( { size:18, letterSpacing:2, font:SWFClassID.SANS } );
						setTextField(_window.txtTitle, language == Config.LANG_CODE_EN);
						
						appForm.addApplicationChild(_window, vo.settingXML, false);
						_window.showPage(TweenerEffect.setAlpha(1));
						_window.addPage(0);
						_window.addPage(1);
						_window.setSize(300, 400);
						_window.x = mainStage.stageWidth - _window.width >> 1;
						_window.y = mainStage.stageHeight - _window.height >> 1;
						
						//shopInfo.productCategoryList.addEventListener(VOEvent.VO_ADDED, voEventHandler);
						//shopInfo.productCategoryList.addEventListener(VOEvent.VO_REMOVED, voEventHandler);
						
						startListener();
						
						
						_window.btnAdd.visible = false;
						_window.isBusy = true;
						return;
					}
					
					break;
				}
				case NotificationType.GET_USER_SHOP_MESSAGE_LIST_SUCCESS:
				{
					refreshUserMessagePage();
					_window.currPageIndex = 0;
					break;
				}
				case NotificationType.GET_USER_SHOP_MESSAGE_BY_UID_SUCCESS:
				{
					//_window.currPageIndex = 1; // no need to set page, as it's supposed in page 1
					refreshUserMessageUserPage(_selectedVO);
					startListener();
					break;
				}
				case NotificationType.GET_USER_SHOP_MESSAGE_LIST_FAIL:
				case NotificationType.GET_USER_SHOP_MESSAGE_BY_UID_FAIL:
				{
					Alert.show
					(
						new AlerterVO
						(
							'', 
							AlerterType.MESSAGE, 
							'', 
							null, 
							getMessage(myShopper.common.emun.MessageID.ERROR_TITLE), 
							getMessage(myShopper.common.emun.MessageID.ERROR_GET_DATA)
						)
					);
					break;
				}
				
				case NotificationType.CREATE_USER_MSG_SUCCESS:
				{
					if (_window.currPageIndex == 1) 
					{
						refreshUserMessageUserPage(_selectedVO); //refresh number of product
						
					}
					break;
				}
				
			}
			
			if (_window) _window.isBusy = false;
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
			_window.btnBack.addEventListener(ButtonEvent.CLICK, windownButtonEventHandler);
			_window.btnAdd.addEventListener(ButtonEvent.CLICK, windownButtonEventHandler);
		}
		
		override public function stopListener():void
		{
			if (_window) return;
			
			_window.btnClose.removeEventListener(ButtonEvent.CLICK, windownButtonEventHandler);
			_window.btnBack.removeEventListener(ButtonEvent.CLICK, windownButtonEventHandler);
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
					if (_selectedVO && _window.currPageIndex == 1)
					{
						sendNotification(WindowEvent.CREATE, _selectedVO,  ShopMgtEvent.SHOP_CREATE_USER_SHOP_MESSAGE);
					}
					
					break;
				}
				case _window.btnBack:
				{
					if (_window.currPageIndex > 0)
					{
						_window.currPageIndex = 0;
						refreshUserMessagePage();
						_window.btnAdd.visible = false;
					}
					break;
				}
			}
		}
		
		private function buttonEventHandler(e:ApplicationEvent):void 
		{
			trace(e.type);
			_selectedVO = e.data as UserShopCommVOList;
			
			switch(e.type)
			{
				case ApplicationEvent.MORE:
				{
					if (_selectedVO)
					{
						//avoid user download another user data while downloading one
						stopListener();
						_window.isBusy = true;
						_window.currPageIndex = 1;
						sendNotification(ShopMgtEvent.SHOP_GET_USER_SHOP_MESSAGE, _selectedVO);
						
					}
					
					break;
				}
				
				/*case ApplicationEvent.DELETE:
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
				}*/
			}
			
		}
		
		private function refreshUserMessagePage():void 
		{
			_window.removeAllItem(0); //refresh
			
			var numItem:int = _commList.length;
			for (var i:int = 0; i < numItem; i++)
			{
				var b:ShopMgtUserMsgUserButton = assetManager.getData(AssetClassID.BTN_SHOP_USER_MSG_USER, AssetLibID.AST_SHOP_MGT);
				var commVOList:UserShopCommVOList = _commList.getVO(i) as UserShopCommVOList;
				
				if (b && commVOList && b.setInfo(commVOList))
				{
					_window.addItem(0, b);
					b.txtNo.text = String(i + 1) + '.';
					b.txtTotal.text = Tools.formatString(getMessage(MessageID.TOTAL_UNREAD_USER_MESSAGE, 'string', AssetLibID.XML_LANG_SHOP_MGT), [commVOList.numUnRead.toString()]);
					//b.addEventListener(ApplicationEvent.DELETE, buttonEventHandler, false, 0, true);
					//b.addEventListener(ApplicationEvent.MODIFY, buttonEventHandler, false, 0, true);
					b.addEventListener(ApplicationEvent.MORE, buttonEventHandler, false, 0, true);
					
					b.updateInfo();
				}
				else
				{
					echo('listNotificationInterests : vo added : fail setting vo to button : ' + b);
				}
				
			}
			
			_window.mcScrollBar.refresh();
		}
		
		private function refreshUserMessageUserPage(inVO:UserShopCommVOList):void 
		{
			if (!inVO) return;
			
			if (!_window.hasPage(1)) _window.addPage(1);
			_window.removeAllItem(1);
			
			
			var numItem:int = inVO.length;
			if (numItem)
			{
				_window.btnAdd.visible = true;
				
				//for (var i:int = 0; i < numItem; i++)
				for (var i:int = numItem - 1; i >= 0; i--)
				{
					var b:ShopMgtUserMsgUserMsgButton = assetManager.getData(AssetClassID.BTN_SHOP_USER_MSG_USER_MSG, AssetLibID.AST_SHOP_MGT);
					var vo:UserShopCommVO = inVO.getVO(i) as UserShopCommVO;
					
					if (b && vo && b.setInfo(vo))
					{
						_window.addItem(1, b);
						b.txtNo.text = String(i + 1) + '.';
						b.txtName.text =  (vo.isShop ? getMessage(myShopper.common.emun.MessageID.MYSELF) : inVO.userName) + ' (' + vo.dateTime + ') ';
						b.mcMail.visible = !vo.isShop && !vo.isRead;
						b.addEventListener(ButtonEvent.CLICK, buttonEventHandler2, false, 0, true);
						//b.addEventListener(ApplicationEvent.DELETE, buttonEventHandler, false, 0, true);
						//b.addEventListener(ApplicationEvent.MODIFY, buttonEventHandler, false, 0, true);
						
						b.updateInfo();
					}
					else
					{
						echo('buttonEventHandler : vo added : fail setting vo to button : ' + b);
					}
					
				}
				
			}
			
			_window.mcScrollBar.refresh();
		}
		
		private function buttonEventHandler2(e:ButtonEvent):void 
		{
			var b:ShopMgtUserMsgUserMsgButton = e.targetDisplayObject as ShopMgtUserMsgUserMsgButton;
			if (b)
			{
				var vo:UserShopCommVO = b.vo as UserShopCommVO;
				if (vo)
				{
					//if message is not read, set message is read, and update server
					if (!vo.isRead && b.mcMail.visible)
					{
						b.mcMail.visible = false;
						sendNotification(ShopMgtEvent.SHOP_READ_USER_SHOP_MESSAGE, vo);
					}
				}
			}
		}
		
		
		
	}
}