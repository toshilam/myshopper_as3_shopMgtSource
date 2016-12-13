package myShopper.shopMgtModule.appForm.model
{
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.shop.ShopNewsVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.AMFServicesErrorID;
	import myShopper.common.emun.VOID;
	import myShopper.common.interfaces.IResponder;
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
	
	public class ShopNewsFormProxy extends ApplicationRemoteProxy
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
		
		public function ShopNewsFormProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		//private var _voService:UserVOService;
		private var _shopInfoVO:ShopMgtShopInfoVO;
		private var _targetNode:XML;
		private var _newsVO:ShopNewsVO;
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
			_targetNode = windowNode.*.(@id == AssetID.BTN_SHOP_NEWS_NEWS)[0];
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
						var type:String = note.getType().toString();
						
						if (type == ShopMgtEvent.SHOP_CREATE_NEWS)
						{
							_newsVO = new ShopNewsVO('-1');
						}
						else if (type == ShopMgtEvent.SHOP_UPDATE_NEWS)
						{
							_newsVO = note.getBody() as ShopNewsVO;
							if (!_newsVO)
							{
								echo('initAsset : unknown data type : ' + note.getBody());
								return;
							}
						}
						else
						{
							echo('initAsset : unknown notification type : ' + type);
							return;
						}
						
						//to send a direct notification to a mediator, as may same type of mediator has created
						sendNotificationToMediator
						(
							type == ShopMgtEvent.SHOP_CREATE_NEWS ? MediatorID.SHOP_MGT_NEWS_CREATE : MediatorID.SHOP_MGT_NEWS_UPDATE,
							NotificationType.ADD_FORM_SHOP_NEWS, 
							new DisplayObjectVO(classID, assetManager.getData(classID, AssetLibID.AST_SHOP_MGT_FORM), _targetNode, _newsVO) 
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
				case ShopMgtEvent.SHOP_CREATE_NEWS:		
				case ShopMgtEvent.SHOP_UPDATE_NEWS:		return AssetClassID.FORM_SHOP_NEWS;
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
				if (inService == AMFShopManagementServicesType.CREATE_NEWS )
				{
					requestData = { n_user_id:userInfo.uid, n_title:_newsVO.title, n_content:_newsVO.content };
				}
				else if ( inService == AMFShopManagementServicesType.UPDATE_NEWS )
				{
					requestData = { n_user_id:userInfo.uid, n_title:_newsVO.title, n_content:_newsVO.content, n_no:_newsVO.id };
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
						inService == AMFShopManagementServicesType.UPDATE_NEWS || 
						inService == AMFShopManagementServicesType.CREATE_NEWS
					)
					{
						sendNotification
						(
							inService == AMFShopManagementServicesType.UPDATE_NEWS ? NotificationType.UPDATE_NEWS_FAIL : NotificationType.CREATE_NEWS_FAIL, 
							resultVO
						);
					}
					
					return false;
				}
				else
				{
					if 
					(
						inService == AMFShopManagementServicesType.UPDATE_NEWS || 
						inService == AMFShopManagementServicesType.CREATE_NEWS
					)
					{
						//once data is set, value will be autometically set in display object form
						if ( !_shopVOService.setShopNews(resultVO.result) )
						{
							echo('setRemoteData : fail setting data into vo');
						}
						else
						{
							sendNotification(inService == AMFShopManagementServicesType.UPDATE_NEWS ? NotificationType.UPDATE_NEWS_SUCCESS : NotificationType.CREATE_NEWS_SUCCESS);
						}
					}
					
					return true;
				}
				
			}
			
			
			return false;
		}
		
		
	}
}