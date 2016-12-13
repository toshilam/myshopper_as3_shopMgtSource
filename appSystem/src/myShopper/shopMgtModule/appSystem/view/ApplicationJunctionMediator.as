package myShopper.shopMgtModule.appSystem.view
{
	
	import myShopper.common.utils.Tracer;
	import org.puremvc.as3.multicore.enum.NotificationType;
	import org.puremvc.as3.multicore.enum.PipeID;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.facade.Facade;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeAwareModule;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;
	import org.puremvc.as3.multicore.utilities.pipes.messages.Message;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.JunctionMediator;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Pipe;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.TeeMerge;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.TeeSplit;

	public class ApplicationJunctionMediator extends JunctionMediator
	{
		
		public static const NAME:String = 'ApplicationJunctionMediator';
		
		public function ApplicationJunctionMediator()
		{
			super(NAME, new Junction());
		}


		override public function onRegister():void
		{
			// The STDOUT pipe from the shell to all modules
			junction.registerPipe( PipeID.APP_TO_MODULE, Junction.OUTPUT, new TeeSplit() );

			// The STDIN pipe to the shell from all modules
			junction.registerPipe( PipeID.MODULE_TO_APP,Junction.INPUT, new TeeMerge() );

			junction.addPipeListener( PipeID.MODULE_TO_APP, this, handlePipeMessage );
		}

		override public function listNotificationInterests():Array
		{
			var interests:Array = super.listNotificationInterests();
			interests.push(NotificationType.CONNECT_MODULE_TO_SHELL);
			//interests.push(MortgageAppEventNames.REQUEST_FOR_LOAN);
			return interests;
		}
		
		override public function handleNotification(note:INotification):void
		{
			
			switch( note.getName() )
			{
				/*case MortgageAppEventNames.REQUEST_FOR_LOAN:
					var loanMessage:Message = new Message(MortgageAppEventNames.REQUEST_FOR_LOAN,null,note);
					junction.sendMessage(PipeAwareModule.APP_TO_MODULE_PIPE,loanMessage);
				break;*/
				
				case  NotificationType.CONNECT_MODULE_TO_SHELL:
					var moduleName:String = String(note.getBody());
					var module:IPipeAwareModule = Facade.getInstance(moduleName) as IPipeAwareModule;
					
					if (!module)
					{
						Tracer.echo(getMediatorName() + ' : FAIL to connect module to shell : ' + moduleName, this, 0xff0000);
						return;
					}
					else
					{
						Tracer.echo(getMediatorName() + ' : connected module to shell : ' + moduleName, this, 0xff0000);
					}
					
					// Create the pipe
					var moduleToApp:Pipe = new Pipe();
					// Connect the pipe to our module
					// Here we're handing down our pipe to the module, the module will, in turn,
					// register this pipe as an OUTPUT pipe via junction.registerPipe(...);
					// See JunctionMediator.as for more info
					module.acceptOutputPipe(PipeID.MODULE_TO_APP, moduleToApp);				
					
					// Connect the pipe to our app
					var appIn:TeeMerge = junction.retrievePipe(PipeID.MODULE_TO_APP) as TeeMerge;
					appIn.connectInput(moduleToApp);
					
					// Cache for easy cleanup later
					//module.cacheFitting(moduleToApp,appIn);
					
					// Create the pipe
					var appToModule:Pipe = new Pipe();
					// Connect the pip to our module
					// The module will register this pipe as an INPUT pipe and add a pipe listener
					// i.e. call junction.registerPipe(...) and junction.addPipeListener(...)
					// See JunctionMediator.as for more info
					module.acceptInputPipe(PipeID.APP_TO_MODULE, appToModule);
					
					// Connect the pipe to our app
					var appOut:TeeSplit = junction.retrievePipe(PipeID.APP_TO_MODULE) as TeeSplit;
					appOut.connect(appToModule);

					// Cache for easy cleanup later
					//module.cacheFitting(appToModule,appOut);
					
					junction.sendMessage(PipeID.APP_TO_MODULE, new Message(Message.NORMAL, null, 'message from system main'));
					break;

				// And let super handle the rest (ACCEPT_OUTPUT_PIPE, ACCEPT_INPUT_PIPE, SEND_TO_LOG)								
				
				default:
					super.handleNotification(note);
					
			}
		}
		
		override public function handlePipeMessage(message:IPipeMessage):void
		{
			Tracer.echo('appSystem : ApplicationJunctionMediator : handlePipeMessage : ' + message.getBody() + ' : ' + message.getType());
			// Handle our Module->Application integration 
			/*if(message.getBody() is INotification)
			{
				var note:INotification = message.getBody() as INotification;
				
				switch(note.getName())
				{
					case MortgageAppEventNames.LOAN_QUOTE_READY:
						sendNotification(note.getName(),note.getBody(),note.getType());
						break;
					default:
						sendNotification(note.getName(),note.getBody(),note.getType());
						break;
				}
			}*/
		}		
	}
}