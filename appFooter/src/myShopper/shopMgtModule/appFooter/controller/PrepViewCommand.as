package myShopper.shopMgtModule.appFooter.controller
{
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.shopMgtModule.appFooter.enum.MediatorID;
	import myShopper.shopMgtModule.appFooter.view.FooterMediator;
	import myShopper.shopMgtModule.appFooter.view.ModuleJunctionMediator;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class PrepViewCommand extends SimpleCommand implements ICommand
	{
		override public function execute( note:INotification ):void
		{
			var app:IModuleMain = note.getBody() as IModuleMain;
			
			
			facade.registerMediator( new ModuleJunctionMediator() );
			facade.registerMediator( new FooterMediator(MediatorID.FOOTER, app) );
		}
	}
}