package myShopper.shopMgtModule.appSystem.model
{
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.service.ShopperVOService;
	import myShopper.common.data.shopper.ShopperCityList;
	import myShopper.common.data.shopper.ShopperCityVO;
	import myShopper.common.data.shopper.ShopperCountryList;
	import myShopper.common.data.shopper.ShopperCountryVO;
	import myShopper.common.emun.AMFShopperServicesType;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.FileType;
	import myShopper.common.emun.PageID;
	import myShopper.common.emun.ServiceID;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.FileEvent;
	import myShopper.common.events.ServiceEvent;
	import myShopper.common.interfaces.IDataManager;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.net.ExternalService;
	import myShopper.common.net.FileLoader;
	import myShopper.common.net.RemoteService;
	import myShopper.common.utils.Tracer;
	import myShopper.shopMgtModule.appSystem.enum.PartsID;
	import myShopper.shopMgtModule.appSystem.enum.ProxyID;
	import myShopper.shopMgtModule.appSystem.model.service.LoaderService;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	
	public class ContentProxy extends ApplicationProxy implements IRemoteDataProxy
	{
		private var _amf:AMFRemoteProxy;
		private function get amf():AMFRemoteProxy
		{
			if (!_amf) _amf = facade.retrieveProxy(ProxyID.AMF) as AMFRemoteProxy;
			return _amf;
		}
		
		private var _service:RemoteService;
		private var _countryList:ShopperCountryList;
		//private var _activeCityList:ShopperCityList;
		
		public function ContentProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			
			_service = serviceManager.getAsset(ServiceID.AMF);
			_countryList = voManager.getAsset(VOID.SHOPPER_COUNTRY);
			//_activeCityList = voManager.getAsset(VOID.SHOPPER_ACTIVE_CITY);
			
			if 
			(
				!_service || 
				!_countryList ||
				//!_activeCityList ||
				!serviceManager.addAsset(ExternalService.getInstance(), ServiceID.EXTERNAL)
			)
			{
				throw(new UninitializedError(multitonKey + ' : onRegister : unable to register/get service'));
			}
			
			_service.serviceConnection.addEventListener(ServiceEvent.CONNECT_SUCCESS, serviceEventHandler);
			
			//var countryVO:ShopperCountryVO = new ShopperCountryVO(country, country);
			//var cityVO:ShopperCityVO = new ShopperCityVO(city, city, city);
			//
			//countryVO.cityList.addVO( cityVO );
			//_countryList.addVO( countryVO );
		}
		
		private function serviceEventHandler(e:ServiceEvent):void 
		{
			if (e.type == ServiceEvent.CONNECT_SUCCESS)
			{
				_service.serviceConnection.removeEventListener(ServiceEvent.CONNECT_SUCCESS, serviceEventHandler);
				//when init download all nessesary non-login data /
				getRemoteData(AMFShopperServicesType.GET_PRODUCT_CATEGORY);
				//getRemoteData(AMFShopperServicesType.GET_ACTIVE_CITY); //data for main menu / search shop / map
				getRemoteData(AMFShopperServicesType.GET_ACTIVE_COUNTRY); //data for shop registeration
			}
			
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			
		}
		
		public function getRemoteData(inService:String, inData:Object = null):Boolean 
		{
			var requestData:Object;
			
			if(inService == AMFShopperServicesType.GET_PRODUCT_CATEGORY)
			{
				requestData = { lang:language }
			}
			/*else if (inService == AMFShopperServicesType.GET_ACTIVE_CITY)
			{
				requestData =	{
									lang:language
								}
			}*/
			else if (inService == AMFShopperServicesType.GET_ACTIVE_COUNTRY)
			{
				requestData =	{
									lang:language
								}
			}
			else
			{
				echo('getRemoteData : : unknown service type ' + inService, this, 0xff0000);
				return false;
			}
			
			amf.call(inService, requestData);
			return true;
		}
		
		public function setRemoteData(inService:String, inData:Object):Boolean 
		{
			var resultVO:ResultVO = inData as ResultVO;
			
			if (inService == AMFShopperServicesType.GET_PRODUCT_CATEGORY)
			{
				return ShopperVOService.setCategoryAndProduct(resultVO.result, voManager.getAsset(VOID.SHOPPER_PRODUCT_CATEGORY));
			}
			/*else if (inService == AMFShopperServicesType.GET_ACTIVE_CITY)
			{
				return ShopperVOService.setShopperActiveCity(resultVO.result as Array, _activeCityList);
			}*/
			else if (inService == AMFShopperServicesType.GET_ACTIVE_COUNTRY)
			{
				return ShopperVOService.setShopperActiveCountry(resultVO.result as Array, _countryList);
			}
			/*else if (inService == AMFShopperServicesType.GET_COUNTRY_AREA)
			{
				var cityVO:ShopperCityVO = _countryList.getCityVO(country, city);
				return ShopperVOService.setShopperArea(resultVO.result as Array, cityVO.areaList);
			}*/
			return false;
		}
	}
}