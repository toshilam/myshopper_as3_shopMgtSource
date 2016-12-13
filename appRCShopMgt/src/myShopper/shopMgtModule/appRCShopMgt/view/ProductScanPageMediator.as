package myShopper.shopMgtModule.appRCShopMgt.view 

{
	import myShopper.common.data.AlerterVO;
	import myShopper.common.emun.AlerterType;
	import myShopper.common.emun.MessageID;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.utils.Alert;
	import myShopper.fl.shopMgtRC.ScanPage;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtModule.appRCShopMgt.enum.AssetClassID;
	import myShopper.shopMgtModule.appRCShopMgt.enum.AssetID;
	import myShopper.shopMgtModule.appRCShopMgt.enum.NotificationType;
	import myShopper.shopMgtModule.appRCShopMgt.enum.PageID;
	import myShopper.shopMgtModule.appRCShopMgt.model.vo.PageVO;
	import myShopper.shopMgtModule.appRCShopMgt.ShopMgtMain;
	import myShopper.shopMgtModule.appRCShopMgt.view.component.ApplicationShopMgt;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	import pl.mateuszmackowiak.nativeANE.dialogs.NativeAlertDialog;
	
	public class ProductScanPageMediator extends ApplicationMediator implements IMediator 
	{
		private var _appShop:ApplicationShopMgt;
		public function get appShop():ApplicationShopMgt 
		{
			if (!_appShop) _appShop = (container as ShopMgtMain).appShop;
			return _appShop;
		}
		
		private var _page:ScanPage;
		
		public function ProductScanPageMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
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
						if (vo.name == PageID.PRODUCT_SCAN)
						{
							_page = appShop.addApplicationChild(vo.displayObject, null) as ScanPage;
							_page.mcHeader.btnBack.id = AssetID.BTN_BACK;
							_page.mcHeader.btnHome.id = AssetID.BTN_HOME;
							_page.mcHeader.btnLogout.id = AssetID.BTN_LOGOUT;
							_page.startScan();
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
				_page.addEventListener(ApplicationEvent.MORE, scannerEventHandler);
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
				_page.removeEventListener(ApplicationEvent.MORE, scannerEventHandler);
				_page.mcHeader.btnBack.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
				_page.mcHeader.btnHome.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
				_page.mcHeader.btnLogout.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			}
		}
		
		private function scannerEventHandler(e:ApplicationEvent):void 
		{
			if (_page && e.data)
			{
				//_page.stopScan();
				
				sendNotification(ShopMgtEvent.SHOP_CREATE_PRODUCT, e.data);
			}
			
		}
		
		private function buttonEventHandler(e:ButtonEvent):void 
		{
			if (!_page) return;
			sendNotification(ButtonEvent.CLICK, e.targetButton.id);
			/*switch(e.targetButton)
			{
				case _page.btnConnect:
				{
					sendNotification(ButtonEvent.CLICK, _loginPage.btnConnect.id);
					break;
				}
			}*/
		}
		
		
		
	}
}