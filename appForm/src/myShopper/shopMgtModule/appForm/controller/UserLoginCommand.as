package myShopper.shopMgtModule.appForm.controller
{
	import myShopper.common.emun.AMFUserServicesType;
	import myShopper.shopMgtCommon.emun.AMFShopManagementServicesType;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.IApplicationMediator;
	import org.puremvc.as3.multicore.interfaces.IApplicationProxy;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class UserLoginCommand extends SimpleCommand implements ICommand
	{
		override public function execute( note:INotification ):void
		{
			(facade.retrieveProxy(ProxyID.USER_LOGIN) as IRemoteDataProxy).getRemoteData(AMFShopManagementServicesType.USER_LOGIN, note.getBody());
		}
		
		
	}
}