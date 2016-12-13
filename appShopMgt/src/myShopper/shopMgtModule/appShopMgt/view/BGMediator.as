package myShopper.shopMgtModule.appShopMgt.view 

{
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.display.ApplicationDisplayObject;
	import myShopper.common.display.Menu;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.SWFClassID;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.fl.ApplicationBG;
	import myShopper.shopMgtModule.appShopMgt.enum.AssetID;
	import myShopper.shopMgtModule.appShopMgt.ShopMgtMain;
	import myShopper.shopMgtModule.appShopMgt.view.component.ApplicationShopMgt;
	import org.puremvc.as3.multicore.enum.NotificationType;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class BGMediator extends ApplicationMediator implements IMediator 
	{
		private var _appShop:ApplicationShopMgt;
		public function get appShop():ApplicationShopMgt 
		{
			if (!_appShop) _appShop = (container as ShopMgtMain).appShop;
			return _appShop;
		}
		
		public function get bg():ApplicationBG
		{
			return appShop.bg;
		}
		
		
		
		public function BGMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
		{
			super(inMediatorName, inViewComponent);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			
		}
		
		override public function listNotificationInterests():Array 
		{
			return [NotificationType.ADD_CHILD];
		}

		override public function handleNotification(note:INotification):void 
		{
			var vo:DisplayObjectVO = note.getBody() as DisplayObjectVO;
			
			switch (note.getName()) 
			{   
				case NotificationType.ADD_CHILD:
				{
					if (vo.id == AssetID.BG) 
					{
						appShop.bg = appShop.addApplicationChild(vo.displayObject, vo.settingXML) as ApplicationBG;
						
					}
					break;
				}
			}
		}
		
		
	}
}