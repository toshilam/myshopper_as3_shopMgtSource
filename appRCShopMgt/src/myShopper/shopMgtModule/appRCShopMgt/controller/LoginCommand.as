package myShopper.shopMgtModule.appRCShopMgt.controller 

{
	import myShopper.common.emun.CommunicationType;
	import myShopper.shopMgtModule.appRCShopMgt.enum.AssetClassID;
	import myShopper.shopMgtModule.appRCShopMgt.enum.NotificationType;
	import myShopper.shopMgtModule.appRCShopMgt.enum.ProxyID;
	import myShopper.shopMgtModule.appRCShopMgt.model.CommunicationProxy;
	import myShopper.shopMgtModule.appRCShopMgt.model.LoginScanPageProxy;
	import org.puremvc.as3.multicore.interfaces.IApplicationProxy;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	import org.puremvc.as3.multicore.patterns.observer.Notification;
    
	
	public class LoginCommand extends SimpleCommand 
	{
		
		override public function execute(note:INotification):void 
		{
			sendNotification(NotificationType.PLAY_SOUND, AssetClassID.SND_SCAN);
			loginScan.initAsset(note.getBody());
		}
		
		private function get loginScan():LoginScanPageProxy
		{
			return facade.retrieveProxy(ProxyID.LOGIN_SCAN_PAGE) as LoginScanPageProxy;
		}
	}
}