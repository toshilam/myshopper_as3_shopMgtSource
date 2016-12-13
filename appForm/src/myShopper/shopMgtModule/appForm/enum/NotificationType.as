package myShopper.shopMgtModule.appForm.enum 
{
	import myShopper.shopMgtModule.appForm.FormMain;
	/**
	 * ...
	 * @author Toshi Lam
	 */
	public class NotificationType 
	{
		public static const ADD_FORM_USER_FORGOT_PASSWORD:String = FormMain.NAME + 'AddUserForgotPassword';
		public static const USER_FORGOT_PASSWORD_SUCCESS:String = FormMain.NAME + 'userForgotPasswordSuccess'; //pw email successfully sent
		public static const USER_FORGOT_PASSWORD_FAIL:String = FormMain.NAME + 'userForgotPasswordFail'; //send pw email fail
		
		public static const ADD_FORM_SHOP_CUSTOMER_CHAT:String = FormMain.NAME + 'AddShopCustomerChat';
		
		public static const ADD_FORM_SHOP_CUSTOMER_INFO:String = FormMain.NAME + 'AddShopCustomerInfo';
		public static const GET_CUSTOMER_INFO_SUCCESS:String = FormMain.NAME + 'getCustomerInfoSuccess';
		public static const GET_CUSTOMER_INFO_FAIL:String = FormMain.NAME + 'getCustomerInfoFail';
		
		public static const RECEIVE_CUSTOMER_CHAT_MESSAGE:String = FormMain.NAME + 'receiveCustomerChatMessage';
		public static const END_CUSTOMER_CHAT:String = FormMain.NAME + 'endCustomerChat'; //to be notified when user is walked out shop
		
		public static const ADD_FORM_SHOPPER_CONTACT_US:String = FormMain.NAME + 'AddShopperContactUs';
		public static const SHOPPER_CONTACT_US_SUCCESS:String = FormMain.NAME + 'ShopperContactUsSuccess';
		public static const SHOPPER_CONTACT_US_FAIL:String = FormMain.NAME + 'ShopperContactUsFail';
		
		public static const ADD_FORM_USER_LOGIN:String = FormMain.NAME + 'AddUserLogin';
		public static const USER_LOGIN_SUCCESS:String = FormMain.NAME + 'userLoginSuccess';
		public static const USER_LOGIN_FAIL:String = FormMain.NAME + 'userLoginFail';
		
		public static const ADD_DISPLAY_SALES_HISTORY:String = FormMain.NAME + 'AddDisplaySalesHistory';
		
		public static const ADD_DISPLAY_SALES:String = FormMain.NAME + 'AddDisplaySales';
		public static const CREATE_SALES_SUCCESS:String = FormMain.NAME + 'CreateSalesSuccess';
		public static const CREATE_SALES_FAIL:String = FormMain.NAME + 'CreateSalesFail';
		public static const ADD_FORM_SHOP_SALES_EXTRA:String = FormMain.NAME + 'AddShopSalesExtra';
		public static const RESULT_GET_SALES_PRODUCT:String = FormMain.NAME + 'resultGetSalesProduct';
		public static const RESULT_GET_SALES_EXTRA:String = FormMain.NAME + 'resultGetSalesExtra';
		public static const DELETE_SALES_SUCCESS:String = FormMain.NAME + 'deleteSalesSuccess';
		public static const DELETE_SALES_FAIL:String = FormMain.NAME + 'deleteSalesFail';
		public static const ADD_SALES_PRODUCT:String = FormMain.NAME + 'addSalesProduct';
		
		public static const ADD_DISPLAY_ORDER:String = FormMain.NAME + 'AddDisplayOrder';
		public static const REFRESH_DISPLAY_ORDER:String = FormMain.NAME + 'RefreshDisplayOrder';
		public static const ADD_FORM_SHOP_ORDER:String = FormMain.NAME + 'AddShopOrder';
		public static const ADD_FORM_SHOP_ORDER_EXTRA:String = FormMain.NAME + 'AddShopOrderExtra';
		//public static const RESULT_ADD_ORDER_EXTRA:String = FormMain.NAME + 'resultAddOrderExtra';
		public static const RESULT_GET_ORDER_PRODUCT:String = FormMain.NAME + 'resultGetOrderProduct';
		public static const RESULT_GET_ORDER_EXTRA:String = FormMain.NAME + 'resultGetOrderExtra';
		public static const UPDATE_ORDER_SHIPMENT_SUCCESS:String = FormMain.NAME + 'updateOrderShipmentSuccess';
		public static const UPDATE_ORDER_SHIPMENT_FAIL:String = FormMain.NAME + 'updateOrderShipmentFail';
		public static const SEND_ORDER_INVOICE_SUCCESS:String = FormMain.NAME + 'sendOrderInvoiceSuccess';
		public static const SEND_ORDER_INVOICE_FAIL:String = FormMain.NAME + 'sendOrderInvoiceFail';
		
		public static const ADD_DISPLAY_SETTING:String = FormMain.NAME + 'AddDisplaySetting';
		public static const ADD_FORM_SHOP_PASSWORD:String = FormMain.NAME + 'AddShopPassword';
		public static const UPDATE_PASSWORD_SUCCESS:String = FormMain.NAME + 'updatePasswordSuccess';
		public static const UPDATE_PASSWORD_FAIL:String = FormMain.NAME + 'updatePasswordFail';
		
		public static const ADD_FORM_PAYPAL_ACC_VERIFY:String = FormMain.NAME + 'AddShopPaypalAccVerify';
		public static const PAYPAL_ACC_VERIFY_SUCCESS:String = FormMain.NAME + 'paypalAccVerifySuccess';
		public static const PAYPAL_ACC_VERIFY_FAIL:String = FormMain.NAME + 'paypalAccVerifyFail';
		
		public static const ADD_FORM_ACC_VERIFY:String = FormMain.NAME + 'AddShopAccVerify';
		public static const ACC_VERIFY_SUCCESS:String = FormMain.NAME + 'accVerifySuccess';
		public static const ACC_VERIFY_FAIL:String = FormMain.NAME + 'accVerifyFail';
		
		public static const ADD_FORM_SHOP_LOGO:String = FormMain.NAME + 'AddShopLogo';
		public static const UPDATE_LOGO_SUCCESS:String = FormMain.NAME + 'updateLogoSuccess';
		public static const UPDATE_LOGO_FAIL:String = FormMain.NAME + 'updateLogoFail';
		
		public static const ADD_FORM_SHOP_BG:String = FormMain.NAME + 'AddShopBG';
		public static const UPDATE_BG_SUCCESS:String = FormMain.NAME + 'updateBGSuccess';
		public static const UPDATE_BG_FAIL:String = FormMain.NAME + 'updateBGFail';
		
		public static const ADD_FORM_SHOP_PRINT:String = FormMain.NAME + 'AddShopPrint';
		public static const SET_PRINT_SUCCESS:String = FormMain.NAME + 'updatePrintSuccess';
		public static const SET_PRINT_FAIL:String = FormMain.NAME + 'updatePrintFail';
		public static const SEARCH_PRINTER_SUCCESS:String = FormMain.NAME + 'searchPrinterSuccess';
		public static const SEARCH_PRINTER_FAIL:String = FormMain.NAME + 'searchPrinterFail';
		
		public static const ADD_FORM_SHOP_REMOTE:String = FormMain.NAME + 'AddShopRemote';
		
		public static const ADD_FORM_GOOGLE_LOGIN:String = FormMain.NAME + 'AddGoogleLogin';
		public static const USER_GOOGLE_LOGIN_SUCCESS:String = FormMain.NAME + 'UserGoogleLogingSuccess';
		public static const USER_GOOGLE_LOGIN_FAIL:String = FormMain.NAME + 'UserGoogleLogingFail';
		
		public static const ADD_FORM_SHOP_CURRENCY:String = FormMain.NAME + 'AddShopCurrency';
		public static const UPDATE_CURRENCY_SUCCESS:String = FormMain.NAME + 'updateCurrencySuccess';
		public static const UPDATE_CURRENCY_FAIL:String = FormMain.NAME + 'updateCurrencyFail';
		
		public static const ADD_FORM_SHOP_TAX:String = FormMain.NAME + 'AddShopTax';
		public static const UPDATE_TAX_SUCCESS:String = FormMain.NAME + 'updateTaxSuccess';
		public static const UPDATE_TAX_FAIL:String = FormMain.NAME + 'updateTaxFail';
		
		public static const ADD_DISPLAY_PROFILES:String = FormMain.NAME + 'AddDisplayProfiles'; //list of shop
		public static const ADD_FORM_SHOP_PROFILE:String = FormMain.NAME + 'AddShopProfile';
		public static const CREATE_PROFILE_SUCCESS:String = FormMain.NAME + 'createProfileSuccess';
		public static const CREATE_PROFILE_FAIL:String = FormMain.NAME + 'createProfileFail';
		public static const UPDATE_PROFILE_SUCCESS:String = FormMain.NAME + 'updateProfileSuccess';
		public static const UPDATE_PROFILE_FAIL:String = FormMain.NAME + 'updateProfileFail';
		public static const DELETE_PROFILE_SUCCESS:String = FormMain.NAME + 'deleteProfileSuccess';
		public static const DELETE_PROFILE_FAIL:String = FormMain.NAME + 'deleteProfileFail';
		
		public static const GET_COUNTRY_SUCCESS:String = FormMain.NAME + 'getCountrySuccess';
		public static const GET_COUNTRY_FAIL:String = FormMain.NAME + 'getCountryFail';
		
		public static const GET_STATE_SUCCESS:String = FormMain.NAME + 'getStateSuccess';
		public static const GET_STATE_FAIL:String = FormMain.NAME + 'getStateFail';
		
		public static const GET_CITY_SUCCESS:String = FormMain.NAME + 'getCitySuccess';
		public static const GET_CITY_FAIL:String = FormMain.NAME + 'getCityFail';
		
		public static const GET_AREA_SUCCESS:String = FormMain.NAME + 'getAreaSuccess';
		public static const GET_AREA_FAIL:String = FormMain.NAME + 'getAreaFail';
		
		public static const ADD_FORM_SHOP_ABOUT:String = FormMain.NAME + 'AddShopAbout';
		public static const GET_ABOUT_SUCCESS:String = FormMain.NAME + 'getAboutSuccess';
		public static const GET_ABOUT_FAIL:String = FormMain.NAME + 'getAboutFail';
		public static const UPDATE_ABOUT_SUCCESS:String = FormMain.NAME + 'updateAboutSuccess';
		public static const UPDATE_ABOUT_FAIL:String = FormMain.NAME + 'updateAboutFail';
		
		public static const ADD_DISPLAY_NEWS:String = FormMain.NAME + 'AddDisplayNews';
		public static const ADD_FORM_SHOP_NEWS:String = FormMain.NAME + 'AddShopNews';
		public static const ADD_ALERT_SHOP_NEWS:String = FormMain.NAME + 'AddShopAlertNews'; //confirm alert for delete news
		public static const RESULT_GET_NEWS:String = FormMain.NAME + 'ResultGetNews';
		public static const CREATE_NEWS_SUCCESS:String = FormMain.NAME + 'createNewsSuccess';
		public static const CREATE_NEWS_FAIL:String = FormMain.NAME + 'createNewsFail';
		public static const UPDATE_NEWS_SUCCESS:String = FormMain.NAME + 'updateNewsSuccess';
		public static const UPDATE_NEWS_FAIL:String = FormMain.NAME + 'updateNewsFail';
		public static const DELETE_NEWS_SUCCESS:String = FormMain.NAME + 'deleteNewsSuccess';
		public static const DELETE_NEWS_FAIL:String = FormMain.NAME + 'deleteNewsFail';
		
		public static const ADD_DISPLAY_CUSTOM:String = FormMain.NAME + 'AddDisplayCustom';
		public static const GET_CUSTOM_SUCCESS:String = FormMain.NAME + 'getCustomSuccess';
		public static const GET_CUSTOM_FAIL:String = FormMain.NAME + 'getCustomFail';
		public static const ADD_FORM_SHOP_CUSTOM:String = FormMain.NAME + 'AddShopCustom';
		public static const ADD_ALERT_SHOP_CUSTOM:String = FormMain.NAME + 'AddShopAlertCustom'; //confirm alert for delete custom
		public static const CREATE_CUSTOM_SUCCESS:String = FormMain.NAME + 'createCustomSuccess';
		public static const CREATE_CUSTOM_FAIL:String = FormMain.NAME + 'createCustomFail';
		public static const UPDATE_CUSTOM_SUCCESS:String = FormMain.NAME + 'updateCustomSuccess';
		public static const UPDATE_CUSTOM_FAIL:String = FormMain.NAME + 'updateCustomFail';
		public static const DELETE_CUSTOM_SUCCESS:String = FormMain.NAME + 'deleteCustomSuccess';
		public static const DELETE_CUSTOM_FAIL:String = FormMain.NAME + 'deleteCustomFail';
		public static const GET_CUSTOM_BY_NO_SUCCESS:String = FormMain.NAME + 'GetCustomByNoSuccess';
		public static const GET_CUSTOM_BY_NO_FAIL:String = FormMain.NAME + 'GetCustomByNoFail';
		
		public static const ADD_DISPLAY_PRODUCT:String = FormMain.NAME + 'AddDisplayProduct';
		public static const ADD_DISPLAY_PRODUCT_STOCK:String = FormMain.NAME + 'AddDisplayProduct';
		public static const RESULT_GET_CATEGORY_PRODUCT:String = FormMain.NAME + 'ResultGetCategoryProduct';
		
		public static const ADD_FORM_SHOP_CATEGORY:String = FormMain.NAME + 'AddShopFormCategory';
		public static const ADD_ALERT_SHOP_CATEGORY:String = FormMain.NAME + 'AddShopAlertCategory'; //confirm alert for delete category
		public static const CREATE_CATEGORY_SUCCESS:String = FormMain.NAME + 'CreateCategorySuccess';
		public static const CREATE_CATEGORY_FAIL:String = FormMain.NAME + 'CreateCategoryFail';
		public static const UPDATE_CATEGORY_SUCCESS:String = FormMain.NAME + 'UpdateCategorySuccess';
		public static const UPDATE_CATEGORY_FAIL:String = FormMain.NAME + 'UpdateCategoryFail';
		public static const DELETE_CATEGORY_SUCCESS:String = FormMain.NAME + 'DeleteCategorySuccess';
		public static const DELETE_CATEGORY_FAIL:String = FormMain.NAME + 'DeleteCategoryFail';
		
		public static const ADD_FORM_SHOP_PRODUCT:String = FormMain.NAME + 'AddShopFormProduct';
		public static const ADD_ALERT_SHOP_PRODUCT:String = FormMain.NAME + 'AddShopAlertProduct'; //confirm alert for delete product
		public static const CREATE_PRODUCT_SUCCESS:String = FormMain.NAME + 'CreateProductSuccess';
		public static const CREATE_PRODUCT_FAIL:String = FormMain.NAME + 'CreateProductFail';
		public static const CREATE_PRODUCT_STOCK_SUCCESS:String = FormMain.NAME + 'CreateProductStockSuccess';
		public static const CREATE_PRODUCT_STOCK_FAIL:String = FormMain.NAME + 'CreateProductStockFail';
		public static const UPDATE_PRODUCT_SUCCESS:String = FormMain.NAME + 'UpdateProductSuccess';
		public static const UPDATE_PRODUCT_FAIL:String = FormMain.NAME + 'UpdateProductFail';
		public static const DELETE_PRODUCT_SUCCESS:String = FormMain.NAME + 'DeleteProductSuccess';
		public static const DELETE_PRODUCT_FAIL:String = FormMain.NAME + 'DeleteProductFail';
		public static const DELETE_PRODUCT_STOCK_SUCCESS:String = FormMain.NAME + 'DeleteProductStockSuccess';
		public static const DELETE_PRODUCT_STOCK_FAIL:String = FormMain.NAME + 'DeleteProductStockFail';
		public static const GET_PRODUCT_BY_NO_SUCCESS:String = FormMain.NAME + 'GetProductByNoSuccess';
		public static const GET_PRODUCT_BY_NO_FAIL:String = FormMain.NAME + 'GetProductByNoFail';
		public static const GET_PRODUCT_STOCK_SUCCESS:String = FormMain.NAME + 'GetProductStockSuccess';
		public static const GET_PRODUCT_STOCK_FAIL:String = FormMain.NAME + 'GetProductStockFail';
		public static const GET_PRODUCT_STOCK_HISTORY_SUCCESS:String = FormMain.NAME + 'GetProductStockHistorySuccess';
		public static const GET_PRODUCT_STOCK_HISTORY_FAIL:String = FormMain.NAME + 'GetProductStockHistoryFail';
		
		public static const ADD_DISPLAY_USER_MESSAGE:String = FormMain.NAME + 'AddDisplayUserMessage';
		public static const ADD_FORM_USER_MESSAGE:String = FormMain.NAME + 'AddFormUserMessage';
		public static const GET_USER_SHOP_MESSAGE_LIST_SUCCESS:String = FormMain.NAME + 'GetUserShopMessageListSuccess';
		public static const GET_USER_SHOP_MESSAGE_LIST_FAIL:String = FormMain.NAME + 'GetUserShopMessageListFail';
		public static const GET_USER_SHOP_MESSAGE_BY_UID_SUCCESS:String = FormMain.NAME + 'GetUserShopMessageByUIDSuccess';
		public static const GET_USER_SHOP_MESSAGE_BY_UID_FAIL:String = FormMain.NAME + 'GetUserShopMessageByUIDFail';
		public static const CREATE_USER_MSG_SUCCESS:String = FormMain.NAME + 'CreateUserMsgSuccess';
		public static const CREATE_USER_MSG_FAIL:String = FormMain.NAME + 'CreateUserMsgFail';
		
		public static const FB_NO_PERMISSION:String = FormMain.NAME + 'fbNOPermission'; //common fb notification
		public static const ADD_FORM_FB_SHARE_P_FRIEND:String = FormMain.NAME + 'AddFBSharePFriend';
		public static const FB_SHARE_P_FRIEND_SUCCESS:String = FormMain.NAME + 'fBSharePFriendSuccess'; 
		public static const FB_SHARE_P_FRIEND_FAIL:String = FormMain.NAME + 'fBSharePFriendFail'; 
	}

}