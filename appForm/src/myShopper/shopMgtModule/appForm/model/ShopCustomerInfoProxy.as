package myShopper.shopMgtModule.appForm.model
{
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.shop.ShopCategoryFormVO;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.shop.ShopProductFormVO;
	import myShopper.common.emun.AMFServicesErrorID;
	import myShopper.common.emun.VOID;
	import myShopper.common.interfaces.ICommServiceRequest;
	import myShopper.common.interfaces.IVO;
	import myShopper.shopMgtCommon.data.service.ShopMgtUserVOService;
	import myShopper.shopMgtCommon.data.ShopMgtUserInfoVO;
	import myShopper.shopMgtCommon.emun.AMFShopManagementServicesType;
	import myShopper.shopMgtCommon.emun.AssetID;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.emun.CommunicationType;
	import myShopper.shopMgtModule.appForm.enum.AssetClassID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	
	public class ShopCustomerInfoProxy extends ApplicationProxy implements IRemoteDataProxy
	{
		
		private var _amf:AMFRemoteProxy;
		private function get amf():AMFRemoteProxy
		{
			if (!_amf) _amf = facade.retrieveProxy(ProxyID.AMF) as AMFRemoteProxy;
			return _amf;
		}
		
		
		private var _customerInfoVO:ShopMgtUserInfoVO;
		private var _targetNode:XML;
		//private var _voService:ShopVOService;
		//private var _userVOService:ShopMgtUserVOService;
		
		
		public function ShopCustomerInfoProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		
		override public function onRegister():void
		{
			super.onRegister();
			
			//_shopInfoVO = voManager.getAsset(VOID.MY_SHOP_INFO);
			var xml:XML = xmlManager.getAsset(AssetLibID.XML_SHOP_MGT);
			
			if (!xml)
			{
				echo('onRegister : unable to get shop info vo/xml');
				throw(new UninitializedError('onRegister : unable to get shop info vo/xml'));
			}
			//
			//_voService = new ShopVOService(_shopInfoVO);
			//
			var windowNode:XML = xml..windowElements[0]
			_targetNode = windowNode.*.(@id == AssetID.SHOP_CUSTOMER_INFO)[0];
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			_amf = null;
			//_shopInfoVO = null;
			_targetNode = null;
			//_voService = null;
			
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			if (inAsset is ICommServiceRequest)
			{
				var commRequest:ICommServiceRequest = inAsset as ICommServiceRequest;
				
				var classID:String = getAssetIDByCommType(commRequest.communicationType);
				//var classID:String = _targetNode.@Class.toString();
				if (classID)
				{
					_customerInfoVO = commRequest.data as ShopMgtUserInfoVO;
					
					if (_customerInfoVO)
					{
						//send a direct notification to a related mediator 
						sendNotificationToMediator
						(
							proxyName, //using proxy name, as the targeted mediator has the same name
							NotificationType.ADD_FORM_SHOP_CUSTOMER_INFO, 
							new DisplayObjectVO(classID, assetManager.getData(classID, AssetLibID.AST_SHOP_MGT), _targetNode, _customerInfoVO) 
						);
						
						getRemoteData(AMFShopManagementServicesType.GET_CUSTOMER_INFO_BY_UID);
					}
					else
					{
						echo('initAsset : unable to retrieve vo data');
					}
					
				}
				else
				{
					echo('initAsset : unknow page id : ' + ICommServiceRequest(inAsset).communicationType);
				}
			}
		}
		
		private function getAssetIDByCommType(inID:String):String
		{
			switch(inID)
			{
				case CommunicationType.SHOP_MGT_CUSTOMER_INFO: return AssetClassID.FORM_SHOP_CUSTOMER_INFO;
			}
			
			return null;
		}
		
		public function getRemoteData(inService:String, inData:Object = null):Boolean
		{
			var requestData:Object;
			
			if (inService == AMFShopManagementServicesType.GET_CUSTOMER_INFO_BY_UID)
			{
				//if no shop found, send error message
				if (_customerInfoVO == null) 
				{
					echo('getRemoteData : get customer info : vo not found : ');
					//sendNotification(RESULT_FAULT);
					return false;
				}
				
				//if already has data in category list, assume we have already got data from server
				/*if (_customerInfoVO.productCategoryList.length) 
				{
					sendNotification(NotificationType.RESULT_GET_CATEGORY_PRODUCT);
					//productPageHandler(); //handle page
					return true;
				}*/
				
				requestData = { s_user_id:_customerInfoVO.uid };
			}
			else
			{
				echo('getRemoteData : : unknown service type ' + inService, this, 0xff0000);
				return false;
			}
			
			amf.call(inService, requestData);
			return true;
		}
		
		public function setRemoteData(inService:String, inData:Object):Boolean
		{
			var resultVO:ResultVO = inData as ResultVO;
			
			if (resultVO)
			{
				//to be handled asset proxy / as to be sure data is to be set
				/*if (inService == AMFShopManagementServicesType.GET_CUSTOMER_INFO_BY_UID)
				{
					if ( resultVO.code != AMFServicesErrorID.NONE || !_userVOService.setUserInfo(resultVO.result) )
					{
						echo('setRemoteData : fail getting data from server');
						
						sendNotification(NotificationType.GET_CUSTOMER_INFO_FAIL, resultVO);
						
						return false;
					}
					else
					{
						sendNotification(NotificationType.GET_CUSTOMER_INFO_SUCCESS);
					}
					
					
					return true;
				}*/
				
			}
			
			return false;
		}
		
		
		
	}
}