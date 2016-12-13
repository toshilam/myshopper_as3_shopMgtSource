package myShopper.shopMgtModule.appRCShopMgt.view 

{
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.fl.shopMgtRC.LoginPage;
	import myShopper.shopMgtCommon.emun.AssetLibID;
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
	
	public class LoginPageMediator extends ApplicationMediator implements IMediator 
	{
		private var _appShop:ApplicationShopMgt;
		public function get appShop():ApplicationShopMgt 
		{
			if (!_appShop) _appShop = (container as ShopMgtMain).appShop;
			return _appShop;
		}
		
		private var _loginPage:LoginPage;
		
		public function LoginPageMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
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
						if (vo.name == PageID.LOGIN)
						{
							_loginPage = appShop.addApplicationChild(vo.displayObject, null) as LoginPage;
							_loginPage.btnConnect.id = AssetID.BTN_CONNECT;
							startListener();
						}
						else
						{
							if (_loginPage)
							{
								stopListener();
								appShop.removeApplicationChild(_loginPage);
								_loginPage = null;
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
			
			if (_loginPage)
			{
				_loginPage.btnConnect.addEventListener(ButtonEvent.CLICK, buttonEventHandler, false, 0, true);
			}
		}
		
		override public function stopListener():void 
		{
			super.stopListener();
			
			if (_loginPage)
			{
				_loginPage.btnConnect.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			}
		}
		
		private function buttonEventHandler(e:ButtonEvent):void 
		{
			if (!_loginPage) return;
			
			switch(e.targetButton)
			{
				case _loginPage.btnConnect:
				{
					sendNotification(ButtonEvent.CLICK, _loginPage.btnConnect.id);
					break;
				}
			}
		}
		
		
		
	}
}