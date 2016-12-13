package myShopper.shopMgtModule.appForm.controller
{
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import myShopper.shopMgtModule.appForm.model.AMFRemoteProxy;
	import myShopper.shopMgtModule.appForm.model.AssetProxy;
	import myShopper.shopMgtModule.appForm.model.CommunicationProxy;
	import myShopper.shopMgtModule.appForm.model.FileInfoProxy;
	import myShopper.shopMgtModule.appForm.model.FMSRemoteProxy;
	import myShopper.shopMgtModule.appForm.model.LocalDataProxy;
	import myShopper.shopMgtModule.appForm.model.PrinterProxy;
	import myShopper.shopMgtModule.appForm.model.RTMFPRemoteProxy;
	import myShopper.shopMgtModule.appForm.model.SWFAddressProxy;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class PrepModelCommand extends SimpleCommand implements ICommand
	{
		override public function execute( note:INotification ):void
		{
			var app:IModuleMain = note.getBody() as IModuleMain;
			
			// Instantiate :: proxies
			facade.registerProxy( new PrinterProxy(ProxyID.PRINTER, app) );
			facade.registerProxy( new FileInfoProxy(ProxyID.FILE_INFO, app) );
			facade.registerProxy( new AMFRemoteProxy(ProxyID.AMF, app) );
			facade.registerProxy( new AssetProxy(ProxyID.ASSET, app) );
			facade.registerProxy( new FMSRemoteProxy(ProxyID.FMS, app) );
			facade.registerProxy( new RTMFPRemoteProxy(ProxyID.RTMFP, app) );
			facade.registerProxy( new SWFAddressProxy(ProxyID.SWF_ADDRESS, app) );
			facade.registerProxy( new CommunicationProxy(ProxyID.COMM, app) );
			facade.registerProxy( new LocalDataProxy(ProxyID.LOCAL_DATA, app) );
			
		}
	}
}