package myShopper.shopMgtModule.appShopMgt.controller
{
	import myShopper.shopMgtCommon.emun.AMFShopManagementServicesType;
	import myShopper.shopMgtModule.appShopMgt.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class StatusCommand extends SimpleCommand implements ICommand
	{
		override public function execute( note:INotification ):void
		{
			(facade.retrieveProxy(ProxyID.SHOP_DATA) as IRemoteDataProxy).getRemoteData(AMFShopManagementServicesType.UPDATE_STATUS, note.getBody());
			
		}
		
	}
}