package myShopper.shopMgtModule.appShopMgt.model
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.communication.CommList;
	import myShopper.common.data.communication.UserShopCommList;
	import myShopper.common.data.communication.UserShopCommVOList;
	import myShopper.common.data.FileImageVO;
	import myShopper.common.data.service.CommVOService;
	import myShopper.common.data.shop.ShopInfoList;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.shopper.ShopperCategoryList;
	import myShopper.common.data.user.UserInfoList;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.AMFCommServicesType;
	import myShopper.common.emun.AMFShopServicesType;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.FileType;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.FileEvent;
	import myShopper.shopMgtCommon.data.service.ShopVOService;
	import myShopper.shopMgtCommon.emun.AMFShopManagementServicesType;
	import myShopper.shopMgtCommon.emun.CommunicationType;
	import myShopper.shopMgtCommon.ShopMgtShopInfoVO;
	import myShopper.shopMgtModule.appShopMgt.enum.ProxyID;
	import org.puremvc.as3.multicore.enum.NotificationType;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	
	public class ShopDataProxy extends ApplicationProxy implements IRemoteDataProxy
	{
		private const CHECK_ORDER_INTERVAL:int = 1000 * 60 * 5 //check order every 5 mins
		private const CHECK_MESSAGE_INTERVAL:int = 1000 * 60 * 15 //check message every 15 mins
		
		private var _amf:AMFRemoteProxy;
		private function get amf():AMFRemoteProxy
		{
			if (!_amf) _amf = facade.retrieveProxy(ProxyID.AMF) as AMFRemoteProxy;
			return _amf;
		}
		
		private var _comm:CommunicationProxy;
		private function get comm():CommunicationProxy
		{
			if (!_comm) _comm = facade.retrieveProxy(ProxyID.COMM) as CommunicationProxy;
			return _comm;
		}
		
		private var _userInfo:UserInfoVO;
		private var _shopInfo:ShopMgtShopInfoVO;
		private var _branchInfo:ShopInfoList;
		private var _commList:UserShopCommList;
		private var _cateogryList:ShopperCategoryList;
		
		private var _shopVOService:ShopVOService;
		private var _commVOService:CommVOService;
		private var _checkOrderTimer:Timer;
		private var _checkMessageTimer:Timer;
		
		public function ShopDataProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		
		override public function onRegister():void
		{
			super.onRegister();
			
			_userInfo = voManager.getAsset(VOID.MY_USER_INFO);
			_shopInfo = voManager.getAsset(VOID.MY_SHOP_INFO);
			_branchInfo = voManager.getAsset(VOID.BRANCH_INFO);
			_commList = voManager.getAsset(VOID.COMM_SHOP_USER_INFO);
			_cateogryList = voManager.getAsset(VOID.SHOPPER_PRODUCT_CATEGORY);
			
			if (!_userInfo || !_branchInfo || !_shopInfo || !_commList)
			{
				echo("unable to get asset user/shop VO");
				throw(new UninitializedError("unable to get asset user/shop VO "));
			}
			
			_shopVOService = new ShopVOService(_shopInfo);
			_commVOService = new CommVOService(_commList);
			
			_checkOrderTimer = new Timer(CHECK_ORDER_INTERVAL, 1);
			_checkMessageTimer = new Timer(CHECK_MESSAGE_INTERVAL, 1);
			_checkOrderTimer.addEventListener(TimerEvent.TIMER_COMPLETE, orderTimerHandler);
			_checkMessageTimer.addEventListener(TimerEvent.TIMER_COMPLETE, messageTimerHandler);
		}
		
		private function messageTimerHandler(e:TimerEvent):void 
		{
			_checkMessageTimer.reset();
			
			getRemoteData(AMFCommServicesType.GET_NUM_UNREAD_USER_SHOP_MESSAGE);
		}
		
		private function orderTimerHandler(e:TimerEvent):void 
		{
			_checkOrderTimer.reset();
			
			//getRemoteData(AMFShopManagementServicesType.GET_ORDER_SINCE);
			getRemoteData(AMFShopManagementServicesType.GET_ORDER);
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			_userInfo = null;
			_shopInfo = null;
			_commList = null;
			_cateogryList = null;
			
			_shopVOService = null;
			_commVOService = null;
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			echo('initAsset');
		}
		
		public function tearDownAsset():void
		{
			if (_userInfo) _userInfo.clear();
			if (_shopInfo) _shopInfo.clear();
			if (_commList) _commList.clear();
			
			//user teardown notification instead of, as module off is only make module invisiable
			//sendNotification(NotificationType.TEARDOWN);
		}
		
		public function getRemoteData(inService:String, inData:Object = null):Boolean
		{
			if (!_userInfo || !_userInfo.isLogged || !_userInfo.isShopExist)
			{
				echo('getRemoteData : unable to get user/shop vo');
				return false;
			}
			
			var requestData:Object;
			
			if (inService == AMFShopManagementServicesType.GET_INFO_BY_USER_ID)
			{
				requestData = { s_user_id:_userInfo.uid }
				
			}
			else if (inService == AMFShopManagementServicesType.GET_ORDER)
			{
				requestData = { o_shop_id:_userInfo.uid, o_is_complete:false  }
			}
			else if (inService == AMFShopManagementServicesType.UPDATE_STATUS)
			{
				requestData = { s_user_id:_userInfo.uid, s_status:_shopInfo.status }
			}
			else if (inService == AMFCommServicesType.GET_NUM_UNREAD_USER_SHOP_MESSAGE) //total (all user) num unread
			{
				requestData = { q_to_user_id:_userInfo.uid }
			}
			/*else if (inService == AMFShopManagementServicesType.GET_ORDER_SINCE)
			{
				requestData = { o_shop_id:_userInfo.uid, o_timeStamp:_shopInfo.shopOrderList.timeStamp }
			}*/
			else
			{
				echo('getRemoteData : : unknown service type ' + inService, this, 0xff0000);
				return false;
			}
			
			
			return amf.call(inService, requestData);
		}
		
		public function setRemoteData(inService:String, inData:Object):Boolean
		{
			var resultVO:ResultVO = inData as ResultVO;
			
			if (inService == AMFShopManagementServicesType.GET_INFO_BY_USER_ID)
			{
				var arrShop:Array = resultVO.result as Array;
				
				if (arrShop)
				{
					for (var i:int = 0; i < arrShop.length; i++)
					{
						//first shop info as head shop
						if (!i)
						{
							if (_shopVOService.setShopInfo(arrShop[i], _cateogryList))
							{
								//to notify form module
								comm.request(CommunicationType.SHOP_INFO_INITIALZIED, _shopInfo);
								
								//download logo / bg
								sendNotification(FileEvent.DOWNLOAD, new FileImageVO('', null, '', '', '', FileType.PATH_SHOP_LOGO) );
								sendNotification(FileEvent.DOWNLOAD, new FileImageVO('', null, '', '', '', FileType.PATH_SHOP_BG) );
								
								//get all order
								getRemoteData(AMFShopManagementServicesType.GET_ORDER);
								getRemoteData(AMFCommServicesType.GET_NUM_UNREAD_USER_SHOP_MESSAGE);
							}
						}
						//set branch
						else
						{
							_branchInfo.addVO( new ShopVOService( new ShopMgtShopInfoVO('') ).setShopInfo(arrShop[i], _cateogryList) );
						}
					}
					
				}
				else
				{
					comm.request(CommunicationType.SHOP_INFO_INITIALZIED, null);
				}
				
			}
			else if (inService == AMFShopManagementServicesType.GET_ORDER)
			{
				if (resultVO && _shopVOService.setShopOrder(resultVO.result))
				{
					sendNotification(myShopper.shopMgtModule.appShopMgt.enum.NotificationType.UPDATE_NUM_NEW_ORDER);
					comm.request(CommunicationType.SHOP_MGT_UPDATE_ORDER); //refresh order list
					//start order timer once all the orders are downloaded
					_checkOrderTimer.start();
				}
				
			}
			else if (inService == AMFShopManagementServicesType.UPDATE_STATUS)
			{
				if (resultVO.result == true)
				{
					sendNotification(myShopper.shopMgtModule.appShopMgt.enum.NotificationType.UPDATE_STATUS_SUCCESS);
				}
				else
				{
					sendNotification(myShopper.shopMgtModule.appShopMgt.enum.NotificationType.UPDATE_STATUS_FAIL);
				}
			}
			else if (inService == AMFCommServicesType.GET_NUM_UNREAD_USER_SHOP_MESSAGE)
			{
				if ( _commVOService.setAMFUserShopNumReadMessage(resultVO.result) )
				{
					//no need to notify, as mediator itself is listening vo change evet
					//sendNotification(myShopper.shopMgtModule.appShopMgt.enum.NotificationType.UPDATE_NUM_NEW_MESSAGE);
					
					//reset time if it's already running, it get num unread by other moudle
					if (_checkMessageTimer.running)
					{
						_checkMessageTimer.reset();
					}
					
					_checkMessageTimer.start();
					
					//if there is any new message unread, notify other module
					/*if (_commList.numUnRead)
					{
						comm.request(CommunicationType.num
					}*/
				}
			}
			/*else if (inService == AMFShopManagementServicesType.GET_ORDER_SINCE)
			{
				if (resultVO && _shopVOService.setShopNewOrder(resultVO.result))
				{
					sendNotification(myShopper.shopMgtModule.appShopMgt.enum.NotificationType.UPDATE_NUM_NEW_ORDER);
					
					//start order timer once all the orders are downloaded
					_checkOrderTimer.start();
				}
				
				
			}*/
			else
			{
				echo('setRemoteData : no matched service type found : ' + inService);
				return false;
			}
			
			return true;
			
		}
		
		
	}
}