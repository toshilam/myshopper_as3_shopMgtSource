package myShopper.shopMgtModule.appForm.model
{
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.user.UserLoginFormVO;
	import myShopper.common.emun.AMFUserServicesType;
	import myShopper.common.utils.Tools;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtModule.appForm.enum.AssetClassID;
	import myShopper.shopMgtModule.appForm.enum.AssetID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationRemoteProxy;
	
	public class UserForgotPasswordFormProxy extends ApplicationRemoteProxy //ApplicationProxy implements IRemoteDataProxy
	{
		/*private var _amf:AMFRemoteProxy;
		private function get amf():AMFRemoteProxy
		{
			if (!_amf) _amf = facade.retrieveProxy(ProxyID.AMF) as AMFRemoteProxy;
			return _amf;
		}*/
		
		/*private var _comm:CommunicationProxy;
		private function get comm():CommunicationProxy
		{
			if (!_comm) _comm = facade.retrieveProxy(ProxyID.COMM) as CommunicationProxy;
			return _comm;
		}*/
		
		public function UserForgotPasswordFormProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		//private var _voService:UserVOService;
		private var _forgotPasswordVO:UserLoginFormVO;
		
		override public function onRegister():void
		{
			super.onRegister();
			
			_forgotPasswordVO = new UserLoginFormVO('');
			
			if (!_forgotPasswordVO)
			{
				echo('onRegister : unable to get user login vo');
			}
			
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			
			_forgotPasswordVO.clear();
			_forgotPasswordVO = null;
			
			//_amf = null;
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			if (inAsset is INotification)
			{
				var note:INotification = inAsset as INotification;
				
				var classID:String = getAssetIDByType(String(note.getBody()));
				
				if (classID)
				{
					
					if (_forgotPasswordVO)
					{
						sendNotification(NotificationType.ADD_FORM_USER_FORGOT_PASSWORD, new DisplayObjectVO(classID, assetManager.getData(classID, AssetLibID.AST_FORM), null, _forgotPasswordVO) );
					}
					else
					{
						echo('initAsset : unable to get user login vo');
					}
					
				}
				else
				{
					echo('initAsset : unknow page id : ' + String(note.getBody()));
				}
			}
		}
		
		private function getAssetIDByType(inID:String):String
		{
			switch(inID)
			{
				case AssetID.BTN_FORGOT_PASSWORD: return AssetClassID.FORM_USER_FORGOT_PASSWORD;
			}
			
			return null;
		}
		
		
		/* INTERFACE org.puremvc.as3.multicore.interfaces.IRemoteDataProxy */
		
		override public function getRemoteData(inService:String, inData:Object = null):Boolean
		{
			var requestData:Object;
			
			if (inService == AMFUserServicesType.USER_FORGOT_PASSWORD)
			{
				//_userLoginVO = voManager.getAsset(VOID.USER_LOGIN);
				
				if (_forgotPasswordVO === inData)
				{
					requestData =	{
										lang:language,
										u_email:Tools.trimSpace(_forgotPasswordVO.email)
									};
				}
				else
				{
					echo('getRemoteData : unable to get vo');
					return false;
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
			if (inService == AMFUserServicesType.USER_FORGOT_PASSWORD)
			{
				var resultVO:ResultVO = inData as ResultVO;
				
				if ( resultVO.result === true )
				{
					sendNotification(NotificationType.USER_FORGOT_PASSWORD_SUCCESS);
					return true;
				}
				else
				{
					echo('setRemoteData : fail send pw email');
					sendNotification(NotificationType.USER_FORGOT_PASSWORD_FAIL);
				}
				
			}
			
			return false;
		}
		
	}
}