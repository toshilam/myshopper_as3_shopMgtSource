package myShopper.shopMgtModule.appForm.model
{
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.AMFPayPalServicesType;
	import myShopper.common.emun.AMFServicesErrorID;
	import myShopper.common.emun.AMFUserManagementServicesType;
	import myShopper.common.emun.VOID;
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
	
	public class ShopPaypalAccVerifyFormProxy extends ApplicationRemoteProxy// ApplicationProxy implements IRemoteDataProxy
	{
		/*private var _amf:AMFRemoteProxy;
		private function get amf():AMFRemoteProxy
		{
			if (!_amf) _amf = facade.retrieveProxy(ProxyID.AMF) as AMFRemoteProxy;
			return _amf;
		}*/
		
		public function ShopPaypalAccVerifyFormProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		//private var _voService:UserVOService;
		private var _shopInfoVO:ShopInfoVO;
		private var _clonedShopInfoVO:ShopInfoVO;
		private var _userInfoVO:UserInfoVO;
		private var _targetNode:XML;
		//private var _shopVOService:ShopVOService;
		
		override public function onRegister():void
		{
			super.onRegister();
			
			_shopInfoVO = voManager.getAsset(VOID.MY_SHOP_INFO);
			_userInfoVO = voManager.getAsset(VOID.MY_USER_INFO);
			var xml:XML = xmlManager.getAsset(AssetLibID.XML_SHOP_MGT);
			
			
			if (!_shopInfoVO || !xml)
			{
				echo('onRegister : unable to get shop info vo/xml');
				throw(new UninitializedError('onRegister : unable to get shop info vo/xml'));
			}
			
			//_shopVOService = new ShopVOService(_shopInfoVO);
			
			var windowNode:XML = xml..windowElements[0]
			_targetNode = windowNode.*.(@id == AssetID.BTN_SHOP_S_PAYPAL_ACC_VERIFY)[0];
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			
			_userInfoVO = null;
			_shopInfoVO = null;
			_clonedShopInfoVO = null;
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
						
						_clonedShopInfoVO = _shopInfoVO.clone() as ShopInfoVO;
						
						sendNotification
						(
							NotificationType.ADD_FORM_PAYPAL_ACC_VERIFY, 
							new DisplayObjectVO(classID, assetManager.getData(classID, AssetLibID.AST_SHOP_MGT_FORM), _targetNode, _clonedShopInfoVO) 
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
				case ShopMgtEvent.SHOP_VERIFY_PAYPAL_ACC: return AssetClassID.FORM_SHOP_PAYPAL_ACC_VERIFY;
			}
			
			return null;
		}
		
		
		/* INTERFACE org.puremvc.as3.multicore.interfaces.IRemoteDataProxy */
		
		override public function getRemoteData(inService:String, inData:Object = null):Boolean
		{
			var requestData:Object;
			
			if (_userInfoVO && _userInfoVO.isLogged && _clonedShopInfoVO === inData)
			{
				//if (_userInfoVO.password == MD5.hash(_passwordVO.oldPassword))
				//{
					if (inService == AMFPayPalServicesType.GET_ACC_VERIFY_STATUS)
					{
						//paypal account first and last name have no number with?
						requestData =	{ 
											s_user_id:_userInfoVO.uid, 
											s_paypal_email:_clonedShopInfoVO.payPalEmail,  
											s_paypal_first_name:_clonedShopInfoVO.payPalFirstName,
											s_paypal_last_name:_clonedShopInfoVO.payPalLastName 
										};
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
					
					sendNotification(NotificationType.PAYPAL_ACC_VERIFY_FAIL, resultVO);
					
					return false;
				}
				else
				{
					//if acc verified, get info to orgranal shop vo
					_shopInfoVO.payPalEmail = _clonedShopInfoVO.payPalEmail;
					_shopInfoVO.payPalFirstName = _clonedShopInfoVO.payPalFirstName;
					_shopInfoVO.payPalLastName = _clonedShopInfoVO.payPalLastName;
					_shopInfoVO.paypalAccVerified = true;
					sendNotification(NotificationType.PAYPAL_ACC_VERIFY_SUCCESS);
					
					return true;
				}
				
			}
			
			
			return false;
		}
		
	}
}