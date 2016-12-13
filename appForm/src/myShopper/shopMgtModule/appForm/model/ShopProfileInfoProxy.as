package myShopper.shopMgtModule.appForm.model
{
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.shop.ShopInfoList;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.AMFServicesErrorID;
	import myShopper.common.emun.VOID;
	import myShopper.common.interfaces.ICommServiceRequest;
	import myShopper.shopMgtCommon.emun.AMFShopManagementServicesType;
	import myShopper.shopMgtCommon.emun.AssetID;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationRemoteProxy;
	
	public class ShopProfileInfoProxy extends ApplicationRemoteProxy// ApplicationProxy implements IRemoteDataProxy
	{
		/*private var _amf:AMFRemoteProxy;
		private function get amf():AMFRemoteProxy
		{
			if (!_amf) _amf = facade.retrieveProxy(ProxyID.AMF) as AMFRemoteProxy;
			return _amf;
		}*/
		
		private var _asset:AssetProxy;
		private function get asset():AssetProxy
		{
			if (!_asset) _asset = facade.retrieveProxy(ProxyID.ASSET) as AssetProxy;
			return _asset;
		}
		
		/*private var _comm:CommunicationProxy;
		private function get comm():CommunicationProxy
		{
			if (!_comm) _comm = facade.retrieveProxy(ProxyID.COMM) as CommunicationProxy;
			return _comm;
		}*/
		
		public function ShopProfileInfoProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		//private var _voService:UserVOService;
		private var _shopInfoVO:ShopInfoVO;
		private var _branchInfo:ShopInfoList;
		private var _targetNode:XML;
		private var _selectedVO:ShopInfoVO;
		
		override public function onRegister():void
		{
			super.onRegister();
			
			_shopInfoVO = voManager.getAsset(VOID.MY_SHOP_INFO);
			_branchInfo = voManager.getAsset(VOID.BRANCH_INFO);
			var xml:XML = xmlManager.getAsset(AssetLibID.XML_SHOP_MGT);
			
			if (!_shopInfoVO || !_branchInfo || !xml)
			{
				echo('onRegister : unable to get shop info vo/xml');
				throw(new UninitializedError('onRegister : unable to get shop info vo/xml'));
			}
			
			
			var windowNode:XML = xml..windowElements[0];
			_targetNode = windowNode.*.(@id == AssetID.BTN_SHOP_PROFILES)[0];
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			
			_shopInfoVO = null;
			_branchInfo = null;
			_selectedVO = null;
			//_amf = null;
			_asset = null;
			_targetNode = null;
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			if (inAsset is ICommServiceRequest)
			{
				//var classID:String = getAssetIDByCommType(ICommServiceRequest(inAsset).communicationType);
				var classID:String = _targetNode.@Class.toString();
				if (classID)
				{
					sendNotification
					(
						NotificationType.ADD_DISPLAY_PROFILES, 
						new DisplayObjectVO(classID, assetManager.getData(classID, AssetLibID.AST_SHOP_MGT_FORM), _targetNode, asset.getAllShopInfo()) 
					);
					
				}
				else
				{
					echo('initAsset : unknow page id : ' + ICommServiceRequest(inAsset).communicationType);
				}
			}
		}
		
		/*private function getAssetIDByCommType(inID:String):String
		{
			switch(inID)
			{
				case CommunicationType.SHOP_MGT_NEWS: return AssetClassID.FORM_SHOP_ABOUT;
			}
			
			return null;
		}*/
		
		
		/* INTERFACE org.puremvc.as3.multicore.interfaces.IRemoteDataProxy */
		
		override public function getRemoteData(inService:String, inData:Object = null):Boolean
		{
			var requestData:Object;
			var userInfo:UserInfoVO = voManager.getAsset(VOID.MY_USER_INFO);
			_selectedVO = inData as ShopInfoVO;
			
			//head shop should never be deleted
			if (_selectedVO === _shopInfoVO)
			{
				sendNotification(NotificationType.DELETE_PROFILE_FAIL);
				return false;
			}
			
			if (userInfo && userInfo.isLogged && _selectedVO)
			{
				if (inService == AMFShopManagementServicesType.DELETE_INFO)
				{
					requestData =	{
										s_user_id:_selectedVO.uid,
										s_no:_selectedVO.shopNo
									}
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
					sendNotification(NotificationType.DELETE_PROFILE_FAIL);
					
					
					return false;
				}
				else
				{
					if (inService == AMFShopManagementServicesType.DELETE_INFO)
					{
						if (resultVO.result === true)
						{
							_branchInfo.removeVO( _selectedVO );
							sendNotification(NotificationType.DELETE_PROFILE_SUCCESS, asset.getAllShopInfo());
						}
						else
						{
							sendNotification(NotificationType.DELETE_PROFILE_FAIL);
						}
					}
					
					return true;
				}
				
			}
			
			
			return false;
		}
		
	}
}