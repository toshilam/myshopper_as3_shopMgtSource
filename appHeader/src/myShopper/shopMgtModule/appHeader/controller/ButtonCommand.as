package myShopper.shopMgtModule.appHeader.controller 

{
	import adobe.utils.ProductManager;
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.utils.setTimeout;
	import myShopper.common.Config;
	import myShopper.common.display.ModuleMain;
	import myShopper.common.emun.CommunicationType;
	import myShopper.common.emun.PageID;
	import myShopper.common.interfaces.IButton;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.utils.Tracer;
	import myShopper.shopMgtModule.appHeader.enum.AssetID;
	import myShopper.shopMgtModule.appHeader.enum.MediatorID;
	import myShopper.shopMgtModule.appHeader.enum.ProxyID;
	import myShopper.shopMgtModule.appHeader.HeaderMain;
	import myShopper.shopMgtModule.appHeader.model.AssetProxy;
	import myShopper.shopMgtModule.appHeader.model.CommunicationProxy;
	import myShopper.shopMgtModule.appHeader.model.SWFAddressProxy;
	import myShopper.shopMgtModule.appHeader.ModuleFacade;
	import myShopper.shopMgtModule.appHeader.view.HeaderMediator;
	import myShopper.shopMgtModule.appHeader.view.LanguageMenuMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	import org.puremvc.as3.multicore.patterns.observer.Notification;
    
	CONFIG::desktop
	import flash.desktop.NativeApplication
	
	CONFIG::mobile
	import flash.desktop.NativeApplication
	
	public class ButtonCommand extends SimpleCommand 
	{
		
		override public function execute(note:INotification):void 
		{
			
			var buttonID:String;
			
			if 		(note.getBody() is IButton) buttonID = (note.getBody() as IButton).id;
			else if	(note.getBody() is String) 	buttonID = String(note.getBody());
			
			switch(buttonID)
			{
				case AssetID.BTN_FULLSCREEN:
				{
					var stage:Stage = (facade.retrieveMediator(MediatorID.HEADER).getViewComponent() as HeaderMain).appHeader.stage;
					stage.displayState = (stage.displayState == StageDisplayState.NORMAL) ? StageDisplayState.FULL_SCREEN_INTERACTIVE : StageDisplayState.NORMAL;
					
					break;
				}
				
				/*case AssetID.LOGO:
				case AssetID.BTN_USER_REGISTER:
				case AssetID.BTN_USER_ACCOUNT:
				case AssetID.BTN_SHOP_REGISTER:
				{
					var url:String = getURLByAssetID(buttonID);
					if (url)
					{
						swfAddress.setPage(url);
					}
					else
					{
						Tracer.echo(multitonKey + ' : ButtonCommand : execute : no matched button id for url', this, 0xff0000);
					}
					break;
				}
				*/
				
				case AssetID.BTN_USER_LOGIN: 	
				{
					comm.request(CommunicationType.USER_LOGIN); 
					break;
				}
				case AssetID.BTN_USER_LOGOUT:	
				{
					comm.request(CommunicationType.USER_LOGOUT); //logout from server
					asset.setHeaderMenu(false); //change menu
					break;
				}
				
				case AssetID.BTN_FB_LOGIN_OUT:	comm.request(CommunicationType.FB_LOGIN_OUT); break;
				
				
				/******* language ********/
				case AssetID.BTN_LANGUAGE:
				{
					if (!facade.hasMediator(MediatorID.LANGUAGE))
					{
						facade.registerMediator(new LanguageMenuMediator(MediatorID.LANGUAGE, asset.host));
					}
					break;
				}
				case AssetID.BTN_CLOSE_LANGUAGE:
				{
					if (facade.hasMediator(MediatorID.LANGUAGE))
					{
						facade.removeMediator(MediatorID.LANGUAGE);
					}
					break;
				}
				case Config.LANG_CODE_CHT:
				case Config.LANG_CODE_CHS:
				case Config.LANG_CODE_EN:
				case Config.LANG_CODE_JP:
				{
					if (asset.getCurrentLanguage() == buttonID)
					{
						facade.removeMediator(MediatorID.LANGUAGE);
						return;
					}
					
					CONFIG::desktop
					{
						//wirte to share object
						asset.setLanguage(buttonID);
						
						//setTimeout(function():void {
								new ProductManager("airappinstaller").launch("-launch " + NativeApplication.nativeApplication.applicationID + /*" " +NativeApplication.nativeApplication.publisherID  +*/ " -- l=" + buttonID);  
						//}, 100);
						
						NativeApplication.nativeApplication.exit();
						return;
					}
					
					CONFIG::mobile
					{
						asset.setLanguage(buttonID);
						NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, function(e:Event):void {
							navigateToURL(new URLRequest(Config.APPLICATION_URI + '://l=' + buttonID )); 
						});
						NativeApplication.nativeApplication.exit();
						return;
					}
					
					navigateToURL(new URLRequest(swfAddress.getBaseURL() + '/?l=' + buttonID + '#/' + swfAddress.getCurrnetPage()), "_self"); 
					break;
				}
				/******* END language ********/
				
				default:
				{
					Tracer.echo(multitonKey + ' : ButtonCommand : execute : no matched button id for action : ' + buttonID, this, 0xff0000);
				}
			}
		}
		
		
		private function getURLByAssetID(inID:String):String
		{
			switch(inID)
			{
				case AssetID.LOGO: 				return PageID.HOME;
				case AssetID.BTN_USER_ACCOUNT:	return PageID.USER_ACCOUNT;
				case AssetID.BTN_USER_REGISTER:	return PageID.USER_REGISTER;
				//case AssetID.BTN_USER_LOGIN: 	return PageID.USER_LOGIN;
			}
			
			return null;
		}
		
		private function get swfAddress():SWFAddressProxy
		{
			return facade.retrieveProxy(ProxyID.SWF_ADDRESS) as SWFAddressProxy;
		}
		
		private function get comm():CommunicationProxy
		{
			return facade.retrieveProxy(ProxyID.COMM) as CommunicationProxy;
		}
		
		private function get asset():AssetProxy
		{
			return facade.retrieveProxy(ProxyID.ASSET) as AssetProxy;
		}
		
		private function get header():HeaderMediator
		{
			return facade.retrieveMediator(MediatorID.HEADER) as HeaderMediator;
		}
	}
}