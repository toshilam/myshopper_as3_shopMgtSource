package myShopper.shopMgtModule.appHeader.controller
{
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.shopMgtModule.appHeader.enum.ProxyID;
	import myShopper.shopMgtModule.appHeader.model.AssetProxy;
	import myShopper.shopMgtModule.appHeader.model.CommunicationProxy;
	import myShopper.shopMgtModule.appHeader.model.SWFAddressProxy;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class PrepModelCommand extends SimpleCommand implements ICommand
	{
		override public function execute( note:INotification ):void
		{
			var app:IModuleMain = note.getBody() as IModuleMain;
			
			// Instantiate :: proxies
			facade.registerProxy( new AssetProxy(ProxyID.ASSET, app) );
			facade.registerProxy( new SWFAddressProxy(ProxyID.SWF_ADDRESS, app) );
			facade.registerProxy( new CommunicationProxy(ProxyID.COMM, app) );
			
		}
	}
}