package myShopper.shopMgtModule.appSystem
{
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.FileEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.net.CommunicationService;
	import myShopper.shopMgtModule.appSystem.controller.AssetCommand;
	import myShopper.shopMgtModule.appSystem.controller.CommCommand;
	import myShopper.shopMgtModule.appSystem.controller.StartupCommand;
	import org.puremvc.as3.multicore.enum.NotificationType;
	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.patterns.facade.Facade;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeAwareModule;
	import org.puremvc.as3.multicore.utilities.pipes.patterns.facade.PipeAwardModule;
	//import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeAware;
	//import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.JunctionMediator;
	
	/**
	 * Application Facade for Prattler Module.
	 */
	public class ApplicationFacade extends PipeAwardModule implements IPipeAwareModule
	{
		public function ApplicationFacade( key:String )
		{
			super(key);
		}
		
		/**
		 * ApplicationFacade Factory Method
		 */
		public static function getInstance( key:String ):ApplicationFacade
		{
			if ( instanceMap[ key ] == null ) instanceMap[ key ] = new ApplicationFacade( key );
			return instanceMap[ key ] as ApplicationFacade;
		}
		
		/**
		 * Register Commands with the Controller
		 */
		override protected function initializeController( ) : void
		{
			super.initializeController();
			
			registerCommand( NotificationType.STARTUP, 				StartupCommand );
			
			registerCommand( FileEvent.COMPLETE, 					AssetCommand );
			registerCommand( FileEvent.COMPLETE_ALL_FILE, 			AssetCommand );
			registerCommand( CommunicationService.NOTIFICATION, 	CommCommand );
		}

		/**
		 * Application startup
		 *
		 * @param app a reference to the application component
		 */
		override public function startup( app:Object ):Boolean
		{
			return super.startup(app);
		}

		/**
		 * Accept an input pipe.
		 * <P>
		 * Registers an input pipe with this module's Junction.
		 */
		/*public function acceptInputPipe( name:String, pipe:IPipeFitting ):void
		{
			sendNotification( JunctionMediator.ACCEPT_INPUT_PIPE, pipe, name );
		}*/

		/**
		 * Accept an output pipe.
		 * <P>
		 * Registers an input pipe with this module's Junction.
		 */
		/*public function acceptOutputPipe( name:String, pipe:IPipeFitting ):void
		{
			sendNotification( JunctionMediator.ACCEPT_OUTPUT_PIPE, pipe, name );
		}*/
	}
}