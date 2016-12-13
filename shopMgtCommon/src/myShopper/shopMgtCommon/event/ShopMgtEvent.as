package myShopper.shopMgtCommon.event 
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import myShopper.common.data.AlerterVO;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.interfaces.IServiceResponse;
	import myShopper.common.utils.Tracer;
	
	/**
	 * ...
	 * @author Toshi
	 */
	public class ShopMgtEvent extends ApplicationEvent 
	{
		public static const NAME:String = 'ShopMgtEvent';
		public static const LOGIN:String = NAME + 'Login';
		
		public static const SHOP_UPDATE_PROFILE:String = NAME + 'ShopUpdateProfile';
		public static const SHOP_CREATE_PROFILE:String = NAME + 'ShopCreateProfile';
		public static const SHOP_DELETE_PROFILE:String = NAME + 'ShopDeleteProfile';
		
		public static const SHOP_GET_ABOUT:String = NAME + 'ShopGetAbout';
		public static const SHOP_UPDATE_ABOUT:String = NAME + 'ShopUpdateAbout';
		
		//setting menu
		public static const SHOP_UPDATE_PASSWORD:String = NAME + 'ShopUpdatePassword';
		public static const SHOP_VERIFY_PAYPAL_ACC:String = NAME + 'ShopVerifyPaypalAcc';
		public static const SHOP_VERIFY_ACC:String = NAME + 'ShopVerifyAcc';
		public static const SHOP_UPDATE_CURRENCY:String = NAME + 'ShopUpdateCurrency';
		public static const SHOP_UPDATE_LOGO:String = NAME + 'ShopUpdateLogo';
		public static const SHOP_UPDATE_BG:String = NAME + 'ShopUpdateBG';
		public static const SHOP_UPDATE_TAX:String = NAME + 'ShopUpdateTax';
		public static const SHOP_SET_PRINT:String = NAME + 'ShopSetPrint';
		public static const SHOP_CONNECT_REMOTE:String = NAME + 'ShopConnectRemote';
		
		public static const SHOP_CREATE_NEWS:String = NAME + 'ShopCreateNews';
		public static const SHOP_UPDATE_NEWS:String = NAME + 'ShopUpdateNews';
		public static const SHOP_DELETE_NEWS:String = NAME + 'ShopDeleteNews';
		
		public static const SHOP_CREATE_CUSTOM:String = NAME + 'ShopCreateCustom';
		public static const SHOP_UPDATE_CUSTOM:String = NAME + 'ShopUpdateCustom';
		public static const SHOP_DELETE_CUSTOM:String = NAME + 'ShopDeleteCustom';
		public static const SHOP_GET_CUSTOM_BY_NO:String = NAME + 'ShopGetCustomByNo';
		
		public static const CUSTOMER_CHAT:String = NAME + 'CustomerChat';
		
		public static const SHOP_CREATE_CATEGORY:String = NAME + 'ShopCreateCategory';
		public static const SHOP_UPDATE_CATEGORY:String = NAME + 'ShopUpdateCategory';
		public static const SHOP_DELETE_CATEGORY:String = NAME + 'ShopDeleteCategory';
		
		public static const SHOP_CLONE_PRODUCT:String = NAME + 'ShopCloneProduct';
		public static const SHOP_CREATE_PRODUCT:String = NAME + 'ShopCreateProduct';
		public static const SHOP_UPDATE_PRODUCT:String = NAME + 'ShopUpdateProduct';
		public static const SHOP_DELETE_PRODUCT:String = NAME + 'ShopDeleteProduct';
		public static const SHOP_CREATE_PRODUCT_STOCK:String = NAME + 'ShopCreateProductStock';
		public static const SHOP_DELETE_PRODUCT_STOCK:String = NAME + 'ShopDeleteProductStock';
		public static const SHOP_GET_PRODUCT_BY_NO:String = NAME + 'ShopGetProductByNo';
		public static const SHOP_GET_PRODUCT_STOCK_HISTORY:String = NAME + 'ShopGetProductStockHistory';
		
		//quick menu
		public static const SHOP_VIEW_ORDER:String = NAME + 'ShopViewOrder';
		public static const SHOP_GET_ORDER:String = NAME + 'ShopGetOrder';
		
		public static const SHOP_SEND_INVOICE:String = NAME + 'ShopSendInvoice'; 
		public static const SHOP_UPDATE_ORDER_SHIPMENT:String = NAME + 'ShopUpdateOrderShipment';
		public static const SHOP_ADD_ORDER_EXTRA:String = NAME + 'ShopAddOrderExtra';
		
		//public static const SHOP_VIEW_SALES:String = NAME + 'ShopViewSales';
		public static const SHOP_VIEW_SALES_HISTORY:String = NAME + 'ShopViewSalesHistory'; //view sales/order history
		public static const SHOP_CREATE_SALES:String = NAME + 'ShopCreateSales';
		public static const SHOP_DELETE_SALES:String = NAME + 'ShopDeleteSales';
		public static const SHOP_ADD_SALES_EXTRA:String = NAME + 'ShopAddSalesExtra';
		
		
		public static const SHOP_UPDATE_STATUS:String = NAME + 'ShopUpdateStatus'; //shop status
		
		public static const SHOP_READ_USER_SHOP_MESSAGE:String = NAME + 'ShopReadUserShopMessage';
		public static const SHOP_CREATE_USER_SHOP_MESSAGE:String = NAME + 'ShopCreateUserShopMessage'; //reply user shop message
		public static const SHOP_GET_USER_SHOP_MESSAGE:String = NAME + 'ShopGetUserShopMessage';
		
		public function ShopMgtEvent(type:String, inDisplayObject:DisplayObject = null, inData:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{ 
			super(type, inDisplayObject, inData, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new ShopMgtEvent(type, _targetDisplayObject, _data, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("ShopMgtEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
		
		
	}
	
}