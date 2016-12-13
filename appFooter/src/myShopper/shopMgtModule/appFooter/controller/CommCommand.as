package myShopper.shopMgtModule.appFooter.controller
{
	import myShopper.common.emun.CommunicationType;
	import myShopper.common.interfaces.ICommServiceRequest;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.shopMgtModule.appFooter.ModuleFacade;
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
					case CommunicationType.USER_LOGOUT:
					{
						sendNotification(request.communicationType, request);
						break;
					}
					
				}
				
			}
			
		}
		
		
		
		private function get moduleMain():IModuleMain
		{
			return (facade as ModuleFacade).module;
		}
	}
}