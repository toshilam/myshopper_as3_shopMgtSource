package myShopper.shopMgtModule.appForm.model
{
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.data.VO;
	import myShopper.common.emun.AMFServicesErrorID;
	import myShopper.common.emun.VOID;
	import myShopper.common.interfaces.ICommServiceRequest;
	import myShopper.common.interfaces.IVO;
	import myShopper.common.utils.Tools;
	import myShopper.shopMgtCommon.data.service.ShopVOService;
	import myShopper.shopMgtCommon.emun.AMFShopManagementServicesType;
	import myShopper.shopMgtCommon.emun.AssetID;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.emun.CommunicationType;
	import myShopper.shopMgtCommon.ShopMgtShopInfoVO;
	import myShopper.shopMgtModule.appForm.enum.AssetClassID;
	import myShopper.shopMgtModule.appForm.enum.MediatorID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationRemoteProxy;
	
	public class ShopAboutFormProxy extends ApplicationRemoteProxy//ApplicationProxy implements IRemoteDataProxy
	{
		//private var _amf:AMFRemoteProxy;
		//private function get amf():AMFRemoteProxy
		//{
			//if (!_amf) _amf = facade.retrieveProxy(ProxyID.AMF) as AMFRemoteProxy;
			//return _amf;
		//}
		
		private var _comm:CommunicationProxy;
		private function get comm():CommunicationProxy
		{
			if (!_comm) _comm = facade.retrieveProxy(ProxyID.COMM) as CommunicationProxy;
			return _comm;
		}
		
		public function ShopAboutFormProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		//private var _voService:UserVOService;
		private var _shopInfoVO:ShopMgtShopInfoVO;
		private var _targetNode:XML;
		private var _shopVOService:ShopVOService;
		
		override public function onRegister():void
		{
			super.onRegister();
			
			_shopInfoVO = voManager.getAsset(VOID.MY_SHOP_INFO);
			var xml:XML = xmlManager.getAsset(AssetLibID.XML_SHOP_MGT);
			
			
			if (!_shopInfoVO || !xml)
			{
				echo('onRegister : unable to get shop info vo/xml');
				throw(new UninitializedError('onRegister : unable to get shop info vo/xml'));
			}
			
			_shopVOService = new ShopVOService(_shopInfoVO);
			
			var windowNode:XML = xml..windowElements[0]
			_targetNode = windowNode.*.(@id == AssetID.BTN_SHOP_ABOUT)[0];
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			
			_shopInfoVO = null;
			_comm = null;
			//_amf = null;
			_targetNode = null;
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			if (inAsset is ICommServiceRequest)
			{
				var classID:String = getAssetIDByCommType(ICommServiceRequest(inAsset).communicationType);
				if (classID)
				{
					
					if (_shopInfoVO)
					{
						sendNotification
						(
							NotificationType.ADD_FORM_SHOP_ABOUT, 
							new DisplayObjectVO(classID, assetManager.getData(classID, AssetLibID.AST_SHOP_MGT_FORM), _targetNode, _shopInfoVO) 
						);
						
						//get about info
						//CHANGED : 27052012 : to be handle by mediator
						//getRemoteData(AMFShopManagementServicesType.GET_ABOUT, new VO('', language) );
					}
					else
					{
						echo('initAsset : unable to get user login vo');
					}
					
				}
				else
				{
					echo('initAsset : unknow page id : ' + ICommServiceRequest(inAsset).communicationType);
				}
			}
		}
		
		private function getAssetIDByCommType(inID:String):String
		{
			switch(inID)
			{
				case CommunicationType.SHOP_MGT_ABOUT: return AssetClassID.FORM_SHOP_ABOUT;
			}
			
			return null;
		}
		
		
		/* INTERFACE org.puremvc.as3.multicore.interfaces.IRemoteDataProxy */
		
		override public function getRemoteData(inService:String, inData:Object = null):Boolean
		{
			var requestData:Object;
			var userInfo:UserInfoVO = voManager.getAsset(VOID.MY_USER_INFO);
			
			//get lang code, if lang code not specified, use system one
			var langCode:String = (inData is IVO && Tools.isLangCode((inData as IVO).selectedLangCode)) ? (inData as IVO).selectedLangCode : language;
			
			if (userInfo && userInfo.isLogged && _shopInfoVO)
			{
				if (inService == AMFShopManagementServicesType.GET_ABOUT)
				{
					requestData =	{
										a_user_id:userInfo.uid,
										lang:langCode
									};
				}
				else if (inService == AMFShopManagementServicesType.UPDATE_ABOUT)
				{
					requestData =	{
										a_user_id:userInfo.uid, 
										lang:langCode,
										a_about:_shopInfoVO.about, 
										a_title:_shopInfoVO.aboutTitle 
									};
				}
				else
				{
					echo('getRemoteData : : unknown service type ' + inService, this, 0xff0000);
					return false;
				}
			}
			else
			{
				echo('getRemoteData : unable to get user/shop vo');
				return false;
			}
			
			//amf.call(inService, requestData);
			call(inService, requestData);
			return true;
		}
		
		override public function setRemoteData(inService:String, inData:Object):Boolean
		{
			var resultVO:ResultVO = inData as ResultVO;
			
			if (resultVO)
			{
				if ( resultVO.code != AMFServicesErrorID.NONE )
				{
					echo('setRemoteData : fail getting data from server');
					
					sendNotificationToMediator
					(
						MediatorID.SHOP_MGT_ABOUT,
						inService == AMFShopManagementServicesType.UPDATE_ABOUT ? NotificationType.UPDATE_ABOUT_FAIL : NotificationType.GET_ABOUT_FAIL, 
						resultVO
					);
					
					return false;
				}
				else
				{
					if (inService == AMFShopManagementServicesType.GET_ABOUT)
					{
						//once data is set, value will be autometically set in display object form
						sendNotificationToMediator
						(
							MediatorID.SHOP_MGT_ABOUT,
							_shopVOService.setShopAbout(resultVO.result) ? NotificationType.GET_ABOUT_SUCCESS : NotificationType.GET_ABOUT_FAIL
						)
					}
					else if (inService == AMFShopManagementServicesType.UPDATE_ABOUT)
					{
						sendNotification(NotificationType.UPDATE_ABOUT_SUCCESS);
					}
					
					return true;
				}
				
			}
			
			
			return false;
		}
		
	}
}