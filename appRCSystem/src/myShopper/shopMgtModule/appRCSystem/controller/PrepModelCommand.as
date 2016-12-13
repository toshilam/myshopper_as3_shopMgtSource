package myShopper.shopMgtModule.appRCSystem.controller
{
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.shopMgtModule.appRCSystem.enum.ProxyID;
	import myShopper.shopMgtModule.appRCSystem.model.AMFRemoteProxy;
	import myShopper.shopMgtModule.appRCSystem.model.AssetProxy;
	import myShopper.shopMgtModule.appRCSystem.model.CommunicationProxy;
	import myShopper.shopMgtModule.appRCSystem.model.ContentProxy;
	//import myShopper.shopMgtModule.appRCSystem.model.FacebookProxy;
	import myShopper.shopMgtModule.appRCSystem.model.FMSRemoteProxy;
	import myShopper.shopMgtModule.appRCSystem.model.LocalDataProxy;
	import myShopper.shopMgtModule.appRCSystem.model.RTMFPRemoteProxy;
	import myShopper.shopMgtModule.appRCSystem.model.SWFAddressProxy;
	import myShopper.shopMgtModule.appRCSystem.model.WSRemoteProxy;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class PrepModelCommand extends SimpleCommand implements ICommand
	{
		override public function execute( note:INotification ):void
		{
			var app:IModuleMain = note.getBody() as IModuleMain;
			
			// Instantiate :: proxies
			facade.registerProxy(new AssetProxy(ProxyID.ASSET, 					app));
			//facade.registerProxy(new AMFRemoteProxy(ProxyID.AMF, 				app));
			facade.registerProxy(new SWFAddressProxy(ProxyID.SWF_ADDRESS, 		app));
			//facade.registerProxy(new FacebookProxy(ProxyID.FACEBOOK,		 	app));
			//facade.registerProxy(new ContentProxy(ProxyID.CONTENT,		 		app));
			facade.registerProxy(new CommunicationProxy(ProxyID.COMMUNICATION,	app));
			//facade.registerProxy(new FMSRemoteProxy(ProxyID.FMS,				app)); //not used! user web socket instead of!
			//facade.registerProxy(new WSRemoteProxy(ProxyID.WS,					app));
			facade.registerProxy(new RTMFPRemoteProxy(ProxyID.RTMFP,			app));
			//facade.registerProxy(new LocalDataProxy(ProxyID.LOCAL_DATA,			app));
			
		}
	}
}