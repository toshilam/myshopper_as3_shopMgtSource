package myShopper.shopMgtCommon.emun 
{
	/**
	 * amf sservice types, that has to be matched with server side.
	 * @author Toshi
	 */
	public class AMFShopManagementServicesType
	{
		//shop management services
		public static const USER_LOGIN:String = 'shopper.shops.ShopManagement.login';
		public static const USER_AUTO_LOGIN:String = 'shopper.shops.ShopManagement.autoLogin';
		public static const GET_INFO_BY_USER_ID:String = 'shopper.shops.ShopManagement.getInfoByUserID';
		public static const IS_SHOP_INFO_APPROVED:String = 'shopper.shops.ShopManagement.isShopInfoApproved';
		public static const GET_ACC_VERIFY_STATUS:String = 'shopper.shops.ShopManagement.getAccVerifyStatus'; //get shop is activated
		public static const GET_ACC_VERIFIED:String = 'shopper.shops.ShopManagement.getAccVerified'; //request (to admin) get shop activated
		
		public static const GET_ABOUT:String = 'shopper.shops.ShopManagement.getAbout';
		public static const UPDATE_ABOUT:String = 'shopper.shops.ShopManagement.updateAbout';
		//public static const UPDATE_PASSWORD:String = 'shopper.shops.ShopManagement.updatePassword';
		public static const GET_NEWS:String = 'shopper.shops.ShopManagement.getNews';
		public static const CREATE_NEWS:String = 'shopper.shops.ShopManagement.createNews';
		public static const UPDATE_NEWS:String = 'shopper.shops.ShopManagement.updateNews';
		public static const DELETE_NEWS:String = 'shopper.shops.ShopManagement.deleteNews';
		
		public static const GET_CUSTOM:String = 'shopper.shops.ShopManagement.getCustom';
		public static const CREATE_CUSTOM:String = 'shopper.shops.ShopManagement.createCustom';
		public static const UPDATE_CUSTOM:String = 'shopper.shops.ShopManagement.updateCustom';
		public static const DELETE_CUSTOM:String = 'shopper.shops.ShopManagement.deleteCustom';
		public static const GET_CUSTOM_BY_NO:String = 'shopper.shops.ShopManagement.getCustomByNo';
		
		public static const GET_LOGO:String = 'shopper.shops.ShopManagement.getLogo';
		public static const UPDATE_LOGO:String = 'shopper.shops.ShopManagement.updateLogo';
		public static const UPDATE_BG:String = 'shopper.shops.ShopManagement.updateBG';
		public static const UPDATE_CURRENCY:String = 'shopper.shops.ShopManagement.updateCurrency';
		public static const UPDATE_TAX:String = 'shopper.shops.ShopManagement.updateTax';
		
		public static const UPDATE_INFO:String = 'shopper.shops.ShopManagement.updateInfo';
		public static const CREATE_INFO:String = 'shopper.shops.ShopManagement.createInfo';
		public static const DELETE_INFO:String = 'shopper.shops.ShopManagement.deleteInfo';
		
		public static const GET_CATEGORY_PRODUCT:String = 'shopper.shops.ShopManagement.getCategoryAndProduct';
		public static const GET_CATEGORY:String = 'shopper.shops.ShopManagement.getCategory'; //not used?
		public static const GET_PRODUCT:String = 'shopper.shops.ShopManagement.getProduct'; //not used?
		public static const GET_PRODUCT_BY_NO:String = 'shopper.shops.ShopManagement.getProductByNo';
		public static const GET_PRODUCT_STOCK:String = 'shopper.shops.ShopManagement.getProductStock';
		public static const GET_PRODUCT_STOCK_HISTORY:String = 'shopper.shops.ShopManagement.getProductStockHistory';
		
		public static const CREATE_CATEGORY:String = 'shopper.shops.ShopManagement.createCategory';
		public static const CREATE_PRODUCT:String = 'shopper.shops.ShopManagement.createProduct';
		public static const CREATE_PRODUCT_STOCK:String = 'shopper.shops.ShopManagement.createProductStock';
		public static const DELETE_PRODUCT_STOCK:String = 'shopper.shops.ShopManagement.deleteProductStock';
		public static const CREATE_PRODUCT_FBID:String = 'shopper.shops.ShopManagement.createProductFBID'; //shared product fb id
		public static const DELETE_CATEGORY:String = 'shopper.shops.ShopManagement.deleteCategory';
		public static const DELETE_PRODUCT:String = 'shopper.shops.ShopManagement.deleteProduct';
		public static const UPDATE_CATEGORY:String = 'shopper.shops.ShopManagement.updateCategory';
		public static const UPDATE_PRODUCT:String = 'shopper.shops.ShopManagement.updateProduct';
		
		//public static const GET_CUSTOMERS_INFO_BY_ID:String = 'shopper.shops.ShopManagement.getCustomersInfoByID'; //NOT used?
		public static const GET_CUSTOMER_INFO_BY_UID:String = 'shopper.shops.ShopManagement.getCustomerInfoByUID';
		
		public static const GET_ORDER:String = 'shopper.shops.ShopManagement.getOrder';
		//public static const UPDATE_ORDER_STATUS:String = 'shopper.shops.ShopManagement.updateOrderStatus'; //order status
		public static const ADD_ORDER_EXTRA:String = 'shopper.shops.ShopManagement.addOrderExtra'; 
		public static const SEND_ORDER_INVOICE:String = 'shopper.shops.ShopManagement.sendOrderInvoice'; 
		public static const UPDATE_ORDER_SHIPMENT:String = 'shopper.shops.ShopManagement.updateOrderShipment'; //order detail info + status
		public static const UPDATE_STATUS:String = 'shopper.shops.ShopManagement.updateStatus'; //shop status 
		//public static const GET_ORDER_SINCE:String = 'shopper.shops.ShopManagement.getOrderSince';
		public static const GET_ORDER_PRODUCT:String = 'shopper.shops.ShopManagement.getOrderProduct';
		public static const GET_ORDER_EXTRA:String = 'shopper.shops.ShopManagement.getOrderExtra';
		
		//public static const GET_SALES_BY_DATE:String = 'shopper.shops.ShopManagement.getSalesByDate';
		public static const CREATE_SALES:String = 'shopper.shops.ShopManagement.createSales';
		public static const DELETE_SALES:String = 'shopper.shops.ShopManagement.deleteSales';
		
		
	}

}