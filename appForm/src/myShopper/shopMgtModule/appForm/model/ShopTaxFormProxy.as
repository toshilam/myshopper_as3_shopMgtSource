package myShopper.shopMgtModule.appForm.model
{
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.AMFServicesErrorID;
	import myShopper.common.emun.VOID;
	import myShopper.shopMgtCommon.data.service.ShopVOService;
	import myShopper.shopMgtCommon.emun.AMFShopManagementServicesType;
	import myShopper.shopMgtCommon.emun.AssetID;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtCommon.ShopMgtShopInfoVO;
	import myShopper.shopMgtModule.appForm.enum.AssetClassID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import org.puremvc.as3.multicore.patterns.observer.Notification;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationRemoteProxy;
	
	public class ShopTaxFormProxy extends ApplicationRemoteProxy //ApplicationProxy implements IRemoteDataProxy
	{
		/*private var _amf:AMFRemoteProxy;
		private function get amf():AMFRemoteProxy
		{
			if (!_amf) _amf = facade.retrieveProxy(ProxyID.AMF) as AMFRemoteProxy;
			return _amf;
		}*/
		
		public function ShopTaxFormProxy(inName:String, inData:Object)
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
			_targetNode = windowNode.*.(@id == AssetID.BTN_SHOP_S_TAX)[0];
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			
			_shopInfoVO = null;
			//_comm = null;
			_shopVOService.clear();
			_shopVOService = null;
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
					
					if (_shopInfoVO)
					{
						//get about info
						//getRemoteData(AMFShopManagementServicesType.GET_ABOUT);
						
						sendNotification
						(
							NotificationType.ADD_FORM_SHOP_TAX, 
							new DisplayObjectVO(classID, assetManager.getData(classID, AssetLibID.AST_SHOP_MGT_FORM), _targetNode, _shopInfoVO) 
						);
					}
					else
					{
						echo('initAsset : unable to get user login vo');
					}
					
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
				case ShopMgtEvent.SHOP_UPDATE_TAX: return AssetClassID.FORM_SHOP_TAX;
			}
			
			return null;
		}
		
		
		/* INTERFACE org.puremvc.as3.multicore.interfaces.IRemoteDataProxy */
		
		override public function getRemoteData(inService:String, inData:Object = null):Boolean
		{
			if (inService == AMFShopManagementServicesType.UPDATE_TAX)
			{
				var requestData:Object;
				var userInfo:UserInfoVO = voManager.getAsset(VOID.MY_USER_INFO);
				
				if (userInfo && userInfo.isLogged)
				{
					requestData =	{
										s_user_id:userInfo.uid,
										s_tax:_shopInfoVO.tax
									}
					
				}
				else
				{
					sendNotification(NotificationType.UPDATE_TAX_FAIL);
					echo('getRemoteData : unable to get user/shop vo');
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
			if (inService == AMFShopManagementServicesType.UPDATE_TAX)
			{
				var resultVO:ResultVO = inData as ResultVO;
				
				if (resultVO)
				{
					if ( resultVO.code != AMFServicesErrorID.NONE )
					{
						echo('setRemoteData : fail getting data from server');
						
						sendNotification(NotificationType.UPDATE_TAX_FAIL, resultVO);
						return false;
					}
					else
					{
						//if (_shopVOService.setShopBGByVO(_newImageVO))
						//{
							sendNotification(NotificationType.UPDATE_TAX_SUCCESS);
						//}
						//else
						//{
							//echo('setRemoteData : fail setting _newImageVO');
						//}
						
						return true;
					}
					
				}
			}
			
			
			
			return false;
		}
		
	}
}