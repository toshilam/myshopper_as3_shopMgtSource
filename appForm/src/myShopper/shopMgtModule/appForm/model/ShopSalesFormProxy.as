package myShopper.shopMgtModule.appForm.model
{
	import com.chewtinfoil.utils.DateUtils;
	import flash.net.Responder;
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.service.UserVOService;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.shop.ShopOrderExtraVO;
	import myShopper.common.data.shop.ShopOrderVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.data.VO;
	import myShopper.common.emun.AMFServicesErrorID;
	import myShopper.common.emun.OrderShipmentID;
	import myShopper.common.emun.OrderStatusID;
	import myShopper.common.emun.PrinterType;
	import myShopper.common.emun.RequestType;
	import myShopper.common.emun.ServiceID;
	import myShopper.common.emun.VOID;
	import myShopper.common.interfaces.ICommServiceRequest;
	import myShopper.common.interfaces.IResponder;
	import myShopper.common.interfaces.IVO;
	import myShopper.common.net.LocalDataService;
	import myShopper.common.net.LocalDataServiceRequest;
	import myShopper.common.net.ServiceResponse;
	import myShopper.common.resources.AssetManager;
	import myShopper.common.server.AMFResultFactory;
	import myShopper.common.utils.DateUtil;
	import myShopper.common.utils.Tools;
	import myShopper.shopMgtCommon.data.service.ShopVOService;
	import myShopper.shopMgtCommon.data.ShopMgtSalesVO;
	import myShopper.shopMgtCommon.emun.AMFShopManagementServicesType;
	import myShopper.shopMgtCommon.emun.AssetID;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.ShopMgtShopInfoVO;
	import myShopper.shopMgtModule.appForm.enum.MediatorID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import myShopper.shopMgtModule.appForm.FormMain;
	import myShopper.shopMgtModule.appForm.model.service.PrintVOService;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.observer.Notification;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	
	public class ShopSalesFormProxy extends ApplicationProxy implements IRemoteDataProxy, IResponder
	{
		private var _printer:PrinterProxy;
		private function get printer():PrinterProxy
		{
			if (!_printer) _printer = facade.retrieveProxy(ProxyID.PRINTER) as PrinterProxy;
			return _printer;
		}
		
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
		
		private var _localData:LocalDataProxy;
		private function get localData():LocalDataProxy
		{
			if (!_localData) _localData = facade.retrieveProxy(ProxyID.LOCAL_DATA) as LocalDataProxy;
			return _localData;
		}
		
		public function ShopSalesFormProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		//private var _voService:UserVOService;
		private var _userInfoVO:UserInfoVO;
		private var _shopInfoVO:ShopMgtShopInfoVO;
		private var _targetNode:XML;
		private var _voService:ShopVOService;
		private var _currVO:ShopMgtSalesVO;
		
		//private var _localDataService:LocalDataService;
		//private var _printService:PrintVOService;
		
		override public function onRegister():void
		{
			super.onRegister();
			//_localDataService = serviceManager.getAsset(ServiceID.LOCAL_DATA);
			_shopInfoVO = voManager.getAsset(VOID.MY_SHOP_INFO);
			_userInfoVO = voManager.getAsset(VOID.MY_USER_INFO);
			var xml:XML = xmlManager.getAsset(AssetLibID.XML_SHOP_MGT);
			
			if (!_userInfoVO || !_shopInfoVO || !xml /*|| !_localDataService*/)
			{
				echo('onRegister : unable to get shop info vo/xml');
				throw(new UninitializedError('onRegister : unable to get shop info vo/xml'));
			}
			
			new PrintVOService(assetManager as AssetManager,  (host as FormMain).appForm);
			_voService = new ShopVOService(_shopInfoVO);
			
			var windowNode:XML = xml..windowElements[0];
			_targetNode = windowNode.*.(@id == AssetID.SHOP_SALES_PANEL)[0];
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			
			_userInfoVO = null;
			_shopInfoVO = null;
			_currVO = null;
			_voService.clear();
			_voService = null;
			_amf = null;
			_targetNode = null;
			//_printService.clear();
			//_printService = null;
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			var classID:String = _targetNode.@Class.toString();
			
			//if (inAsset is ICommServiceRequest) //shop sales
			//{
				//var classID:String = getAssetIDByCommType(ICommServiceRequest(inAsset).communicationType);
				
				_currVO = refreshSalesVO(new ShopMgtSalesVO(proxyName));
				
				if(classID)
				{
					sendNotificationToMediator
					(
						MediatorID.SHOP_MGT_SALES,
						NotificationType.ADD_DISPLAY_SALES, 
						new DisplayObjectVO(classID, assetManager.getData(classID, AssetLibID.AST_SHOP_MGT_FORM), _targetNode, _currVO) 
					);
					
					getRemoteData(AMFShopManagementServicesType.GET_CATEGORY_PRODUCT, new VO('', language) );
					
				}
				else
				{
					echo('initAsset : unknow page id : ' + classID);
				}
			//}
			//CHANGED : to be handled by ShopSalesHistoryFormProxy
			/*else if (inAsset is Notification) //view sales history
			{
				var note:Notification = inAsset as Notification;
				
				_currVO = note.getBody() as ShopMgtSalesVO;
				if(classID && _currVO)
				{
					sendNotificationToMediator
					(
						MediatorID.SHOP_MGT_SALES_DETAIL,
						NotificationType.ADD_DISPLAY_SALES, 
						new DisplayObjectVO(classID, assetManager.getData(classID, AssetLibID.AST_SHOP_MGT_FORM), _targetNode, _currVO) 
					);
					
					getRemoteData(AMFShopManagementServicesType.GET_ORDER_PRODUCT, _currVO);
					getRemoteData(AMFShopManagementServicesType.GET_ORDER_EXTRA, _currVO);
					
				}
				else
				{
					throw new Error(multitonKey + ' : ' + proxyName + ' : unable to retrieve data : ' + note.getBody());
				}
			}*/
		}
		
		private function refreshSalesVO(inVO:ShopMgtSalesVO):ShopMgtSalesVO
		{
			//UTC datetime
			//Time to be reset when data to server
			var now:Date = DateUtils.getUTCDate(new Date());
			inVO.clear();
			//incorrect timestamp value?
			//inVO.timestamp = now.getTime();
			inVO.dateTime = DateUtil.dateToString(now, true);
			inVO.invoiceNo = ShopVOService.getSalesInvoiceNo(_shopInfoVO);
			
			return inVO;
		}
		
		private function onSaleCreated(inVO:ShopMgtSalesVO):void
		{
			refreshSalesVO(inVO);
			sendNotificationToMediator(MediatorID.SHOP_MGT_SALES, NotificationType.CREATE_SALES_SUCCESS, inVO);
		}
		
		
		/* INTERFACE org.puremvc.as3.multicore.interfaces.IRemoteDataProxy */
		
		public function getRemoteData(inService:String, inData:Object = null):Boolean
		{
			var requestData:Object;
			//get lang code, if lang code not specified, use system one
			var langCode:String = (inData is IVO && Tools.isLangCode((inData as IVO).selectedLangCode)) ? (inData as IVO).selectedLangCode : language;
			var userInfo:UserInfoVO = voManager.getAsset(VOID.MY_USER_INFO);
			
			if (inService == AMFShopManagementServicesType.GET_CATEGORY_PRODUCT)
			{
				//if no shop found, send error message
				if (_shopInfoVO == null) 
				{
					echo('getRemoteData : get about : shopInfo not found : ');
					//sendNotification(RESULT_FAULT);
					return false;
				}
				
				//if already has data in category list, assume we have already got data from server
				if (_shopInfoVO.productCategoryList.length) 
				{
					sendNotificationToMediator(MediatorID.SHOP_MGT_SALES, NotificationType.RESULT_GET_CATEGORY_PRODUCT);
					//productPageHandler(); //handle page
					return true;
				}
				
				requestData =	{
									c_user_id:_shopInfoVO.uid,
									lang:langCode
								};
			}
			else if (inService == AMFShopManagementServicesType.CREATE_SALES)
			{
				if (_currVO !== inData)
				{
					throw new Error(multitonKey + ' : ' + proxyName + ' : ' + inService + ' : unknown data object!');
				}
				
				
				_currVO.dateTime = DateUtil.dateToString(DateUtils.getUTCDate(new Date()), true);
				
				requestData = 	{
									o_user_id:_currVO.userInfoVO.uid,
									o_email:_currVO.userInfoVO.email, 
									o_address:_currVO.userInfoVO.address,
									o_shop_id:_shopInfoVO.uid,
									o_shop_url_id:_shopInfoVO.shopNo, //{sp-XXXXXX}
									o_currency:_shopInfoVO.currency, //use currency no, NOT code
									o_phone:_currVO.userInfoVO.phone,
									o_status:OrderStatusID.ORDER_RECEIVED, //always received as buy in shop
									o_remark:'',//no user remark for pos
									o_product_list:UserVOService.getCheckOutProductListObj(_currVO.productList, true),
									o_shipping_remark:_currVO.remark, //shop remark
									o_shipping_method:OrderShipmentID.SHOP_SALES, 
									o_shipping_fee:_currVO.shippingFee, 
									o_total:_currVO.total, 
									o_final_total:_currVO.finalTotal, 
									o_extra:myShopper.shopMgtCommon.data.service.ShopVOService.getOrderExtraArrayByVO(_currVO.extraList),
									o_user_paid:_currVO.paid,
									o_pay_type:_currVO.payMethod,
									o_invoice_no:_currVO.invoiceNo,
									o_date_time:_currVO.dateTime,
									//for printing
									o_sub_total:myShopper.common.data.service.ShopVOService.getOrderSubTotalByVO(_currVO.productList),
									o_other_total:myShopper.common.data.service.ShopVOService.getOrderExtraTotalByVO(_currVO.extraList),
									o_change:Number(_currVO.paid) - Number(_currVO.finalTotal)
								}
				
				
				//printing
				//if (!CONFIG::mobile)
				//{
					if (_currVO.withPrint)
					{
						if (_userInfoVO.printerVO.selectedPrinterType == PrinterType.SYSTEM)
						{
							printer.print(_currVO, _currVO.printSize);
							//_printService.order(_currVO, _shopInfoVO, _currVO.printType);
						}
						else
						{
							requestData.withPrint = _userInfoVO.printerVO.selectedPrinterType == PrinterType.CLOUD;
						}
					}
				//}	
				
				
				//before making request, check if any pending request in localData
				//if so, try save on server
				//TODO to implements in localDataProxy, using timer?
				//_localDataService.request(new LocalDataServiceRequest('', RequestType.LOCAL_DATA_GET_ORDERS, null, this))
				
				
				//write data locally in case of fail saving data on server
				if ( !localData.request( new LocalDataServiceRequest(_currVO.invoiceNo, RequestType.LOCAL_DATA_SAVE_ORDER, requestData) ) )
				{
					echo('getRemoteData : if fail saving data in local, wait for remote service reply');
				}
				else
				{
					//directly notify mediator when data stored in local
					//no need to wait for remote service reply
					onSaleCreated(_currVO);
				}
			}
			else if (inService == AMFShopManagementServicesType.ADD_ORDER_EXTRA)
			{
				var orderExtraVO:ShopOrderExtraVO = inData as ShopOrderExtraVO;
				if (orderExtraVO /*&& orderExtraVO.id == _selectedOrderVO.id*/)
				{
					//no need to notifiy mediator, as it is listening to vo event
					_currVO.extraList.addVO( orderExtraVO );
					return true;
				}
				
				return false;
			}
			/*else if (inService == AMFShopManagementServicesType.GET_ORDER_PRODUCT)
			{
				requestData =	{
									o_order_no:_currVO.orderNo,
									o_user_id:userInfo.uid
								};
			}
			else if (inService == AMFShopManagementServicesType.GET_ORDER_EXTRA)
			{
				requestData =	{
									e_order_no:_currVO.orderNo,
									e_user_id:userInfo.uid
								};
			}*/
			else
			{
				echo('getRemoteData : : unknown service type ' + inService, this, 0xff0000);
				return false;
			}
			
			if (inService == AMFShopManagementServicesType.CREATE_SALES)
			{
				amf.directCall(inService, requestData, this);
			}
			else
			{
				amf.call(inService, requestData, this);
			}
			
			return true;
		}
		
		public function setRemoteData(inService:String, inData:Object):Boolean
		{
			var resultVO:ResultVO = inData as ResultVO;
			
			if (resultVO)
			{
				if (inService == AMFShopManagementServicesType.GET_CATEGORY_PRODUCT)
				{
					if ( resultVO.code == AMFServicesErrorID.NONE && _voService.setShopCategory(resultVO.result) )
					{
						sendNotificationToMediator(MediatorID.SHOP_MGT_SALES, NotificationType.RESULT_GET_CATEGORY_PRODUCT);
					}
					else
					{
						echo('setRemoteData : fail getting data from server : ' + inService);
						//retry
						getRemoteData(AMFShopManagementServicesType.GET_CATEGORY_PRODUCT);
						return false;
					}
				}
				else if (inService == AMFShopManagementServicesType.CREATE_SALES)
				{
					var invoiceNo:String = resultVO.result['o_invoice_no'];
					//// CHANGED on 06072014 /////
					//to be handled by localDataProxy
					/*
					
					if ( resultVO.code != AMFServicesErrorID.NONE  )
					{
						//if fail saving sales on server and local, popup
						//else retry later by localDataProxy
						if (!localData.request(new LocalDataServiceRequest(invoiceNo, RequestType.LOCAL_DATA_GET_ORDER_BY_NO)))
						//if (!_localDataService.request(new LocalDataServiceRequest(invoiceNo, RequestType.LOCAL_DATA_GET_ORDER_BY_NO)))
						{
							echo('setRemoteData : fail getting data from server : ' + inService);
							sendNotificationToMediator(MediatorID.SHOP_MGT_SALES, NotificationType.CREATE_SALES_FAIL, _currVO);
							return false;
						}
					}
					else
					{
						//_localDataService.request(new LocalDataServiceRequest(invoiceNo, RequestType.LOCAL_DATA_REMOVE_ORDER))
						localData.request(new LocalDataServiceRequest(invoiceNo, RequestType.LOCAL_DATA_REMOVE_ORDER))
					}*/
					localData.setRemoteData(inService, inData);
					////////////////////////////////
					
					//TODO handle receipt result
					
					//if the returned invoice is not matched with the current invoice no, do nothing
					//or it may notified if data saved in localData
					if (invoiceNo == _currVO.invoiceNo)
					{
						//clear previous record, and reuse it
						//refreshSalesVO(_currVO);
						//sendNotificationToMediator(MediatorID.SHOP_MGT_SALES, NotificationType.CREATE_SALES_SUCCESS, _currVO);
						onSaleCreated(_currVO);
					}
					
					
				}
				/*else if (inService == AMFShopManagementServicesType.GET_ORDER_PRODUCT)
				{
					//once data is set, value will be autometically set in display object form
					if ( !_voService.setShopOrderProduct(resultVO.result, _currVO) )
					{
						echo('setRemoteData : fail setting data into vo');
					}
					else
					{
						sendNotificationToMediator(MediatorID.SHOP_MGT_SALES_DETAIL, NotificationType.RESULT_GET_SALES_PRODUCT);
					}
				}
				else if (inService == AMFShopManagementServicesType.GET_ORDER_EXTRA)
				{
					//return can be null if no related order extra item
					if ( !myShopper.common.data.service.ShopVOService.setShopOrderExtra(resultVO.result, _currVO) )
					{
						echo('setRemoteData : fail setting data into vo');
					}
					else
					{
						sendNotificationToMediator(MediatorID.SHOP_MGT_SALES_DETAIL, NotificationType.RESULT_GET_SALES_EXTRA);
					}
				}*/
			}
			
			return true;
		}
		
		/* INTERFACE myShopper.common.interfaces.IResponder */
		
		public function result(inData:Object):void 
		{
			
			/*var response:ServiceResponse = inData as ServiceResponse;
			if (response)
			{
				if (response.request.type == RequestType.LOCAL_DATA_GET_ORDERS && response.data)
				{
					var orderList:Object = response.data;
					
					for (var i:String in orderList)
					{
						var targetOrder:Object = orderList[i];
						if (targetOrder)
						{
							amf.call(AMFShopManagementServicesType.CREATE_SALES, targetOrder, this);
						}
					}
				}
				
			}*/
			
			var result:ResultVO = (!(inData is ResultVO)) ? AMFResultFactory.convert(inData) : inData as ResultVO;
				
			if (result)
			{
				if (result.service == AMFShopManagementServicesType.CREATE_SALES)
				{
					setRemoteData(result.service, result);
				}
			}
		}
		
		public function fault(info:Object):void 
		{
			echo('fault : ' + info);
			//do nothing for fail calling createSales, as LocalDataProxy will retry later
		}
		
	}
}