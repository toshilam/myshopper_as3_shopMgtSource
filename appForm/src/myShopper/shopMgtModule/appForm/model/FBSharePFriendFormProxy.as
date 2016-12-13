package myShopper.shopMgtModule.appForm.model
{
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.facebook.FbFriendList;
	import myShopper.common.data.facebook.FbFriendVO;
	import myShopper.common.data.facebook.FbShareProductVO;
	import myShopper.common.data.service.ImageVOService;
	import myShopper.common.data.service.ShopVOService;
	import myShopper.common.data.shop.ShopProductFormVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.CommunicationType;
	import myShopper.common.emun.FacebookServicesType;
	import myShopper.common.emun.FileType;
	import myShopper.common.emun.VOID;
	import myShopper.common.interfaces.IFacebookResponder;
	import myShopper.common.net.FacebookResponder;
	import myShopper.common.utils.Tools;
	import myShopper.shopMgtCommon.emun.AMFShopManagementServicesType;
	import myShopper.shopMgtModule.appForm.enum.AssetClassID;
	import myShopper.shopMgtModule.appForm.enum.MediatorID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationFBProxy;
	
	public class FBSharePFriendFormProxy extends ApplicationFBProxy implements IRemoteDataProxy, IFacebookResponder
	{
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
		
		//private var _voService:UserVOService;
		private var _myUserInfo:UserInfoVO;
		private var _productShareFriendVO:FbShareProductVO;
		//private var _service:FacebookService;
		//private var _comm:ICommServiceRequest;
		
		public function FBSharePFriendFormProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		
		
		override public function onRegister():void
		{
			super.onRegister();
			_myUserInfo = voManager.getAsset(VOID.MY_USER_INFO);
			//_service = serviceManager.getAsset(ServiceID.FACEBOOK);
			
			if ( !(_myUserInfo is UserInfoVO) /*|| !_service*/)
			{
				throw(new UninitializedError('onRegister : unable to get data/service'));
			}
			
			_productShareFriendVO = new FbShareProductVO('');
			
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			
			//_sendFriendVO.clear();
			//_sendFriendVO = null;
			_myUserInfo = null;
			_productShareFriendVO.clear();
			_productShareFriendVO = null;
			//_service = null;
			//_comm = null;
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			if (inAsset is INotification)
			{
				//no check needed, as should have checked by command
				//isConnected(true);
				
				var note:INotification = inAsset as INotification;
				
				var classID:String = AssetClassID.FORM_FB_SHARE_PRODUCT;
				var productVO:ShopProductFormVO = note.getBody() as ShopProductFormVO;
				
				//if (classID)
				//{
					if (productVO)
					{
						//clone a new fb user data object, NOT to directly use the one store myUserInfo vo, as data may shared among object
						_productShareFriendVO.product = productVO;
						_productShareFriendVO.fdList = _myUserInfo.fbFriendList.clone() as FbFriendList;
						
						sendNotification(NotificationType.ADD_FORM_FB_SHARE_P_FRIEND, new DisplayObjectVO(classID, assetManager.getData(classID, AssetLibID.AST_FORM), null, _productShareFriendVO) );
						
					}
					else
					{
						echo('initAsset : unable to get vo');
					}
					
				//}
				//else
				//{
					//echo('initAsset : unknow page id : ' + String(note.getBody()));
				//}
			}
		}
		
		
		/*private function getAssetIDByType(inID:String):String
		{
			switch(inID)
			{
				case AssetID.BTN_FORGOT_PASSWORD: return AssetClassID.FORM_USER_FORGOT_PASSWORD;
			}
			
			return null;
		}*/
		
		
		/* INTERFACE org.puremvc.as3.multicore.interfaces.IRemoteDataProxy */
		
		public function getRemoteData(inService:String, inData:Object = null):Boolean
		{
			var requestData:Object;
			
			if (inService == FacebookServicesType.ADD_ME_FEED)
			{
				//_userLoginVO = voManager.getAsset(VOID.USER_LOGIN);
				if (!isConnected())
				{
					sendNotification(NotificationType.FB_SHARE_P_FRIEND_FAIL);
					return false;
				}
				
				if (_productShareFriendVO === inData)
				{
					var pVO:ShopProductFormVO = _productShareFriendVO.product;
					var shopNo:String = ShopVOService.getShopNoByProductPageID(pVO.productURL); //sp-xxxxxx
					var message:String = Tools.trimSpace(_productShareFriendVO.message);
					
					requestData = new Object();
					requestData.name = pVO.productName; 
					requestData.caption = pVO.productCategoryName;
					requestData.link = encodeURI( ShopVOService.getProductPageURL(httpHost, shopNo, pVO.productCategoryName, pVO.productID) ); 
					requestData.picture = ImageVOService.getImageURL(httpHost, shopNo, FileType.PATH_SHOP_PRODUCT, [pVO.productNo]);
					requestData.description = pVO.productDescription + (message.length ? "\n\n : " + _productShareFriendVO.message : ''); 
					
					//post to my feed picture = "http://prerelease.my-shopper.com/sp-000020/shop/product/26.img"
					call(FacebookServicesType.ADD_ME_FEED, requestData);
					
					//post to fd's feed
					var numItem:int = _productShareFriendVO.fdList.length;
					for (var i:int = 0; i < numItem; i++)
					{
						var fbVO:FbFriendVO = _productShareFriendVO.fdList.getVO(i) as FbFriendVO;
						if (fbVO.isSelected)
						{
							requestData.id = fbVO.id;
							
							//no handle need for fd feed request, create new FB responder
							call(FacebookServicesType.ADD_FD_FEED, requestData, new FacebookResponder());
						}
					}
					
				}
				else
				{
					sendNotification(NotificationType.FB_SHARE_P_FRIEND_FAIL);
					echo('getRemoteData : unable to get vo');
					return false;
				}
			}
			else if (inService == AMFShopManagementServicesType.CREATE_PRODUCT_FBID)
			{
				if (_productShareFriendVO && inData && inData['id'])
				{
					_productShareFriendVO.product.productFBID = inData['id'];
					
					requestData =	{
										f_product_no:_productShareFriendVO.product.productNo,
										f_fb_id:_productShareFriendVO.product.productFBID
									}
					
				}
				else
				{
					echo('getRemoteData : unknown data type!');
					return false;
				}
			}
			else
			{
				sendNotification(NotificationType.FB_SHARE_P_FRIEND_FAIL);
				echo('getRemoteData : : unknown service type ' + inService, this, 0xff0000);
				return false;
			}
			
			amf.call(inService, requestData);
			return true;
		}
		
		public function setRemoteData(inService:String, inData:Object):Boolean
		{
			if (inService == AMFShopManagementServicesType.CREATE_PRODUCT_FBID)
			{
				var resultVO:ResultVO = inData as ResultVO;
				
				if ( resultVO.result === true )
				{
					//nothing need to be handled
					return true;
				}
				else
				{
					echo('setRemoteData : fail add fb id : ' + resultVO.result );
				}
				
			}
			
			return false;
		}
		
		/*override public function fbResult(inData:Object, inFault:Object):Boolean 
		{
			if(super.fbResult(inData, inFault))
			{
				
				return true;
			}
			
			//error to be handled by parent
			return false;
		}*/
		
		override public function result(data:Object):void 
		{
			if (getRemoteData(AMFShopManagementServicesType.CREATE_PRODUCT_FBID, data))
			{
				sendNotificationToMediator(MediatorID.FB_SHARE_PRODUCT, NotificationType.FB_SHARE_P_FRIEND_SUCCESS);
			}
			else
			{
				sendNotificationToMediator(MediatorID.FB_SHARE_PRODUCT, NotificationType.FB_SHARE_P_FRIEND_FAIL);
			}
		}
		
		override public function fault(info:Object):void 
		{
			super.fault(info);
			//assume all error caused by permission
			comm.request(CommunicationType.FB_REQUEST_PERMISSION);
			
			sendNotificationToMediator(MediatorID.FB_SHARE_PRODUCT, NotificationType.FB_NO_PERMISSION);
		}
		
	}
}