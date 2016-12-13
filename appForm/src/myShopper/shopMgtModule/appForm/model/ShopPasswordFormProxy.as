package myShopper.shopMgtModule.appForm.model
{
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.data.user.UserPasswordVO;
	import myShopper.common.emun.AMFServicesErrorID;
	import myShopper.common.emun.AMFUserManagementServicesType;
	import myShopper.common.emun.VOID;
	import myShopper.common.utils.Tools;
	import myShopper.shopMgtCommon.emun.AssetID;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtModule.appForm.enum.AssetClassID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.observer.Notification;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationRemoteProxy;
	
	public class ShopPasswordFormProxy extends ApplicationRemoteProxy// ApplicationProxy implements IRemoteDataProxy
	{
		/*private var _amf:AMFRemoteProxy;
		private function get amf():AMFRemoteProxy
		{
			if (!_amf) _amf = facade.retrieveProxy(ProxyID.AMF) as AMFRemoteProxy;
			return _amf;
		}*/
		
		public function ShopPasswordFormProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		//private var _voService:UserVOService;
		private var _passwordVO:UserPasswordVO;
		private var _userInfoVO:UserInfoVO;
		private var _targetNode:XML;
		//private var _shopVOService:ShopVOService;
		
		override public function onRegister():void
		{
			super.onRegister();
			
			_userInfoVO = voManager.getAsset(VOID.MY_USER_INFO);
			var xml:XML = xmlManager.getAsset(AssetLibID.XML_SHOP_MGT);
			
			
			if (!_userInfoVO || !xml)
			{
				echo('onRegister : unable to get shop info vo/xml');
				throw(new UninitializedError('onRegister : unable to get shop info vo/xml'));
			}
			
			//_shopVOService = new ShopVOService(_shopInfoVO);
			
			var windowNode:XML = xml..windowElements[0]
			_targetNode = windowNode.*.(@id == AssetID.BTN_SHOP_S_PASSWORD)[0];
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			
			_passwordVO = null;
			_userInfoVO = null;
			//_comm = null;
			//_amf = null;
			_targetNode = null;
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			if (inAsset is Notification)
			{
				var classID:String = getAssetIDByNoteType(Notification(inAsset).getType());
				if (classID)
				{
					
					//if (_shopInfoVO)
					//{
						//get about info
						//getRemoteData(AMFShopManagementServicesType.GET_ABOUT);
						
						_passwordVO = new UserPasswordVO('');
						sendNotification
						(
							NotificationType.ADD_FORM_SHOP_PASSWORD, 
							new DisplayObjectVO(classID, assetManager.getData(classID, AssetLibID.AST_SHOP_MGT_FORM), _targetNode, _passwordVO) 
						);
					/*}
					else
					{
						echo('initAsset : unable to get user login vo');
					}*/
					
				}
				else
				{
					echo('initAsset : unknow page id : ' + Notification(inAsset).getType());
				}
			}
		}
		
		private function getAssetIDByNoteType(inID:String):String
		{
			switch(inID)
			{
				case ShopMgtEvent.SHOP_UPDATE_PASSWORD: return AssetClassID.FORM_SHOP_PASSWORD;
			}
			
			return null;
		}
		
		
		/* INTERFACE org.puremvc.as3.multicore.interfaces.IRemoteDataProxy */
		
		override public function getRemoteData(inService:String, inData:Object = null):Boolean
		{
			var requestData:Object;
			
			if (_userInfoVO && _userInfoVO.isLogged)
			{
				//if (_userInfoVO.password == MD5.hash(_passwordVO.oldPassword))
				//{
					if (inService == AMFUserManagementServicesType.UPDATE_PASSWORD)
					{
						//requestData = { u_id:_userInfoVO.uid, u_password:MD5.hash(_passwordVO.newPassword) };
						//requestData = { u_id:_userInfoVO.uid, u_old_password:MD5.hash(_passwordVO.oldPassword),  u_password:MD5.hash(_passwordVO.newPassword) };
						requestData = { u_id:_userInfoVO.uid, u_old_password:Tools.encodePassword(_passwordVO.oldPassword),  u_password:Tools.encodePassword(_passwordVO.newPassword) };
					}
					else
					{
						echo('getRemoteData : : unknown service type ' + inService, this, 0xff0000);
						return false;
					}
				/*}
				else
				{
					sendNotification(NotificationType.UPDATE_PASSWORD_FAIL);
					echo('getRemoteData : password doesnt match');
					return false;
				}*/
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
					
					if (inService == AMFUserManagementServicesType.UPDATE_PASSWORD)
					{
						sendNotification(NotificationType.UPDATE_PASSWORD_FAIL, resultVO);
					}
					
					return false;
				}
				else
				{
					if (inService == AMFUserManagementServicesType.UPDATE_PASSWORD)
					{
						_userInfoVO.password = _passwordVO.newPassword;
						sendNotification(NotificationType.UPDATE_PASSWORD_SUCCESS);
					}
					
					return true;
				}
				
			}
			
			
			return false;
		}
		
	}
}