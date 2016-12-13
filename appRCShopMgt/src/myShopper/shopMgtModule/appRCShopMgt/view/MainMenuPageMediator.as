package myShopper.shopMgtModule.appRCShopMgt.view 

{
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.fl.shopMgtRC.MenuPage;
	import myShopper.shopMgtModule.appRCShopMgt.enum.AssetID;
	import myShopper.shopMgtModule.appRCShopMgt.enum.NotificationType;
	import myShopper.shopMgtModule.appRCShopMgt.enum.PageID;
	import myShopper.shopMgtModule.appRCShopMgt.model.vo.PageVO;
	import myShopper.shopMgtModule.appRCShopMgt.ShopMgtMain;
	import myShopper.shopMgtModule.appRCShopMgt.view.component.ApplicationShopMgt;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class MainMenuPageMediator extends ApplicationMediator implements IMediator 
	{
		private var _appShop:ApplicationShopMgt;
		public function get appShop():ApplicationShopMgt 
		{
			if (!_appShop) _appShop = (container as ShopMgtMain).appShop;
			return _appShop;
		}
		
		private var _page:MenuPage;
		
		public function MainMenuPageMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
		{
			super(inMediatorName, inViewComponent);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			
		}
		
		override public function listNotificationInterests():Array 
		{
			return [NotificationType.VIEW_PAGE];
		}

		override public function handleNotification(note:INotification):void 
		{
			
			switch (note.getName()) 
			{
				
				case NotificationType.VIEW_PAGE:
				{
					var vo:PageVO = note.getBody() as PageVO;
					if (vo)
					{
						if (vo.name == PageID.MAIN_MENU)
						{
							_page = appShop.addApplicationChild(vo.displayObject, null) as MenuPage;
							_page.btnScan.id = AssetID.BTN_PRODUCT_SCAN;
							_page.mcHeader.btnBack.id = AssetID.BTN_BACK;
							_page.mcHeader.btnHome.id = AssetID.BTN_HOME;
							_page.mcHeader.btnLogout.id = AssetID.BTN_LOGOUT;
							_page.mcHeader.btnBack.visible = false;
							startListener();
						}
						else
						{
							if (_page)
							{
								stopListener();
								appShop.removeApplicationChild(_page);
								_page = null;
							}
						}
						
						
					}
					
					
					break;
				}
				
				
			}
		}
		
		override public function startListener():void 
		{
			super.startListener();
			
			if (_page)
			{
				_page.btnScan.addEventListener(ButtonEvent.CLICK, buttonEventHandler, false, 0, true);
				_page.mcHeader.btnBack.addEventListener(ButtonEvent.CLICK, buttonEventHandler, false, 0, true);
				_page.mcHeader.btnHome.addEventListener(ButtonEvent.CLICK, buttonEventHandler, false, 0, true);
				_page.mcHeader.btnLogout.addEventListener(ButtonEvent.CLICK, buttonEventHandler, false, 0, true);
			}
		}
		
		override public function stopListener():void 
		{
			super.stopListener();
			
			if (_page)
			{
				_page.btnScan.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
				_page.mcHeader.btnBack.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
				_page.mcHeader.btnHome.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
				_page.mcHeader.btnLogout.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			}
		}
		
		
		private function buttonEventHandler(e:ButtonEvent):void 
		{
			if (!_page) return;
			
			sendNotification(ButtonEvent.CLICK, e.targetButton.id);
		}
		
		
		
	}
}