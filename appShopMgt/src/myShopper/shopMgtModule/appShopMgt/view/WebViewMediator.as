package myShopper.shopMgtModule.appShopMgt.view 

{
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.SWFClassID;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.flAIR.WebView;
	import myShopper.shopMgtModule.appShopMgt.enum.NotificationType;
	import myShopper.shopMgtModule.appShopMgt.ShopMgtMain;
	import myShopper.shopMgtModule.appShopMgt.view.component.ApplicationShopMgt;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	CONFIG::mobile
	public class WebViewMediator extends ApplicationMediator implements IMediator 
	{
		private var _appShop:ApplicationShopMgt;
		public function get appShop():ApplicationShopMgt 
		{
			if (!_appShop) _appShop = (container as ShopMgtMain).appShop;
			return _appShop;
		}
		
		
		//user display object
		private var _webView:WebView;
		
		public function WebViewMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
		{
			super(inMediatorName, inViewComponent);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			
		}
		
		override public function listNotificationInterests():Array 
		{
			return [NotificationType.VIEW_WEB_PAGE];
		}

		override public function handleNotification(note:INotification):void 
		{
			
			switch (note.getName()) 
			{   
				case NotificationType.VIEW_WEB_PAGE:
				{
					var url:String = note.getBody() as String;
					if (url)
					{
						_webView = mainStage.addChild( assetManager.getData(SWFClassID.WEB_VIEW, AssetLibID.AST_SHOP_MGT_MOB)) as WebView;
						
						if (_webView)
						{
							_webView.initDisplayObject(null, mainStage);
							_webView.loadURL(url);
							_webView.btnClose.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
						}
					}
					break;
				}
				
				
			}
		}
		
		private function buttonEventHandler(e:ButtonEvent):void 
		{
			if (_webView)
			{
				mainStage.removeChild(_webView);
				_webView.destroyDisplayObject();
				_webView = null;
			}
		}
		
		
	}
}