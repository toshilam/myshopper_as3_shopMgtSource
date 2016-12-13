package myShopper.shopMgtModule.appForm.model
{
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.communication.UserShopCommList;
	import myShopper.common.data.communication.UserShopCommVO;
	import myShopper.common.data.communication.UserShopCommVOList;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.service.CommVOService;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.AMFCommServicesType;
	import myShopper.common.emun.AMFServicesErrorID;
	import myShopper.common.emun.VOID;
	import myShopper.common.utils.Tools;
	import myShopper.shopMgtCommon.emun.AssetID;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtModule.appForm.enum.AssetClassID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.observer.Notification;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationRemoteProxy;
	
	public class ShopUserMsgFormProxy extends ApplicationRemoteProxy //ApplicationProxy implements IRemoteDataProxy
	{
		/*private var _amf:AMFRemoteProxy;
		private function get amf():AMFRemoteProxy
		{
			if (!_amf) _amf = facade.retrieveProxy(ProxyID.AMF) as AMFRemoteProxy;
			return _amf;
		}*/
		
		public function ShopUserMsgFormProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		private var _selectedVO:UserShopCommVOList;
		private var _userInfoVO:UserInfoVO;
		private var _userShopMsgVO:UserShopCommVO;
		private var _targetNode:XML;
		
		private var _commList:UserShopCommList;
		private var _commVOService:CommVOService;
		
		override public function onRegister():void
		{
			super.onRegister();
			
			_userInfoVO = voManager.getAsset(VOID.MY_USER_INFO);
			_commList = voManager.getAsset(VOID.COMM_SHOP_USER_INFO);
			
			var xml:XML = xmlManager.getAsset(AssetLibID.XML_SHOP_MGT);
			
			if (!_userInfoVO || !xml || !_commList)
			{
				echo('onRegister : unable to get shop info vo/xml');
				throw(new UninitializedError('onRegister : unable to get shop info vo/xml'));
			}
			
			_commVOService = new CommVOService(_commList);
			
			var windowNode:XML = xml..windowElements[0]
			_targetNode = windowNode.*.(@id == AssetID.BTN_Q_USER_MESSAGE_CREATE)[0];
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			_selectedVO = null;
			_userShopMsgVO = null;
			_userInfoVO = null;
			_commVOService.clear();
			_commVOService = null;
			//_amf = null;
			_targetNode = null;
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			if (inAsset is Notification)
			{
				var note:INotification = inAsset as INotification;
				
				var classID:String = getAssetIDByNoteType(note.getType());
				_selectedVO = note.getBody() as UserShopCommVOList;
				
				if (classID && _selectedVO)
				{
					
					//if (_shopInfoVO)
					//{
						//get about info
						//getRemoteData(AMFShopManagementServicesType.GET_ABOUT);
						
						_userShopMsgVO = new UserShopCommVO('-1', '', '');
						sendNotification
						(
							NotificationType.ADD_FORM_USER_MESSAGE, 
							new DisplayObjectVO(classID, assetManager.getData(classID, AssetLibID.AST_SHOP_MGT_FORM), _targetNode, _userShopMsgVO) 
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
				case ShopMgtEvent.SHOP_CREATE_USER_SHOP_MESSAGE: return AssetClassID.FORM_SHOP_USER_MSG;
			}
			
			return null;
		}
		
		
		/* INTERFACE org.puremvc.as3.multicore.interfaces.IRemoteDataProxy */
		
		override public function getRemoteData(inService:String, inData:Object = null):Boolean
		{
			var requestData:Object;
			
			if (_userInfoVO && _userInfoVO.isLogged)
			{
				if (_userShopMsgVO === inData)
				{
					if (inService == AMFCommServicesType.SEND_USER_SHOP_MESSAGE)
					{
						requestData =	{
											q_is_shop:true,
											//s_email:_questionVO.email,
											//s_name:_questionVO.name,
											//s_subject:_questionVO.subject,
											q_message:Tools.replaceRestrictedString(String(_userShopMsgVO.data)),
											q_from_user_id:_userInfoVO.uid, //shop id
											q_to_user_id:_selectedVO.userID, //user id
											q_get_message:true //to specify to return a list of user shop message
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
					echo('getRemoteData : unknown data object');
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
					
					sendNotification(NotificationType.CREATE_USER_MSG_FAIL, resultVO);
					
					return false;
				}
				else
				{
					//it's supposed to return a list of user shop message
					if (_commVOService.setAMFUserShopMessageByUID(resultVO.result))
					{
						sendNotification(NotificationType.CREATE_USER_MSG_SUCCESS);
					}
					else
					{
						sendNotification(NotificationType.CREATE_USER_MSG_FAIL, resultVO);
					}
					
					return true;
				}
				
			}
			
			
			return false;
		}
		
	}
}