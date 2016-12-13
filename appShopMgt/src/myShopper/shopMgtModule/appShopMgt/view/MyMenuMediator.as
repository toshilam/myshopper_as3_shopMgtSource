package myShopper.shopMgtModule.appShopMgt.view 

{
	import myShopper.common.Config;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.display.ApplicationDisplayObject;
	import myShopper.common.display.Menu;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.SWFClassID;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.text.Font;
	import myShopper.fl.shopMgt.AppButton;
	import myShopper.fl.shopMgt.MyMenu;
	import myShopper.shopMgtModule.appShopMgt.enum.AssetID;
	import myShopper.shopMgtCommon.emun.AssetID;
	import myShopper.shopMgtModule.appShopMgt.ShopMgtMain;
	import myShopper.shopMgtModule.appShopMgt.view.component.ApplicationShopMgt;
	import org.puremvc.as3.multicore.enum.NotificationType;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class MyMenuMediator extends ApplicationMediator implements IMediator 
	{
		private var _appShop:ApplicationShopMgt;
		public function get appShop():ApplicationShopMgt 
		{
			if (!_appShop) _appShop = (container as ShopMgtMain).appShop;
			return _appShop;
		}
		
		public function get myMenu():MyMenu
		{
			return appShop.myMenu;
		}
		
		
		
		public function MyMenuMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
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
					if (vo.id == myShopper.shopMgtModule.appShopMgt.enum.AssetID.MY_MENU) 
					{
						var menuXML:XML = vo.settingXML;
						
						appShop.myMenu = appShop.addApplicationChild(vo.displayObject, menuXML) as MyMenu;
						
						var numItem:int = menuXML..button.length();
						for (var i:int = 0; i < numItem; i++)
						{
							var targetNode:XML = menuXML..button[i];
							if (targetNode && targetNode.@Class.length())
							{
								var b:AppButton = assetManager.getData(targetNode.@Class.toString(), AssetLibID.APP_SHOP_MGT);
								if (b)
								{
									//b.txt.embedFonts = false;
									//b.txt.defaultTextFormat = Font.getTextFormat( { /*size:18, letterSpacing:2,*/ font:SWFClassID.SANS } );
									setTextField(b.txt, language == Config.LANG_CODE_EN, Font.getTextFormat( { font:SWFClassID.SANS } ));
									
									myMenu.holder.addApplicationChild(b, targetNode);
									b.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
								}
							}
							
						}
						
						appShop.onStageResize(mainStage);
					}
					break;
				}
			}
		}
		
		private function buttonEventHandler(e:ButtonEvent):void 
		{
			switch(e.targetButton.id)
			{
				case myShopper.shopMgtCommon.emun.AssetID.BTN_SHOP_SETTING:
				case myShopper.shopMgtCommon.emun.AssetID.BTN_SHOP_ABOUT:
				case myShopper.shopMgtCommon.emun.AssetID.BTN_SHOP_NEWS:
				case myShopper.shopMgtCommon.emun.AssetID.BTN_SHOP_PRODUCT:
				case myShopper.shopMgtCommon.emun.AssetID.BTN_SHOP_PROFILE:
				case myShopper.shopMgtCommon.emun.AssetID.BTN_SHOP_CUSTOM:
				{
					sendNotification(e.type, e.targetButton);
					break;
				}
			}
			
			//sendNotification(WindowEvent.CREATE, e.targetButton);
		}
		
		
	}
}