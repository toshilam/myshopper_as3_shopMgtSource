package myShopper.shopMgtModule.appForm.model
{
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.service.ShopperVOService;
	import myShopper.common.data.shop.ShopInfoList;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.AMFServicesErrorID;
	import myShopper.common.emun.VOID;
	import myShopper.common.interfaces.ICommServiceRequest;
	import myShopper.shopMgtCommon.data.service.ShopVOService;
	import myShopper.shopMgtCommon.emun.AMFShopManagementServicesType;
	import myShopper.shopMgtCommon.emun.AssetID;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.emun.CommunicationType;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtCommon.ShopMgtShopInfoVO;
	import myShopper.shopMgtModule.appForm.enum.AssetClassID;
	import myShopper.shopMgtModule.appForm.enum.MediatorID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationRemoteProxy;
	
	public class ShopProfileFormProxy extends ApplicationRemoteProxy//ApplicationProxy implements IRemoteDataProxy
	{
		/*private var _amf:AMFRemoteProxy;
		private function get amf():AMFRemoteProxy
		{
			if (!_amf) _amf = facade.retrieveProxy(ProxyID.AMF) as AMFRemoteProxy;
			return _amf;
		}*/
		
		private var _asset:AssetProxy;
		private function get asset():AssetProxy
		{
			if (!_asset) _asset = facade.retrieveProxy(ProxyID.ASSET) as AssetProxy;
			return _asset;
		}
		
		private var _comm:CommunicationProxy;
		private function get comm():CommunicationProxy
		{
			if (!_comm) _comm = facade.retrieveProxy(ProxyID.COMM) as CommunicationProxy;
			return _comm;
		}
		
		public function ShopProfileFormProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		private var _voService:ShopVOService;
		private var _branchList:ShopInfoList;
		private var _shopInfoVO:ShopMgtShopInfoVO;
		private var _targetNode:XML;
		
		override public function onRegister():void
		{
			super.onRegister();
			
			_branchList = voManager.getAsset(VOID.BRANCH_INFO);
			var xml:XML = xmlManager.getAsset(AssetLibID.XML_SHOP_MGT);
			
			
			if (!_branchList || !xml)
			{
				echo('onRegister : unable to get shop info vo/xml');
				throw(new UninitializedError('onRegister : unable to get shop info vo/xml'));
			}
			
			//_voService = new ShopVOService(_shopInfoVO);
			
			var windowNode:XML = xml..windowElements[0]
			_targetNode = windowNode.*.(@id == AssetID.BTN_SHOP_PROFILE)[0];
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			
			_branchList = null;
			_shopInfoVO = null;
			_comm = null;
			_asset = null;
			//_amf = null;
			_targetNode = null;
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			if (inAsset is INotification)
			{
				var note:INotification = inAsset as INotification;
				var classID:String = AssetClassID.FORM_SHOP_PROFILE;
				
				
				var type:String = note.getType().toString();
						
				if (type == ShopMgtEvent.SHOP_CREATE_PROFILE)
				{
					_shopInfoVO = new ShopMgtShopInfoVO('-1');
					//get head shop info for setting default
					var _vo:ShopInfoVO = voManager.getAsset(VOID.MY_SHOP_INFO);
					if (_vo)
					{
						//no need to set phone and address for branch
						//_vo.phone = txtPhone.text;
						//_vo.address = txtAddress.text;
						_shopInfoVO.uid = _vo.uid;
						_shopInfoVO.name = _vo.name;
						
						_shopInfoVO.intro = _vo.intro;
						_shopInfoVO.productType = _vo.productType;
						//_shopInfoVO.productTypeList = _vo.productTypeList.clone();
						//reference product vo from head shop
						for (var i:int = 0; i < _vo.productTypeList.length; i++)
						{
							_shopInfoVO.productTypeList.addVO( _vo.productTypeList.getVO(i) );
						}
						
						//all shop's paypal info will be based on head shop
						_shopInfoVO.payPalEmail = _vo.payPalEmail;
						_shopInfoVO.payPalFirstName = _vo.payPalFirstName;
						_shopInfoVO.payPalLastName = _vo.payPalLastName;
						_shopInfoVO.paypalAccVerified = _vo.paypalAccVerified;
						
						//set info approve to true, avoid mediator window title, and will be set to false once info saved to DB
						_shopInfoVO.infoApproved = true;
						
						//activate status to be check on server side
						//_shopInfoVO.activated = _vo.activated;
					}
				}
				else if (type == ShopMgtEvent.SHOP_UPDATE_PROFILE)
				{
					_shopInfoVO = note.getBody() as ShopMgtShopInfoVO;
					
					getRemoteData(AMFShopManagementServicesType.IS_SHOP_INFO_APPROVED);
				}
				else
				{
					echo('initAsset : unknown notification type : ' + type);
					return;
				}
				
				if (_shopInfoVO)
				{
					_voService = new ShopVOService(_shopInfoVO);
					
					//to send a direct notification to a mediator, as may same type of mediator has created
					sendNotificationToMediator
					(
						type == ShopMgtEvent.SHOP_CREATE_PROFILE ? MediatorID.SHOP_MGT_PROFILE_CREATE : MediatorID.SHOP_MGT_PROFILE_UPDATE,
						NotificationType.ADD_FORM_SHOP_PROFILE, 
						new DisplayObjectVO(classID, assetManager.getData(classID, AssetLibID.AST_SHOP_MGT_FORM), _targetNode, _shopInfoVO) 
					);
				}
				else
				{
					echo('initAsset : unable to get user login vo');
				}
			}
		}
		
		/*private function getAssetIDByCommType(inID:String):String
		{
			switch(inID)
			{
				case CommunicationType.SHOP_MGT_PROFILE: return AssetClassID.FORM_SHOP_PROFILE;
			}
			
			return null;
		}*/
		
		
		/* INTERFACE org.puremvc.as3.multicore.interfaces.IRemoteDataProxy */
		
		override public function getRemoteData(inService:String, inData:Object = null):Boolean
		{
			var requestData:Object;
			
			if 
			(
				inService == AMFShopManagementServicesType.UPDATE_INFO ||
				inService == AMFShopManagementServicesType.CREATE_INFO
			)
			{
				var userInfo:UserInfoVO = voManager.getAsset(VOID.MY_USER_INFO);
				
				if (userInfo && userInfo.isLogged && _shopInfoVO)
				{
					requestData = 	{
										s_user_id:_shopInfoVO.uid,
										s_shop_no:_shopInfoVO.shopNo,
										s_name:_shopInfoVO.name,
										//s_paypal_email:_shopInfoVO.payPalEmail,
										s_phone:_shopInfoVO.phone,
										//s_product_type:_shopInfoVO.productType,
										s_product_type:ShopperVOService.getCategoryNoArrayBySelectedShopperCategory(_shopInfoVO.productTypeList),
										s_intro:_shopInfoVO.intro,
										//s_room:_shopInfoVO.room,
										//s_street:_shopInfoVO.street,
										//s_house:_shopInfoVO.house,
										s_address:_shopInfoVO.address,
										
										//CHANGED : 26/03/2014 / always set in HK for state, city, area
										//s_area_no:_shopInfoVO.area,
										s_area_no:'34',
										s_country:_shopInfoVO.country,
										s_state:'hong-kong',
										s_city:'hong-kong'
									}
									
					if (inService == AMFShopManagementServicesType.CREATE_INFO)
					{
						requestData.s_paypal_email = _shopInfoVO.payPalEmail;
						requestData.s_paypal_first_name = _shopInfoVO.payPalFirstName;
						requestData.s_paypal_last_name = _shopInfoVO.payPalLastName;
						requestData.s_paypal_verified = _shopInfoVO.paypalAccVerified;
					}
				}
				else
				{
					echo('getRemoteData : unable to get user/shop vo');
				}
			}
			else if (inService == AMFShopManagementServicesType.IS_SHOP_INFO_APPROVED)
			{
				if (_shopInfoVO)
				{
					requestData = 	{
										s_user_id:_shopInfoVO.uid,
										s_shop_no:_shopInfoVO.shopNo
									}
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
			var resultVO:ResultVO = inData as ResultVO;
			
			if (!resultVO || resultVO.code != AMFServicesErrorID.NONE)
			{
				sendNotification(inService == AMFShopManagementServicesType.UPDATE_INFO ? NotificationType.UPDATE_PROFILE_FAIL : NotificationType.CREATE_PROFILE_FAIL, resultVO);
				return false;
			}
			
			if 
			(
				inService == AMFShopManagementServicesType.UPDATE_INFO ||
				inService == AMFShopManagementServicesType.CREATE_INFO
			)
			{
				//once info change set approved to false;
				_shopInfoVO.infoApproved = false;
				
				//add newly create shop info to branch list
				if (inService == AMFShopManagementServicesType.CREATE_INFO)
				{
					_shopInfoVO.shopNo = resultVO.result ? resultVO.result['s_no'] : 'error';
					_branchList.addVO(_shopInfoVO);
				}
				
				sendNotification(inService == AMFShopManagementServicesType.UPDATE_INFO ? NotificationType.UPDATE_PROFILE_SUCCESS : NotificationType.CREATE_PROFILE_SUCCESS, asset.getAllShopInfo());
				//comm.request(CommunicationType.USER_LOGIN_SUCCESS); // notify other module
				return true;
				
			}
			else if (inService == AMFShopManagementServicesType.IS_SHOP_INFO_APPROVED)
			{
				
				_voService.setIsShopInfoApproved(resultVO.result);
				//no need to send notification, as mediator itself listening to the vo change event
				//sendNotification(NotificationType.UPDATE_PROFILE_SUCCESS);
				return true;
				
			}
			return false;
		}
		
	}
}