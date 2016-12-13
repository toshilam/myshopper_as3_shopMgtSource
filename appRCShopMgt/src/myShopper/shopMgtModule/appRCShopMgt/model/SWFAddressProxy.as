package myShopper.shopMgtModule.appRCShopMgt.model
{
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.PageID;
	import myShopper.common.emun.ServiceID;
	import myShopper.common.emun.SWFAddressServicesType;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.PageEvent;
	import myShopper.common.interfaces.IResponder;
	import myShopper.common.net.CommunicationService;
	import myShopper.common.net.ServiceRequest;
	import myShopper.common.net.SWFAddressService;
	import myShopper.common.utils.Tracer;
	import org.puremvc.as3.multicore.enum.NotificationType;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	
	//all page logic should be kept in this object!!! for easier manage
	public class SWFAddressProxy extends ApplicationProxy implements IResponder
	{
		private var _swfAddressService:SWFAddressService;
		private var _userInfo:UserInfoVO;
		
		public function SWFAddressProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		
		override public function onRegister():void
		{
			super.onRegister();
			
			_swfAddressService = serviceManager.getAsset(ServiceID.SWF_ADDRESS);
			_userInfo = voManager.getAsset(VOID.MY_USER_INFO);
			
			if (!_swfAddressService || !(_swfAddressService is SWFAddressService) || !_userInfo)
			{
				throw(UninitializedError(multitonKey + ' : ' + proxyName + 'onRegister : unable to get swfaddress service'));
				return;
			}
			
			_swfAddressService.addEventListener(PageEvent.URL_CHANGED, urlEventHandler);
			
			//close shop module if current URL is not in shop page
			var pages:Array = _swfAddressService.getCurrentPages();
			pageHandler(pages);
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			echo('initAsset');
			
		}
		
		public function addPage(inPage:String):Boolean
		{
			return _swfAddressService.request(new ServiceRequest(SWFAddressServicesType.PAGE_ADD, inPage));
		}
		
		public function setPage(inPage:String):Boolean
		{
			var url:String = inPage is String && inPage.length ? inPage : PageID.HOME;
			//no need to check page id, as it will be checked inside swfAddressService
			return _swfAddressService.request(new ServiceRequest(SWFAddressServicesType.PAGE_SET, url, this));
		}
		
		public function result(data:Object):void 
		{
			echo('SWFAddressProxy : result : ' + data);
		}
		
		public function fault(info:Object):void 
		{
			echo('SWFAddressProxy : fault : ' + info);
			
			//if fail shop page / set back to home
			//to be checked by shop mediator itself
			//if (!host.view.isClosed)
			//{
				sendNotification(NotificationType.MODULE_OFF);
			//}
			
			setPage(PageID.HOME);
		}
		
		
		private function urlEventHandler(e:PageEvent):void 
		{
			echo('urlEventHandler : ' + e, this);
			
			pageHandler(e.pages);
		}
		
		private function pageHandler(inPages:Array):void 
		{
			if (!inPages || !inPages.length) return;
			
			if (inPages[0] == PageID.HOME)
			{
				if (!_userInfo.isLogged)	
				{
					//sendNotification(NotificationType.MODULE_ON);
				}
				else
				{
					
				}
			}
			else
			{
				sendNotification(NotificationType.MODULE_OFF);
			}
		}
		
	}
}