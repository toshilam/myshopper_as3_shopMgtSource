package myShopper.shopMgtModule.appShopMgt.controller 

{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import myShopper.common.interfaces.IButton;
	import myShopper.common.interfaces.IDataDisplayObject;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.interfaces.IVO;
	import myShopper.common.utils.Tracer;
	import myShopper.shopMgtCommon.emun.AssetID;
	import myShopper.shopMgtCommon.emun.CommunicationType;
	import myShopper.shopMgtModule.appShopMgt.enum.ProxyID;
	import myShopper.shopMgtModule.appShopMgt.model.CommunicationProxy;
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
				case AssetID.BTN_SHOP_SETTING:
				case AssetID.BTN_SHOP_PROFILE:
				case AssetID.BTN_SHOP_ABOUT:
				case AssetID.BTN_SHOP_PRODUCT:
				case AssetID.BTN_SHOP_NEWS:
				case AssetID.BTN_SHOP_CUSTOM:
				case AssetID.BTN_Q_SALES:
				case AssetID.BTN_Q_ORDER:
				case AssetID.BTN_Q_CLOSED_ORDER:
				case AssetID.BTN_Q_USER_MESSAGE:
				{
					comm.request(getCommTypeByAssetID(buttonID));
					break;
				}
				case AssetID.BTN_CUSTOMER_MORE:
				case AssetID.BTN_CUSTOMER_CHAT:
				{
					var item:IDataDisplayObject = note.getBody() as IDataDisplayObject;
					if (item && item.vo)
					{
						comm.request(getCommTypeByAssetID(buttonID), item.vo);
					}
					else
					{
						Tracer.echo(multitonKey + ' : ButtonCommand : unknown button type : ' + note.getBody(), this, 0xff0000);
					}
					break;
				}
				default:
				{
					Tracer.echo(multitonKey + ' : ButtonCommand : no matched id found : ' + buttonID, this, 0xff0000);
				}
			}
		}
		
		private function getCommTypeByAssetID(inID:String):String
		{
			switch(inID)
			{
				case AssetID.BTN_SHOP_SETTING: 				return CommunicationType.SHOP_MGT_SETTING;
				case AssetID.BTN_SHOP_PROFILE: 				return CommunicationType.SHOP_MGT_PROFILE;
				case AssetID.BTN_SHOP_ABOUT: 				return CommunicationType.SHOP_MGT_ABOUT;
				case AssetID.BTN_SHOP_PRODUCT:				return CommunicationType.SHOP_MGT_PRODUCT;
				case AssetID.BTN_SHOP_NEWS:					return CommunicationType.SHOP_MGT_NEWS;
				case AssetID.BTN_SHOP_CUSTOM:				return CommunicationType.SHOP_MGT_CUSTOM;
				case AssetID.BTN_CUSTOMER_MORE:				return CommunicationType.SHOP_MGT_CUSTOMER_INFO;
				case AssetID.BTN_CUSTOMER_CHAT:				return CommunicationType.SHOP_MGT_CUSTOMER_CHAT;
				case AssetID.BTN_Q_SALES:					return CommunicationType.SHOP_MGT_SALES;
				case AssetID.BTN_Q_ORDER:					return CommunicationType.SHOP_MGT_ORDER;
				case AssetID.BTN_Q_CLOSED_ORDER:			return CommunicationType.SHOP_MGT_CLOSED_ORDER;
				case AssetID.BTN_Q_USER_MESSAGE:			return CommunicationType.SHOP_MGT_USER_MESSAGE;
			}
			
			return '';
		}
		
		private function get comm():CommunicationProxy
		{
			return facade.retrieveProxy(ProxyID.COMM) as CommunicationProxy
		}
	}
}