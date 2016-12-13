package myShopper.shopMgtModule.appSystem.controller
{
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.shopMgtModule.appSystem.enum.MediatorID;
	import myShopper.shopMgtModule.appSystem.view.ApplicationJunctionMediator;
	import myShopper.shopMgtModule.appSystem.view.SystemMediator;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class PrepViewCommand extends SimpleCommand implements ICommand
	{
		override public function execute( note:INotification ):void
		{
			var app:IModuleMain = note.getBody() as IModuleMain;
			
			facade.registerMediator( new ApplicationJunctionMediator() );
			facade.registerMediator( new SystemMediator(MediatorID.SYSTEM, app) );
		}
	}
}