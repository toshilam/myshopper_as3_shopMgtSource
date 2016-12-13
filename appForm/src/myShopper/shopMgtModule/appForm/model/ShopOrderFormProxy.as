package myShopper.shopMgtModule.appForm.model
{
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.AlerterVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.shop.ShopInfoList;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.shop.ShopOrderExtraVO;
	import myShopper.common.data.shop.ShopOrderVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.AMFServicesErrorID;
	import myShopper.common.emun.MessageID;
	import myShopper.common.emun.OrderStatusID;
	import myShopper.common.emun.VOID;
	import myShopper.common.interfaces.ICommServiceRequest;
	import myShopper.common.utils.Alert;
	import myShopper.common.data.service.ShopVOService;
	import myShopper.shopMgtCommon.data.service.ShopVOService;
	import myShopper.shopMgtCommon.emun.AMFShopManagementServicesType;
	import myShopper.shopMgtCommon.emun.AssetID;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.emun.CommunicationType;
	import myShopper.shopMgtCommon.ShopMgtShopInfoVO;
	import myShopper.shopMgtModule.appForm.enum.MediatorID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.observer.Notification;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationRemoteProxy;
	
	public class ShopOrderFormProxy extends ApplicationRemoteProxy //ApplicationProxy implements IRemoteDataProxy
	{
		/*private var _amf:AMFRemoteProxy;
		private function get amf():AMFRemoteProxy
		{
			if (!_amf) _amf = facade.retrieveProxy(ProxyID.AMF) as AMFRemoteProxy;
			return _amf;
		}*/
		
		private var _comm:CommunicationProxy;
		private function get comm():CommunicationProxy
		{
			if (!_comm) _comm = facade.retrieveProxy(ProxyID.COMM) as CommunicationProxy;
			return _comm;
		}
		
		public function ShopOrderFormProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		//private var _voService:UserVOService;
		private var _shopInfoVO:ShopMgtShopInfoVO;
		private var _targetNode:XML;
		private var _shopVOService:myShopper.shopMgtCommon.data.service.ShopVOService;
		private var _selectedOrderVO:ShopOrderVO;
		
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
			
			_shopVOService = new myShopper.shopMgtCommon.data.service.ShopVOService(_shopInfoVO);
			
			var windowNode:XML = xml..windowElements[0];
			_targetNode = windowNode.*.(@id == AssetID.SHOP_ORDER_DETAIL)[0];
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			
			_shopInfoVO = null;
			_selectedOrderVO = null;
			_shopVOService.clear();
			_shopVOService = null;
			//_amf = null;
			_targetNode = null;
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			if (inAsset is Notification)
			{
				//var classID:String = getAssetIDByCommType(ICommServiceRequest(inAsset).communicationType);
				var classID:String = _targetNode.@Class.toString();
				_selectedOrderVO = Notification(inAsset).getBody() as ShopOrderVO;
				
				if (classID && _selectedOrderVO)
				{
					sendNotification
					(
						NotificationType.ADD_FORM_SHOP_ORDER, 
						new DisplayObjectVO(classID, assetManager.getData(classID, AssetLibID.AST_COMMON), _targetNode, _selectedOrderVO) 
					);
					
					getRemoteData(AMFShopManagementServicesType.GET_ORDER_PRODUCT, _selectedOrderVO);
					getRemoteData(AMFShopManagementServicesType.GET_ORDER_EXTRA, _selectedOrderVO);
					
				}
				else
				{
					echo('initAsset : unknow page id : ' + Notification(inAsset).getName());
				}
			}
		}
		
		/*private function getAssetIDByCommType(inID:String):String
		{
			switch(inID)
			{
				case CommunicationType.SHOP_MGT_NEWS: return AssetClassID.FORM_SHOP_ABOUT;
			}
			
			return null;
		}*/
		
		
		/* INTERFACE org.puremvc.as3.multicore.interfaces.IRemoteDataProxy */
		
		override public function getRemoteData(inService:String, inData:Object = null):Boolean
		{
			var requestData:Object;
			var userInfo:UserInfoVO = voManager.getAsset(VOID.MY_USER_INFO);
			
			
			if (userInfo && userInfo.isLogged)
			{
				var orderVO:ShopOrderVO = inData as ShopOrderVO;
				
				if (inService == AMFShopManagementServicesType.GET_ORDER_PRODUCT)
				{
					requestData =	{
										o_order_no:orderVO.orderNo,
										o_user_id:userInfo.uid
									};
				}
				else if (inService == AMFShopManagementServicesType.GET_ORDER_EXTRA)
				{
					requestData =	{
										e_order_no:orderVO.orderNo,
										e_user_id:userInfo.uid
									};
				}
				else if (inService == AMFShopManagementServicesType.ADD_ORDER_EXTRA)
				{
					var orderExtraVO:ShopOrderExtraVO = inData as ShopOrderExtraVO;
					if (orderExtraVO /*&& orderExtraVO.id == _selectedOrderVO.id*/)
					{
						//no need to notifiy mediator, as it is listening to vo event
						_selectedOrderVO.extraList.addVO( orderExtraVO );
						return true;
					}
					
					return false;
				}
				else if (inService == AMFShopManagementServicesType.SEND_ORDER_INVOICE)
				{
					requestData =	{
										lang:language,
										o_order_no:orderVO.orderNo,
										o_status:OrderStatusID.ORDER_WAITING_PAYMENT,
										o_shipping_fee:orderVO.shippingFee,
										o_shipping_remark:orderVO.shippingRemark,
										o_user_email:orderVO.email,
										o_user_name:orderVO.userInfoVO.firstName,
										o_shop_name:_shopInfoVO.name,
										o_extra:myShopper.shopMgtCommon.data.service.ShopVOService.getOrderExtraArrayByVO(orderVO.extraList),
										o_final_total:myShopper.common.data.service.ShopVOService.getOrderFinalTotalByOrderVO(orderVO)
										//o_shop_id:userInfo.uid
									};
				}
				else if (inService == AMFShopManagementServicesType.UPDATE_ORDER_SHIPMENT)
				{
					requestData =	{
										o_order_no:orderVO.orderNo,
										o_status:orderVO.status,
										//o_shipping_method:orderVO.shippingMethod,
										o_shipping_remark:orderVO.shippingRemark
										//o_shop_id:userInfo.uid
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
					
					if (inService == AMFShopManagementServicesType.UPDATE_ORDER_SHIPMENT)
					{
						sendNotification(NotificationType.UPDATE_ORDER_SHIPMENT_FAIL, resultVO);
					}
					else if (inService == AMFShopManagementServicesType.SEND_ORDER_INVOICE)
					{
						sendNotification(NotificationType.SEND_ORDER_INVOICE_FAIL, resultVO);
					}
				}
				else
				{
					if (inService == AMFShopManagementServicesType.GET_ORDER_PRODUCT)
					{
						//once data is set, value will be autometically set in display object form
						if ( !_shopVOService.setShopOrderProduct(resultVO.result, _selectedOrderVO) )
						{
							echo('setRemoteData : fail setting data into vo');
						}
						else
						{
							sendNotificationToMediator(MediatorID.SHOP_MGT_ORDER_DETAIL, NotificationType.RESULT_GET_ORDER_PRODUCT);
							
							//notify other module update number of new order
							if (!_selectedOrderVO.isRead)
							{
								_selectedOrderVO.isRead = true;
								comm.request(CommunicationType.SHOP_MGT_UPDATE_NUM_NEW_ORDER);
							}
							
							
						}
					}
					else if (inService == AMFShopManagementServicesType.GET_ORDER_EXTRA)
					{
						//return can be null if no related order extra item
						if ( !myShopper.common.data.service.ShopVOService.setShopOrderExtra(resultVO.result, _selectedOrderVO) )
						{
							echo('setRemoteData : fail setting data into vo');
						}
						else
						{
							sendNotificationToMediator(MediatorID.SHOP_MGT_ORDER_DETAIL, NotificationType.RESULT_GET_ORDER_EXTRA);
						}
					}
					else if (inService == AMFShopManagementServicesType.SEND_ORDER_INVOICE)
					{
						_selectedOrderVO.status = OrderStatusID.ORDER_WAITING_PAYMENT;
						sendNotification(NotificationType.SEND_ORDER_INVOICE_SUCCESS);
					}
					else if (inService == AMFShopManagementServicesType.UPDATE_ORDER_SHIPMENT)
					{
						sendNotification(NotificationType.UPDATE_ORDER_SHIPMENT_SUCCESS);
					}
					
					return true;
				}
				
			}
			
			
			return false;
		}
		
	}
}