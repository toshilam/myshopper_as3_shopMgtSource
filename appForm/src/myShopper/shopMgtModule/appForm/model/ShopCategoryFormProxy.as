package myShopper.shopMgtModule.appForm.model
{
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.shop.ShopCategoryFormVO;
	import myShopper.common.data.shop.ShopInfoVO;
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
	import myShopper.shopMgtModule.appForm.enum.MediatorID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.observer.Notification;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationRemoteProxy;
	
	public class ShopCategoryFormProxy extends ApplicationRemoteProxy//ApplicationProxy implements IRemoteDataProxy
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
		
		public function ShopCategoryFormProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		//private var _voService:UserVOService;
		private var _shopInfoVO:ShopMgtShopInfoVO;
		private var _categoryVO:ShopCategoryFormVO;
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
			_targetNode = windowNode.*.(@id == AssetID.BTN_SHOP_CATEGORY)[0];
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
			if (inAsset is Notification)
			{
				var note:Notification = inAsset as Notification;
				
				var classID:String = getAssetIDByCommType(String(note.getType()));
				if (classID)
				{
					var type:String = note.getType().toString();
					
					if (_shopInfoVO)
					{
						if (type == ShopMgtEvent.SHOP_CREATE_CATEGORY)
						{
							_categoryVO = new ShopCategoryFormVO('-1');
						}
						else if(type == ShopMgtEvent.SHOP_UPDATE_CATEGORY)
						{
							_categoryVO = note.getBody() as ShopCategoryFormVO;
						}
						else
						{
							echo('initAsset : unknown notification type : ' + type);
							return;
						}
						
						//to send a direct notification to a mediator, as may same type of mediator has created
						sendNotificationToMediator
						(
							type == ShopMgtEvent.SHOP_CREATE_CATEGORY ? MediatorID.SHOP_MGT_CATEGORY_CREATE : MediatorID.SHOP_MGT_CATEGORY_UPDATE,
							NotificationType.ADD_FORM_SHOP_CATEGORY, 
							new DisplayObjectVO(classID, assetManager.getData(classID, AssetLibID.AST_SHOP_MGT_FORM), _targetNode, _categoryVO) 
						);
					}
					else
					{
						echo('initAsset : unable to get shopInfoVO vo');
					}
					
				}
				else
				{
					echo('initAsset : unknow page id : ' + String(note.getType()));
				}
			}
			else
			{
				echo('initAsset : unknow data type : ' + inAsset);
			}
		}
		
		private function getAssetIDByCommType(inID:String):String
		{
			switch(inID)
			{
				case ShopMgtEvent.SHOP_CREATE_CATEGORY: 
				case ShopMgtEvent.SHOP_UPDATE_CATEGORY: return AssetClassID.FORM_SHOP_CATEGORY;
			}
			
			return null;
		}
		
		
		/* INTERFACE org.puremvc.as3.multicore.interfaces.IRemoteDataProxy */
		
		override public function getRemoteData(inService:String, inData:Object = null):Boolean
		{
			var requestData:Object;
			var userInfo:UserInfoVO = voManager.getAsset(VOID.MY_USER_INFO);
			
			if (userInfo && userInfo.isLogged && _shopInfoVO)
			{
				if (inService == AMFShopManagementServicesType.CREATE_CATEGORY)
				{
					requestData = 	{ 
										c_user_id:userInfo.uid,
										c_category:_categoryVO.categoryName,
										c_private:(_categoryVO.isPrivate === true) ? 1 : 0
									};
				}
				else if (inService == AMFShopManagementServicesType.UPDATE_CATEGORY)
				{
					requestData = 	{ 
										c_user_id:userInfo.uid, 
										c_no:_categoryVO.categoryNo,
										c_category:_categoryVO.categoryName,
										c_private:(_categoryVO.isPrivate == true) ? 1 : 0
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
					
					if 
					(
						inService == AMFShopManagementServicesType.CREATE_CATEGORY ||
						inService == AMFShopManagementServicesType.UPDATE_CATEGORY
					)
					{
						sendNotification
						(
							inService == AMFShopManagementServicesType.CREATE_CATEGORY ? NotificationType.CREATE_CATEGORY_FAIL : NotificationType.UPDATE_CATEGORY_FAIL, 
							resultVO
						);
					}
					
					return false;
				}
				else
				{
					if
					(
						inService == AMFShopManagementServicesType.CREATE_CATEGORY ||
						inService == AMFShopManagementServicesType.UPDATE_CATEGORY
					)
					{
						//to need to the temp vo into list, as result return from server has already inculde it
						//_shopInfoVO.productCategoryList.addVO(_categoryVO); 
						
						//TODO : may need to improve perforance? only update the related item?
						if ( _shopVOService.setShopCategory(resultVO.result) )
						{
							sendNotification
							(
								inService == AMFShopManagementServicesType.CREATE_CATEGORY ? NotificationType.CREATE_CATEGORY_SUCCESS : NotificationType.UPDATE_CATEGORY_SUCCESS
							);
						}
						else
						{
							echo('setRemoteData : ' + inService + ' : unable to set data!');
						}
					}
					
					return true;
				}
				
			}
			
			
			return false;
		}
		
	}
}