package myShopper.shopMgtModule.appForm.model
{
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.service.PrinterVOService;
	import myShopper.common.data.service.ShopperVOService;
	import myShopper.common.data.service.ShopVOService;
	import myShopper.common.data.service.UserVOService;
	import myShopper.common.data.shop.ShopInfoList;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.shopper.ShopperCategoryList;
	import myShopper.common.data.shopper.ShopperCityVO;
	import myShopper.common.data.shopper.ShopperCountryList;
	import myShopper.common.data.user.UserInfoList;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.data.user.UserLoginFormVO;
	import myShopper.common.emun.AMFServicesErrorID;
	import myShopper.common.emun.AMFShopperServicesType;
	import myShopper.common.emun.AMFShopServicesType;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.CommunicationType;
	import myShopper.common.emun.FileType;
	import myShopper.common.emun.RequestType;
	import myShopper.common.emun.ServiceID;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.VOEvent;
	import myShopper.common.net.FacebookService;
	import myShopper.common.net.LocalDataService;
	import myShopper.common.net.LocalDataServiceRequest;
	import myShopper.common.utils.Tools;
	import myShopper.shopMgtCommon.data.service.ShopMgtUserVOService;
	import myShopper.shopMgtCommon.data.ShopMgtUserInfoVO;
	import myShopper.shopMgtCommon.emun.AMFShopManagementServicesType;
	import myShopper.shopMgtModule.appForm.enum.MediatorID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.FileEvent;
	import myShopper.common.interfaces.IDataManager;
	import myShopper.common.net.FileLoader;
	import myShopper.common.utils.Tracer;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import myShopper.shopMgtModule.appForm.view.component.ApplicationForm;
	import org.puremvc.as3.multicore.enum.NotificationType;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationRemoteProxy;
	
	public class AssetProxy extends ApplicationRemoteProxy//ApplicationProxy implements IRemoteDataProxy
	{
		/*private var _amf:AMFRemoteProxy;
		private function get amf():AMFRemoteProxy
		{
			if (!_amf) _amf = facade.retrieveProxy(ProxyID.AMF) as AMFRemoteProxy;
			return _amf;
		}*/
		
		private var _comm:CommunicationProxy;
		private function get comm():CommunicationProxy
		{
			if (!_comm) _comm = facade.retrieveProxy(ProxyID.COMM) as CommunicationProxy;
			return _comm;
		}
		
		private var _localData:LocalDataProxy;
		private function get localData():LocalDataProxy
		{
			if (!_localData) _localData = facade.retrieveProxy(ProxyID.LOCAL_DATA) as LocalDataProxy;
			return _localData;
		}
		
		//private var _localDataService:LocalDataService;
		
		private var _branchList:ShopInfoList;
		private var _myShopInfoVO:ShopInfoVO;
		private var _myUserInfoVO:UserInfoVO;
		private var _countryList:ShopperCountryList;
		private var _userVOService:ShopMgtUserVOService;
		protected var _service:FacebookService;
		private var _userLoginVO:UserLoginFormVO;
		
		private var _selectedSRCountryID:String; //used for shop profile form only
		private var _selectedSRStateID:String; //used for shop profile form only
		private var _selectedSRCityID:String; //used for shop profile form only
		
		public static function getChatProxyMediatorName(inUID:String):String
		{
			return MediatorID.SHOP_MGT_CUSTOMER_CHAT + inUID;
		}
		
		public static function getCustomerInfoProxyMediatorName(inUID:String):String
		{
			return MediatorID.SHOP_MGT_CUSTOMER_INFO + inUID;
		}
		
		public function AssetProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		
		override public function onRegister():void
		{
			super.onRegister();
			echo("onRegister() ");
			
			_myShopInfoVO = voManager.getAsset(VOID.MY_SHOP_INFO);
			_branchList = voManager.getAsset(VOID.BRANCH_INFO);
			_myUserInfoVO = voManager.getAsset(VOID.MY_USER_INFO);
			var userInfoList:UserInfoList = voManager.getAsset(VOID.USER_INFO);
			_countryList = voManager.getAsset(VOID.SHOPPER_COUNTRY);
			_service = serviceManager.getAsset(ServiceID.FACEBOOK);
			_userLoginVO = voManager.getAsset(VOID.USER_LOGIN); //for auto login
			
			//_localDataService = serviceManager.getAsset(ServiceID.LOCAL_DATA);
			
			if (!_myShopInfoVO || !_branchList || !_myUserInfoVO || !_countryList || !userInfoList || !_service || !_userLoginVO)
			{
				echo('onRegister : unable to retrieve user info vo');
				throw(new UninitializedError('onRegister : unable to retrieve user info vo'));
			}
			
			_userVOService = new ShopMgtUserVOService(userInfoList);
			
			initAsset();
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			sendNotification(org.puremvc.as3.multicore.enum.NotificationType.ADD_HOST, new DisplayObjectVO('', new ApplicationForm(), null) );
			
			//try re-login
			getRemoteData(AMFShopManagementServicesType.USER_AUTO_LOGIN);
		}
		
		public function isFBConnected(inAutoConnect:Boolean = false):Boolean
		{
			var isConnected:Boolean = _service.isConnected();
			if (!isConnected && inAutoConnect)
			{
				_service.connect('');
			}
			
			return isConnected;
		}
		
		public function getAllShopInfo():ShopInfoList
		{
			var shopList:ShopInfoList = new ShopInfoList('');
			shopList.addVO(_myShopInfoVO);
			for (var i:int = 0; i < _branchList.length; i++)
			{
				shopList.addVO( _branchList.getVO(i) );
			}
			return shopList;
		}
		
		public function logout():void
		{
			localData.request(new LocalDataServiceRequest('', RequestType.LOCAL_DATA_USER_INFO, {} ));
		}
		
		/**
		 * to be called when shop info received/failed from shopMgt module
		 * @param	inData - shopInfoVO if successfully received else null
		 */
		public function shopInfoInitialized(inData:Object):void
		{
			if (inData is ShopInfoVO)
			{
				localData.initAsset();
				
				
				//save logged user email (to be improve : with password?)
				localData.request(new LocalDataServiceRequest('', RequestType.LOCAL_DATA_USER_INFO, { email:_myUserInfoVO.email } ));
				
				//this only used for USER_LOGIN
				//if USER_AUTO_LOGIN nothing to be handled
				sendNotification(myShopper.shopMgtModule.appForm.enum.NotificationType.USER_LOGIN_SUCCESS);
				
			}
			else
			{
				sendNotification(myShopper.shopMgtModule.appForm.enum.NotificationType.USER_LOGIN_FAIL);
			}
		}
		
		/* INTERFACE org.puremvc.as3.multicore.interfaces.IRemoteDataProxy */
		
		override public function getRemoteData(inService:String, inData:Object = null):Boolean 
		{
			var requestData:Object;
			var result:*;
			
			
			//if (inService == AMFShopServicesType.GET_COUNTRY)
			if (inService == AMFShopperServicesType.GET_ACTIVE_COUNTRY)
			{
				if (_countryList.isDataDownloaded)
				{
					result = ShopVOService.getActiveCountryCBArrayByShopperCountry( _countryList );
					
					if (result is Array)
					{
						sendNotification(myShopper.shopMgtModule.appForm.enum.NotificationType.GET_COUNTRY_SUCCESS, result);
					}
					else
					{
						sendNotification(myShopper.shopMgtModule.appForm.enum.NotificationType.GET_COUNTRY_FAIL);
					}
				}
				else
				{
					_countryList.addEventListener(VOEvent.VALUE_CHANGED, countryVOEventHandler, false, 0, true);
				}
				
				return true;
			}
			//else if (inService == AMFShopServicesType.GET_CITY)
			else if (inService == AMFShopperServicesType.GET_STATE_BY_COUNTRY_ID)
			{
				_selectedSRCountryID = String(inData);
				
				//if data already download
				result = ShopVOService.getStateCBArrayByShopperCountry( _countryList, _selectedSRCountryID );
				
				if (result is Array && (result as Array).length)
				{
					sendNotification(myShopper.shopMgtModule.appForm.enum.NotificationType.GET_STATE_SUCCESS, result);
					return true;
				}
				else
				{
					requestData =	{
										lang:language,
										s_country:_selectedSRCountryID
									}
				}
			}
			else if (inService == AMFShopperServicesType.GET_CITY_BY_STATE_ID)
			{
				var arrData:Array = inData as Array;
				_selectedSRCountryID = arrData[0];
				_selectedSRStateID = arrData[1];
				
				result = ShopVOService.getCityCBArrayByShopperCountry( _countryList, _selectedSRCountryID, _selectedSRStateID );
				
				if (result is Array && (result as Array).length)
				{
					sendNotification(myShopper.shopMgtModule.appForm.enum.NotificationType.GET_CITY_SUCCESS, result);
					return true;
					
				}
				else
				{
					requestData =	{
										lang:language,
										c_country:_selectedSRCountryID,
										c_state:_selectedSRStateID
									}
				}
			}
			else if (inService == AMFShopperServicesType.GET_CITY_AREA)
			{
				arrData = inData as Array;
				_selectedSRCountryID = arrData[0];
				_selectedSRStateID = arrData[1];
				_selectedSRCityID = arrData[2];
				
				result = ShopVOService.getAreaCBArrayByShopperCountry( _countryList, _selectedSRCountryID, _selectedSRStateID, _selectedSRCityID );
				
				if (result is Array && (result as Array).length)
				{
					sendNotification(myShopper.shopMgtModule.appForm.enum.NotificationType.GET_AREA_SUCCESS, result);
					return true;
				}
				else
				{
					requestData = 	{ 
										lang:language,
										a_city:_selectedSRCityID
										//a_country:_shopVO.country
									};
				}
				
			}
			else if (inService == AMFShopManagementServicesType.USER_AUTO_LOGIN)
			{
				//re-login for user who has logged in previously
				if (_userLoginVO.email.length && _userLoginVO.email.indexOf('@') != -1 && _userLoginVO.password.length == 64)
				{
					requestData = { u_email:Tools.trimSpace(_userLoginVO.email), u_password:_userLoginVO.password };
				}
				else
				{
					return false;
				}
			}
			else
			{
				echo('getRemoteData : : unknown service type ' + inService, this, 0xff0000);
				return false;
			}
			
			//comm.request(CommunicationType.SHOPPER_DOWNLOADING, inService);
			//amf.call(inService, requestData);
			call(inService, requestData);
			return true;
		}
		
		private function countryVOEventHandler(e:VOEvent):void 
		{
			if (e.propertyName == 'isDataDownloaded' && e.propertyValue === true)
			{
				getRemoteData(AMFShopperServicesType.GET_ACTIVE_COUNTRY);
			}
		}
		
		
		override public function setRemoteData(inService:String, inData:Object):Boolean 
		{
			//comm.request(CommunicationType.SHOPPER_DOWNLOADED, inService);
			
			var resultVO:ResultVO = inData as ResultVO;
			
			if (inService == AMFShopperServicesType.GET_CITY_AREA)
			{
				if ((resultVO.result is Array) && resultVO.result['a_city'] == _selectedSRCityID)
				{
					var targetCityVO:ShopperCityVO = _countryList.getCityVOByID(_selectedSRCountryID, _selectedSRStateID, _selectedSRCityID);
					if (targetCityVO)
					{
						if ( ShopperVOService.setShopperArea(resultVO.result as Array, targetCityVO.areaList, _selectedSRCountryID, _selectedSRCityID) )
						{
							sendNotification
							(
								myShopper.shopMgtModule.appForm.enum.NotificationType.GET_AREA_SUCCESS, 
								ShopVOService.getAreaCBArrayByShopperCountry( _countryList, _selectedSRCountryID, _selectedSRStateID, _selectedSRCityID )
							);
							
							return true;
						}
						
					}
				}
				
				sendNotification(myShopper.shopMgtModule.appForm.enum.NotificationType.GET_AREA_FAIL);
				
			}
			else if (inService == AMFShopperServicesType.GET_STATE_BY_COUNTRY_ID)
			{
				
				if ( ShopperVOService.setShopperState( resultVO.result as Array, _countryList ) )
				{
					sendNotification
					(
						myShopper.shopMgtModule.appForm.enum.NotificationType.GET_STATE_SUCCESS,
						ShopVOService.getStateCBArrayByShopperCountry( _countryList, resultVO.result['s_country'] )
					);
				}
				else
				{
					sendNotification(myShopper.shopMgtModule.appForm.enum.NotificationType.GET_STATE_FAIL);
				}
			}
			else if (inService == AMFShopperServicesType.GET_CITY_BY_STATE_ID)
			{
				
				if ( ShopperVOService.setShopperCity( resultVO.result as Array, _countryList ) )
				{
					sendNotification
					(
						myShopper.shopMgtModule.appForm.enum.NotificationType.GET_CITY_SUCCESS,
						ShopVOService.getCityCBArrayByShopperCountry( _countryList, resultVO.result['c_country'], resultVO.result['c_state'] )
					);
				}
				else
				{
					sendNotification(myShopper.shopMgtModule.appForm.enum.NotificationType.GET_CITY_FAIL);
				}
				
			}
			else if (inService == AMFShopManagementServicesType.GET_CUSTOMER_INFO_BY_UID)
			{
				if ( resultVO.code != AMFServicesErrorID.NONE )
				{
					echo('setRemoteData : fail getting data from server');
					
					//sendNotification(NotificationType.GET_CUSTOMER_INFO_FAIL, resultVO);
					
					return false;
				}
				else
				{
					var userInfo:ShopMgtUserInfoVO = _userVOService.setUserInfo(resultVO.result, voManager.getAsset(VOID.SHOPPER_PRODUCT_CATEGORY)) as ShopMgtUserInfoVO;
					
					if (userInfo)
					{
						sendNotificationToMediator
						(
							getCustomerInfoProxyMediatorName(userInfo.uid),
							myShopper.shopMgtModule.appForm.enum.NotificationType.GET_CUSTOMER_INFO_SUCCESS
						);
					}
					//sendNotification(NotificationType.GET_CUSTOMER_INFO_SUCCESS);
				}
				
				
				return true;
			} 
			else if (inService == AMFShopManagementServicesType.USER_LOGIN || inService == AMFShopManagementServicesType.USER_AUTO_LOGIN)
			{
				var vo:UserInfoVO = voManager.getAsset(VOID.MY_USER_INFO);
				var shopperCategory:ShopperCategoryList = voManager.getAsset(VOID.SHOPPER_PRODUCT_CATEGORY);
				
				if (vo)
				{
					if ( UserVOService.setMyUserInfo(resultVO.result, vo, shopperCategory) && vo.isShopExist )
					{
						PrinterVOService.setPrinterInfo(resultVO.result, vo.printerVO);
						
						/////  CHANGED on 06072014 /////
						//to be handled by shopInfoInitialized() after shop info is received/failed by shopMgt module
						
						/*//this only used for USER_LOGIN
						//if USER_AUTO_LOGIN nothing to be handled
						sendNotification(myShopper.shopMgtModule.appForm.enum.NotificationType.USER_LOGIN_SUCCESS);
						
						//save logged user email (to be improve : with password?)
						_localDataService.request(new LocalDataServiceRequest('', RequestType.LOCAL_DATA_USER_INFO, { email:vo.email } ));
						 */
						
						// notify other module
						comm.request(CommunicationType.USER_LOGIN_SUCCESS);
						return true;
					}
					else
					{
						echo('setRemoteData : fail setting data into vo');
						sendNotification(myShopper.shopMgtModule.appForm.enum.NotificationType.USER_LOGIN_FAIL);
					}
				}
				
				
			}
			
			return false;
		}
		
	}
}