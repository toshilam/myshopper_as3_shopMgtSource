package myShopper.shopMgtModule.appForm.controller
{
	import myShopper.common.interfaces.ICommServiceRequest;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.utils.Tracer;
	import myShopper.common.emun.CommunicationType;
	import myShopper.shopMgtCommon.data.ShopMgtUserInfoVO;
	import myShopper.shopMgtCommon.emun.CommunicationType;
	import myShopper.shopMgtModule.appForm.enum.MediatorID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import myShopper.shopMgtModule.appForm.model.AssetProxy;
	import myShopper.shopMgtModule.appForm.model.ShopAboutFormProxy;
	import myShopper.shopMgtModule.appForm.model.ShopChatFormProxy;
	import myShopper.shopMgtModule.appForm.model.ShopClosedOrderInfoProxy;
	import myShopper.shopMgtModule.appForm.model.ShopCustomerInfoProxy;
	import myShopper.shopMgtModule.appForm.model.ShopCustomInfoProxy;
	import myShopper.shopMgtModule.appForm.model.ShopNewsInfoProxy;
	import myShopper.shopMgtModule.appForm.model.ShopOrderInfoProxy;
	import myShopper.shopMgtModule.appForm.model.ShopperContactUsFormProxy;
	import myShopper.shopMgtModule.appForm.model.ShopProductInfoProxy;
	import myShopper.shopMgtModule.appForm.model.ShopProfileFormProxy;
	import myShopper.shopMgtModule.appForm.model.ShopProfileInfoProxy;
	import myShopper.shopMgtModule.appForm.model.ShopSalesFormProxy;
	import myShopper.shopMgtModule.appForm.model.ShopSettingInfoProxy;
	import myShopper.shopMgtModule.appForm.model.ShopUserMsgInfoProxy;
	import myShopper.shopMgtModule.appForm.model.UserLoginFormProxy;
	import myShopper.shopMgtModule.appForm.ModuleFacade;
	import myShopper.shopMgtModule.appForm.view.FormMediator;
	import myShopper.shopMgtModule.appForm.view.ShopAboutFormMediator;
	import myShopper.shopMgtModule.appForm.view.ShopClosedOrderMediator;
	import myShopper.shopMgtModule.appForm.view.ShopCustomerChatMediator;
	import myShopper.shopMgtModule.appForm.view.ShopCustomerInfoMediator;
	import myShopper.shopMgtModule.appForm.view.ShopCustomInfoMediator;
	import myShopper.shopMgtModule.appForm.view.ShopNewsMediator;
	import myShopper.shopMgtModule.appForm.view.ShopOrderMediator;
	import myShopper.shopMgtModule.appForm.view.ShopperContactUsFormMediator;
	import myShopper.shopMgtModule.appForm.view.ShopProductMediator;
	import myShopper.shopMgtModule.appForm.view.ShopProfileFormMediator;
	import myShopper.shopMgtModule.appForm.view.ShopProfilesMediator;
	import myShopper.shopMgtModule.appForm.view.ShopSalesFormMediator;
	import myShopper.shopMgtModule.appForm.view.ShopSettingMediator;
	import myShopper.shopMgtModule.appForm.view.ShopUserMsgMediator;
	import myShopper.shopMgtModule.appForm.view.UserLoginFormMediator;
	import org.puremvc.as3.multicore.interfaces.IApplicationMediator;
	import org.puremvc.as3.multicore.interfaces.IApplicationProxy;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.IContainerMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CommCommand extends SimpleCommand implements ICommand
	{
		override public function execute( note:INotification ):void
		{
			var request:ICommServiceRequest = note.getBody() as ICommServiceRequest;
			var mediator:IApplicationMediator;
			var proxy:IApplicationProxy;
			
			if (request)
			{
				switch(request.communicationType)
				{
					case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_INFO_INITIALZIED:
					{
						var assetProxy:AssetProxy = facade.retrieveProxy(ProxyID.ASSET) as AssetProxy;
						if (assetProxy)
						{
							assetProxy.shopInfoInitialized(request.data);
						}
						break;
					}
					
					case myShopper.common.emun.CommunicationType.USER_LOGIN:
					case myShopper.common.emun.CommunicationType.USER_LOGOUT:
					case myShopper.common.emun.CommunicationType.SHOPPER_CONTACT_US:
					case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_SETTING:
					case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_PROFILE:
					case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_ABOUT:
					case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_PRODUCT:
					case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_NEWS:
					case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_CUSTOM:
					case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_SALES:
					case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_ORDER:
					case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_CLOSED_ORDER:
					case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_USER_MESSAGE:
					{
						if (request.communicationType == myShopper.common.emun.CommunicationType.USER_LOGOUT)
						{
							(facade.retrieveMediator(MediatorID.FORM) as FormMediator).form.removeAllWindow();
							(facade.retrieveProxy(ProxyID.ASSET) as AssetProxy).logout();
						}
						
						if 
						(
							!facade.hasMediator(getMediatorIDByRequestType(request.communicationType)) && 
							!facade.hasProxy(getProxyIDByRequestType(request.communicationType))
						)
						{
							mediator = getMediatorByCommType(request.communicationType);
							proxy = getProxyByCommType(request.communicationType);
							
							if (proxy && mediator)
							{
								facade.registerMediator( mediator );
								facade.registerProxy( proxy );
								
								proxy.initAsset(request);
							}
							else
							{
								Tracer.echo(multitonKey + ' : CommCommand : execute : unable to create proxy or mediator : ' + request.communicationType);
							}
						}
						else
						{
							Tracer.echo(multitonKey + ' : CommCommand : execute : proxy or mediator has already created : no action to be taken : ' + request.communicationType);
							
							//if object already created, set index to top
							mediator = facade.retrieveMediator(getMediatorIDByRequestType(request.communicationType)) as IApplicationMediator;
							
							setOnTop(mediator as IContainerMediator);
						}
						break;
					}
					case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_UPDATE_ORDER:
					{
						if 
						(
							facade.hasMediator(getMediatorIDByRequestType(request.communicationType)) && 
							facade.hasProxy(getProxyIDByRequestType(request.communicationType))
						)
						{
							//(getProxyByCommType(request.communicationType) as IRemoteDataProxy).getRemoteData(AMF;
							//if order window is already open refresh list
							sendNotification(NotificationType.REFRESH_DISPLAY_ORDER);
						}
						break;
					}
					case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_CUSTOMER_INFO:
					case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_CUSTOMER_CHAT:
					{
						var vo:ShopMgtUserInfoVO = request.data as ShopMgtUserInfoVO;
						if (vo && vo.uid)
						{
							var mediatorName:String;
							
							if (request.communicationType == myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_CUSTOMER_INFO)
							{
								mediatorName = AssetProxy.getCustomerInfoProxyMediatorName( vo.uid );
							}
							else
							{
								mediatorName = AssetProxy.getChatProxyMediatorName( vo.uid );
							}
							
							//if mediator exist, which means related proxy is also exist / no check needed
							if (facade.hasMediator(mediatorName))
							{
								setOnTop( facade.retrieveMediator( mediatorName ) as IContainerMediator );
							}
							else
							{
								if (request.communicationType == myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_CUSTOMER_INFO)
								{
									mediator = new ShopCustomerInfoMediator(mediatorName, moduleMain);
									proxy = new ShopCustomerInfoProxy(mediatorName, moduleMain);
								}
								else
								{
									mediator = new ShopCustomerChatMediator(mediatorName, moduleMain);
									proxy = new ShopChatFormProxy(mediatorName, moduleMain);
								}
								
								facade.registerMediator( mediator );
								facade.registerProxy( proxy );
								
								proxy.initAsset(request);
							}
						}
						else
						{
							Tracer.echo(multitonKey + ' : CommCommand : execute : unable to retrieve ShopMgtUserInfoVO object : ' + request.communicationType);
						}
						break;
					}
				}
				
			}
			
		}
		
		private function setOnTop(mediator:IContainerMediator):void 
		{
			if (mediator is IContainerMediator)
			{
				IContainerMediator(mediator).setIndex();
			}
		}
		
		private function getMediatorIDByRequestType(inType:String):String
		{
			switch(inType)
			{
				case myShopper.common.emun.CommunicationType.USER_LOGIN:
				case myShopper.common.emun.CommunicationType.USER_LOGOUT: 					return MediatorID.USER_LOGIN;
				case myShopper.common.emun.CommunicationType.SHOPPER_CONTACT_US: 			return MediatorID.SHOPPER_CONTACT_US;
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_SETTING:		return MediatorID.SHOP_MGT_SETTING;
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_PROFILE:		return MediatorID.SHOP_MGT_PROFILES;
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_ABOUT:			return MediatorID.SHOP_MGT_ABOUT;
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_PRODUCT:		return MediatorID.SHOP_MGT_PRODUCT;
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_NEWS:			return MediatorID.SHOP_MGT_NEWS;
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_CUSTOM:		return MediatorID.SHOP_MGT_CUSTOM;
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_SALES:			return MediatorID.SHOP_MGT_SALES;
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_ORDER:			return MediatorID.SHOP_MGT_ORDER;
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_CLOSED_ORDER:	return MediatorID.SHOP_MGT_CLOSED_ORDER;
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_UPDATE_ORDER:	return MediatorID.SHOP_MGT_ORDER;
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_USER_MESSAGE:	return MediatorID.SHOP_MGT_USER_MESSAGE;
				//case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_CUSTOMER_INFO:	return MediatorID.SHOP_MGT_CUSTOMER_INFO;
			}
			
			return null;
		}
		
		private function getProxyIDByRequestType(inType:String):String
		{
			switch(inType)
			{
				case myShopper.common.emun.CommunicationType.USER_LOGIN:
				case myShopper.common.emun.CommunicationType.USER_LOGOUT: 					return ProxyID.USER_LOGIN;
				case myShopper.common.emun.CommunicationType.SHOPPER_CONTACT_US: 			return ProxyID.SHOPPER_CONTACT_US;
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_SETTING:		return ProxyID.SHOP_MGT_SETTING;
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_PROFILE:		return ProxyID.SHOP_MGT_PROFILES;
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_ABOUT:			return ProxyID.SHOP_MGT_ABOUT;
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_PRODUCT:		return ProxyID.SHOP_MGT_PRODUCT;
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_NEWS:			return ProxyID.SHOP_MGT_NEWS;
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_CUSTOM:		return ProxyID.SHOP_MGT_CUSTOM;
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_SALES:			return ProxyID.SHOP_MGT_SALES;
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_ORDER:			return ProxyID.SHOP_MGT_ORDER;
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_CLOSED_ORDER:	return ProxyID.SHOP_MGT_CLOSED_ORDER;
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_UPDATE_ORDER:	return ProxyID.SHOP_MGT_ORDER;
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_USER_MESSAGE:	return ProxyID.SHOP_MGT_USER_MESSAGE;
				//case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_CUSTOMER_INFO:	return ProxyID.SHOP_MGT_CUSTOMER_INFO;
			}
			
			return null;
		}
		
		private function getMediatorByCommType(inID:String):IApplicationMediator 
		{
			switch(inID)
			{
				case myShopper.common.emun.CommunicationType.USER_LOGIN:
				case myShopper.common.emun.CommunicationType.USER_LOGOUT: 					return new UserLoginFormMediator(MediatorID.USER_LOGIN, moduleMain);
				case myShopper.common.emun.CommunicationType.SHOPPER_CONTACT_US: 			return new ShopperContactUsFormMediator(MediatorID.SHOPPER_CONTACT_US, moduleMain);
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_SETTING:		return new ShopSettingMediator(MediatorID.SHOP_MGT_SETTING, moduleMain);
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_PROFILE:		return new ShopProfilesMediator(MediatorID.SHOP_MGT_PROFILES, moduleMain);
				//case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_PROFILE:		return new ShopProfileFormMediator(MediatorID.SHOP_MGT_PROFILE, moduleMain);
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_ABOUT:			return new ShopAboutFormMediator(MediatorID.SHOP_MGT_ABOUT, moduleMain);
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_PRODUCT:		return new ShopProductMediator(MediatorID.SHOP_MGT_PRODUCT, moduleMain);
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_NEWS:			return new ShopNewsMediator(MediatorID.SHOP_MGT_NEWS, moduleMain);
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_CUSTOM:		return new ShopCustomInfoMediator(MediatorID.SHOP_MGT_CUSTOM, moduleMain);
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_SALES:			return new ShopSalesFormMediator(MediatorID.SHOP_MGT_SALES, moduleMain);
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_ORDER:			return new ShopOrderMediator(MediatorID.SHOP_MGT_ORDER, moduleMain);
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_CLOSED_ORDER:	return new ShopClosedOrderMediator(MediatorID.SHOP_MGT_CLOSED_ORDER, moduleMain);
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_USER_MESSAGE:	return new ShopUserMsgMediator(MediatorID.SHOP_MGT_USER_MESSAGE, moduleMain);
				//case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_CUSTOMER_INFO:	return new ShopCustomerInfoMediator(MediatorID.SHOP_MGT_CUSTOMER_INFO, moduleMain);
			}
			
			return null;
		}
		
		private function getProxyByCommType(inID:String):IApplicationProxy 
		{
			switch(inID)
			{
				case myShopper.common.emun.CommunicationType.USER_LOGIN:
				case myShopper.common.emun.CommunicationType.USER_LOGOUT: 					return new UserLoginFormProxy(ProxyID.USER_LOGIN, moduleMain);
				case myShopper.common.emun.CommunicationType.SHOPPER_CONTACT_US: 			return new ShopperContactUsFormProxy(ProxyID.SHOPPER_CONTACT_US, moduleMain);
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_SETTING:		return new ShopSettingInfoProxy(ProxyID.SHOP_MGT_SETTING, moduleMain);
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_PROFILE:		return new ShopProfileInfoProxy(ProxyID.SHOP_MGT_PROFILES, moduleMain);
				//case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_PROFILE:		return new ShopProfileFormProxy(ProxyID.SHOP_MGT_PROFILE, moduleMain);
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_ABOUT:			return new ShopAboutFormProxy(ProxyID.SHOP_MGT_ABOUT, moduleMain);
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_PRODUCT:		return new ShopProductInfoProxy(ProxyID.SHOP_MGT_PRODUCT, moduleMain);
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_NEWS:			return new ShopNewsInfoProxy(ProxyID.SHOP_MGT_NEWS, moduleMain);
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_CUSTOM:		return new ShopCustomInfoProxy(ProxyID.SHOP_MGT_CUSTOM, moduleMain);
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_SALES:			return new ShopSalesFormProxy(ProxyID.SHOP_MGT_SALES, moduleMain);
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_ORDER:			return new ShopOrderInfoProxy(ProxyID.SHOP_MGT_ORDER, moduleMain);
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_CLOSED_ORDER:	return new ShopClosedOrderInfoProxy(ProxyID.SHOP_MGT_CLOSED_ORDER, moduleMain);
				case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_USER_MESSAGE:	return new ShopUserMsgInfoProxy(ProxyID.SHOP_MGT_USER_MESSAGE, moduleMain);
				//case myShopper.shopMgtCommon.emun.CommunicationType.SHOP_MGT_CUSTOMER_INFO:	return new ShopCustomerInfoProxy(ProxyID.SHOP_MGT_CUSTOMER_INFO, moduleMain);
			}
			
			return null;
		}
		
		
		private function get moduleMain():IModuleMain
		{
			return (facade as ModuleFacade).module;
		}
	}
}