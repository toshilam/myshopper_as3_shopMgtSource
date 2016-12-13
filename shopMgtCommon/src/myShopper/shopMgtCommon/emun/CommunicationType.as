package myShopper.shopMgtCommon.emun 
{
	/**
	 * ...
	 * @author Toshi
	 */
	public class CommunicationType
	{
		//after user login and shop info received/failed
		public static const SHOP_INFO_INITIALZIED:String = 'shopInfoInitialzied';
		
		public static const SHOP_MGT_SETTING:String = 'shopMgtSetting';
		public static const SHOP_MGT_PROFILE:String = 'shopMgtProfile';
		public static const SHOP_MGT_ABOUT:String = 'shopMgtAbout';
		public static const SHOP_MGT_PRODUCT:String = 'shopMgtProduct';
		public static const SHOP_MGT_NEWS:String = 'shopMgtNews';
		public static const SHOP_MGT_CUSTOM:String = 'shopMgtCustom';
		public static const SHOP_MGT_CUSTOMER_INFO:String = 'shopMgtCustomerInfo'; //open user info window
		public static const SHOP_MGT_CUSTOMER_CHAT:String = 'shopMgtCustomerChat'; //open user chat window
		public static const SHOP_MGT_SALES:String = 'shopMgtSales';
		public static const SHOP_MGT_ORDER:String = 'shopMgtOrder';
		public static const SHOP_MGT_CLOSED_ORDER:String = 'shopMgtClosedOrder';
		public static const SHOP_MGT_USER_MESSAGE:String = 'shopMgtUserMessage'; //user message (mail box, not chatting message)
		public static const SHOP_MGT_UPDATE_NUM_NEW_MESSAGE:String = 'shopMgtUpdateNumNewMessage'; //update quick menu btn
		public static const SHOP_MGT_UPDATE_NUM_NEW_ORDER:String = 'shopMgtUpdateNumNewOrder'; //update quick menu btn
		public static const SHOP_MGT_UPDATE_ORDER:String = 'shopMgtUpdateOrder'; //refresh order list
		//public static const SHOP_MGT_UPDATE_PROFILE:String = 'shopMgtUpdateProfile'; //refresh order list
		
		//a new message receive from user(walked in user), and the chat window is not created yet
		//this notified by appForm module
		public static const SHOP_RECEIVE_CHAT_MESSAGE:String = 'shopReceiveChatMessage'; 
	}

}