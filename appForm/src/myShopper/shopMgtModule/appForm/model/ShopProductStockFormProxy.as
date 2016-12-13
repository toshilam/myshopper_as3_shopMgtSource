package myShopper.shopMgtModule.appForm.model
{
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.shop.ShopProductFormVO;
	import myShopper.common.data.shop.ShopProductStockVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.AMFServicesErrorID;
	import myShopper.common.emun.VOID;
	import myShopper.shopMgtCommon.data.service.ShopVOService;
	import myShopper.shopMgtCommon.data.ShopMgtStockVO;
	import myShopper.shopMgtCommon.emun.AMFShopManagementServicesType;
	import myShopper.shopMgtCommon.emun.AssetID;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.ShopMgtShopInfoVO;
	import myShopper.shopMgtModule.appForm.enum.MediatorID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.observer.Notification;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationRemoteProxy;
	
	public class ShopProductStockFormProxy extends ApplicationRemoteProxy// ApplicationProxy implements IRemoteDataProxy
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
		
		public function ShopProductStockFormProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		//private var _voService:UserVOService;
		private var _shopInfoVO:ShopMgtShopInfoVO;
		private var _stockVO:ShopMgtStockVO;
		private var _productVO:ShopProductFormVO;
		private var _targetNode:XML;
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
			_targetNode = windowNode.*.(@id == AssetID.BTN_SHOP_PRODUCT_STOCK)[0];
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			
			_shopInfoVO = null;
			_comm = null;
			//_amf = null;
			_targetNode = null;
			_shopVOService.clear();
			_shopVOService = null;
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			if (inAsset is Notification)
			{
				var note:Notification = inAsset as Notification;
				
				var classID:String = _targetNode.@Class.toString();//getAssetIDByCommType(String(note.getType()));
				_productVO = note.getBody() as ShopProductFormVO;
				
				if (classID && _productVO)
				{
					_stockVO = new ShopMgtStockVO(proxyName);
					_stockVO.productID = _productVO.productID;
					_stockVO.productName = _productVO.productName;
					_stockVO.productNo = _productVO.productNo;
					
					if(classID)
					{
						sendNotificationToMediator
						(
							MediatorID.SHOP_MGT_PRODUCT_STOCK,
							NotificationType.ADD_DISPLAY_PRODUCT_STOCK, 
							new DisplayObjectVO(classID, assetManager.getData(classID, AssetLibID.AST_SHOP_MGT_FORM), _targetNode, _stockVO) 
						);
						
						//getRemoteData(AMFShopManagementServicesType.GET_CATEGORY_PRODUCT, new VO('', language) );
						
					}
					else
					{
						echo('initAsset : unknow page id : ' + classID);
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
			
			if (userInfo && userInfo.isLogged && _shopInfoVO)
			{
				if (inService == AMFShopManagementServicesType.CREATE_PRODUCT_STOCK)
				{
					requestData = 	{ 
										s_user_id:userInfo.uid,
										s_product_no:_stockVO.productNo,
										s_id:_stockVO.stockID,
										s_stock:_stockVO.numStock
									};
					
					
				}
				else if (inService == AMFShopManagementServicesType.DELETE_PRODUCT_STOCK)
				{
					var productStockVO:ShopProductStockVO = inData as ShopProductStockVO;
					if (productStockVO)
					{
						requestData = 	{ 
											s_user_id:userInfo.uid,
											s_no:productStockVO.stockNo,
											s_product_no:productStockVO.productNo
										};
					}
					else
					{
						echo('getRemoteData : : unknown data ' + inData, this, 0xff0000);
						return false;
					}
					
					
				}
				else if (inService == AMFShopManagementServicesType.GET_PRODUCT_STOCK_HISTORY)
				{
					if (_stockVO === inData)
					{
						requestData = 	{ 
											s_user_id:userInfo.uid,
											s_product_no:_stockVO.productNo,
											s_from_date:_stockVO.searchVO.fromDate + " 00:00:00",
											s_to_date:_stockVO.searchVO.toDate + " 23:59:59"
										}
					}
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
			
			//amf.call(inService, requestData, this);
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
					
					if (inService == AMFShopManagementServicesType.CREATE_PRODUCT_STOCK)
					{
						sendNotification(NotificationType.CREATE_PRODUCT_STOCK_FAIL, resultVO);
					}
					else if (inService == AMFShopManagementServicesType.DELETE_PRODUCT_STOCK)
					{
						sendNotification(NotificationType.DELETE_PRODUCT_STOCK_FAIL, resultVO);
					}
					else if (inService == AMFShopManagementServicesType.GET_PRODUCT_STOCK_HISTORY)
					{
						sendNotification(NotificationType.GET_PRODUCT_STOCK_HISTORY_FAIL, resultVO);
					}
					
					return false;
				}
				else
				{
					if (inService == AMFShopManagementServicesType.CREATE_PRODUCT_STOCK)
					{
						if (_shopVOService.setShopProductStock(resultVO.result, _productVO))
						{
							sendNotification(NotificationType.CREATE_PRODUCT_STOCK_SUCCESS);
						}
						else
						{
							sendNotification(NotificationType.CREATE_PRODUCT_STOCK_FAIL);
						}
					}
					if (inService == AMFShopManagementServicesType.DELETE_PRODUCT_STOCK)
					{
						if (_shopVOService.setDeleteShopProductStock(resultVO.result, _productVO))
						{
							sendNotification(NotificationType.DELETE_PRODUCT_STOCK_SUCCESS);
						}
						else
						{
							sendNotification(NotificationType.DELETE_PRODUCT_STOCK_FAIL);
						}
					}
					else if (inService == AMFShopManagementServicesType.GET_PRODUCT_STOCK_HISTORY)
					{
						if (_shopVOService.setShopProductStockHistory(resultVO.result, _productVO))
						{
							sendNotification(NotificationType.GET_PRODUCT_STOCK_HISTORY_SUCCESS, _productVO);
						}
						else
						{
							sendNotification(NotificationType.GET_PRODUCT_STOCK_HISTORY_FAIL);
						}
					}
					return true;
				}
				
			}
			
			
			return false;
		}
		
	}
}