package myShopper.shopMgtModule.appShopMgt.enum 
{
	import myShopper.shopMgtModule.appShopMgt.ShopMgtMain;
	/**
	 * ...
	 * @author Toshi Lam
	 */
	public class NotificationType 
	{
		public static const RECEIVE_CHAT_MESSAGE:String = ShopMgtMain.NAME + 'receiveChatMessage';
		public static const UPDATE_CUSTOMER_LIST:String = ShopMgtMain.NAME + 'updateCustomerList';
		public static const UPDATE_NUM_NEW_ORDER:String = ShopMgtMain.NAME + 'updateNumberOfNewOrder';
		public static const UPDATE_NUM_NEW_MESSAGE:String = ShopMgtMain.NAME + 'updateNumberOfNewMessage';
		public static const UPDATE_STATUS_SUCCESS:String = ShopMgtMain.NAME + 'updateStatusSuccess';
		public static const UPDATE_STATUS_FAIL:String = ShopMgtMain.NAME + 'updateStatusFail';
		public static const VIEW_WEB_PAGE:String = ShopMgtMain.NAME + 'viewWebPage';
		//public static const USER_WALK_IN_SHOP:String = ShopMgtMain.NAME + 'userWalkInShop';
		//public static const USER_WALK_OUT_SHOP:String = ShopMgtMain.NAME + 'userWalkOutShop';
	}

}