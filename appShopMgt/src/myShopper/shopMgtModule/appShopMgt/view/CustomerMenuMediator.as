package myShopper.shopMgtModule.appShopMgt.view 
{
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.service.ImageVOService;
	import myShopper.common.data.user.UserInfoList;
	import myShopper.common.display.button.Button;
	import myShopper.common.display.Menu;
	import myShopper.common.emun.FileType;
	import myShopper.common.emun.MessageID;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.fl.shopMgt.button.ShopMgtCustomerButton;
	import myShopper.fl.shopMgt.CustomerMenu;
	import myShopper.shopMgtCommon.data.ShopMgtUserInfoVO;
	import myShopper.shopMgtCommon.emun.AssetID;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtModule.appShopMgt.enum.AssetClassID;
	import myShopper.shopMgtModule.appShopMgt.enum.AssetID;
	import myShopper.shopMgtModule.appShopMgt.enum.NotificationType;
	import myShopper.shopMgtModule.appShopMgt.ShopMgtMain;
	import myShopper.shopMgtModule.appShopMgt.view.component.ApplicationShopMgt;
	import org.puremvc.as3.multicore.enum.NotificationType;
	import org.puremvc.as3.multicore.interfaces.IApplicationMediator;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class CustomerMenuMediator extends ApplicationMediator implements IApplicationMediator 
	{
		private var _appShop:ApplicationShopMgt;
		public function get appShop():ApplicationShopMgt 
		{
			if (!_appShop) _appShop = (container as ShopMgtMain).appShop;
			return _appShop;
		}
		
		private var _menu:CustomerMenu;
		private function get menu():CustomerMenu
		{
			if (!_menu) _menu = appShop.customerMenu;
			return _menu;
		}
		
		//user display object
		private var _userInfoList:UserInfoList;
		
		public function CustomerMenuMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
		{
			super(inMediatorName, inViewComponent);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			
			_userInfoList = voManager.getAsset(VOID.USER_INFO);
			if (!_userInfoList)
			{
				echo('unable to retrieve user vo list');
				throw(new UninitializedError('unable to retrieve user vo list'));
			}
		}
		
		override public function listNotificationInterests():Array 
		{
			return	[
						org.puremvc.as3.multicore.enum.NotificationType.ADD_CHILD, 
						myShopper.shopMgtModule.appShopMgt.enum.NotificationType.UPDATE_CUSTOMER_LIST,
						myShopper.shopMgtModule.appShopMgt.enum.NotificationType.RECEIVE_CHAT_MESSAGE
					];
		}

		override public function handleNotification(note:INotification):void 
		{
			var vo:DisplayObjectVO = note.getBody() as DisplayObjectVO;
			
			switch (note.getName()) 
			{   
				case org.puremvc.as3.multicore.enum.NotificationType.ADD_CHILD:
				{
					if (vo.id == myShopper.shopMgtModule.appShopMgt.enum.AssetID.CUSTOMER_MENU) 
					{
						var menuXML:XML = vo.settingXML;
						
						appShop.customerMenu = appShop.addApplicationChild(vo.displayObject, menuXML) as CustomerMenu;
						menu.btnArrow.tooltip = getMessage(MessageID.tt1012);
						
					}
					break;
				}
				case myShopper.shopMgtModule.appShopMgt.enum.NotificationType.UPDATE_CUSTOMER_LIST:
				{
					if (menu)
					{
						//clear all previous added button
						if (menu.holder.content is Menu)
						{
							Menu(menu.holder.content).removeAllButton();
						}
						
						var numItem:int = _userInfoList.length;
						for (var i:int = 0; i < numItem; i++)
						{
							var b:ShopMgtCustomerButton = assetManager.getData(AssetClassID.BTN_SHOP_CUSTOMER, AssetLibID.AST_SHOP_MGT);
							var uVO:ShopMgtUserInfoVO = _userInfoList.getVO(i) as ShopMgtUserInfoVO;
							if (b && uVO && uVO.uid)
							{
								menu.holder.addApplicationChild(b, null, false);
								
								//b.id = myShopper.shopMgtCommon.emun.AssetID.BTN_CUSTOMER;
								b.txtNo.text = String(i + 1) + '.';
								b.setInfo(uVO);
								b.btnMessage.id = myShopper.shopMgtCommon.emun.AssetID.BTN_CUSTOMER_CHAT;
								b.btnMore.id = myShopper.shopMgtCommon.emun.AssetID.BTN_CUSTOMER_MORE;
								
								b.btnMessage.addEventListener(ButtonEvent.CLICK, customerButtonEventHandler, false, 0, true);
								b.btnMore.addEventListener(ButtonEvent.CLICK, customerButtonEventHandler, false, 0, true);
								
								loadURLImage(b.logo, ImageVOService.getImageURL(httpHost, uVO.uid, FileType.PATH_USER_LOGO), FileType.PATH_USER_LOGO);
							}
							else
							{
								echo('unable to retrieve button : ' + AssetClassID.BTN_SHOP_CUSTOMER);
							}
						}
						
						menu.onStageResize(mainStage);
					}
					else
					{
						echo('unable to retrieve menu : ' + menu);
					}
					break;
				}
				case myShopper.shopMgtModule.appShopMgt.enum.NotificationType.RECEIVE_CHAT_MESSAGE:
				{
					if (menu)
					{
						menu.startFlashByUID(String(note.getBody()));
					}
					break;
				}
			}
		}
		
		private function customerButtonEventHandler(e:ButtonEvent):void 
		{
			var b:Button = e.targetButton as Button;
			var customerButton:ShopMgtCustomerButton = b.parent as ShopMgtCustomerButton;
			
			if (customerButton)
			{
				if (customerButton.isMoving)
				{
					customerButton.stopMoving();
				}
				//re-assign id for buttonCommand
				customerButton.id = b.id;
				sendNotification(ButtonEvent.CLICK, customerButton);
			}
			
		}
		
		
	}
}