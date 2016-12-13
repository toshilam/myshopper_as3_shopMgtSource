package myShopper.shopMgtModule.appForm.model
{
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.communication.UserShopCommList;
	import myShopper.common.data.communication.UserShopCommVO;
	import myShopper.common.data.communication.UserShopCommVOList;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.service.CommVOService;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.emun.AMFCommServicesType;
	import myShopper.common.emun.AMFServicesErrorID;
	import myShopper.common.emun.VOID;
	import myShopper.common.interfaces.ICommServiceRequest;
	import myShopper.shopMgtCommon.emun.AMFShopManagementServicesType;
	import myShopper.shopMgtCommon.emun.AssetID;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.emun.CommunicationType;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationRemoteProxy;
	
	public class ShopUserMsgInfoProxy extends ApplicationRemoteProxy //ApplicationProxy implements IRemoteDataProxy
	{
		
		private var _comm:CommunicationProxy;
		private function get comm():CommunicationProxy
		{
			if (!_comm) _comm = facade.retrieveProxy(ProxyID.COMM) as CommunicationProxy;
			return _comm;
		}
		
		/*private var _amf:AMFRemoteProxy;
		private function get amf():AMFRemoteProxy
		{
			if (!_amf) _amf = facade.retrieveProxy(ProxyID.AMF) as AMFRemoteProxy;
			return _amf;
		}*/
		
		
		private var _shopInfoVO:ShopInfoVO;
		private var _selectedVO:UserShopCommVO;
		private var _targetNode:XML;
		
		private var _commList:UserShopCommList;
		private var _commVOService:CommVOService;
		
		
		public function ShopUserMsgInfoProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		
		override public function onRegister():void
		{
			super.onRegister();
			//echo("onRegister() ");
			
			_shopInfoVO = voManager.getAsset(VOID.MY_SHOP_INFO);
			_commList = voManager.getAsset(VOID.COMM_SHOP_USER_INFO);
			
			var xml:XML = xmlManager.getAsset(AssetLibID.XML_SHOP_MGT);
			
			if (!_shopInfoVO || !xml || !_commList)
			{
				echo('onRegister : unable to get shop info vo/xml');
				throw(new UninitializedError('onRegister : unable to get shop info vo/xml'));
			}
			
			_commVOService = new CommVOService(_commList);
			
			var windowNode:XML = xml..windowElements[0]
			_targetNode = windowNode.*.(@id == AssetID.BTN_Q_USER_MESSAGE)[0];
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			//_swfAddress = null;
			//_amf = null;
			_shopInfoVO = null;
			_targetNode = null;
			_commVOService.clear();
			_commVOService = null;
			
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			if (inAsset is ICommServiceRequest)
			{
				//var classID:String = getAssetIDByCommType(String(inAsset));
				var classID:String = _targetNode.@Class.toString();
				if (classID)
				{
					
					//if (_shopInfoVO)
					//{
						sendNotification
						(
							NotificationType.ADD_DISPLAY_USER_MESSAGE, 
							new DisplayObjectVO(classID, assetManager.getData(classID, AssetLibID.AST_SHOP_MGT), _targetNode) 
						);
						
						//get user shop message's user list
						getRemoteData(AMFCommServicesType.GET_USER_SHOP_MESSAGE_USER_LIST);
					//}
					//else
					//{
						//echo('initAsset : unable to get user login vo');
					//}
					
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
				case CommunicationType.SHOP_MGT_PRODUCT: return AssetClassID.FORM_SHOP_PRODUCT;
			}
			
			return null;
		}*/
		
		override public function getRemoteData(inService:String, inData:Object = null):Boolean
		{
			var requestData:Object;
			
			if (inService == AMFCommServicesType.READ_USER_SHOP_MESSAGE)
			{
				_selectedVO = inData as UserShopCommVO;
				//if no shop found, send error message
				if (_selectedVO == null) 
				{
					echo('getRemoteData : unable to retrieve vo : ' + inData);
					//sendNotification(RESULT_FAULT);
					return false;
				}
				
				//if message already read, do nothing
				if (_selectedVO.isRead) 
				{
					return false;
				}
				
				//update data straight, no need to wait for server response, as user may click each message fester than server response?
				_selectedVO.isRead = true;
				
				requestData =	{
									q_to_user_id:_shopInfoVO.uid, //q_to_user_id and q_from_user_id used for retrieve numUnRead message
									q_from_user_id:_selectedVO.fromUID, 
									q_no:_selectedVO.no 
								};
			}
			else if (inService == AMFCommServicesType.GET_USER_SHOP_MESSAGE_USER_LIST)
			{
				requestData =	{
									q_to_user_id:_shopInfoVO.uid 
								};
			}
			else if (inService == AMFCommServicesType.GET_USER_SHOP_MESSAGE_BY_UID)
			{
				var voList:UserShopCommVOList = inData as UserShopCommVOList;
				if (voList)
				{
					requestData =	{
										q_to_user_id:_shopInfoVO.uid, 
										q_from_user_id:voList.userID 
									};
				}
				else
				{
					echo('getRemoteData : unknown data type: ' + inData, this, 0xff0000);
					return false;
				}
				
			}
			else
			{
				echo('getRemoteData : unknown service type ' + inService, this, 0xff0000);
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
					
					return false;
				}
				else
				{
					if (inService == AMFCommServicesType.READ_USER_SHOP_MESSAGE)
					{
						//notify a message is read to shopMgtModule
						comm.request(CommunicationType.SHOP_MGT_UPDATE_NUM_NEW_MESSAGE);
						
						if (_selectedVO)
						{
							_commVOService.setAMFUserShopUserNumReadMessage(resultVO.result, _selectedVO.fromUID)
						}
						
					}
					else if (inService == AMFCommServicesType.GET_USER_SHOP_MESSAGE_USER_LIST)
					{
						if (_commVOService.setAMFUserShopMessageUserList(resultVO.result))
						{
							sendNotification(NotificationType.GET_USER_SHOP_MESSAGE_LIST_SUCCESS);
						}
						else
						{
							sendNotification(NotificationType.GET_USER_SHOP_MESSAGE_LIST_FAIL);
						}
					}
					else if (inService == AMFCommServicesType.GET_USER_SHOP_MESSAGE_BY_UID)
					{
						if (_commVOService.setAMFUserShopMessageByUID(resultVO.result))
						{
							sendNotification(NotificationType.GET_USER_SHOP_MESSAGE_BY_UID_SUCCESS);
						}
						else 
						{
							sendNotification(NotificationType.GET_USER_SHOP_MESSAGE_BY_UID_FAIL);
						}
					}
					
					return true;
				}
				
			}
			
			return false;
		}
		
		
		
	}
}