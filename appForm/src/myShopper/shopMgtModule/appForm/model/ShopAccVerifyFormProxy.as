package myShopper.shopMgtModule.appForm.model
{
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.AMFServicesErrorID;
	import myShopper.common.emun.VOID;
	import myShopper.shopMgtCommon.emun.AMFShopManagementServicesType;
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
	
	public class ShopAccVerifyFormProxy extends ApplicationRemoteProxy//ApplicationProxy implements IRemoteDataProxy
	{
		/*private var _amf:AMFRemoteProxy;
		private function get amf():AMFRemoteProxy
		{
			if (!_amf) _amf = facade.retrieveProxy(ProxyID.AMF) as AMFRemoteProxy;
			return _amf;
		}*/
		
		public function ShopAccVerifyFormProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		//private var _voService:UserVOService;
		private var _shopInfoVO:ShopInfoVO;
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
			_targetNode = windowNode.*.(@id == AssetID.BTN_SHOP_S_ACC_VERIFY)[0];
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			
			_userInfoVO = null;
			_shopInfoVO = null;
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
						
						
						sendNotification
						(
							NotificationType.ADD_FORM_ACC_VERIFY, 
							new DisplayObjectVO(classID, assetManager.getData(classID, AssetLibID.AST_SHOP_MGT_FORM), _targetNode, _shopInfoVO) 
						);
						
						getRemoteData(AMFShopManagementServicesType.GET_ACC_VERIFY_STATUS);
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
				case ShopMgtEvent.SHOP_VERIFY_ACC: return AssetClassID.FORM_SHOP_ACC_VERIFY;
			}
			
			return null;
		}
		
		
		/* INTERFACE org.puremvc.as3.multicore.interfaces.IRemoteDataProxy */
		
		override public function getRemoteData(inService:String, inData:Object = null):Boolean
		{
			var requestData:Object;
			
			//only check if activate is false / activate only need once?
			if (_userInfoVO && _userInfoVO.isLogged && _shopInfoVO.activated == false)
			{
				
				if (inService == AMFShopManagementServicesType.GET_ACC_VERIFY_STATUS || inService == AMFShopManagementServicesType.GET_ACC_VERIFIED)
				{
					requestData =	{ 
										v_user_id:_userInfoVO.uid
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
				if (inService == AMFShopManagementServicesType.GET_ACC_VERIFY_STATUS)
				{
					_shopInfoVO.activated = resultVO.result === true;
					return true;
				}
				else if (inService == AMFShopManagementServicesType.GET_ACC_VERIFIED)
				{
					sendNotification(resultVO.result === true ? NotificationType.ACC_VERIFY_SUCCESS : NotificationType.ACC_VERIFY_FAIL, resultVO);
					return true;
				}
				
			}
			
			
			return false;
		}
		
	}
}