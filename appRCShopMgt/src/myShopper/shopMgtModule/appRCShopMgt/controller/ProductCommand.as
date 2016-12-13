package myShopper.shopMgtModule.appRCShopMgt.controller 

{
	import myShopper.common.emun.CommunicationType;
	import myShopper.common.emun.RTMFPServicesType;
	import myShopper.shopMgtModule.appRCShopMgt.enum.AssetClassID;
	import myShopper.shopMgtModule.appRCShopMgt.enum.NotificationType;
	import myShopper.shopMgtModule.appRCShopMgt.enum.ProxyID;
	import myShopper.shopMgtModule.appRCShopMgt.model.CommunicationProxy;
	import myShopper.shopMgtModule.appRCShopMgt.model.LoginScanPageProxy;
	import myShopper.shopMgtModule.appRCShopMgt.model.ProductScanPageProxy;
	import org.puremvc.as3.multicore.interfaces.IApplicationProxy;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	import org.puremvc.as3.multicore.patterns.observer.Notification;
    
	
	public class ProductCommand extends SimpleCommand 
	{
		
		override public function execute(note:INotification):void 
		{
			sendNotification(NotificationType.PLAY_SOUND, AssetClassID.SND_SCAN);
			productScan.call(RTMFPServicesType.RC_CREATE_PRODUCT, String(note.getBody()));
		}
		
		private function get productScan():ProductScanPageProxy
		{
			return facade.retrieveProxy(ProxyID.PRODUCT_SCAN_PAGE) as ProductScanPageProxy;
		}
	}
}