package myShopper.shopMgtModule.appShopMgt.controller
{
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.shopMgtModule.appShopMgt.enum.MediatorID;
	import myShopper.shopMgtModule.appShopMgt.view.ModuleJunctionMediator;
	import myShopper.shopMgtModule.appShopMgt.view.ShopMediator;
	import myShopper.shopMgtModule.appShopMgt.view.BGMediator;
	import myShopper.shopMgtModule.appShopMgt.view.LogoMediator;
	import myShopper.shopMgtModule.appShopMgt.view.MyMenuMediator;
	import myShopper.shopMgtModule.appShopMgt.view.MyQuickMenuMediator;
	import myShopper.shopMgtModule.appShopMgt.view.MyStatusMediator;
	import myShopper.shopMgtModule.appShopMgt.view.CustomerMenuMediator;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	CONFIG::mobile
	import myShopper.shopMgtModule.appShopMgt.view.WebViewMediator;
	
	public class PrepViewCommand extends SimpleCommand implements ICommand
	{
		override public function execute( note:INotification ):void
		{
			var app:IModuleMain = note.getBody() as IModuleMain;
			
			
			facade.registerMediator( new ModuleJunctionMediator() );
			facade.registerMediator( new ShopMediator(MediatorID.SHOP, 					app) );
			facade.registerMediator( new BGMediator(MediatorID.BG, 						app) );
			facade.registerMediator( new MyMenuMediator(MediatorID.MY_MENU,				app) );
			facade.registerMediator( new LogoMediator(MediatorID.LOGO,					app) );
			facade.registerMediator( new MyStatusMediator(MediatorID.MY_STATUS,			app) );
			facade.registerMediator( new MyQuickMenuMediator(MediatorID.MY_QUICK_MENU,	app) );
			facade.registerMediator( new CustomerMenuMediator(MediatorID.CUSTOMER_MENU,	app) );
			
			CONFIG::mobile
			{
				facade.registerMediator( new WebViewMediator(MediatorID.WEB_VIEW,		app) );
			}
			
		}
	}
}