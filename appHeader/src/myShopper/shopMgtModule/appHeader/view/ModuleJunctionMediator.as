package myShopper.shopMgtModule.appHeader.view
{
	
	import myShopper.common.utils.Tracer;
	import myShopper.shopMgtModule.appHeader.HeaderMain;
	import org.puremvc.as3.multicore.enum.NotificationType;
	import org.puremvc.as3.multicore.enum.PipeID;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;
	import org.puremvc.as3.multicore.utilities.pipes.messages.Message;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.JunctionMediator;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Pipe;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.TeeMerge;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.TeeSplit;

	public class ModuleJunctionMediator extends JunctionMediator
	{
		
		public static const NAME:String = HeaderMain.NAME + 'JunctionMediator';
		
		public function ModuleJunctionMediator()
		{
			super(NAME, new Junction());
		}	
		
		
		override public function handlePipeMessage(message:IPipeMessage):void
		{
			Tracer.echo('appHeader : ModuleJunctionMediator : handlePipeMessage : ' + message.getBody() + ' : ' + message.getType());
			junction.sendMessage(PipeID.MODULE_TO_APP, new Message(Message.NORMAL, null, 'message from header main'));
		}		
	}
}