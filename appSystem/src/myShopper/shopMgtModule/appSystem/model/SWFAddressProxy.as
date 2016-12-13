package myShopper.shopMgtModule.appSystem.model 
{
	import com.asual.swfaddress.SWFAddress;
	import com.asual.swfaddress.SWFAddressEvent;
	import myShopper.common.emun.PageID;
	import myShopper.common.emun.ServiceID;
	import myShopper.common.emun.SWFAddressServicesType;
	import myShopper.common.events.PageEvent;
	import myShopper.common.net.ServiceRequest;
	import myShopper.common.net.SWFAddressService;
	import myShopper.common.utils.Tracer;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;

	public class SWFAddressProxy extends ApplicationProxy
	{
		//public static const NAME:String = "SWFAddressProxy";
		
		//public static const CHANGE_PAGE:String = NAME + 'changePage_';
		
		//public var arrValidatedPages:Vector.<String>;
		//to store the current pages
		//private var _arrCurrentPages:Array;
		//private var _currentPages:String;
		
		//to store a page that will be used later
		//private var _subscribedPage:String;
		
		//to store a data object that will be used later
		//private var _subscribedData:Object;
		
		
		private var _swfAddressService:SWFAddressService;
		
		public function SWFAddressProxy(inName:String, data:Object = null) 
		{
			super(inName, data);
			
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			
			_swfAddressService = new SWFAddressService();
			_swfAddressService.addEventListener(PageEvent.URL_CHANGED, urlEventHandler);
			
			if ( !serviceManager.addAsset(_swfAddressService, ServiceID.SWF_ADDRESS) )
			{
				Tracer.echo(multitonKey + ' : ' + getProxyName() + ' : initAsset : unable to create service controller!', this, 0xff0000);
				return;
			}
			
			var pages:Vector.<String> = new Vector.<String>();
			pages.push
			(
				PageID.HOME,
				
				//PageID.SHOP, //shop have to be with shop id
				PageID.SHOP_REGISTER,
				
				PageID.SHOP_MANAGEMENT,
				PageID.SHOP_MANAGEMENT_ABOUT,
				PageID.SHOP_MANAGEMENT_INFO,
				PageID.SHOP_MANAGEMENT_NEWS,
				PageID.SHOP_MANAGEMENT_LOGO,
				PageID.SHOP_MANAGEMENT_PRODUCT
				
				//PageID.USER_MANAGEMENT_BLOG,
				//PageID.USER_MANAGEMENT_FRIEND,
				//PageID.USER_MANAGEMENT_GALLERY,
				//PageID.USER_MANAGEMENT_INFO,
				//PageID.USER_MANAGEMENT_MESSAGE
				
			);
			
			for (var i:int = 0; i < pages.length; i++)
			{
				_swfAddressService.request( new ServiceRequest(SWFAddressServicesType.PAGE_ADD, pages[i]) );
			}
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			super.initAsset(inAsset);
		}
		
		public function getCurrentPages():Array
		{
			return _swfAddressService.getCurrentPages();
		}
		
		private function urlEventHandler(e:PageEvent):void 
		{
			echo('urlEventHandler : ' + e, this);
		}
		
	}
}