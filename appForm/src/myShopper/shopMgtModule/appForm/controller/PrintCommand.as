package myShopper.shopMgtModule.appForm.controller 

{
	import myShopper.common.data.VO;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import myShopper.shopMgtModule.appForm.model.PrinterProxy;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	
	public class PrintCommand extends SimpleCommand 
	{
		
		override public function execute(note:INotification):void 
		{
			(facade.retrieveProxy(ProxyID.PRINTER) as PrinterProxy).print(note.getBody() as VO, int(note.getType()));
		}
		
	}
}