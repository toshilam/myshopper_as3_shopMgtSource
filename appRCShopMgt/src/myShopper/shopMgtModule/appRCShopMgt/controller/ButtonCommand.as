package myShopper.shopMgtModule.appRCShopMgt.controller 

{
	import myShopper.common.interfaces.IButton;
	import myShopper.common.utils.Tracer;
	import myShopper.shopMgtModule.appRCShopMgt.enum.AssetID;
	import myShopper.shopMgtModule.appRCShopMgt.enum.PageID;
	import myShopper.shopMgtModule.appRCShopMgt.enum.ProxyID;
	import myShopper.shopMgtModule.appRCShopMgt.model.AssetProxy;
	import myShopper.shopMgtModule.appRCShopMgt.model.CommunicationProxy;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
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
				case AssetID.BTN_CONNECT:
				{
					asset.changePage(PageID.LOGIN_SCAN);
					break;
				}
				case AssetID.BTN_PRODUCT_SCAN:
				{
					asset.changePage(PageID.PRODUCT_SCAN);
					break;
				}
				case AssetID.BTN_HOME:
				{
					asset.changePage(PageID.MAIN_MENU);
					break;
				}
				case AssetID.BTN_LOGOUT:
				{
					asset.changePage(PageID.LOGIN);
					break;
				}
				case AssetID.BTN_BACK:
				{
					asset.previousPage();
					break;
				}
				default:
				{
					Tracer.echo(multitonKey + ' : ButtonCommand : no matched id found : ' + buttonID, this, 0xff0000);
				}
			}
		}
		
		private function get asset():AssetProxy
		{
			return facade.retrieveProxy(ProxyID.ASSET) as AssetProxy
		}
		
		private function get comm():CommunicationProxy
		{
			return facade.retrieveProxy(ProxyID.COMM) as CommunicationProxy
		}
	}
}