package myShopper.shopMgtModule.appShopMgt.controller
{
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.shopMgtModule.appShopMgt.enum.ProxyID;
	import myShopper.shopMgtModule.appShopMgt.model.AMFRemoteProxy;
	import myShopper.shopMgtModule.appShopMgt.model.AssetProxy;
	import myShopper.shopMgtModule.appShopMgt.model.CommunicationProxy;
	import myShopper.shopMgtModule.appShopMgt.model.FacebookProxy;
	import myShopper.shopMgtModule.appShopMgt.model.FileInfoProxy;
	import myShopper.shopMgtModule.appShopMgt.model.FMSRemoteProxy;
	import myShopper.shopMgtModule.appShopMgt.model.ShopDataProxy;
	import myShopper.shopMgtModule.appShopMgt.model.SWFAddressProxy;
	import myShopper.shopMgtModule.appShopMgt.model.UserInfoProxy;
	import myShopper.shopMgtModule.appShopMgt.model.WindowAssetProxy;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class PrepModelCommand extends SimpleCommand implements ICommand
	{
		override public function execute( note:INotification ):void
		{
			var app:IModuleMain = note.getBody() as IModuleMain;
			
			// Instantiate :: proxies
			facade.registerProxy( new CommunicationProxy(ProxyID.COMM,		app) );
			facade.registerProxy( new FileInfoProxy(ProxyID.FILE_INFO,		app) );
			facade.registerProxy( new AssetProxy(ProxyID.ASSET, 			app) );
			facade.registerProxy( new AMFRemoteProxy(ProxyID.AMF, 			app) );
			facade.registerProxy( new FMSRemoteProxy(ProxyID.FMS, 			app) );
			facade.registerProxy( new ShopDataProxy(ProxyID.SHOP_DATA,		app) );
			facade.registerProxy( new SWFAddressProxy(ProxyID.SWF_ADDRESS,	app) );
			facade.registerProxy( new WindowAssetProxy(ProxyID.WINDOW, 		app) );
			facade.registerProxy( new UserInfoProxy(ProxyID.USER, 			app) );
			facade.registerProxy( new FacebookProxy(ProxyID.FACEBOOK, 		app) );
		}
	}
}