package myShopper.shopMgtModule.appFooter.controller 

{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import myShopper.common.Config;
	import myShopper.common.emun.CommunicationType;
	import myShopper.common.interfaces.IButton;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.utils.Tools;
	import myShopper.common.utils.Tracer;
	import myShopper.shopMgtModule.appFooter.enum.AssetID;
	import myShopper.shopMgtModule.appFooter.enum.ProxyID;
	import myShopper.shopMgtModule.appFooter.model.CommunicationProxy;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	import org.puremvc.as3.multicore.patterns.observer.Notification;
    
	
	public class ButtonCommand extends SimpleCommand 
	{
		
		override public function execute(note:INotification):void 
		{
			
			var buttonID:String;
			
			if 		(note.getBody() is IButton) buttonID = (note.getBody() as IButton).id;
			else if	(note.getBody() is String) 	buttonID = String(note.getBody());
			
			Tracer.echo(multitonKey + ' : ButtonCommand : execute : ' + buttonID, this, 0xff0000);
			
			switch(buttonID)
			{
				//case AssetID.BTN_SHOPPER_ABOUT:
				case AssetID.BTN_SHOPPER_AD:
				case AssetID.BTN_SHOPPER_CONTACT:
				case AssetID.BTN_SHOPPER_ERROR_REPORT:
				case AssetID.BTN_SHOPPER_SUGGEST:
				//case AssetID.BTN_SHOPPER_FAQ:
				{
					comm.request(CommunicationType.SHOPPER_CONTACT_US, note.getBody());
					break;
				}
				case AssetID.BTN_SHOPPER_ABOUT:
				//case AssetID.BTN_SHOPPER_SERVICE:
				//case AssetID.BTN_SHOPPER_BENEFIT:
				case AssetID.BTN_SHOPPER_PROCEDURE:
				case AssetID.BTN_SHOPPER_HOWTO:
				{
					CONFIG::mobile
					{
						comm.request(CommunicationType.SHOPPER_WEB_VIEW, getURLByID(buttonID));
						return;
					}
					navigateToURL(new URLRequest(getURLByID(buttonID)), "_blank"); 
					break;
					
				}
				default:
				{
					Tracer.echo(multitonKey + ' : ButtonCommand : no matched id found : ' + buttonID, this, 0xff0000);
				}
			}
		}
		
		private function getURLByID(id:String):String 
		{
			
			switch(id)
			{
				//TODO if more languages available 
				case AssetID.BTN_SHOPPER_ABOUT:			return Tools.formatString(Config.URL_SHOPPER_ABOUT, [Config.LANG_CODE_EN]); 
				//case AssetID.BTN_SHOPPER_SERVICE:		return httpHost + Config.URL_SHOPPER_SERVICE;
				//case AssetID.BTN_SHOPPER_BENEFIT:		return httpHost + Config.URL_SHOPPER_BENEFIT;
				case AssetID.BTN_SHOPPER_PROCEDURE:		return Tools.formatString(Config.URL_SHOPPER_PROCEDURE, [Config.LANG_CODE_EN]);
				case AssetID.BTN_SHOPPER_HOWTO:			return Tools.formatString(Config.URL_SHOPPER_HOWTO, [Config.LANG_CODE_EN]);
			}
			
			return '';
		}
		
		
		private function get comm():CommunicationProxy
		{
			return facade.retrieveProxy(ProxyID.COMM) as CommunicationProxy;
		}
	}
}