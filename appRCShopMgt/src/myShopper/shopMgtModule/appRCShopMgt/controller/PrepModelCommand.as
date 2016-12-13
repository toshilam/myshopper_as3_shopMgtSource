package myShopper.shopMgtModule.appRCShopMgt.controller
{
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.shopMgtModule.appRCShopMgt.enum.ProxyID;
	import myShopper.shopMgtModule.appRCShopMgt.model.AMFRemoteProxy;
	import myShopper.shopMgtModule.appRCShopMgt.model.AssetProxy;
	import myShopper.shopMgtModule.appRCShopMgt.model.CommunicationProxy;
	import myShopper.shopMgtModule.appRCShopMgt.model.FMSRemoteProxy;
	import myShopper.shopMgtModule.appRCShopMgt.model.LoginScanPageProxy;
	import myShopper.shopMgtModule.appRCShopMgt.model.MainMenuPageProxy;
	import myShopper.shopMgtModule.appRCShopMgt.model.ProductScanPageProxy;
	import myShopper.shopMgtModule.appRCShopMgt.model.SWFAddressProxy;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class PrepModelCommand extends SimpleCommand implements ICommand
	{
		override public function execute( note:INotification ):void
		{
			var app:IModuleMain = note.getBody() as IModuleMain;
			
			// Instantiate :: proxies
			facade.registerProxy( new CommunicationProxy(ProxyID.COMM,				app) );
			facade.registerProxy( new AssetProxy(ProxyID.ASSET, 					app) );
			facade.registerProxy( new LoginScanPageProxy(ProxyID.LOGIN_SCAN_PAGE, 	app) );
			facade.registerProxy( new ProductScanPageProxy(ProxyID.PRODUCT_SCAN_PAGE, 	app) );
			facade.registerProxy( new MainMenuPageProxy(ProxyID.MAIN_MENU_PAGE, 	app) );
			//facade.registerProxy( new AMFRemoteProxy(ProxyID.AMF, 			app) );
			//facade.registerProxy( new FMSRemoteProxy(ProxyID.FMS, 			app) );
			//facade.registerProxy( new SWFAddressProxy(ProxyID.SWF_ADDRESS,	app) );
		}
	}
}