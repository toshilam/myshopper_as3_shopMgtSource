package myShopper.shopMgtModule.appForm.model
{
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.shop.ShopCustomPageVO;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.AMFServicesErrorID;
	import myShopper.common.emun.VOID;
	import myShopper.shopMgtCommon.emun.AMFShopManagementServicesType;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.observer.Notification;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationRemoteProxy;
	
	public class ShopCustomAlertProxy extends ApplicationRemoteProxy //ApplicationProxy implements IRemoteDataProxy
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
		
		public function ShopCustomAlertProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		//private var _voService:UserVOService;
		private var _shopInfoVO:ShopInfoVO;
		private var _customVO:ShopCustomPageVO;
		//private var _targetNode:XML;
		//private var _shopVOService:ShopVOService;
		
		override public function onRegister():void
		{
			super.onRegister();
			
			_shopInfoVO = voManager.getAsset(VOID.MY_SHOP_INFO);
			//var xml:XML = xmlManager.getAsset(AssetLibID.XML_SHOP_MGT);
			
			
			if (!_shopInfoVO /*|| !xml*/)
			{
				echo('onRegister : unable to get shop info vo/xml');
				throw(new UninitializedError('onRegister : unable to get shop info vo/xml'));
			}
			
			//_shopVOService = new ShopVOService(_shopInfoVO);
			
			//var windowNode:XML = xml..windowElements[0]
			//_targetNode = windowNode.*.(@id == AssetID.BTN_SHOP_CATEGORY)[0];
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			
			_shopInfoVO = null;
			//_comm = null;
			//_amf = null;
			_customVO = null;
			//_shopVOService = null;
			//_targetNode = null;
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			if (inAsset is Notification)
			{
				var note:Notification = inAsset as Notification;
				
				var type:String = String(note.getType());
				if (type == ShopMgtEvent.SHOP_DELETE_CUSTOM)
				{
					_customVO = note.getBody() as ShopCustomPageVO;
					
					if (_customVO)
					{
						sendNotification(NotificationType.ADD_ALERT_SHOP_CUSTOM);
					}
					else
					{
						echo('initAsset : unable to retrieve vo data : ' + note.getBody());
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
		
		
		/* INTERFACE org.puremvc.as3.multicore.interfaces.IRemoteDataProxy */
		
		override public function getRemoteData(inService:String, inData:Object = null):Boolean
		{
			var requestData:Object;
			var userInfo:UserInfoVO = voManager.getAsset(VOID.MY_USER_INFO);
			
			if (userInfo && userInfo.isLogged && _customVO)
			{
				if (inService == AMFShopManagementServicesType.DELETE_CUSTOM)
				{
					//p_category for retrieving list of product on server side
					requestData = 	{ c_user_id:userInfo.uid, c_no:_customVO.pageNo };
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
					
					sendNotification(NotificationType.DELETE_CUSTOM_FAIL, resultVO);
					
					return false;
				}
				else
				{
					//if successfully deleted the target vo, remove from current vo list 
					if( _customVO && _shopInfoVO.customPageList.removeVO(_customVO) )
					//in case of DELETE, no need to reset the list of vo
					//if ( _shopVOService.setShopCategory(resultVO.result) )
					{
						sendNotification(NotificationType.DELETE_CUSTOM_SUCCESS);
					}
					else
					{
						echo('setRemoteData : ' + inService + ' : unable to set data!');
					}
					
					return true;
				}
				
			}
			
			
			return false;
		}
		
	}
}