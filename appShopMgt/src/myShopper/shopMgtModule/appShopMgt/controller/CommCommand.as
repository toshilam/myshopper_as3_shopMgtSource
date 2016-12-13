package myShopper.shopMgtModule.appShopMgt.controller
{
	import myShopper.common.data.FileImageVO;
	import myShopper.common.emun.AMFCommServicesType;
	import myShopper.common.emun.AMFShopServicesType;
	import myShopper.common.emun.CommunicationType;
	import myShopper.common.emun.FileType;
	import myShopper.common.events.FileEvent;
	import myShopper.common.interfaces.ICommServiceRequest;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.utils.Tracer;
	import myShopper.shopMgtCommon.emun.AMFShopManagementServicesType;
	import myShopper.shopMgtCommon.emun.CommunicationType;
	import myShopper.shopMgtModule.appShopMgt.enum.NotificationType;
	import myShopper.shopMgtModule.appShopMgt.enum.ProxyID;
	import myShopper.shopMgtModule.appShopMgt.model.ShopDataProxy;
	import org.puremvc.as3.multicore.interfaces.IApplicationMediator;
	import org.puremvc.as3.multicore.interfaces.IApplicationProxy;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CommCommand extends SimpleCommand implements ICommand
	{
		override public function execute( note:INotification ):void
		{
			var request:ICommServiceRequest = note.getBody() as ICommServiceRequest;
			
			if (request)
			{
				switch(request.communicationType)
				{
					case myShopper.common.emun.CommunicationType.USER_LOGIN_SUCCESS:
					{
						//get shop info
						(facade.retrieveProxy(ProxyID.SHOP_DATA) as IRemoteDataProxy).getRemoteData(AMFShopManagementServicesType.GET_INFO_BY_USER_ID, note.getBody());
						break;
					}
					case myShopper.common.emun.CommunicationType.USER_LOGOUT:
					{
						(facade.retrieveProxy(ProxyID.SHOP_DATA) as ShopDataProxy).tearDownAsset();
						break;
					}
					case myShopper.common.emun.CommunicationType.SHOPPER_WEB_VIEW:
					{
						sendNotification(NotificationType.VIEW_WEB_PAGE, request.data);
						break;
					}
					case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_UPDATE_NUM_NEW_MESSAGE:
					{
						//get num unread message
						(facade.retrieveProxy(ProxyID.SHOP_DATA) as IRemoteDataProxy).getRemoteData(AMFCommServicesType.GET_NUM_UNREAD_USER_SHOP_MESSAGE, note.getBody());
						break;
					}
					case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_UPDATE_NUM_NEW_ORDER:
					case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_RECEIVE_CHAT_MESSAGE:
					{
						sendNotification(getNotificationTypeByCommType(request.communicationType), request.data);
						break;
					}
				}
				
			}
			
		}
		
		private function getNotificationTypeByCommType(inType:String):String
		{
			if (inType == myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_UPDATE_NUM_NEW_ORDER)	return myShopper.shopMgtModule.appShopMgt.enum.NotificationType.UPDATE_NUM_NEW_ORDER;
			if (inType == myShopper.shopMgtCommon.emun.CommunicationType.SHOP_RECEIVE_CHAT_MESSAGE)	return myShopper.shopMgtModule.appShopMgt.enum.NotificationType.RECEIVE_CHAT_MESSAGE;
			
			return '';
		}
		
		
		/*private function get asset():AssetProxy
		{
			return facade.retrieveProxy(ProxyID.ASSET) as AssetProxy;
		}*/
	}
}