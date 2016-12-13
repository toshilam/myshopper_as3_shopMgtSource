package myShopper.shopMgtModule.appForm.model
{
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.service.UserVOService;
	import myShopper.common.data.shopper.ShopperCategoryList;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.data.user.UserLoginFormVO;
	import myShopper.common.emun.AMFUserServicesType;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.CommunicationType;
	import myShopper.common.emun.PageID;
	import myShopper.common.emun.VOID;
	import myShopper.common.interfaces.ICommServiceRequest;
	import myShopper.common.interfaces.IDataManager;
	import myShopper.common.utils.Tools;
	import myShopper.shopMgtCommon.emun.AMFShopManagementServicesType;
	import myShopper.shopMgtModule.appForm.enum.AssetClassID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationRemoteProxy;
	
	public class UserLoginFormProxy extends ApplicationRemoteProxy //ApplicationProxy implements IRemoteDataProxy
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
		
		private var _asset:AssetProxy;
		private function get asset():AssetProxy
		{
			if (!_asset) _asset = facade.retrieveProxy(ProxyID.ASSET) as AssetProxy;
			return _asset;
		}
		
		public function UserLoginFormProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		//private var _voService:UserVOService;
		private var _userLoginVO:UserLoginFormVO;
		
		override public function onRegister():void
		{
			super.onRegister();
			
			_userLoginVO = voManager.getAsset(VOID.USER_LOGIN);
			
			if (!_userLoginVO)
			{
				echo('onRegister : unable to get user login vo');
			}
			
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			_userLoginVO = null;
			_comm = null;
			//_amf = null;
			
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			if (inAsset is ICommServiceRequest)
			{
				var classID:String = getAssetIDByCommType(ICommServiceRequest(inAsset).communicationType);
				
				if (classID)
				{
					
					if (_userLoginVO)
					{
						sendNotification(NotificationType.ADD_FORM_USER_LOGIN, new DisplayObjectVO(classID, assetManager.getData(classID, AssetLibID.AST_FORM), null, _userLoginVO) );
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
				case CommunicationType.USER_LOGIN: 
				case CommunicationType.USER_LOGOUT: return AssetClassID.FORM_USER_LOGIN;
			}
			
			return null;
		}
		
		
		/* INTERFACE org.puremvc.as3.multicore.interfaces.IRemoteDataProxy */
		
		override public function getRemoteData(inService:String, inData:Object = null):Boolean
		{
			var requestData:Object;
			
			if (inService == AMFShopManagementServicesType.USER_LOGIN)
			{
				//_userLoginVO = voManager.getAsset(VOID.USER_LOGIN);
				
				if (_userLoginVO)
				{
					//requestData = { u_email:_userLoginVO.email, u_password:MD5.hash(_userLoginVO.password) };
					requestData = { u_email:_userLoginVO.email, u_password:Tools.encodePassword(_userLoginVO.password) };
				}
				else
				{
					echo('getRemoteData : unable to get user login vo');
				}
			}
			else
			{
				echo('getRemoteData : : unknown service type ' + inService, this, 0xff0000);
				return false;
			}
			
			//amf.call(inService, requestData);
			call(inService, requestData);
			return true;
		}
		
		override public function setRemoteData(inService:String, inData:Object):Boolean
		{
			if (inService == AMFShopManagementServicesType.USER_LOGIN)
			{
				return asset.setRemoteData(inService, inData);
				/*var vo:UserInfoVO = voManager.getAsset(VOID.MY_USER_INFO);
				var resultVO:ResultVO = inData as ResultVO;
				var shopperCategory:ShopperCategoryList = voManager.getAsset(VOID.SHOPPER_PRODUCT_CATEGORY);
				
				if (vo)
				{
					if ( UserVOService.setMyUserInfo(resultVO.result, vo, shopperCategory) && vo.isShopExist )
					{
						sendNotification(NotificationType.USER_LOGIN_SUCCESS);
						comm.request(CommunicationType.USER_LOGIN_SUCCESS); // notify other module
						return true;
					}
					else
					{
						echo('setRemoteData : fail setting data into vo');
						sendNotification(NotificationType.USER_LOGIN_FAIL);
					}
				}*/
				
			}
			
			return false;
		}
		
	}
}