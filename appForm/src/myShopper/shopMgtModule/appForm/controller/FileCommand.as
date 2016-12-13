package myShopper.shopMgtModule.appForm.controller 

{
	import myShopper.common.emun.AMFShopServicesType;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	import org.puremvc.as3.multicore.patterns.observer.Notification;
    
	
	public class FileCommand extends SimpleCommand 
	{
		
		override public function execute(note:INotification):void 
		{
			
			(facade.retrieveProxy(ProxyID.FILE_INFO) as IRemoteDataProxy).getRemoteData(AMFShopServicesType.DOWNLOAD_IMAGE, note.getBody());
		}
		
	}
}