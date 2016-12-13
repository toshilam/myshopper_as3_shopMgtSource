package myShopper.shopMgtModule.appSystem
{
	import caurina.transitions.properties.ColorShortcuts;
	import caurina.transitions.properties.CurveModifiers;
	import caurina.transitions.properties.DisplayShortcuts;
	import caurina.transitions.properties.FilterShortcuts;
	import flash.display.DisplayObjectContainer;
	import flash.net.registerClassAlias;
	import flash.system.Security;
	import myShopper.amf.common.data.ResultVO;
	import myShopper.amf.shop.data.CategoryVO;
	import myShopper.amf.shop.data.ProductVO;
	import myShopper.common.data.communication.CommList;
	import myShopper.common.data.communication.UserShopCommList;
	import myShopper.common.data.map.MapInfoVO;
	import myShopper.common.data.SetupVO;
	import myShopper.common.data.shop.ShopInfoList;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.shop.ShopRegisterFormVO;
	import myShopper.common.data.shopper.ShopperCategoryList;
	import myShopper.common.data.shopper.ShopperCityList;
	import myShopper.common.data.shopper.ShopperCountryList;
	import myShopper.common.data.user.UserInfoList;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.data.user.UserLoginFormVO;
	import myShopper.common.data.user.UserRegisterFormVO;
	import myShopper.common.emun.VOID;
	import myShopper.common.interfaces.IApplicationDisplayObject;
	import myShopper.common.interfaces.IVO;
	import myShopper.common.display.ApplicationDisplayObject;
	import myShopper.common.display.ModuleMain;
	import myShopper.common.resources.AssetManager;
	import myShopper.common.resources.ServiceManager;
	import myShopper.common.resources.SettingManager;
	import myShopper.common.resources.VOManager;
	import myShopper.common.resources.XMLManager;
	import myShopper.common.utils.Tracer;
	import myShopper.common.Config;
	import myShopper.common.utils.XMLAttributesConvertor;
	import myShopper.common.worker.MediaWorker;
	import myShopper.shopMgtCommon.emun.ShopMgtVOID;
	import myShopper.shopMgtCommon.ShopMgtShopInfoVO;
	/**
	 * ...
	 * @author Toshi Lam
	 */
	public class SystemMain extends ModuleMain 
	{
		public static const NAME:String = 'systemMain';
		
		/*override public function get view():IApplicationDisplayObject 
		{
			return _rootContainer;
		}*/
		
		//root container is the root of this application, as the main.swf is just a dummy shell
		private var _rootContainer:ApplicationDisplayObject = new ApplicationDisplayObject();
		
		//contain all window display object
		private var _windowContainer:ApplicationDisplayObject;
		public function get windowContainer():ApplicationDisplayObject { return _windowContainer; }
		
		private var _headerContainer:ApplicationDisplayObject;
		public function get headerContainer():ApplicationDisplayObject { return _headerContainer; }
		
		private var _footerContainer:ApplicationDisplayObject;
		public function get footerContainer():ApplicationDisplayObject { return _footerContainer; }
		
		private var _adContainer:ApplicationDisplayObject;
		public function get adContainer():ApplicationDisplayObject { return _adContainer; }
		
		//contain layout display objects
		private var _contentContainer:ApplicationDisplayObject;
		public function get contentContainer():ApplicationDisplayObject { return _contentContainer; }
		
		private var _mediaWorker:MediaWorker;
		public function get mediaWorker():MediaWorker { return _mediaWorker; }
		
		public function SystemMain():void 
		{
			trace(CONFIG::air, CONFIG::mobile, CONFIG::desktop);
			
			CONFIG::web
			{
				//avoid exception, information=SecurityError: Error #2122: Security sandbox violation: Loader.content
				//A policy file is required, but the checkPolicyFile flag was not set when this media was loaded.
				Security.loadPolicyFile(myShopper.common.Config.URL_FACEBOOK_CROSS_DOMAIN);
				Security.allowDomain(myShopper.common.Config.URL_FACEBOOK_CROSS_DOMAIN);
				Security.allowInsecureDomain(myShopper.common.Config.URL_FACEBOOK_CROSS_DOMAIN);
				
			}
			
			
			super();
			_moduleName = NAME;
		}
		
		
		override public function setup(inContainer:DisplayObjectContainer, inVO:IVO = null):Boolean 
		{
			addApplicationChild(_rootContainer, null, /*inContainer.stage,*/ false);
			
			
			//worker
			_mediaWorker = new MediaWorker();
			
			var setupVO:SetupVO = (inVO is SetupVO) ? inVO as SetupVO : new SetupVO('setup', new AssetManager(), new XMLManager(), new SettingManager(), new ServiceManager(), new VOManager());
			
			//language
			var flashvars:Object = setupVO.parameters ? setupVO.parameters : parent.loaderInfo.parameters;
			var language:String = flashvars.l; 	//language
			var email:String = flashvars.e ? flashvars.e : ''; 	//re-login email
			var password:String = flashvars.p ? flashvars.p : '';	//re-login password
			
			if
			(
				language != myShopper.common.Config.LANG_CODE_JP &&
				language != myShopper.common.Config.LANG_CODE_CHS &&
				language != myShopper.common.Config.LANG_CODE_CHT &&
				language != myShopper.common.Config.LANG_CODE_EN
			)
			{
				language = myShopper.common.Config.LANG_CODE_EN //if no matched lang found, set cht by default
			}
			
			//prefix url
			var prefixURL:String = loaderInfo.loaderURL.indexOf('http') != -1 ? '/' : '';
			
			setupVO.language = language;
			setupVO.prefixURL = prefixURL;
			
			
			//only System module create a new view (_rootContainer), for the rest of modules are refer to the container pass by setup
			if ( super.setup(_rootContainer, setupVO) )
			{
				registerClassAlias("shopper.amf.common.data.ResultVO", ResultVO);
				registerClassAlias("shopper.amf.shop.data.CategoryVO", CategoryVO);
				registerClassAlias("shopper.amf.shop.data.ProductVO", ProductVO);
				
				DisplayShortcuts.init();
				FilterShortcuts.init();
				ColorShortcuts.init();
				CurveModifiers.init();
				
				_contentContainer 	= view.addApplicationChild(new ApplicationDisplayObject(), null /*_rootContainer.stage*/) as ApplicationDisplayObject;
				_windowContainer 	= view.addApplicationChild(new ApplicationDisplayObject(), null /*_rootContainer.stage*/) as ApplicationDisplayObject;
				_headerContainer 	= view.addApplicationChild(new ApplicationDisplayObject(), null /*_rootContainer.stage*/) as ApplicationDisplayObject;
				_footerContainer 	= view.addApplicationChild(new ApplicationDisplayObject(), null /*_rootContainer.stage*/) as ApplicationDisplayObject;
				_adContainer 		= view.addApplicationChild(new ApplicationDisplayObject(), null /*_rootContainer.stage*/) as ApplicationDisplayObject;
				
				CONFIG::debug
				{
					voManager.addAsset(new UserLoginFormVO(VOID.USER_LOGIN, 'cs@my-shopper.com'/*'toshilam@gmail.com'*/, 'be56e057f20f883ee10adc3949ba59abbe56e057f20f883ee10adc3949ba59ab'), VOID.USER_LOGIN);
				}
				
				CONFIG::release
				{
					voManager.addAsset(new UserLoginFormVO(VOID.USER_LOGIN, email, password), 	VOID.USER_LOGIN);
				}
				
				
				voManager.addAsset(new ShopRegisterFormVO(VOID.SHOP_REGISTER), 				VOID.SHOP_REGISTER);
				voManager.addAsset(new UserInfoList(VOID.USER_INFO), 						VOID.USER_INFO); //contains a list of shopped in users
				voManager.addAsset(new UserInfoVO(VOID.MY_USER_INFO), 						VOID.MY_USER_INFO);
				//TO DO shop info list and user info list
				//voManager.addAsset(new ShopInfoList(VOID.SHOP_INFO), 						VOID.SHOP_INFO);
				voManager.addAsset(new ShopMgtShopInfoVO(VOID.MY_SHOP_INFO), 				VOID.MY_SHOP_INFO);
				voManager.addAsset(new ShopInfoList(VOID.BRANCH_INFO), 						VOID.BRANCH_INFO); //list of shop info (branch)
				voManager.addAsset(new CommList(VOID.COMM_INFO), 							VOID.COMM_INFO); //contains a list of user shop comm via fms
				voManager.addAsset(new UserShopCommList(VOID.COMM_SHOP_USER_INFO), 			VOID.COMM_SHOP_USER_INFO); //contains a list of user shop comm via amf
				voManager.addAsset(new ShopperCategoryList(VOID.SHOPPER_PRODUCT_CATEGORY),	VOID.SHOPPER_PRODUCT_CATEGORY);
				voManager.addAsset(new ShopperCountryList(VOID.SHOPPER_COUNTRY),			VOID.SHOPPER_COUNTRY);
				//voManager.addAsset(new ShopperCityList(VOID.SHOPPER_ACTIVE_CITY),			VOID.SHOPPER_ACTIVE_CITY);
				
				//list of sales vo
				//17/11/2013 CHANGED : moved to ShopMgtShopInfoVO
				//voManager.addAsset(new ShopMgtSalesVOList(ShopMgtVOID.SHOP_SALES_INFO),		ShopMgtVOID.SHOP_SALES_INFO);
				
				//set current location (country and city) / to be improved!
				settingManager.addAsset(myShopper.common.Config.COUNTRY_HK, SettingManager.COUNTRY);
				settingManager.addAsset('hong-kong', SettingManager.STATE);
				settingManager.addAsset('hong-kong', SettingManager.CITY);
				
				for (var i:String in flashvars)
				{
					settingManager.addAsset(flashvars[i], i);
				}
				
				ApplicationDisplayObject.assetManager = assetManager;
				ApplicationDisplayObject.settingManager = settingManager;
				XMLAttributesConvertor.xmlManager = xmlManager;
				
				return ApplicationFacade.getInstance(_moduleName).startup(this);
			}
			
			return false;
		}
		
		
		
	}
	
}