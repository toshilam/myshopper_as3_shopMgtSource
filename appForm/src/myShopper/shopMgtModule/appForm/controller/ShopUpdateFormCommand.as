package myShopper.shopMgtModule.appForm.controller
{
	import myShopper.common.emun.AMFCommServicesType;
	import myShopper.common.emun.AMFGoogleServicesType;
	import myShopper.common.emun.AMFPayPalServicesType;
	import myShopper.common.emun.AMFShopperServicesType;
	import myShopper.common.emun.AMFUserManagementServicesType;
	import myShopper.common.emun.AMFUserServicesType;
	import myShopper.common.emun.FacebookServicesType;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.ApplicationUserEvent;
	import myShopper.common.events.GoogleEvent;
	import myShopper.common.events.ShopperEvent;
	import myShopper.common.utils.Tracer;
	import myShopper.shopMgtCommon.emun.AMFShopManagementServicesType;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.IApplicationMediator;
	import org.puremvc.as3.multicore.interfaces.IApplicationProxy;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ShopUpdateFormCommand extends SimpleCommand implements ICommand
	{
		override public function execute( note:INotification ):void
		{
			var eventType:String = String(note.getName());
			
			switch(eventType)
			{
				case ShopMgtEvent.SHOP_CREATE_PROFILE:	
				case ShopMgtEvent.SHOP_UPDATE_PROFILE:	
				case ShopMgtEvent.SHOP_DELETE_PROFILE:	
				case ShopMgtEvent.SHOP_GET_ABOUT:
				case ShopMgtEvent.SHOP_UPDATE_ABOUT:
				case ShopMgtEvent.SHOP_UPDATE_PASSWORD:
				case ShopMgtEvent.SHOP_VERIFY_PAYPAL_ACC:
				case ShopMgtEvent.SHOP_UPDATE_CURRENCY:
				case ShopMgtEvent.SHOP_UPDATE_TAX:
				case ShopMgtEvent.SHOP_VERIFY_ACC:
				case ShopMgtEvent.SHOP_UPDATE_LOGO:
				case ShopMgtEvent.SHOP_UPDATE_BG:
				case ShopMgtEvent.SHOP_CREATE_CATEGORY:
				case ShopMgtEvent.SHOP_UPDATE_CATEGORY:
				case ShopMgtEvent.SHOP_DELETE_CATEGORY:
				//case ShopMgtEvent.SHOP_CLONE_PRODUCT:
				case ShopMgtEvent.SHOP_CREATE_PRODUCT:
				case ShopMgtEvent.SHOP_UPDATE_PRODUCT:
				case ShopMgtEvent.SHOP_CREATE_PRODUCT_STOCK:
				case ShopMgtEvent.SHOP_DELETE_PRODUCT_STOCK:
				case ShopMgtEvent.SHOP_GET_PRODUCT_STOCK_HISTORY:
				case ShopMgtEvent.SHOP_GET_PRODUCT_BY_NO:
				case ShopMgtEvent.SHOP_DELETE_PRODUCT:
				case ShopMgtEvent.SHOP_CREATE_NEWS:
				case ShopMgtEvent.SHOP_UPDATE_NEWS:
				case ShopMgtEvent.SHOP_DELETE_NEWS:
				case ShopMgtEvent.SHOP_CREATE_CUSTOM:
				case ShopMgtEvent.SHOP_UPDATE_CUSTOM:
				case ShopMgtEvent.SHOP_DELETE_CUSTOM:
				case ShopMgtEvent.SHOP_GET_CUSTOM_BY_NO:
				case ShopMgtEvent.SHOP_GET_ORDER:
				case ShopMgtEvent.SHOP_ADD_ORDER_EXTRA:
				case ShopMgtEvent.SHOP_ADD_SALES_EXTRA:
				case ShopMgtEvent.SHOP_SEND_INVOICE:
				case ShopMgtEvent.SHOP_UPDATE_ORDER_SHIPMENT:
				case ShopMgtEvent.SHOP_READ_USER_SHOP_MESSAGE:
				case ShopMgtEvent.SHOP_CREATE_USER_SHOP_MESSAGE:
				case ShopMgtEvent.SHOP_GET_USER_SHOP_MESSAGE:
				case ShopperEvent.CONTACT_US:
				case ApplicationEvent.SHARE:
				case ApplicationUserEvent.FORGOT_PASSWORD:
				case ShopMgtEvent.SHOP_CREATE_SALES:
				case ShopMgtEvent.SHOP_DELETE_SALES:
				case GoogleEvent.LOGIN:
				case GoogleEvent.PRINTER_SEARCH:
				case ShopMgtEvent.SHOP_SET_PRINT:
				{
					if ( !(facade.retrieveProxy(getProxyIDByEventType(eventType)) as IRemoteDataProxy).getRemoteData(getServiceTypeByEventType(eventType), note.getBody()) )
					{
						Tracer.echo(multitonKey + ' : ShopUpdateFormCommand : execute : fail getRemoteData : ' + eventType, this, 0xff0000);
					}
					
					return;
				}
			}
			
			Tracer.echo(multitonKey + ' : ShopUpdateFormCommand : execute : unknown event type : ' + eventType, this, 0xff0000);
		}
		
		private function getProxyIDByEventType(inType:String):String
		{
			switch(inType)
			{
				case ShopMgtEvent.SHOP_UPDATE_PROFILE:		return ProxyID.SHOP_MGT_PROFILE_UPDATE;
				case ShopMgtEvent.SHOP_CREATE_PROFILE:		return ProxyID.SHOP_MGT_PROFILE_CREATE;
				case ShopMgtEvent.SHOP_DELETE_PROFILE:		return ProxyID.SHOP_MGT_PROFILES;
				case ShopMgtEvent.SHOP_GET_ABOUT:			return ProxyID.SHOP_MGT_ABOUT;
				case ShopMgtEvent.SHOP_UPDATE_ABOUT:		return ProxyID.SHOP_MGT_ABOUT;
				case ShopMgtEvent.SHOP_UPDATE_PASSWORD:		return ProxyID.SHOP_MGT_PASSWORD_UPDATE;
				case ShopMgtEvent.SHOP_VERIFY_PAYPAL_ACC:	return ProxyID.SHOP_MGT_PAYPAL_ACC_VERIFY;
				case ShopMgtEvent.SHOP_UPDATE_CURRENCY:		return ProxyID.SHOP_MGT_CURRENCY_UPDATE;
				case ShopMgtEvent.SHOP_UPDATE_TAX:			return ProxyID.SHOP_MGT_TAX_UPDATE;
				case ShopMgtEvent.SHOP_VERIFY_ACC:			return ProxyID.SHOP_MGT_ACC_VERIFY;
				case ShopMgtEvent.SHOP_UPDATE_LOGO:			return ProxyID.SHOP_MGT_LOGO_UPDATE;
				case ShopMgtEvent.SHOP_UPDATE_BG:			return ProxyID.SHOP_MGT_BG_UPDATE;
				case ShopMgtEvent.SHOP_CREATE_CATEGORY:		return ProxyID.SHOP_MGT_CATEGORY_CREATE;
				case ShopMgtEvent.SHOP_UPDATE_CATEGORY:		return ProxyID.SHOP_MGT_CATEGORY_UPDATE;
				case ShopMgtEvent.SHOP_DELETE_CATEGORY:		return ProxyID.SHOP_MGT_CATEGORY_DELETE;
				//case ShopMgtEvent.SHOP_CLONE_PRODUCT:		return ProxyID.SHOP_MGT_PRODUCT_CREATE;
				case ShopMgtEvent.SHOP_CREATE_PRODUCT:		return ProxyID.SHOP_MGT_PRODUCT_CREATE;
				case ShopMgtEvent.SHOP_GET_PRODUCT_BY_NO:	
				case ShopMgtEvent.SHOP_UPDATE_PRODUCT:		return ProxyID.SHOP_MGT_PRODUCT_UPDATE;
				case ShopMgtEvent.SHOP_DELETE_PRODUCT:		return ProxyID.SHOP_MGT_PRODUCT_DELETE;
				case ShopMgtEvent.SHOP_CREATE_PRODUCT_STOCK:
				case ShopMgtEvent.SHOP_DELETE_PRODUCT_STOCK:
				case ShopMgtEvent.SHOP_GET_PRODUCT_STOCK_HISTORY:return ProxyID.SHOP_MGT_PRODUCT_STOCK;
				case ShopMgtEvent.SHOP_CREATE_NEWS:			return ProxyID.SHOP_MGT_NEWS_CREATE;
				case ShopMgtEvent.SHOP_UPDATE_NEWS:			return ProxyID.SHOP_MGT_NEWS_UPDATE;
				case ShopMgtEvent.SHOP_DELETE_NEWS:			return ProxyID.SHOP_MGT_NEWS_DELETE;
				case ShopMgtEvent.SHOP_CREATE_CUSTOM:		return ProxyID.SHOP_MGT_CUSTOM_CREATE;
				case ShopMgtEvent.SHOP_GET_CUSTOM_BY_NO:	
				case ShopMgtEvent.SHOP_UPDATE_CUSTOM:		return ProxyID.SHOP_MGT_CUSTOM_UPDATE;
				case ShopMgtEvent.SHOP_DELETE_CUSTOM:		return ProxyID.SHOP_MGT_CUSTOM_DELETE;
				case ShopMgtEvent.SHOP_ADD_ORDER_EXTRA:			
				case ShopMgtEvent.SHOP_SEND_INVOICE:			
				case ShopMgtEvent.SHOP_UPDATE_ORDER_SHIPMENT:	return ProxyID.SHOP_MGT_ORDER_DETAIL;
				case ShopMgtEvent.SHOP_READ_USER_SHOP_MESSAGE:	return ProxyID.SHOP_MGT_USER_MESSAGE;
				case ShopMgtEvent.SHOP_GET_USER_SHOP_MESSAGE:	return ProxyID.SHOP_MGT_USER_MESSAGE;
				case ShopMgtEvent.SHOP_CREATE_USER_SHOP_MESSAGE:return ProxyID.SHOP_MGT_USER_MESSAGE_CREATE;
				case ShopperEvent.CONTACT_US:					return ProxyID.SHOPPER_CONTACT_US;
				case ApplicationEvent.SHARE:					return ProxyID.FB_SHARE_PRODUCT;
				case ApplicationUserEvent.FORGOT_PASSWORD:		return ProxyID.USER_FORGOT_PASSWORD;
				case ShopMgtEvent.SHOP_CREATE_SALES:		
				case ShopMgtEvent.SHOP_ADD_SALES_EXTRA:			return ProxyID.SHOP_MGT_SALES;
				case ShopMgtEvent.SHOP_GET_ORDER:				return ProxyID.SHOP_MGT_CLOSED_ORDER;
				case ShopMgtEvent.SHOP_DELETE_SALES:			return ProxyID.SHOP_MGT_CLOSED_ORDER;
				case GoogleEvent.LOGIN:							return ProxyID.GOOGLE_LOGIN;
				case GoogleEvent.PRINTER_SEARCH:				return ProxyID.SHOP_MGT_PRINT_SET;
				case ShopMgtEvent.SHOP_SET_PRINT:				return ProxyID.SHOP_MGT_PRINT_SET;
				
			}
			
			return '';
		}
		
		private function getServiceTypeByEventType(inType:String):String
		{
			switch(inType)
			{
				case ShopMgtEvent.SHOP_UPDATE_PROFILE:				return AMFShopManagementServicesType.UPDATE_INFO;
				case ShopMgtEvent.SHOP_CREATE_PROFILE:				return AMFShopManagementServicesType.CREATE_INFO;
				case ShopMgtEvent.SHOP_DELETE_PROFILE:				return AMFShopManagementServicesType.DELETE_INFO;
				case ShopMgtEvent.SHOP_GET_ABOUT:					return AMFShopManagementServicesType.GET_ABOUT;
				case ShopMgtEvent.SHOP_UPDATE_ABOUT:				return AMFShopManagementServicesType.UPDATE_ABOUT;
				case ShopMgtEvent.SHOP_UPDATE_PASSWORD:				return AMFUserManagementServicesType.UPDATE_PASSWORD; //user service
				case ShopMgtEvent.SHOP_VERIFY_PAYPAL_ACC:			return AMFPayPalServicesType.GET_ACC_VERIFY_STATUS; 
				case ShopMgtEvent.SHOP_UPDATE_CURRENCY:				return AMFShopManagementServicesType.UPDATE_CURRENCY;
				case ShopMgtEvent.SHOP_UPDATE_TAX:					return AMFShopManagementServicesType.UPDATE_TAX;
				case ShopMgtEvent.SHOP_VERIFY_ACC:					return AMFShopManagementServicesType.GET_ACC_VERIFIED;
				case ShopMgtEvent.SHOP_UPDATE_LOGO:					return AMFShopManagementServicesType.UPDATE_LOGO;
				case ShopMgtEvent.SHOP_UPDATE_BG:					return AMFShopManagementServicesType.UPDATE_BG;
				case ShopMgtEvent.SHOP_CREATE_CATEGORY:				return AMFShopManagementServicesType.CREATE_CATEGORY;
				case ShopMgtEvent.SHOP_UPDATE_CATEGORY:				return AMFShopManagementServicesType.UPDATE_CATEGORY;
				case ShopMgtEvent.SHOP_DELETE_CATEGORY:				return AMFShopManagementServicesType.DELETE_CATEGORY;
				//case ShopMgtEvent.SHOP_CLONE_PRODUCT:				return AMFShopManagementServicesType.CREATE_PRODUCT;
				case ShopMgtEvent.SHOP_CREATE_PRODUCT:				return AMFShopManagementServicesType.CREATE_PRODUCT;
				case ShopMgtEvent.SHOP_GET_PRODUCT_BY_NO:			return AMFShopManagementServicesType.GET_PRODUCT_BY_NO;
				case ShopMgtEvent.SHOP_UPDATE_PRODUCT:				return AMFShopManagementServicesType.UPDATE_PRODUCT;
				case ShopMgtEvent.SHOP_DELETE_PRODUCT:				return AMFShopManagementServicesType.DELETE_PRODUCT;
				case ShopMgtEvent.SHOP_CREATE_PRODUCT_STOCK:		return AMFShopManagementServicesType.CREATE_PRODUCT_STOCK;
				case ShopMgtEvent.SHOP_DELETE_PRODUCT_STOCK:		return AMFShopManagementServicesType.DELETE_PRODUCT_STOCK;
				case ShopMgtEvent.SHOP_GET_PRODUCT_STOCK_HISTORY:	return AMFShopManagementServicesType.GET_PRODUCT_STOCK_HISTORY;
				case ShopMgtEvent.SHOP_CREATE_NEWS:					return AMFShopManagementServicesType.CREATE_NEWS;
				case ShopMgtEvent.SHOP_UPDATE_NEWS:					return AMFShopManagementServicesType.UPDATE_NEWS;
				case ShopMgtEvent.SHOP_GET_CUSTOM_BY_NO:			return AMFShopManagementServicesType.GET_CUSTOM_BY_NO;
				case ShopMgtEvent.SHOP_DELETE_NEWS:					return AMFShopManagementServicesType.DELETE_NEWS;
				case ShopMgtEvent.SHOP_CREATE_CUSTOM:				return AMFShopManagementServicesType.CREATE_CUSTOM;
				case ShopMgtEvent.SHOP_UPDATE_CUSTOM:				return AMFShopManagementServicesType.UPDATE_CUSTOM;
				case ShopMgtEvent.SHOP_DELETE_CUSTOM:				return AMFShopManagementServicesType.DELETE_CUSTOM;
				case ShopMgtEvent.SHOP_ADD_ORDER_EXTRA:				return AMFShopManagementServicesType.ADD_ORDER_EXTRA;
				case ShopMgtEvent.SHOP_SEND_INVOICE:				return AMFShopManagementServicesType.SEND_ORDER_INVOICE;
				case ShopMgtEvent.SHOP_UPDATE_ORDER_SHIPMENT:		return AMFShopManagementServicesType.UPDATE_ORDER_SHIPMENT;
				case ShopMgtEvent.SHOP_READ_USER_SHOP_MESSAGE:		return AMFCommServicesType.READ_USER_SHOP_MESSAGE;
				case ShopMgtEvent.SHOP_GET_USER_SHOP_MESSAGE:		return AMFCommServicesType.GET_USER_SHOP_MESSAGE_BY_UID;
				case ShopMgtEvent.SHOP_CREATE_USER_SHOP_MESSAGE:	return AMFCommServicesType.SEND_USER_SHOP_MESSAGE;
				case ShopperEvent.CONTACT_US:						return AMFShopperServicesType.CONTACT_US_SHOP;
				case ApplicationEvent.SHARE:						return FacebookServicesType.ADD_ME_FEED;
				case ApplicationUserEvent.FORGOT_PASSWORD:			return AMFUserServicesType.USER_FORGOT_PASSWORD; //user service
				case ShopMgtEvent.SHOP_CREATE_SALES:				return AMFShopManagementServicesType.CREATE_SALES;
				case ShopMgtEvent.SHOP_ADD_SALES_EXTRA:				return AMFShopManagementServicesType.ADD_ORDER_EXTRA;
				case ShopMgtEvent.SHOP_GET_ORDER:					return AMFShopManagementServicesType.GET_ORDER;
				case ShopMgtEvent.SHOP_DELETE_SALES:				return AMFShopManagementServicesType.DELETE_SALES;
				case GoogleEvent.LOGIN:								return AMFGoogleServicesType.LOGIN;
				case GoogleEvent.PRINTER_SEARCH:					return AMFGoogleServicesType.PRINTER_SEARCH;
				case ShopMgtEvent.SHOP_SET_PRINT:					return AMFGoogleServicesType.SET_PRINTER_INFO;
			}
			
			return '';
		}
	}
}