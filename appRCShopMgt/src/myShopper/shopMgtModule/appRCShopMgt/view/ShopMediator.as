package myShopper.shopMgtModule.appRCShopMgt.view 

{
	import flash.display.DisplayObject;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.display.ApplicationDisplayObject;
	import myShopper.common.display.Menu;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.utils.Tracer;
	import myShopper.common.utils.TweenerEffect;
	import myShopper.shopMgtModule.appRCShopMgt.ShopMgtMain;
	import myShopper.shopMgtModule.appRCShopMgt.view.component.ApplicationShopMgt;
	import org.puremvc.as3.multicore.enum.NotificationType;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class ShopMediator extends ApplicationMediator implements IMediator 
	{
		private var _appShop:ApplicationShopMgt;
		public function get appShop():ApplicationShopMgt 
		{
			if (!_appShop) _appShop = (container as ShopMgtMain).appShop;
			return _appShop;
		}
		
		
		//user display object
		//private var _figure:Figure;
		
		public function ShopMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
		{
			super(inMediatorName, inViewComponent);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			
		}
		
		override public function listNotificationInterests():Array 
		{
			return [NotificationType.ADD_HOST, NotificationType.MODULE_OFF, NotificationType.MODULE_ON];
		}

		override public function handleNotification(note:INotification):void 
		{
			var vo:DisplayObjectVO = note.getBody() as DisplayObjectVO;
			
			switch (note.getName()) 
			{   
				case NotificationType.ADD_HOST:
				{
					
					if (vo)
					{
						(container as ShopMgtMain).appShop = container.view.addApplicationChild(vo.displayObject, vo.settingXML, false) as ApplicationShopMgt ;
						 //by default mgt module is turn to off / module will be turned on once the url is chaged to mgt page
						//appShop.closePage(TweenerEffect.setAlpha(0,0));
					}
					
					break;
				}
				case NotificationType.MODULE_OFF:
				{
					if (!appShop.isClosed)
					{
						appShop.closePage();
					}
					
					break;
				}
				
				case NotificationType.MODULE_ON:
				{
					if (appShop.isClosed)
					{
						appShop.showPage();
					}
					
					break;
				}
				
			}
		}
		
		
	}
}