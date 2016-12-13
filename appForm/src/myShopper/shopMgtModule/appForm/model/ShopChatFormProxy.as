package myShopper.shopMgtModule.appForm.model
{
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.communication.CommList;
	import myShopper.common.data.communication.CommVO;
	import myShopper.common.data.communication.CommVOList;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.service.CommVOService;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.FMSServicesType;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.ChatEvent;
	import myShopper.common.events.WindowEvent;
	import myShopper.common.interfaces.ICommServiceRequest;
	import myShopper.common.interfaces.IVO;
	import myShopper.shopMgtCommon.data.ShopMgtUserInfoVO;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtModule.appForm.enum.AssetClassID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.observer.Notification;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	
	public class ShopChatFormProxy extends ApplicationProxy implements IRemoteDataProxy
	{
		/*private var _amf:AMFRemoteProxy;
		private function get amf():AMFRemoteProxy
		{
			if (!_amf) _amf = facade.retrieveProxy(ProxyID.AMF) as AMFRemoteProxy;
			return _amf;
		}*/
		
		private var _fms:FMSRemoteProxy;
		private function get fms():FMSRemoteProxy
		{
			if (!_fms) _fms = facade.retrieveProxy(ProxyID.FMS) as FMSRemoteProxy;
			return _fms;
		}
		
		private var _voService:CommVOService;
		private var _shopInfoVO:ShopInfoVO;
		//private var _targetNode:XML;
		//private var _shopVOService:ShopVOService;
		private var _commInfo:CommList; //contains all the user commVOList
		private var _commVOList:CommVOList; //contains a specify user commVOs
		
		public function ShopChatFormProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		
		override public function onRegister():void
		{
			super.onRegister();
			
			_shopInfoVO = voManager.getAsset(VOID.MY_SHOP_INFO);
			_commInfo = voManager.getAsset(VOID.COMM_INFO);
			//var xml:XML = xmlManager.getAsset(AssetLibID.XML_SHOP_MGT);
			
			
			if (!_shopInfoVO /*|| !xml*/)
			{
				echo('onRegister : unable to get shop info vo/xml');
				throw(new UninitializedError('onRegister : unable to get shop info vo/xml'));
			}
			
			_voService = new CommVOService(_commInfo);
			
			/*_shopVOService = new ShopVOService(_shopInfoVO);
			
			var windowNode:XML = xml..windowElements[0]
			_targetNode = windowNode.*.(@id == AssetID.BTN_SHOP_ABOUT)[0];*/
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			
			_shopInfoVO = null;
			_commInfo = null;
			
			_voService.clear();
			_voService = null;
			/*_comm = null;
			_amf = null;
			_targetNode = null;*/
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			//if (inAsset is Notification)
			if (inAsset is ICommServiceRequest)
			{
				var note:ICommServiceRequest = inAsset as ICommServiceRequest;
				//var type:String = note.getType();
				//var classID:String = getAssetIDByCommType(type);
				
				//var name:String = note.getName();
				//if 
				//(
					//name == ChatEvent.RECEIVE_SHOP_MESSAGE || //event sent by user side
					//name == WindowEvent.CREATE //ShopMgtEvent.CUSTOMER_CHAT //event sent by shop itself
				//)
				//{
					var vo:ShopMgtUserInfoVO = note.data as ShopMgtUserInfoVO;
					var fromUID:String;
					
					//if vo is ShopMgtUserInfoVO this chat action trigger by shop
					if (vo)
					{
						fromUID = vo.uid;
					}
					//if vo is ShopMgtUserInfoVO this chat action trigger by user side
					//else if (vo is ResultVO)
					//{
						//fromUID = CommVOService.getFromUIDByFMSDataObj(ResultVO(vo).result);
					//}
					else
					{
						echo('initAsset : unable to get from FMS ID');
						return;
					}
					
					_commVOList = _voService.getCommVOListByUID(fromUID, true);
					
					//send a direct notification to a related mediator 
					sendNotificationToMediator
					(
						proxyName, //using proxy name, as the targeted mediator has the same name
						NotificationType.ADD_FORM_SHOP_CUSTOMER_CHAT, 
						new DisplayObjectVO(vo.firstName, assetManager.getData(AssetClassID.FORM_SHOP_CUSTOMER_CHAT, AssetLibID.AST_SHOP_MGT_FORM), null, _commVOList) 
					);
					
					/*if (name == ChatEvent.RECEIVE_SHOP_MESSAGE)
					{
						setRemoteData(ResultVO(vo).service, vo);
					}*/
					
				//}
				//else
				//{
					//echo('initAsset : no matched name type found : ' + name);
				//}
			}
			else
			{
				echo('initAsset : unknow data type : ' + inAsset);
			}
		}
		
		/*private function getAssetIDByCommType(inID:String):String
		{
			switch(inID)
			{
				case ShopMgtEvent.CUSTOMER_CHAT: return AssetClassID.FORM_SHOP_CUSTOMER_CHAT;
			}
			
			return null;
		}*/
		
		
		/* INTERFACE org.puremvc.as3.multicore.interfaces.IRemoteDataProxy */
		
		public function getRemoteData(inService:String, inData:Object = null):Boolean
		{
			var requestData:Object;
			var userInfo:UserInfoVO = voManager.getAsset(VOID.MY_USER_INFO);
			
			if (userInfo && userInfo.isLogged && _commVOList)
			{
				if (inService == FMSServicesType.SEND_SHOP_CHAT_MESSAGE)
				{
					var commVO:CommVO = _commVOList.getVO(_commVOList.length - 1) as CommVO;
					
					if (commVO)
					{
						var message:String = commVO.data.toString();
						
						if (message)
						{
							//case 1: user to shop, "to" value will be shop id (uid == s_id)
							//case 2: shop to user, "to" value will be UID
							requestData = CommVOService.getShopToUserDataObj(_commVOList.id, message);
						}
						else
						{
							echo('unable to retrieve message data object');
							return false;
						}
						
					}
					else
					{
						echo('unable to retrieve commVO data object');
						return false;
					}
					
				}
				/*else if (inService == AMFShopManagementServicesType.UPDATE_ABOUT)
				{
					requestData = { a_user_id:userInfo.uid, a_about:_shopInfoVO.about, a_title:_shopInfoVO.aboutTitle };
				}*/
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
			
			fms.call(inService, requestData);
			return true;
		}
		
		public function setRemoteData(inService:String, inData:Object):Boolean
		{
			var result:ResultVO = inData as ResultVO;
			if (result && result.service == FMSServicesType.RECEIVE_SHOP_CHAT_MESSAGE)
			{
				if ( CommVOService.isVaildChatDataObj(result.result) )
				{
					
					//message from shop
					//no check needed, as received message will only be sent by user (customer)
					//if ( CommVOService.isChatDataObjByShop(result.result) )
					//{
						//check whether the message receive from shop is matched with the walkedInShop vo id 
						//var walkedInShopInfo:ShopInfoVO = fmsShop.walkedInShopInfo;
						
						//var fromUID:String = CommVOService.getFromUIDByFMSDataObj(result.result);
						//var fromID:String = CommVOService.getFromIDByFMSDataObj(result.result); //fms id
						
						//if (fromUID && fromID && walkedInShopInfo && walkedInShopInfo.uid == fromUID)
						//{
							_commVOList = _voService.setCommInfo(result) as CommVOList;
							
							if (_commVOList)
							{
								sendNotification
								(
									NotificationType.RECEIVE_CUSTOMER_CHAT_MESSAGE, 
									_commVOList
								);
								
								return true;
							}
							
							echo('setRemoteData : unable to set vo');
							
						//}
						//else
						//{
							//echo('setRemoteData : walkedInShopInfo uid doesnt matched with from id');
						//}
						
					//}
					//messsage from user
					//else
					//{
						//
						//return true;
					//}
				}
				else
				{
					echo('setRemoteData : unknown chat message data : ' + result.result);
				}
				
			}
			
			
			return false;
		}
		
	}
}