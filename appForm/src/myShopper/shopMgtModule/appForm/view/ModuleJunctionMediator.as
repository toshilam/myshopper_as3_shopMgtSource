package myShopper.shopMgtModule.appForm.view
{
	
	import myShopper.common.utils.Tracer;
	import myShopper.shopMgtModule.appForm.FormMain;
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
		
		public static const NAME:String = FormMain.NAME + 'JunctionMediator';
		
		public function ModuleJunctionMediator()
		{
			super(NAME, new Junction());
		}
		
		
		override public function handlePipeMessage(message:IPipeMessage):void
		{
			Tracer.echo(multitonKey + ' : ModuleJunctionMediator : handlePipeMessage : ' + message.getBody() + ' : ' + message.getType());
			junction.sendMessage(PipeID.MODULE_TO_APP, new Message(Message.NORMAL, null, 'message from footer main'));
		}		
	}
}