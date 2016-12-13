package myShopper.shopMgtModule.appForm.controller
{
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.shopMgtModule.appForm.enum.MediatorID;
	import myShopper.shopMgtModule.appForm.view.FormMediator;
	import myShopper.shopMgtModule.appForm.view.ModuleJunctionMediator;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class PrepViewCommand extends SimpleCommand implements ICommand
	{
		override public function execute( note:INotification ):void
		{
			var app:IModuleMain = note.getBody() as IModuleMain;
			
			
			facade.registerMediator( new ModuleJunctionMediator() );
			facade.registerMediator( new FormMediator(MediatorID.FORM, app) );
		}
	}
}