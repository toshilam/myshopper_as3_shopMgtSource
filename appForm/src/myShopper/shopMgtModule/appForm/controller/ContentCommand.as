package myShopper.shopMgtModule.appForm.controller
{
	import myShopper.common.display.ApplicationDisplayObject;
	import myShopper.common.emun.PageID;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.ApplicationUserEvent;
	import myShopper.common.events.GoogleEvent;
	import myShopper.common.events.WindowEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.utils.Tracer;
	import myShopper.shopMgtCommon.data.ShopMgtUserInfoVO;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtModule.appForm.enum.MediatorID;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import myShopper.shopMgtModule.appForm.FormMain;
	import myShopper.shopMgtModule.appForm.model.AssetProxy;
	import myShopper.shopMgtModule.appForm.model.FBSharePFriendFormProxy;
	import myShopper.shopMgtModule.appForm.model.GoogleLoginFormProxy;
	import myShopper.shopMgtModule.appForm.model.ShopAccVerifyFormProxy;
	import myShopper.shopMgtModule.appForm.model.ShopBGFormProxy;
	import myShopper.shopMgtModule.appForm.model.ShopCategoryAlertProxy;
	import myShopper.shopMgtModule.appForm.model.ShopCategoryFormProxy;
	import myShopper.shopMgtModule.appForm.model.ShopChatFormProxy;
	import myShopper.shopMgtModule.appForm.model.ShopCurrencyFormProxy;
	import myShopper.shopMgtModule.appForm.model.ShopCustomAlertProxy;
	import myShopper.shopMgtModule.appForm.model.ShopCustomFormProxy;
	import myShopper.shopMgtModule.appForm.model.ShopLogoFormProxy;
	import myShopper.shopMgtModule.appForm.model.ShopNewsAlertProxy;
	import myShopper.shopMgtModule.appForm.model.ShopNewsFormProxy;
	import myShopper.shopMgtModule.appForm.model.ShopOrderExtraFormProxy;
	import myShopper.shopMgtModule.appForm.model.ShopOrderFormProxy;
	import myShopper.shopMgtModule.appForm.model.ShopPasswordFormProxy;
	import myShopper.shopMgtModule.appForm.model.ShopPaypalAccVerifyFormProxy;
	import myShopper.shopMgtModule.appForm.model.ShopPrintFormProxy;
	import myShopper.shopMgtModule.appForm.model.ShopProductAlertProxy;
	import myShopper.shopMgtModule.appForm.model.ShopProductFormProxy;
	import myShopper.shopMgtModule.appForm.model.ShopProductInfoProxy;
	import myShopper.shopMgtModule.appForm.model.ShopProductStockFormProxy;
	import myShopper.shopMgtModule.appForm.model.ShopProfileFormProxy;
	import myShopper.shopMgtModule.appForm.model.ShopRemoteFormProxy;
	import myShopper.shopMgtModule.appForm.model.ShopSalesFormProxy;
	import myShopper.shopMgtModule.appForm.model.ShopSalesHistoryFormProxy;
	import myShopper.shopMgtModule.appForm.model.ShopTaxFormProxy;
	import myShopper.shopMgtModule.appForm.model.ShopUserMsgFormProxy;
	import myShopper.shopMgtModule.appForm.model.SWFAddressProxy;
	import myShopper.shopMgtModule.appForm.model.UserForgotPasswordFormProxy;
	import myShopper.shopMgtModule.appForm.ModuleFacade;
	import myShopper.shopMgtModule.appForm.view.component.ApplicationForm;
	import myShopper.shopMgtModule.appForm.view.FBSharePFriendFormMediator;
	import myShopper.shopMgtModule.appForm.view.GoogleLoginFormMediator;
	import myShopper.shopMgtModule.appForm.view.ShopAccVerifyFormMediator;
	import myShopper.shopMgtModule.appForm.view.ShopBGFormMediator;
	import myShopper.shopMgtModule.appForm.view.ShopCategoryAlertMediator;
	import myShopper.shopMgtModule.appForm.view.ShopCategoryFormMediator;
	import myShopper.shopMgtModule.appForm.view.ShopCurrencyFormMediator;
	import myShopper.shopMgtModule.appForm.view.ShopCustomAlertMediator;
	import myShopper.shopMgtModule.appForm.view.ShopCustomerChatMediator;
	import myShopper.shopMgtModule.appForm.view.ShopCustomFormMediator;
	import myShopper.shopMgtModule.appForm.view.ShopLogoFormMediator;
	import myShopper.shopMgtModule.appForm.view.ShopNewsAlertMediator;
	import myShopper.shopMgtModule.appForm.view.ShopNewsFormMediator;
	import myShopper.shopMgtModule.appForm.view.ShopOrderExtraFormMediator;
	import myShopper.shopMgtModule.appForm.view.ShopOrderFormMediator;
	import myShopper.shopMgtModule.appForm.view.ShopPasswordFormMediator;
	import myShopper.shopMgtModule.appForm.view.ShopPaypalAccVerifyFormMediator;
	import myShopper.shopMgtModule.appForm.view.ShopPrintFormMediator;
	import myShopper.shopMgtModule.appForm.view.ShopProductAlertMediator;
	import myShopper.shopMgtModule.appForm.view.ShopProductFormMediator;
	import myShopper.shopMgtModule.appForm.view.ShopProductStockFormMediator;
	import myShopper.shopMgtModule.appForm.view.ShopProfileFormMediator;
	import myShopper.shopMgtModule.appForm.view.ShopRemoteFormMediator;
	import myShopper.shopMgtModule.appForm.view.ShopSalesFormMediator;
	import myShopper.shopMgtModule.appForm.view.ShopSalesHistoryFormMediator;
	import myShopper.shopMgtModule.appForm.view.ShopTaxFormMediator;
	import myShopper.shopMgtModule.appForm.view.ShopUserMsgFormMediator;
	import myShopper.shopMgtModule.appForm.view.UserForgotPasswordFormMediator;
	import org.puremvc.as3.multicore.interfaces.IApplicationMediator;
	import org.puremvc.as3.multicore.interfaces.IApplicationProxy;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.IContainerMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ContentCommand extends SimpleCommand implements ICommand
	{
		override public function execute( note:INotification ):void
		{
			var event:String = note.getName();
			if (event == WindowEvent.CLOSE)
			{
				//var target:ApplicationDisplayObject = note.getBody() as ApplicationDisplayObject;
				var mediatorID:String = String(note.getBody());
				
				if 
				(
					/*target is UserLoginForm ||
					target is ShopMgtProfileForm ||
					target is ShopMgtAboutForm ||
					target is ProductWindow ||
					target is ShopMgtCategoryForm*/
					mediatorID == MediatorID.USER_LOGIN ||
					mediatorID == MediatorID.SHOP_MGT_PROFILES ||
					mediatorID == MediatorID.SHOP_MGT_PROFILE_UPDATE ||
					mediatorID == MediatorID.SHOP_MGT_PROFILE_CREATE ||
					mediatorID == MediatorID.SHOP_MGT_ABOUT ||
					mediatorID == MediatorID.SHOP_MGT_NEWS ||
					mediatorID == MediatorID.SHOP_MGT_NEWS_CREATE ||
					mediatorID == MediatorID.SHOP_MGT_NEWS_UPDATE ||
					mediatorID == MediatorID.SHOP_MGT_NEWS_DELETE ||
					mediatorID == MediatorID.SHOP_MGT_CUSTOM ||
					mediatorID == MediatorID.SHOP_MGT_CUSTOM_CREATE ||
					mediatorID == MediatorID.SHOP_MGT_CUSTOM_UPDATE ||
					mediatorID == MediatorID.SHOP_MGT_CUSTOM_DELETE ||
					mediatorID == MediatorID.SHOP_MGT_PRODUCT ||
					mediatorID == MediatorID.SHOP_MGT_CATEGORY_CREATE ||
					mediatorID == MediatorID.SHOP_MGT_CATEGORY_UPDATE ||
					mediatorID == MediatorID.SHOP_MGT_CATEGORY_DELETE || 
					//mediatorID == MediatorID.SHOP_MGT_PRODUCT_CLONE ||
					mediatorID == MediatorID.SHOP_MGT_PRODUCT_CREATE ||
					mediatorID == MediatorID.SHOP_MGT_PRODUCT_UPDATE ||
					mediatorID == MediatorID.SHOP_MGT_PRODUCT_DELETE ||
					mediatorID == MediatorID.SHOP_MGT_PRODUCT_STOCK ||
					mediatorID == MediatorID.SHOP_MGT_SETTING ||
					mediatorID == MediatorID.SHOP_MGT_PASSWORD_UPDATE ||
					mediatorID == MediatorID.SHOP_MGT_PAYPAL_ACC_VERIFY ||
					mediatorID == MediatorID.SHOP_MGT_CURRENCY_UPDATE ||
					mediatorID == MediatorID.SHOP_MGT_TAX_UPDATE ||
					mediatorID == MediatorID.SHOP_MGT_ACC_VERIFY ||
					mediatorID == MediatorID.SHOP_MGT_LOGO_UPDATE ||
					mediatorID == MediatorID.SHOP_MGT_BG_UPDATE ||
					mediatorID == MediatorID.SHOP_MGT_PRINT_SET ||
					mediatorID == MediatorID.SHOP_MGT_REMOTE_CONNECT ||
					mediatorID == MediatorID.SHOP_MGT_ORDER_EXTRA ||
					mediatorID == MediatorID.SHOP_MGT_ORDER ||
					mediatorID == MediatorID.SHOP_MGT_CLOSED_ORDER ||
					mediatorID == MediatorID.SHOP_MGT_ORDER_DETAIL ||
					mediatorID == MediatorID.SHOP_MGT_SALES ||
					mediatorID == MediatorID.SHOP_MGT_SALES_EXTRA ||
					mediatorID == MediatorID.SHOP_MGT_SALES_HISTORY ||
					mediatorID == MediatorID.SHOP_MGT_USER_MESSAGE ||
					mediatorID == MediatorID.SHOP_MGT_USER_MESSAGE_CREATE ||
					mediatorID == MediatorID.SHOPPER_CONTACT_US ||
					mediatorID == MediatorID.FB_SHARE_PRODUCT ||
					mediatorID == MediatorID.USER_FORGOT_PASSWORD ||
					mediatorID == MediatorID.GOOGLE_LOGIN 
				)
				{
					//var mediatorID:String = getMediatorIDByObject(target);
					if (mediatorID && facade.hasMediator( mediatorID )) facade.removeMediator( mediatorID );
					
					//var proxyID:String = getProxyIDByObject(target);
					var proxyID:String = getProxyIDByMediatorID(mediatorID);
					if (proxyID && facade.hasProxy( proxyID )) facade.removeProxy( proxyID );
					
					//once a form is close redirect to page home (may need to redirect to the previous subscribed page? but be aware of null)
					//in mgt application, no swfaddress page can be set?
					//swfAddress.setPage(PageID.HOME);
					
					//remove (to be hanlded by mediator)
					//appForm.removeApplicationChild(target);
				}
				else if (facade.hasMediator( mediatorID ) && facade.hasProxy( mediatorID )) //chat window and customer info window
				{
					if ( !facade.removeProxy( mediatorID ) ) 
					{
						Tracer.echo(multitonKey + ' : ContentCommand : execute : unable to remove proxy : ' + mediatorID);
					}
					if ( !facade.removeMediator( mediatorID ) ) 
					{
						Tracer.echo(multitonKey + ' : ContentCommand : execute : unable to remove mediator : ' + mediatorID);
					}
				}
				else
				{
					Tracer.echo(multitonKey + ' : ContentCommand : no action found : ' + mediatorID);
				}
				
			}
			else if (event == WindowEvent.CREATE)
			{
				var eventType:String = String(note.getType());
				var mediator:IApplicationMediator;
				var proxy:IApplicationProxy;
				
				if
				(
					eventType == ShopMgtEvent.SHOP_UPDATE_PROFILE ||
					eventType == ShopMgtEvent.SHOP_CREATE_PROFILE ||
					eventType == ShopMgtEvent.SHOP_CREATE_NEWS ||
					eventType == ShopMgtEvent.SHOP_UPDATE_NEWS ||
					eventType == ShopMgtEvent.SHOP_DELETE_NEWS ||
					eventType == ShopMgtEvent.SHOP_CREATE_CUSTOM ||
					eventType == ShopMgtEvent.SHOP_DELETE_CUSTOM ||
					eventType == ShopMgtEvent.SHOP_UPDATE_CUSTOM ||
					eventType == ShopMgtEvent.SHOP_CREATE_CATEGORY ||
					eventType == ShopMgtEvent.SHOP_UPDATE_CATEGORY ||
					eventType == ShopMgtEvent.SHOP_DELETE_CATEGORY ||
					eventType == ShopMgtEvent.SHOP_CLONE_PRODUCT ||
					eventType == ShopMgtEvent.SHOP_CREATE_PRODUCT ||
					eventType == ShopMgtEvent.SHOP_UPDATE_PRODUCT ||
					eventType == ShopMgtEvent.SHOP_DELETE_PRODUCT ||
					eventType == ShopMgtEvent.SHOP_CREATE_PRODUCT_STOCK ||
					eventType == ShopMgtEvent.SHOP_UPDATE_PASSWORD ||
					eventType == ShopMgtEvent.SHOP_VERIFY_PAYPAL_ACC ||
					eventType == ShopMgtEvent.SHOP_VERIFY_ACC ||
					eventType == ShopMgtEvent.SHOP_UPDATE_CURRENCY ||
					eventType == ShopMgtEvent.SHOP_UPDATE_TAX ||
					eventType == ShopMgtEvent.SHOP_UPDATE_LOGO ||
					eventType == ShopMgtEvent.SHOP_UPDATE_BG ||
					eventType == ShopMgtEvent.SHOP_SET_PRINT ||
					eventType == ShopMgtEvent.SHOP_CONNECT_REMOTE ||
					eventType == ShopMgtEvent.SHOP_VIEW_ORDER ||
					eventType == ShopMgtEvent.SHOP_ADD_ORDER_EXTRA ||
					eventType == ShopMgtEvent.SHOP_VIEW_SALES_HISTORY ||
					eventType == ShopMgtEvent.SHOP_ADD_SALES_EXTRA ||
					eventType == ShopMgtEvent.SHOP_CREATE_USER_SHOP_MESSAGE ||
					eventType == GoogleEvent.LOGIN ||
					eventType == ApplicationEvent.SHARE ||
					eventType == ApplicationUserEvent.FORGOT_PASSWORD
				)
				{
					if (eventType == ApplicationEvent.SHARE)
					{
						//first check is app connected to fb (with all required permission)
						//if not connected, get connected first, and no need to create mediator and proxy
						if (!asset.isFBConnected(true))
						{
							return;
						}
					}
					
					if 
					(
						!facade.hasMediator(getMediatorIDByEventType(eventType)) && 
						!facade.hasProxy(getProxyIDByEventType(eventType))
					)
					{
						mediator = getMediatorByEventType(eventType);
						proxy = getProxyByEventType(eventType);
						
						if (proxy && mediator)
						{
							facade.registerMediator( mediator );
							facade.registerProxy( proxy );
							
							proxy.initAsset(note);
						}
						else
						{
							Tracer.echo(multitonKey + ' : ContentCommand : execute : unable to create proxy or mediator : ' + eventType);
						}
					}
					else
					{
						Tracer.echo(multitonKey + ' : ContentCommand : execute : proxy or mediator has already created : no action to be taken : ' + eventType);
						
						//if object already created, set index to top
						setToTop(facade.retrieveMediator(getMediatorIDByEventType(eventType)) as IContainerMediator);
						
					}
				}
				else if (eventType == ShopMgtEvent.CUSTOMER_CHAT)
				{
					var vo:ShopMgtUserInfoVO = note.getBody() as ShopMgtUserInfoVO;
					if (vo)
					{
						var mediatorName:String = MediatorID.SHOP_MGT_CUSTOMER_CHAT + vo.fmsID;
						//var proxyName:String = ProxyID.SHOP_MGT_CUSTOMER_CHAT + vo.fmsID;
						
						if 
						(
							!facade.hasMediator(mediatorName) && 
							!facade.hasProxy(mediatorName)
						)
						{
							//proxy & mediator using same name for easier retrieve later on
							proxy = new ShopChatFormProxy(mediatorName, moduleMain);
							
							facade.registerMediator( new ShopCustomerChatMediator(mediatorName, moduleMain) );
							facade.registerProxy( proxy );
							
							proxy.initAsset(note);
						}
						else
						{
							Tracer.echo(multitonKey + ' : ContentCommand : execute : proxy or mediator has already created : no action to be taken : ' + eventType);
							
							//if object already created, set index to top
							setToTop(facade.retrieveMediator(mediatorName) as IContainerMediator);
							
						}
					}
					
				}
			}
		}
		
		private function setToTop(inMediator:IContainerMediator):void
		{
			if (inMediator is IContainerMediator)
			{
				inMediator.setIndex();
			}
		}
		
		/*private function getMediatorIDByObject(inTarget:ApplicationDisplayObject):String 
		{
			if 		(inTarget is UserLoginForm) 		return MediatorID.USER_LOGIN;
			else if (inTarget is ShopMgtProfileForm) 	return MediatorID.SHOP_MGT_PROFILE;
			else if (inTarget is ShopMgtAboutForm) 		return MediatorID.SHOP_MGT_ABOUT;
			else if (inTarget is ProductWindow) 		return MediatorID.SHOP_MGT_PRODUCT;
			else if (inTarget is ShopMgtCategoryForm) 	return MediatorID.SHOP_MGT_CATEGORY;
			
			Tracer.echo('ContentCommand : getMediatorIDByObject : no matched target object found', this , 0xff0000);
			return null;
		}*/
		
		/*private function getProxyIDByObject(inTarget:ApplicationDisplayObject):String 
		{
			if 		(inTarget is UserLoginForm) 		return ProxyID.USER_LOGIN;
			else if (inTarget is ShopMgtProfileForm) 	return ProxyID.SHOP_MGT_PROFILE;
			else if (inTarget is ShopMgtAboutForm) 		return ProxyID.SHOP_MGT_ABOUT;
			else if (inTarget is ProductWindow) 		return ProxyID.SHOP_MGT_PRODUCT;
			else if (inTarget is ShopMgtCategoryForm) 	return ProxyID.SHOP_MGT_CATEGORY;
			
			Tracer.echo('ContentCommand : getProxyIDByObject : no matched target object found', this , 0xff0000);
			return null;
		}*/
		
		private function getProxyIDByMediatorID(inID:String):String
		{
			switch(inID)
			{
				case MediatorID.USER_LOGIN: 								return ProxyID.USER_LOGIN;
				case MediatorID.SHOP_MGT_PROFILES:							return ProxyID.SHOP_MGT_PROFILES;
				case MediatorID.SHOP_MGT_PROFILE_UPDATE:					return ProxyID.SHOP_MGT_PROFILE_UPDATE;
				case MediatorID.SHOP_MGT_PROFILE_CREATE:					return ProxyID.SHOP_MGT_PROFILE_CREATE;
				case MediatorID.SHOP_MGT_ABOUT:								return ProxyID.SHOP_MGT_ABOUT;
				case MediatorID.SHOP_MGT_NEWS:								return ProxyID.SHOP_MGT_NEWS;
				case MediatorID.SHOP_MGT_NEWS_CREATE:						return ProxyID.SHOP_MGT_NEWS_CREATE;
				case MediatorID.SHOP_MGT_NEWS_UPDATE:						return ProxyID.SHOP_MGT_NEWS_UPDATE;
				case MediatorID.SHOP_MGT_NEWS_DELETE:						return ProxyID.SHOP_MGT_NEWS_DELETE;
				case MediatorID.SHOP_MGT_CUSTOM:							return ProxyID.SHOP_MGT_CUSTOM;
				case MediatorID.SHOP_MGT_CUSTOM_CREATE:						return ProxyID.SHOP_MGT_CUSTOM_CREATE;
				case MediatorID.SHOP_MGT_CUSTOM_UPDATE:						return ProxyID.SHOP_MGT_CUSTOM_UPDATE;
				case MediatorID.SHOP_MGT_CUSTOM_DELETE:						return ProxyID.SHOP_MGT_CUSTOM_DELETE;
				case MediatorID.SHOP_MGT_PRODUCT:							return ProxyID.SHOP_MGT_PRODUCT;
				case MediatorID.SHOP_MGT_CATEGORY_CREATE:					return ProxyID.SHOP_MGT_CATEGORY_CREATE;
				case MediatorID.SHOP_MGT_CATEGORY_UPDATE:					return ProxyID.SHOP_MGT_CATEGORY_UPDATE;
				case MediatorID.SHOP_MGT_CATEGORY_DELETE:					return ProxyID.SHOP_MGT_CATEGORY_DELETE;
				//case MediatorID.SHOP_MGT_PRODUCT_CLONE:						return ProxyID.SHOP_MGT_PRODUCT_CLONE;
				case MediatorID.SHOP_MGT_PRODUCT_CREATE:					return ProxyID.SHOP_MGT_PRODUCT_CREATE;
				case MediatorID.SHOP_MGT_PRODUCT_UPDATE:					return ProxyID.SHOP_MGT_PRODUCT_UPDATE;
				case MediatorID.SHOP_MGT_PRODUCT_DELETE:					return ProxyID.SHOP_MGT_PRODUCT_DELETE;
				case MediatorID.SHOP_MGT_PRODUCT_STOCK:						return ProxyID.SHOP_MGT_PRODUCT_STOCK;
				case MediatorID.SHOP_MGT_CUSTOMER_INFO:						return ProxyID.SHOP_MGT_CUSTOMER_INFO;
				case MediatorID.SHOP_MGT_SETTING:							return ProxyID.SHOP_MGT_SETTING;
				case MediatorID.SHOP_MGT_PASSWORD_UPDATE:					return ProxyID.SHOP_MGT_PASSWORD_UPDATE;
				case MediatorID.SHOP_MGT_PAYPAL_ACC_VERIFY:					return ProxyID.SHOP_MGT_PAYPAL_ACC_VERIFY;
				case MediatorID.SHOP_MGT_CURRENCY_UPDATE:					return ProxyID.SHOP_MGT_CURRENCY_UPDATE;
				case MediatorID.SHOP_MGT_TAX_UPDATE:						return ProxyID.SHOP_MGT_TAX_UPDATE;
				case MediatorID.SHOP_MGT_ACC_VERIFY:						return ProxyID.SHOP_MGT_ACC_VERIFY;
				case MediatorID.SHOP_MGT_LOGO_UPDATE:						return ProxyID.SHOP_MGT_LOGO_UPDATE;
				case MediatorID.SHOP_MGT_BG_UPDATE:							return ProxyID.SHOP_MGT_BG_UPDATE;
				case MediatorID.SHOP_MGT_PRINT_SET:							return ProxyID.SHOP_MGT_PRINT_SET;
				case MediatorID.SHOP_MGT_REMOTE_CONNECT:					return ProxyID.SHOP_MGT_REMOTE_CONNECT;
				case MediatorID.SHOP_MGT_ORDER_EXTRA:						return ProxyID.SHOP_MGT_ORDER_EXTRA;
				case MediatorID.SHOP_MGT_ORDER:								return ProxyID.SHOP_MGT_ORDER;
				case MediatorID.SHOP_MGT_CLOSED_ORDER:						return ProxyID.SHOP_MGT_CLOSED_ORDER;
				case MediatorID.SHOP_MGT_ORDER_DETAIL:						return ProxyID.SHOP_MGT_ORDER_DETAIL;
				case MediatorID.SHOP_MGT_USER_MESSAGE:						return ProxyID.SHOP_MGT_USER_MESSAGE;
				case MediatorID.SHOP_MGT_USER_MESSAGE_CREATE:				return ProxyID.SHOP_MGT_USER_MESSAGE_CREATE;
				case MediatorID.SHOPPER_CONTACT_US:							return ProxyID.SHOPPER_CONTACT_US;
				case MediatorID.FB_SHARE_PRODUCT:							return ProxyID.FB_SHARE_PRODUCT;
				case MediatorID.USER_FORGOT_PASSWORD:						return ProxyID.USER_FORGOT_PASSWORD;
				case MediatorID.SHOP_MGT_SALES:								return ProxyID.SHOP_MGT_SALES;
				case MediatorID.SHOP_MGT_SALES_HISTORY:						return ProxyID.SHOP_MGT_SALES_HISTORY;
				case MediatorID.SHOP_MGT_SALES_EXTRA:						return ProxyID.SHOP_MGT_SALES_EXTRA;
				case MediatorID.GOOGLE_LOGIN:								return ProxyID.GOOGLE_LOGIN;
			}
			
			return null;
		}
		
		private function getMediatorIDByEventType(inTarget:String):String 
		{
			if 		(inTarget == ShopMgtEvent.SHOP_UPDATE_PROFILE) 			return MediatorID.SHOP_MGT_PROFILE_UPDATE;
			else if (inTarget == ShopMgtEvent.SHOP_CREATE_PROFILE) 			return MediatorID.SHOP_MGT_PROFILE_CREATE;
			else if (inTarget == ShopMgtEvent.SHOP_CREATE_CATEGORY) 		return MediatorID.SHOP_MGT_CATEGORY_CREATE;
			else if (inTarget == ShopMgtEvent.SHOP_UPDATE_CATEGORY)		 	return MediatorID.SHOP_MGT_CATEGORY_UPDATE;
			else if (inTarget == ShopMgtEvent.SHOP_DELETE_CATEGORY)		 	return MediatorID.SHOP_MGT_CATEGORY_DELETE;
			else if (inTarget == ShopMgtEvent.SHOP_CLONE_PRODUCT)		 	return MediatorID.SHOP_MGT_PRODUCT_CREATE;
			else if (inTarget == ShopMgtEvent.SHOP_CREATE_PRODUCT)		 	return MediatorID.SHOP_MGT_PRODUCT_CREATE;
			else if (inTarget == ShopMgtEvent.SHOP_UPDATE_PRODUCT)		 	return MediatorID.SHOP_MGT_PRODUCT_UPDATE;
			else if (inTarget == ShopMgtEvent.SHOP_DELETE_PRODUCT)		 	return MediatorID.SHOP_MGT_PRODUCT_DELETE;
			else if (inTarget == ShopMgtEvent.SHOP_CREATE_PRODUCT_STOCK)	return MediatorID.SHOP_MGT_PRODUCT_STOCK;
			else if (inTarget == ShopMgtEvent.SHOP_CREATE_NEWS)		 		return MediatorID.SHOP_MGT_NEWS_CREATE;
			else if (inTarget == ShopMgtEvent.SHOP_UPDATE_NEWS)		 		return MediatorID.SHOP_MGT_NEWS_UPDATE;
			else if (inTarget == ShopMgtEvent.SHOP_DELETE_NEWS)		 		return MediatorID.SHOP_MGT_NEWS_DELETE;
			else if (inTarget == ShopMgtEvent.SHOP_CREATE_CUSTOM)		 	return MediatorID.SHOP_MGT_CUSTOM_CREATE;
			else if (inTarget == ShopMgtEvent.SHOP_DELETE_CUSTOM)		 	return MediatorID.SHOP_MGT_CUSTOM_DELETE;
			else if (inTarget == ShopMgtEvent.SHOP_UPDATE_CUSTOM)		 	return MediatorID.SHOP_MGT_CUSTOM_UPDATE;
			else if (inTarget == ShopMgtEvent.SHOP_UPDATE_PASSWORD)		 	return MediatorID.SHOP_MGT_PASSWORD_UPDATE;
			else if (inTarget == ShopMgtEvent.SHOP_VERIFY_PAYPAL_ACC)		return MediatorID.SHOP_MGT_PAYPAL_ACC_VERIFY;
			else if (inTarget == ShopMgtEvent.SHOP_UPDATE_CURRENCY)			return MediatorID.SHOP_MGT_CURRENCY_UPDATE;
			else if (inTarget == ShopMgtEvent.SHOP_UPDATE_TAX)				return MediatorID.SHOP_MGT_TAX_UPDATE;
			else if (inTarget == ShopMgtEvent.SHOP_VERIFY_ACC)				return MediatorID.SHOP_MGT_ACC_VERIFY;
			else if (inTarget == ShopMgtEvent.SHOP_UPDATE_LOGO)		 		return MediatorID.SHOP_MGT_LOGO_UPDATE;
			else if (inTarget == ShopMgtEvent.SHOP_UPDATE_BG)		 		return MediatorID.SHOP_MGT_BG_UPDATE;
			else if (inTarget == ShopMgtEvent.SHOP_SET_PRINT)		 		return MediatorID.SHOP_MGT_PRINT_SET;
			else if (inTarget == ShopMgtEvent.SHOP_CONNECT_REMOTE)		 	return MediatorID.SHOP_MGT_REMOTE_CONNECT;
			else if (inTarget == ShopMgtEvent.SHOP_VIEW_ORDER)		 		return MediatorID.SHOP_MGT_ORDER_DETAIL;
			else if (inTarget == ShopMgtEvent.SHOP_ADD_ORDER_EXTRA)		 	return MediatorID.SHOP_MGT_ORDER_EXTRA;
			else if (inTarget == ShopMgtEvent.SHOP_VIEW_SALES_HISTORY)		return MediatorID.SHOP_MGT_SALES_HISTORY;
			else if (inTarget == ShopMgtEvent.SHOP_ADD_SALES_EXTRA)		 	return MediatorID.SHOP_MGT_SALES_EXTRA;
			else if (inTarget == ShopMgtEvent.SHOP_CREATE_USER_SHOP_MESSAGE)return MediatorID.SHOP_MGT_USER_MESSAGE_CREATE;
			else if (inTarget == ApplicationEvent.SHARE)					return MediatorID.FB_SHARE_PRODUCT;
			else if (inTarget == ApplicationUserEvent.FORGOT_PASSWORD)		return MediatorID.USER_FORGOT_PASSWORD;
			else if (inTarget == GoogleEvent.LOGIN)							return MediatorID.GOOGLE_LOGIN;
			
			Tracer.echo('ContentCommand : getMediatorIDByEventType : no matched target object found : ' + inTarget, this , 0xff0000);
			return null;
		}
		
		private function getProxyIDByEventType(inTarget:String):String 
		{
			if 		(inTarget == ShopMgtEvent.SHOP_UPDATE_PROFILE) 			return ProxyID.SHOP_MGT_PROFILE_UPDATE;
			else if (inTarget == ShopMgtEvent.SHOP_CREATE_PROFILE) 			return ProxyID.SHOP_MGT_PROFILE_CREATE;
			else if (inTarget == ShopMgtEvent.SHOP_CREATE_CATEGORY) 		return ProxyID.SHOP_MGT_CATEGORY_CREATE;
			else if (inTarget == ShopMgtEvent.SHOP_UPDATE_CATEGORY)		 	return ProxyID.SHOP_MGT_CATEGORY_UPDATE;
			else if (inTarget == ShopMgtEvent.SHOP_DELETE_CATEGORY)		 	return ProxyID.SHOP_MGT_CATEGORY_DELETE;
			else if (inTarget == ShopMgtEvent.SHOP_CLONE_PRODUCT)		 	return ProxyID.SHOP_MGT_PRODUCT_CREATE; 
			else if (inTarget == ShopMgtEvent.SHOP_CREATE_PRODUCT)		 	return ProxyID.SHOP_MGT_PRODUCT_CREATE; 
			else if (inTarget == ShopMgtEvent.SHOP_UPDATE_PRODUCT)		 	return ProxyID.SHOP_MGT_PRODUCT_UPDATE; 
			else if (inTarget == ShopMgtEvent.SHOP_DELETE_PRODUCT)		 	return ProxyID.SHOP_MGT_PRODUCT_DELETE;
			else if (inTarget == ShopMgtEvent.SHOP_CREATE_PRODUCT_STOCK)	return ProxyID.SHOP_MGT_PRODUCT_STOCK;
			else if (inTarget == ShopMgtEvent.SHOP_CREATE_NEWS)		 		return ProxyID.SHOP_MGT_NEWS_CREATE;
			else if (inTarget == ShopMgtEvent.SHOP_UPDATE_NEWS)		 		return ProxyID.SHOP_MGT_NEWS_UPDATE;
			else if (inTarget == ShopMgtEvent.SHOP_DELETE_NEWS)		 		return ProxyID.SHOP_MGT_NEWS_DELETE;
			else if (inTarget == ShopMgtEvent.SHOP_CREATE_CUSTOM)		 	return ProxyID.SHOP_MGT_CUSTOM_CREATE;
			else if (inTarget == ShopMgtEvent.SHOP_DELETE_CUSTOM)		 	return ProxyID.SHOP_MGT_CUSTOM_DELETE;
			else if (inTarget == ShopMgtEvent.SHOP_UPDATE_CUSTOM)		 	return ProxyID.SHOP_MGT_NEWS_UPDATE;
			else if (inTarget == ShopMgtEvent.SHOP_UPDATE_PASSWORD)		 	return ProxyID.SHOP_MGT_PASSWORD_UPDATE;
			else if (inTarget == ShopMgtEvent.SHOP_VERIFY_PAYPAL_ACC)		return ProxyID.SHOP_MGT_PAYPAL_ACC_VERIFY;
			else if (inTarget == ShopMgtEvent.SHOP_UPDATE_CURRENCY)			return ProxyID.SHOP_MGT_CURRENCY_UPDATE;
			else if (inTarget == ShopMgtEvent.SHOP_UPDATE_TAX)				return ProxyID.SHOP_MGT_TAX_UPDATE;
			else if (inTarget == ShopMgtEvent.SHOP_VERIFY_ACC)				return ProxyID.SHOP_MGT_ACC_VERIFY;
			else if (inTarget == ShopMgtEvent.SHOP_UPDATE_LOGO)		 		return ProxyID.SHOP_MGT_LOGO_UPDATE;
			else if (inTarget == ShopMgtEvent.SHOP_UPDATE_BG)		 		return ProxyID.SHOP_MGT_BG_UPDATE;
			else if (inTarget == ShopMgtEvent.SHOP_SET_PRINT)		 		return ProxyID.SHOP_MGT_PRINT_SET;
			else if (inTarget == ShopMgtEvent.SHOP_CONNECT_REMOTE)		 	return ProxyID.SHOP_MGT_REMOTE_CONNECT;
			else if (inTarget == ShopMgtEvent.SHOP_VIEW_ORDER)		 		return ProxyID.SHOP_MGT_ORDER_DETAIL;
			else if (inTarget == ShopMgtEvent.SHOP_ADD_ORDER_EXTRA)		 	return ProxyID.SHOP_MGT_ORDER_EXTRA;
			else if (inTarget == ShopMgtEvent.SHOP_VIEW_SALES_HISTORY)		return ProxyID.SHOP_MGT_SALES_HISTORY;
			else if (inTarget == ShopMgtEvent.SHOP_ADD_SALES_EXTRA)		 	return ProxyID.SHOP_MGT_SALES_EXTRA;
			else if (inTarget == ShopMgtEvent.SHOP_CREATE_USER_SHOP_MESSAGE)return ProxyID.SHOP_MGT_USER_MESSAGE_CREATE;
			else if (inTarget == ApplicationEvent.SHARE)					return ProxyID.FB_SHARE_PRODUCT;
			else if (inTarget == ApplicationUserEvent.FORGOT_PASSWORD)		return ProxyID.USER_FORGOT_PASSWORD;
			else if (inTarget == GoogleEvent.LOGIN)							return ProxyID.GOOGLE_LOGIN;
			
			Tracer.echo('ContentCommand : getProxyIDByEventType : no matched target object found' + inTarget, this , 0xff0000);
			return null;
		}
		
		private function getMediatorByEventType(inID:String):IApplicationMediator 
		{
			switch(inID)
			{
				case ShopMgtEvent.SHOP_UPDATE_PROFILE: 						return new ShopProfileFormMediator(MediatorID.SHOP_MGT_PROFILE_UPDATE, moduleMain);
				case ShopMgtEvent.SHOP_CREATE_PROFILE: 						return new ShopProfileFormMediator(MediatorID.SHOP_MGT_PROFILE_CREATE, moduleMain);
				case ShopMgtEvent.SHOP_CREATE_CATEGORY: 					return new ShopCategoryFormMediator(MediatorID.SHOP_MGT_CATEGORY_CREATE, moduleMain);
				case ShopMgtEvent.SHOP_UPDATE_CATEGORY: 					return new ShopCategoryFormMediator(MediatorID.SHOP_MGT_CATEGORY_UPDATE, moduleMain);
				case ShopMgtEvent.SHOP_DELETE_CATEGORY: 					return new ShopCategoryAlertMediator(MediatorID.SHOP_MGT_CATEGORY_DELETE, moduleMain);
				case ShopMgtEvent.SHOP_CLONE_PRODUCT: 						
				case ShopMgtEvent.SHOP_CREATE_PRODUCT: 						return new ShopProductFormMediator(MediatorID.SHOP_MGT_PRODUCT_CREATE, moduleMain);
				case ShopMgtEvent.SHOP_UPDATE_PRODUCT: 						return new ShopProductFormMediator(MediatorID.SHOP_MGT_PRODUCT_UPDATE, moduleMain);
				case ShopMgtEvent.SHOP_DELETE_PRODUCT: 						return new ShopProductAlertMediator(MediatorID.SHOP_MGT_PRODUCT_DELETE, moduleMain);
				case ShopMgtEvent.SHOP_CREATE_PRODUCT_STOCK: 				return new ShopProductStockFormMediator(MediatorID.SHOP_MGT_PRODUCT_STOCK, moduleMain);
				case ShopMgtEvent.SHOP_CREATE_NEWS: 						return new ShopNewsFormMediator(MediatorID.SHOP_MGT_NEWS_CREATE, moduleMain);
				case ShopMgtEvent.SHOP_UPDATE_NEWS: 						return new ShopNewsFormMediator(MediatorID.SHOP_MGT_NEWS_UPDATE, moduleMain);
				case ShopMgtEvent.SHOP_DELETE_NEWS: 						return new ShopNewsAlertMediator(MediatorID.SHOP_MGT_NEWS_DELETE, moduleMain);
				case ShopMgtEvent.SHOP_CREATE_CUSTOM: 						return new ShopCustomFormMediator(MediatorID.SHOP_MGT_CUSTOM_CREATE, moduleMain);
				case ShopMgtEvent.SHOP_UPDATE_CUSTOM: 						return new ShopCustomFormMediator(MediatorID.SHOP_MGT_CUSTOM_UPDATE, moduleMain);
				case ShopMgtEvent.SHOP_DELETE_CUSTOM: 						return new ShopCustomAlertMediator(MediatorID.SHOP_MGT_CUSTOM_DELETE, moduleMain);
				case ShopMgtEvent.SHOP_UPDATE_PASSWORD: 					return new ShopPasswordFormMediator(MediatorID.SHOP_MGT_PASSWORD_UPDATE, moduleMain);
				case ShopMgtEvent.SHOP_VERIFY_PAYPAL_ACC: 					return new ShopPaypalAccVerifyFormMediator(MediatorID.SHOP_MGT_PAYPAL_ACC_VERIFY, moduleMain);
				case ShopMgtEvent.SHOP_VERIFY_ACC: 							return new ShopAccVerifyFormMediator(MediatorID.SHOP_MGT_ACC_VERIFY, moduleMain);
				case ShopMgtEvent.SHOP_UPDATE_CURRENCY: 					return new ShopCurrencyFormMediator(MediatorID.SHOP_MGT_CURRENCY_UPDATE, moduleMain);
				case ShopMgtEvent.SHOP_UPDATE_TAX: 							return new ShopTaxFormMediator(MediatorID.SHOP_MGT_TAX_UPDATE, moduleMain);
				case ShopMgtEvent.SHOP_UPDATE_LOGO: 						return new ShopLogoFormMediator(MediatorID.SHOP_MGT_LOGO_UPDATE, moduleMain);
				case ShopMgtEvent.SHOP_UPDATE_BG: 							return new ShopBGFormMediator(MediatorID.SHOP_MGT_BG_UPDATE, moduleMain);
				case ShopMgtEvent.SHOP_SET_PRINT: 							return new ShopPrintFormMediator(MediatorID.SHOP_MGT_PRINT_SET, moduleMain);
				case ShopMgtEvent.SHOP_CONNECT_REMOTE: 						return new ShopRemoteFormMediator(MediatorID.SHOP_MGT_REMOTE_CONNECT, moduleMain);
				case ShopMgtEvent.SHOP_ADD_ORDER_EXTRA: 					return new ShopOrderExtraFormMediator(MediatorID.SHOP_MGT_ORDER_EXTRA, moduleMain);
				case ShopMgtEvent.SHOP_ADD_SALES_EXTRA: 					return new ShopOrderExtraFormMediator(MediatorID.SHOP_MGT_SALES_EXTRA, moduleMain);
				case ShopMgtEvent.SHOP_VIEW_ORDER: 							return new ShopOrderFormMediator(MediatorID.SHOP_MGT_ORDER_DETAIL, moduleMain);
				case ShopMgtEvent.SHOP_VIEW_SALES_HISTORY: 					return new ShopSalesHistoryFormMediator(MediatorID.SHOP_MGT_SALES_HISTORY, moduleMain);
				case ShopMgtEvent.SHOP_CREATE_USER_SHOP_MESSAGE: 			return new ShopUserMsgFormMediator(MediatorID.SHOP_MGT_USER_MESSAGE_CREATE, moduleMain);
				//case ShopMgtEvent.SHOP_CREATE_USER_SHOP_MESSAGE:			return new ShopOrderFormMediator(MediatorID.SHOP_MGT_ORDER_DETAIL, moduleMain);
				case ApplicationEvent.SHARE:								return new FBSharePFriendFormMediator(MediatorID.FB_SHARE_PRODUCT, moduleMain);
				case ApplicationUserEvent.FORGOT_PASSWORD:					return new UserForgotPasswordFormMediator(MediatorID.USER_FORGOT_PASSWORD, moduleMain);
				case GoogleEvent.LOGIN:										return new GoogleLoginFormMediator(MediatorID.GOOGLE_LOGIN, moduleMain);
			}
			
			return null;
		}
		
		private function getProxyByEventType(inID:String):IApplicationProxy 
		{
			switch(inID)
			{
				case ShopMgtEvent.SHOP_UPDATE_PROFILE: 						return new ShopProfileFormProxy(ProxyID.SHOP_MGT_PROFILE_UPDATE, moduleMain);
				case ShopMgtEvent.SHOP_CREATE_PROFILE: 						return new ShopProfileFormProxy(ProxyID.SHOP_MGT_PROFILE_CREATE, moduleMain);
				case ShopMgtEvent.SHOP_CREATE_CATEGORY: 					return new ShopCategoryFormProxy(ProxyID.SHOP_MGT_CATEGORY_CREATE, moduleMain);
				case ShopMgtEvent.SHOP_UPDATE_CATEGORY: 					return new ShopCategoryFormProxy(ProxyID.SHOP_MGT_CATEGORY_UPDATE, moduleMain);
				case ShopMgtEvent.SHOP_DELETE_CATEGORY: 					return new ShopCategoryAlertProxy(ProxyID.SHOP_MGT_CATEGORY_DELETE, moduleMain);
				case ShopMgtEvent.SHOP_CLONE_PRODUCT: 						
				case ShopMgtEvent.SHOP_CREATE_PRODUCT: 						return new ShopProductFormProxy(ProxyID.SHOP_MGT_PRODUCT_CREATE, moduleMain); 
				case ShopMgtEvent.SHOP_UPDATE_PRODUCT: 						return new ShopProductFormProxy(ProxyID.SHOP_MGT_PRODUCT_UPDATE, moduleMain); 
				case ShopMgtEvent.SHOP_DELETE_PRODUCT: 						return new ShopProductAlertProxy(ProxyID.SHOP_MGT_PRODUCT_DELETE, moduleMain);
				case ShopMgtEvent.SHOP_CREATE_PRODUCT_STOCK: 				return new ShopProductStockFormProxy(ProxyID.SHOP_MGT_PRODUCT_STOCK, moduleMain);
				case ShopMgtEvent.SHOP_CREATE_NEWS: 						return new ShopNewsFormProxy(ProxyID.SHOP_MGT_NEWS_CREATE, moduleMain);
				case ShopMgtEvent.SHOP_UPDATE_NEWS: 						return new ShopNewsFormProxy(ProxyID.SHOP_MGT_NEWS_UPDATE, moduleMain);
				case ShopMgtEvent.SHOP_DELETE_NEWS: 						return new ShopNewsAlertProxy(ProxyID.SHOP_MGT_NEWS_DELETE, moduleMain);
				case ShopMgtEvent.SHOP_CREATE_CUSTOM: 						return new ShopCustomFormProxy(ProxyID.SHOP_MGT_CUSTOM_CREATE, moduleMain);
				case ShopMgtEvent.SHOP_UPDATE_CUSTOM: 						return new ShopCustomFormProxy(ProxyID.SHOP_MGT_CUSTOM_UPDATE, moduleMain);
				case ShopMgtEvent.SHOP_DELETE_CUSTOM: 						return new ShopCustomAlertProxy(ProxyID.SHOP_MGT_CUSTOM_DELETE, moduleMain);
				case ShopMgtEvent.SHOP_UPDATE_PASSWORD: 					return new ShopPasswordFormProxy(ProxyID.SHOP_MGT_PASSWORD_UPDATE, moduleMain);
				case ShopMgtEvent.SHOP_VERIFY_PAYPAL_ACC: 					return new ShopPaypalAccVerifyFormProxy(ProxyID.SHOP_MGT_PAYPAL_ACC_VERIFY, moduleMain);
				case ShopMgtEvent.SHOP_UPDATE_CURRENCY: 					return new ShopCurrencyFormProxy(ProxyID.SHOP_MGT_CURRENCY_UPDATE, moduleMain);
				case ShopMgtEvent.SHOP_UPDATE_TAX: 							return new ShopTaxFormProxy(ProxyID.SHOP_MGT_TAX_UPDATE, moduleMain);
				case ShopMgtEvent.SHOP_VERIFY_ACC: 							return new ShopAccVerifyFormProxy(ProxyID.SHOP_MGT_ACC_VERIFY, moduleMain);
				case ShopMgtEvent.SHOP_UPDATE_LOGO: 						return new ShopLogoFormProxy(ProxyID.SHOP_MGT_LOGO_UPDATE, moduleMain);
				case ShopMgtEvent.SHOP_UPDATE_BG: 							return new ShopBGFormProxy(ProxyID.SHOP_MGT_BG_UPDATE, moduleMain);
				case ShopMgtEvent.SHOP_SET_PRINT: 							return new ShopPrintFormProxy(ProxyID.SHOP_MGT_PRINT_SET, moduleMain);
				case ShopMgtEvent.SHOP_CONNECT_REMOTE: 						return new ShopRemoteFormProxy(ProxyID.SHOP_MGT_REMOTE_CONNECT, moduleMain);
				case ShopMgtEvent.SHOP_ADD_ORDER_EXTRA: 					return new ShopOrderExtraFormProxy(ProxyID.SHOP_MGT_ORDER_EXTRA, moduleMain);
				case ShopMgtEvent.SHOP_ADD_SALES_EXTRA: 					return new ShopOrderExtraFormProxy(ProxyID.SHOP_MGT_SALES_EXTRA, moduleMain);
				case ShopMgtEvent.SHOP_VIEW_ORDER: 							return new ShopOrderFormProxy(ProxyID.SHOP_MGT_ORDER_DETAIL, moduleMain);
				case ShopMgtEvent.SHOP_VIEW_SALES_HISTORY: 					return new ShopSalesHistoryFormProxy(ProxyID.SHOP_MGT_SALES_HISTORY, moduleMain);
				case ShopMgtEvent.SHOP_CREATE_USER_SHOP_MESSAGE: 			return new ShopUserMsgFormProxy(ProxyID.SHOP_MGT_USER_MESSAGE_CREATE, moduleMain);
				case ApplicationEvent.SHARE: 								return new FBSharePFriendFormProxy(ProxyID.FB_SHARE_PRODUCT, moduleMain);
				case ApplicationUserEvent.FORGOT_PASSWORD: 					return new UserForgotPasswordFormProxy(ProxyID.USER_FORGOT_PASSWORD, moduleMain);
				case GoogleEvent.LOGIN: 									return new GoogleLoginFormProxy(ProxyID.GOOGLE_LOGIN, moduleMain);
			}
			
			return null;
		}
		
		/*private function get swfAddress():SWFAddressProxy
		{
			return facade.retrieveProxy(ProxyID.SWF_ADDRESS) as SWFAddressProxy;
		}
		*/
		private function get appForm():ApplicationForm
		{
			return ((facade as ModuleFacade).module as FormMain).appForm;
		}
		
		private function get moduleMain():IModuleMain
		{
			return (facade as ModuleFacade).module;
		}
		
		private function get asset():AssetProxy
		{
			return facade.retrieveProxy(ProxyID.ASSET) as AssetProxy;
		}
	}
}