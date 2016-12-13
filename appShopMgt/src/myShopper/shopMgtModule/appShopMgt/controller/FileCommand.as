package myShopper.shopMgtModule.appShopMgt.controller 

{
	import myShopper.common.emun.AMFShopServicesType;
	import myShopper.shopMgtModule.appShopMgt.enum.ProxyID;
	import myShopper.shopMgtModule.appShopMgt.model.FileInfoProxy;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	import org.puremvc.as3.multicore.patterns.observer.Notification;
    
	
	public class FileCommand extends SimpleCommand 
	{
		
		override public function execute(note:INotification):void 
		{
			
			(facade.retrieveProxy(ProxyID.FILE_INFO) as FileInfoProxy).getRemoteData(AMFShopServicesType.DOWNLOAD_IMAGE, note.getBody());
		}
		
	}
}