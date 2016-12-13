package myShopper.shopMgtModule.appForm.model
{
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.shopper.ContactUsVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.AMFShopperServicesType;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.VOID;
	import myShopper.common.interfaces.ICommServiceRequest;
	import myShopper.shopMgtModule.appForm.enum.AssetClassID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationRemoteProxy;
	
	public class ShopperContactUsFormProxy extends ApplicationRemoteProxy //ApplicationProxy implements IRemoteDataProxy
	{
		/*private var _amf:AMFRemoteProxy;
		private function get amf():AMFRemoteProxy
		{
			if (!_amf) _amf = facade.retrieveProxy(ProxyID.AMF) as AMFRemoteProxy;
			return _amf;
		}*/
		
		
		
		public function ShopperContactUsFormProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		//private var _voService:UserVOService;
		private var _userInfo:UserInfoVO;
		private var _contactVO:ContactUsVO;
		
		override public function onRegister():void
		{
			super.onRegister();
			_userInfo = voManager.getAsset(VOID.MY_USER_INFO);
			
			if ( !(_userInfo is UserInfoVO))
			{
				echo('onRegister : user is not logged yet!');
				throw(new UninitializedError('onRegister : user is not logged yet!'));
			}
			
			
			
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			
			//_sendFriendVO.clear();
			//_sendFriendVO = null;
			_userInfo = null;
			_contactVO.clear();
			_contactVO = null;
			//_amf = null;
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			if (inAsset is ICommServiceRequest)
			{
				var comm:ICommServiceRequest = inAsset as ICommServiceRequest;
				
				var classID:String = AssetClassID.FORM_SHOPPER_CONTACT_US;
				//var classID:String = getAssetIDByType(comm.communicationType);
				
				//if (classID)
				//{
					_contactVO = new ContactUsVO('');
					sendNotification(NotificationType.ADD_FORM_SHOPPER_CONTACT_US, new DisplayObjectVO(classID, assetManager.getData(classID, AssetLibID.AST_FORM), null, _contactVO) );
					
				//}
				//else
				//{
					//echo('initAsset : unknow page id : ' + String(note.getBody()));
				//}
			}
		}
		
		/*private function getAssetIDByType(inID:String):String
		{
			switch(inID)
			{
				case AssetID.BTN_FORGOT_PASSWORD: return AssetClassID.FORM_USER_FORGOT_PASSWORD;
			}
			
			return null;
		}*/
		
		
		/* INTERFACE org.puremvc.as3.multicore.interfaces.IRemoteDataProxy */
		
		override public function getRemoteData(inService:String, inData:Object = null):Boolean
		{
			var requestData:Object;
			
			if (inService == AMFShopperServicesType.CONTACT_US_SHOP)
			{
				//_userLoginVO = voManager.getAsset(VOID.USER_LOGIN);
				
				if (_contactVO === inData)
				{
					requestData =	{
										s_user_id:_userInfo.uid,
										s_email:_contactVO.mail,
										s_name:_contactVO.name,
										s_message:_contactVO.message,
										s_subject:_contactVO.subject
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
			if (inService == AMFShopperServicesType.CONTACT_US_SHOP)
			{
				var resultVO:ResultVO = inData as ResultVO;
				
				if ( resultVO.result === true )
				{
					sendNotification(NotificationType.SHOPPER_CONTACT_US_SUCCESS);
					return true;
				}
				else
				{
					echo('setRemoteData : fail send email to friend');
					sendNotification(NotificationType.SHOPPER_CONTACT_US_FAIL);
				}
				
			}
			
			return false;
		}
		
	}
}