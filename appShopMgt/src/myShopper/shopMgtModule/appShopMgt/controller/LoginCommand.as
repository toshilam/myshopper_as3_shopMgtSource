package myShopper.shopMgtModule.appShopMgt.controller 

{
	import myShopper.common.emun.CommunicationType;
	import myShopper.shopMgtModule.appShopMgt.enum.ProxyID;
	import myShopper.shopMgtModule.appShopMgt.model.CommunicationProxy;
	import org.puremvc.as3.multicore.interfaces.IApplicationProxy;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	import org.puremvc.as3.multicore.patterns.observer.Notification;
    
	
	public class LoginCommand extends SimpleCommand 
	{
		
		override public function execute(note:INotification):void 
		{
			comm.request(CommunicationType.USER_LOGIN);
		}
		
		private function get comm():CommunicationProxy
		{
			return facade.retrieveProxy(ProxyID.COMM) as CommunicationProxy;
		}
	}
}