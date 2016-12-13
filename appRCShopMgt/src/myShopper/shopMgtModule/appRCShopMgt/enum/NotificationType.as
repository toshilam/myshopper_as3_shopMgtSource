package myShopper.shopMgtModule.appRCShopMgt.enum 
{
	import myShopper.shopMgtModule.appRCShopMgt.ShopMgtMain;
	/**
	 * ...
	 * @author Toshi Lam
	 */
	public class NotificationType 
	{
		public static const PLAY_SOUND:String = ShopMgtMain.NAME + 'pageSound';
		
		public static const VIEW_PAGE:String = ShopMgtMain.NAME + 'viewPage';
		public static const VIEW_WEB_PAGE:String = ShopMgtMain.NAME + 'viewWebPage';
		
		public static const LOGIN_FAIL:String = ShopMgtMain.NAME + 'loginFail';
		public static const LOGIN_SUCCESS:String = ShopMgtMain.NAME + 'loginSuccess';
	}

}