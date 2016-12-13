package myShopper.shopMgtModule.appRCShopMgt.controller
{
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.shopMgtModule.appRCShopMgt.enum.MediatorID;
	import myShopper.shopMgtModule.appRCShopMgt.view.LoginPageMediator;
	import myShopper.shopMgtModule.appRCShopMgt.view.LoginScanPageMediator;
	import myShopper.shopMgtModule.appRCShopMgt.view.MainMenuPageMediator;
	import myShopper.shopMgtModule.appRCShopMgt.view.ModuleJunctionMediator;
	import myShopper.shopMgtModule.appRCShopMgt.view.ProductScanPageMediator;
	import myShopper.shopMgtModule.appRCShopMgt.view.ShopMediator;
	import myShopper.shopMgtModule.appRCShopMgt.view.SoundMediator;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	CONFIG::mobile
	import myShopper.shopMgtModule.appRCShopMgt.view.WebViewMediator;
	
	public class PrepViewCommand extends SimpleCommand implements ICommand
	{
		override public function execute( note:INotification ):void
		{
			var app:IModuleMain = note.getBody() as IModuleMain;
			
			
			facade.registerMediator( new ModuleJunctionMediator() );
			facade.registerMediator( new SoundMediator(MediatorID.SOUND, 						app) );
			facade.registerMediator( new ShopMediator(MediatorID.SHOP, 							app) );
			
			facade.registerMediator( new WebViewMediator(MediatorID.WEB_VIEW,					app) );
			facade.registerMediator( new LoginPageMediator(MediatorID.LOGIN_PAGE,				app) );
			facade.registerMediator( new LoginScanPageMediator(MediatorID.LOGIN_SCAN_PAGE,		app) );
			facade.registerMediator( new ProductScanPageMediator(MediatorID.PRODUCT_SCAN_PAGE,	app) );
			facade.registerMediator( new MainMenuPageMediator(MediatorID.MAIN_MENU_PAGE,		app) );
			
		}
	}
}