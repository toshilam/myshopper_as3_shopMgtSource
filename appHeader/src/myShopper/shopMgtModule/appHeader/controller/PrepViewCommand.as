package myShopper.shopMgtModule.appHeader.controller
{
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.shopMgtModule.appHeader.enum.MediatorID;
	import myShopper.shopMgtModule.appHeader.view.HeaderMediator;
	import myShopper.shopMgtModule.appHeader.view.HeaderMenuMediator;
	import myShopper.shopMgtModule.appHeader.view.ModuleJunctionMediator;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class PrepViewCommand extends SimpleCommand implements ICommand
	{
		override public function execute( note:INotification ):void
		{
			var app:IModuleMain = note.getBody() as IModuleMain;
			
			
			facade.registerMediator( new ModuleJunctionMediator() );
			facade.registerMediator( new HeaderMediator(MediatorID.HEADER, app) );
			facade.registerMediator( new HeaderMenuMediator(MediatorID.HEADER_MENU, app) );
		}
	}
}