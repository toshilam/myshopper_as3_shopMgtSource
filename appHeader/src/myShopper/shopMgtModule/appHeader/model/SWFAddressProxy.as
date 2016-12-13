package myShopper.shopMgtModule.appHeader.model
{
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.emun.PageID;
	import myShopper.common.emun.ServiceID;
	import myShopper.common.emun.SWFAddressServicesType;
	import myShopper.common.events.PageEvent;
	import myShopper.common.interfaces.IResponder;
	import myShopper.common.net.ServiceRequest;
	import myShopper.common.net.SWFAddressService;
	import org.puremvc.as3.multicore.enum.NotificationType;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	
	//all page logic should be kept in this object!!! for easier manage
	public class SWFAddressProxy extends ApplicationProxy implements IResponder
	{
		private var _swfAddressService:SWFAddressService;
		
		public function SWFAddressProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		
		override public function onRegister():void
		{
			echo(multitonKey + ' : ' + getProxyName() + " : onRegister() ");
			
			_swfAddressService = serviceManager.getAsset(ServiceID.SWF_ADDRESS);
			
			if (!_swfAddressService || !(_swfAddressService is SWFAddressService))
			{
				echo(multitonKey + ' : ' + getProxyName() + " : onRegister : unable to get asset SWFAddressService");
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
		
		public function getBaseURL():String
		{
			var url:String = _swfAddressService.getBaseURL().split('?')[0];
			if (url.charAt(url.length - 1) == '/')
			{
				url = url.substring(0, url.length -1 );
			}
			
			return url;
		}
		
		public function trace():void
		{
			_swfAddressService.trace();
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
			echo('result : ' + data, this);
		}
		
		public function fault(info:Object):void 
		{
			echo('fault : ' + info, this, 0xff0000);
			
		}
		
		
		private function urlEventHandler(e:PageEvent):void 
		{
			echo('urlEventHandler : ' + e, this);
			
			pageHandler(e.pages);
		}
		
		private function pageHandler(inPages:Array):void 
		{
			
			
		}
		
		public function getCurrnetPage():String
		{
			return _swfAddressService.getCurrentPage();
		}
		
		public function getCurrentPages():Array
		{
			return _swfAddressService.getCurrentPages();
		}
		
	}
}