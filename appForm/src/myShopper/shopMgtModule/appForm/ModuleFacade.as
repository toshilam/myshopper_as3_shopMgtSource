package myShopper.shopMgtModule.appForm
{
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.ApplicationUserEvent;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.events.ChatEvent;
	import myShopper.common.events.FileEvent;
	import myShopper.common.events.GoogleEvent;
	import myShopper.common.events.PageEvent;
	import myShopper.common.events.ShopEvent;
	import myShopper.common.events.ShopperEvent;
	import myShopper.common.events.WindowEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.net.CommunicationService;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtModule.appForm.controller.AssetCommand;
	import myShopper.shopMgtModule.appForm.controller.ChatCommand;
	import myShopper.shopMgtModule.appForm.controller.CommCommand;
	import myShopper.shopMgtModule.appForm.controller.ContentCommand;
	import myShopper.shopMgtModule.appForm.controller.FileCommand;
	import myShopper.shopMgtModule.appForm.controller.PageCommand;
	import myShopper.shopMgtModule.appForm.controller.PrintCommand;
	import myShopper.shopMgtModule.appForm.controller.ShopUpdateFormCommand;
	import myShopper.shopMgtModule.appForm.controller.StartupCommand;
	import myShopper.shopMgtModule.appForm.controller.UserLoginCommand;
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
			
			registerCommand( NotificationType.STARTUP, 						StartupCommand );
			//registerCommand( PageEvent.URL_CHANGED, 						PageCommand );
			registerCommand( CommunicationService.NOTIFICATION, 			CommCommand );
			registerCommand( ShopMgtEvent.LOGIN, 							UserLoginCommand );
			registerCommand( FileEvent.DOWNLOAD, 							FileCommand );
			registerCommand( WindowEvent.CLOSE, 							ContentCommand );
			registerCommand( WindowEvent.CREATE, 							ContentCommand );
			registerCommand( ApplicationUserEvent.FORGOT_PASSWORD, 			ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_UPDATE_PASSWORD, 			ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_VERIFY_PAYPAL_ACC, 			ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_VERIFY_ACC, 					ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_UPDATE_CURRENCY, 			ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_UPDATE_TAX, 					ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_UPDATE_PROFILE, 				ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_CREATE_PROFILE, 				ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_DELETE_PROFILE, 				ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_GET_ABOUT, 					ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_UPDATE_ABOUT, 				ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_UPDATE_LOGO, 				ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_UPDATE_BG, 					ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_CREATE_NEWS, 				ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_UPDATE_NEWS, 				ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_DELETE_NEWS, 				ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_CREATE_CUSTOM, 				ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_UPDATE_CUSTOM, 				ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_DELETE_CUSTOM, 				ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_GET_CUSTOM_BY_NO,	 		ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_CREATE_CATEGORY, 			ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_UPDATE_CATEGORY, 			ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_DELETE_CATEGORY, 			ShopUpdateFormCommand );
			//registerCommand( ShopMgtEvent.SHOP_CLONE_PRODUCT,	 			ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_CREATE_PRODUCT,	 			ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_CREATE_PRODUCT_STOCK,	 	ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_DELETE_PRODUCT_STOCK,	 	ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_GET_PRODUCT_STOCK_HISTORY,	ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_GET_PRODUCT_BY_NO,	 		ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_UPDATE_PRODUCT,	 			ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_DELETE_PRODUCT,	 			ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_SEND_INVOICE,				ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_GET_ORDER,					ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_ADD_ORDER_EXTRA,				ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_ADD_SALES_EXTRA,				ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_UPDATE_ORDER_SHIPMENT,		ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_READ_USER_SHOP_MESSAGE,		ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_CREATE_USER_SHOP_MESSAGE,	ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_GET_USER_SHOP_MESSAGE,		ShopUpdateFormCommand );
			registerCommand( ChatEvent.END_SHOP_CHAT,		 				ChatCommand );
			registerCommand( ChatEvent.SEND_SHOP_MESSAGE,		 			ChatCommand );
			registerCommand( ChatEvent.RECEIVE_SHOP_MESSAGE,		 		ChatCommand );
			registerCommand( ShopEvent.GET_COUNTRY,		 					AssetCommand );
			registerCommand( ShopEvent.GET_STATE,		 					AssetCommand );
			registerCommand( ShopEvent.GET_CITY,		 					AssetCommand );
			registerCommand( ShopEvent.GET_AREA,		 					AssetCommand );
			registerCommand( ShopperEvent.CONTACT_US,		 				ShopUpdateFormCommand );
			registerCommand( ApplicationEvent.SHARE,		 				ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_CREATE_SALES,		 		ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_DELETE_SALES,		 		ShopUpdateFormCommand );
			registerCommand( GoogleEvent.LOGIN,		 						ShopUpdateFormCommand );
			registerCommand( GoogleEvent.PRINTER_SEARCH,		 			ShopUpdateFormCommand );
			registerCommand( ShopMgtEvent.SHOP_SET_PRINT,		 			ShopUpdateFormCommand );
			registerCommand( ApplicationEvent.PRINT,		 				PrintCommand );
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