package myShopper.shopMgtModule.appForm.model
{
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.data.user.UserLoginFormVO;
	import myShopper.common.emun.AMFGoogleServicesType;
	import myShopper.common.emun.AMFServicesErrorID;
	import myShopper.common.emun.VOID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationRemoteProxy;
	
	public class GoogleLoginFormProxy extends ApplicationRemoteProxy //ApplicationProxy implements IRemoteDataProxy
	{
		/*private var _asset:AssetProxy;
		private function get asset():AssetProxy
		{
			if (!_asset) _asset = facade.retrieveProxy(ProxyID.ASSET) as AssetProxy;
			return _asset;
		}*/
		
		public function GoogleLoginFormProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		//private var _voService:UserVOService;
		private var _userLoginVO:UserLoginFormVO;
		
		override public function onRegister():void
		{
			super.onRegister();
			
			_userLoginVO = new UserLoginFormVO('');
			
			if (!_userLoginVO)
			{
				echo('onRegister : unable to get user login vo');
			}
			
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			_userLoginVO = null;
			//_comm = null;
			//_amf = null;
			
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			sendNotification(NotificationType.ADD_FORM_GOOGLE_LOGIN, new DisplayObjectVO('',null, null, _userLoginVO) );
		}
		
		
		/* INTERFACE org.puremvc.as3.multicore.interfaces.IRemoteDataProxy */
		
		override public function getRemoteData(inService:String, inData:Object = null):Boolean
		{
			var requestData:Object;
			
			if (inService == AMFGoogleServicesType.LOGIN)
			{
				var userInfo:UserInfoVO = voManager.getAsset(VOID.MY_USER_INFO);
				
				if (userInfo && userInfo.isLogged && _userLoginVO === inData)
				{
					//password = an authorization code, which your application can exchange for an access token and a refresh token.
					requestData = { u_password:_userLoginVO.password, g_user_id:userInfo.uid };
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
			if (inService == AMFGoogleServicesType.LOGIN)
			{
				var resultVO:ResultVO = inData as ResultVO;
				
				if (resultVO)
				{
					if ( resultVO.code != AMFServicesErrorID.NONE )
					{
						echo('setRemoteData : fail getting data from server');
						
						sendNotification(NotificationType.USER_GOOGLE_LOGIN_FAIL, resultVO);
						return false;
					}
					else
					{
						sendNotification(NotificationType.USER_GOOGLE_LOGIN_SUCCESS, resultVO);
						
						return true;
					}
					
				}
			}
			
			return false;
		}
		
	}
}