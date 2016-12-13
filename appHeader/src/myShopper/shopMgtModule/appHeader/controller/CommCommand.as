package myShopper.shopMgtModule.appHeader.controller
{
	import myShopper.common.emun.CommunicationType;
	import myShopper.common.interfaces.ICommServiceRequest;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.utils.Tracer;
	import myShopper.shopMgtModule.appHeader.enum.NotificationType;
	import myShopper.shopMgtModule.appHeader.enum.ProxyID;
	import myShopper.shopMgtModule.appHeader.model.AssetProxy;
	import org.puremvc.as3.multicore.interfaces.IApplicationMediator;
	import org.puremvc.as3.multicore.interfaces.IApplicationProxy;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CommCommand extends SimpleCommand implements ICommand
	{
		override public function execute( note:INotification ):void
		{
			var request:ICommServiceRequest = note.getBody() as ICommServiceRequest;
			
			if (request)
			{
				switch(request.communicationType)
				{
					case CommunicationType.USER_LOGIN_SUCCESS:
					{
						//sendNotification(NotificationType.USER_LOGIN_SUCCESS);
						
						asset.setHeaderMenu(true);
						break;
					}
					case CommunicationType.USER_CONNECTED:
					case CommunicationType.USER_DISCONNECTED:
					case CommunicationType.USER_DISCONNECTING:
					{
						sendNotification(NotificationType.UPDATE_CONNECTION_STATUS, request.communicationType);
						break;
					}
				}
				
			}
			
		}
		
		/*private function getMediatorByPageID(inID:String):IApplicationMediator 
		{
			if (inID == CommunicationType.USER_LOGIN) return new UserLoginFormMediator(MediatorID.USER_LOGIN, moduleMain);
			
			return null;
		}
		
		private function getProxyByPageID(inID:String):IApplicationProxy 
		{
			if (inID == CommunicationType.USER_LOGIN) return new UserInfoProxy(ProxyID.USER_LOGIN, moduleMain);
			
			return null;
		}*/
		
		private function get asset():AssetProxy
		{
			return facade.retrieveProxy(ProxyID.ASSET) as AssetProxy;
		}
	}
}