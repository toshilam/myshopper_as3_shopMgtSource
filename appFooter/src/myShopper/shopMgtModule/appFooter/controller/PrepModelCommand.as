package myShopper.shopMgtModule.appFooter.controller
{
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.shopMgtModule.appFooter.enum.ProxyID;
	import myShopper.shopMgtModule.appFooter.model.AssetProxy;
	import myShopper.shopMgtModule.appFooter.model.CommunicationProxy;
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
			facade.registerProxy( new CommunicationProxy(ProxyID.COMM, app) );
			
		}
	}
}