package myShopper.shopMgtModule.appHeader
{
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.net.CommunicationService;
	import myShopper.shopMgtModule.appHeader.controller.ButtonCommand;
	import myShopper.shopMgtModule.appHeader.controller.CommCommand;
	import myShopper.shopMgtModule.appHeader.controller.StartupCommand;
	import org.puremvc.as3.multicore.enum.NotificationType;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeAwareModule;
	import org.puremvc.as3.multicore.utilities.pipes.patterns.facade.PipeAwardModule;

	/**
	 * Application Facade for Prattler Module.
	 */
	public class ModuleFacade extends PipeAwardModule implements IPipeAwareModule
	{
		public function ModuleFacade( key:String )
		{
			super(key);
		}
		
		/**
		 * ApplicationFacade Factory Method
		 */
		public static function getInstance( key:String ):ModuleFacade
		{
			if ( instanceMap[ key ] == null ) instanceMap[ key ] = new ModuleFacade( key );
			return instanceMap[ key ] as ModuleFacade;
		}
		
		/**
		 * Register Commands with the Controller
		 */
		override protected function initializeController( ) : void
		{
			super.initializeController();
			
			registerCommand( NotificationType.STARTUP, 				StartupCommand );
			registerCommand( ButtonEvent.CLICK, 					ButtonCommand );
			registerCommand( CommunicationService.NOTIFICATION, 	CommCommand );
		}

		/**
		 * Application startup
		 *
		 * @param app a reference to the application component
		 */
		override public function startup( app:Object ):Boolean
		{
			return super.startup( app );
		}
	}
}