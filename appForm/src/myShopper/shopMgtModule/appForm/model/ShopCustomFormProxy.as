package myShopper.shopMgtModule.appForm.model
{
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.shop.ShopCustomPageVO;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.AMFServicesErrorID;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.FileEvent;
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
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.observer.Notification;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationRemoteProxy;
	
	public class ShopCustomFormProxy extends ApplicationRemoteProxy// ApplicationProxy implements IRemoteDataProxy
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
		
		public function ShopCustomFormProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		//private var _voService:UserVOService;
		private var _shopInfoVO:ShopMgtShopInfoVO;
		private var _targetNode:XML;
		private var _customVO:ShopCustomPageVO;
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
			_targetNode = windowNode.*.(@id == AssetID.BTN_SHOP_CUSTOM_FORM)[0];
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			
			_shopInfoVO = null;
			//_comm = null;
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
					
					if (_shopInfoVO)
					{
						var type:String = note.getType();
						
						if (type == ShopMgtEvent.SHOP_CREATE_CUSTOM)
						{
							_customVO = new ShopCustomPageVO('-1');
						}
						else if (type == ShopMgtEvent.SHOP_UPDATE_CUSTOM)
						{
							_customVO = note.getBody() as ShopCustomPageVO;
							if (!_customVO)
							{
								echo('initAsset : unknown data type : ' + note.getBody());
								return;
							}
							
							//download image
							sendNotification(FileEvent.DOWNLOAD, _customVO);
						}
						else
						{
							echo('initAsset : unknown notification type : ' + type);
							return;
						}
						
						//to send a direct notification to a mediator, as may same type of mediator has created
						sendNotificationToMediator
						(
							type == ShopMgtEvent.SHOP_CREATE_CUSTOM ? MediatorID.SHOP_MGT_CUSTOM_CREATE : MediatorID.SHOP_MGT_CUSTOM_UPDATE,
							NotificationType.ADD_FORM_SHOP_CUSTOM, 
							new DisplayObjectVO(classID, assetManager.getData(classID, AssetLibID.AST_SHOP_MGT_FORM), _targetNode, _customVO) 
						);
					}
					else
					{
						echo('initAsset : unable to get user login vo');
					}
					
				}
				else
				{
					echo('initAsset : unknow page id : ' + String(note.getType()));
				}
			}
		}
		
		private function getAssetIDByCommType(inID:String):String
		{
			switch(inID)
			{
				case ShopMgtEvent.SHOP_CREATE_CUSTOM:		
				case ShopMgtEvent.SHOP_UPDATE_CUSTOM:		return AssetClassID.FORM_SHOP_CUSTOM;
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
				if 
				(
					inService == AMFShopManagementServicesType.CREATE_CUSTOM ||
					inService == AMFShopManagementServicesType.UPDATE_CUSTOM
				)
				{
					requestData = 	{ 
										lang:_customVO.selectedLangCode,
										c_user_id:userInfo.uid, 
										c_id:_customVO.pageID,
										c_name:_customVO.pageName,
										c_title:_customVO.pageTitle,
										c_content:_customVO.pageContent,
										
										i_name:_customVO.photoFileVO.name,
										i_data:_customVO.photoFileVO.data,
										i_type:_customVO.photoFileVO.type,
										i_size:_customVO.photoFileVO.size,
										i_path:_customVO.photoFileVO.path
									};
									
					if (inService == AMFShopManagementServicesType.UPDATE_CUSTOM)
					{
						requestData.c_no = _customVO.pageNo;
					}
				}
				//will only be call while updating custom (not create custom)
				else if (inService == AMFShopManagementServicesType.GET_CUSTOM_BY_NO)
				{
					if (_customVO === inData && _customVO.pageNo)
					{
						requestData =	{
											lang:_customVO.selectedLangCode,
											c_no:_customVO.pageNo
										}
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
					
					if 
					(
						inService == AMFShopManagementServicesType.CREATE_CUSTOM ||
						inService == AMFShopManagementServicesType.UPDATE_CUSTOM
					)
					{
						sendNotification
						(
							inService == AMFShopManagementServicesType.CREATE_CUSTOM ? NotificationType.CREATE_CUSTOM_FAIL : NotificationType.UPDATE_CUSTOM_FAIL, 
							resultVO
						);
					}
					else if (inService == AMFShopManagementServicesType.GET_CUSTOM_BY_NO)
					{
						sendNotification(NotificationType.GET_CUSTOM_BY_NO_FAIL, resultVO);
					}
					
					return false;
				}
				else
				{
					if (inService == AMFShopManagementServicesType.CREATE_CUSTOM)
					{
						if (_customVO && resultVO.result)
						{
							_customVO.pageNo = String(resultVO.result);
							
							if (!_shopInfoVO.customPageList.getVOByPageNo(_customVO.pageNo))
							{
								_shopInfoVO.customPageList.addVO( _customVO );
							}
							
							sendNotification(NotificationType.CREATE_CUSTOM_SUCCESS);
						}
						else
						{
							sendNotification(NotificationType.CREATE_CUSTOM_FAIL, resultVO);
						}
						
					}
					else if (inService == AMFShopManagementServicesType.UPDATE_CUSTOM)
					{
						if (resultVO.result)
						{
							sendNotification(NotificationType.UPDATE_CUSTOM_SUCCESS);
						}
						else
						{
							sendNotification(NotificationType.UPDATE_CUSTOM_FAIL, resultVO);
						}
					}
					else if (inService == AMFShopManagementServicesType.GET_CUSTOM_BY_NO)
					{
						if (resultVO.result && _shopVOService.setShopCustom([resultVO.result]))
						{
							sendNotification(NotificationType.GET_CUSTOM_BY_NO_SUCCESS);
						}
						else
						{
							sendNotification(NotificationType.GET_CUSTOM_BY_NO_FAIL, resultVO);
						}
					}
					
					return true;
				}
				
			}
			
			
			return false;
		}
		
	}
}