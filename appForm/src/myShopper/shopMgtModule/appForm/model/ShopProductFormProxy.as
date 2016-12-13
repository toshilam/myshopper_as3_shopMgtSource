package myShopper.shopMgtModule.appForm.model
{
	import myShopper.amf.common.data.ResultVO;
	import myShopper.amf.shop.data.ProductVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.FileImageVO;
	import myShopper.common.data.shop.ShopCategoryFormVO;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.shop.ShopProductFormVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.AMFServicesErrorID;
	import myShopper.common.emun.AMFShopServicesType;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.FileEvent;
	import myShopper.common.utils.Tools;
	import myShopper.shopMgtCommon.data.service.ShopVOService;
	import myShopper.shopMgtCommon.emun.AMFShopManagementServicesType;
	import myShopper.shopMgtCommon.emun.AssetID;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtCommon.ShopMgtShopInfoVO;
	import myShopper.shopMgtModule.appForm.enum.AssetClassID;
	import myShopper.shopMgtModule.appForm.enum.MediatorID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.observer.Notification;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationRemoteProxy;
	
	public class ShopProductFormProxy extends ApplicationRemoteProxy// ApplicationProxy implements IRemoteDataProxy
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
		
		public function ShopProductFormProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		//private var _voService:UserVOService;
		private var _shopInfoVO:ShopMgtShopInfoVO;
		private var _categoryVO:ShopCategoryFormVO;
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
			_targetNode = windowNode.*.(@id == AssetID.BTN_SHOP_CATEGORY_PRODUCT)[0];
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			
			_shopInfoVO = null;
			_comm = null;
			//_amf = null;
			_targetNode = null;
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			if (inAsset is Notification)
			{
				var note:Notification = inAsset as Notification;
				
				var classID:String = getAssetIDByCommType(String(note.getType()));
				if (classID)
				{
					var type:String = note.getType().toString();
					if (_shopInfoVO)
					{
						if (type == ShopMgtEvent.SHOP_CREATE_PRODUCT)
						{
							_categoryVO = note.getBody() as ShopCategoryFormVO;
							if (_categoryVO)
							{
								_productVO = new ShopProductFormVO('-1');
								_productVO.productCategoryName = _categoryVO.categoryName;
								_productVO.productCategoryNo = _categoryVO.categoryNo;
							}
							else
							{
								echo('initAsset : unknown data type : ' + note.getBody());
								return;
							}
						}
						else if (type == ShopMgtEvent.SHOP_UPDATE_PRODUCT)
						{
							_productVO = note.getBody() as ShopProductFormVO;
							
							//download image
							sendNotification(FileEvent.DOWNLOAD, _productVO);
							getRemoteData(AMFShopManagementServicesType.GET_PRODUCT_STOCK);
						}
						else if (type == ShopMgtEvent.SHOP_CLONE_PRODUCT)
						{
							var targetPVO:ShopProductFormVO = note.getBody() as ShopProductFormVO;
							_productVO = targetPVO.clone() as ShopProductFormVO;
							_categoryVO = _shopInfoVO.productCategoryList.getVOByCategoryNo(_productVO.productCategoryNo) as ShopCategoryFormVO;
						}
						else
						{
							echo('initAsset : unknown notification type : ' + type);
							return;
						}
						
						//to send a direct notification to a mediator, as may same type of mediator has created
						sendNotificationToMediator
						(
							getMediatorNameByType(type),
							NotificationType.ADD_FORM_SHOP_PRODUCT, 
							new DisplayObjectVO(classID, assetManager.getData(classID, AssetLibID.AST_SHOP_MGT_FORM), _targetNode, _productVO) 
						);
					}
					else
					{
						echo('initAsset : unable to get shopInfoVO vo');
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
		
		private function getAssetIDByCommType(inID:String):String
		{
			switch(inID)
			{
				case ShopMgtEvent.SHOP_CLONE_PRODUCT: 
				case ShopMgtEvent.SHOP_CREATE_PRODUCT: 
				case ShopMgtEvent.SHOP_UPDATE_PRODUCT: return AssetClassID.FORM_SHOP_PRODUCT;
			}
			
			return null;
		}
		
		private function getMediatorNameByType(inType:String):String
		{
			switch(inType)
			{
				case ShopMgtEvent.SHOP_CREATE_PRODUCT:	return MediatorID.SHOP_MGT_PRODUCT_CREATE;
				case ShopMgtEvent.SHOP_UPDATE_PRODUCT:	return MediatorID.SHOP_MGT_PRODUCT_UPDATE;
				case ShopMgtEvent.SHOP_CLONE_PRODUCT:	return MediatorID.SHOP_MGT_PRODUCT_CREATE;
			}
			
			return '';
		}
		
		
		/* INTERFACE org.puremvc.as3.multicore.interfaces.IRemoteDataProxy */
		
		override public function getRemoteData(inService:String, inData:Object = null):Boolean
		{
			var requestData:Object;
			var userInfo:UserInfoVO = voManager.getAsset(VOID.MY_USER_INFO);
			
			if (userInfo && userInfo.isLogged && _shopInfoVO)
			{
				if 
				(
					inService == AMFShopManagementServicesType.CREATE_PRODUCT ||
					inService == AMFShopManagementServicesType.UPDATE_PRODUCT
				)
				{
					requestData = 	{ 
										lang:_productVO.selectedLangCode,
										p_user_id:userInfo.uid, 
										p_id:_productVO.productID,
										p_name:_productVO.productName,
										p_price:_productVO.productPrice,
										p_currency:_productVO.productCurrency,
										p_description:_productVO.productDescription,
										p_category:_productVO.productCategoryNo,
										p_discount:_productVO.productDiscount,
										p_tax:_productVO.productTax,
										p_unit:_productVO.productUnit,
										p_shopper_category:_productVO.shopperCategoryNo,
										p_shopper_product:_productVO.shopperProductNo,
										p_shopper_product_type:_productVO.shopperProductTypeNo
										
										/*i_name:_productVO.photoFileVO.name,
										i_data:_productVO.photoFileVO.data,
										i_type:_productVO.photoFileVO.type,
										i_size:_productVO.photoFileVO.size,
										i_path:_productVO.photoFileVO.path*/
									};
					
					//NOTE : image data can be null
					//add image data
					var arrPhoto:Array = new Array();
					for (var i:int = 0 ; i < ShopProductFormVO.NUM_PHOTO; i++)
					{
						var iVO:FileImageVO = _productVO.getPhotoVO(i);
						
						if (!iVO.data || !iVO.data.bytesAvailable) continue;
						
						var imageObj:Object = 	{
													i_name:iVO.name,
													i_data:iVO.data,
													i_type:iVO.type,
													i_size:iVO.size,
													i_path:iVO.path
												}
						arrPhoto.push(imageObj);
					}
					
					requestData.p_photo_list = arrPhoto;
					
					
					if (inService == AMFShopManagementServicesType.UPDATE_PRODUCT)
					{
						requestData.p_no = _productVO.productNo;
					}
				}
				//will only be call while updating product (not create product)
				else if (inService == AMFShopManagementServicesType.GET_PRODUCT_BY_NO)
				{
					if (_productVO === inData && _productVO.productNo)
					{
						requestData =	{
											p_no:_productVO.productNo,
											lang:_productVO.selectedLangCode
										}
					}
				}
				else if (inService == AMFShopManagementServicesType.GET_PRODUCT_STOCK)
				{
					if (_productVO)
					{
						requestData =	{
											s_user_id:userInfo.uid,
											s_product_no:_productVO.productNo
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
					
					if 
					(
						inService == AMFShopManagementServicesType.CREATE_PRODUCT ||
						inService == AMFShopManagementServicesType.UPDATE_PRODUCT
					)
					{
						sendNotification
						(
							inService == AMFShopManagementServicesType.CREATE_PRODUCT ? NotificationType.CREATE_PRODUCT_FAIL : NotificationType.UPDATE_PRODUCT_FAIL, 
							resultVO
						);
					}
					else if (inService == AMFShopManagementServicesType.GET_PRODUCT_BY_NO)
					{
						sendNotification(NotificationType.GET_PRODUCT_BY_NO_FAIL, resultVO);
					}
					else if (inService == AMFShopManagementServicesType.GET_PRODUCT_STOCK)
					{
						sendNotification(NotificationType.GET_PRODUCT_STOCK_FAIL, resultVO);
					}
					return false;
				}
				else
				{
					//CHANGED : 28052012 : server not return list of product after update/create product anymore
					/*if
					(
						inService == AMFShopManagementServicesType.CREATE_PRODUCT ||
						inService == AMFShopManagementServicesType.UPDATE_PRODUCT
					)
					{
						
						//if categoryVO not set yet(this is the case for UPDATE_PRODUCT), retrieve from productVO
						if (!_categoryVO)
						{
							_categoryVO = _shopInfoVO.productCategoryList.getVOByCategoryNo(_productVO.productCategoryNo) as ShopCategoryFormVO
						}
						
						//TODO : may need to improve perforance? only update the related item?
						if ( _shopVOService.setShopProduct(resultVO.result as Array, _categoryVO) )
						{
							sendNotification
							(
								inService == AMFShopManagementServicesType.CREATE_PRODUCT ? NotificationType.CREATE_PRODUCT_SUCCESS : NotificationType.UPDATE_PRODUCT_SUCCESS
							);
						}
						else
						{
							echo('setRemoteData : ' + inService + ' : unable to set data!');
						}
					}*/
					if (inService == AMFShopManagementServicesType.CREATE_PRODUCT)
					{
						//category vo should have store while initAsset for CREATE_PRODUCT
						if (_categoryVO && _productVO && resultVO.result)
						{
							_productVO.productNo = String(resultVO.result);
							//for the case of CREATE_PRODUCT, _productVO should not exist in list yet
							if (!_categoryVO.productList.getVOByProductNo(_productVO.productNo))
							{
								_categoryVO.productList.addVO( _productVO );
							}
							
							sendNotification(NotificationType.CREATE_PRODUCT_SUCCESS);
						}
						else
						{
							sendNotification(NotificationType.CREATE_PRODUCT_FAIL, resultVO);
						}
						
					}
					else if (inService == AMFShopManagementServicesType.UPDATE_PRODUCT)
					{
						if (resultVO.result)
						{
							sendNotification(NotificationType.UPDATE_PRODUCT_SUCCESS);
						}
						else
						{
							sendNotification(NotificationType.UPDATE_PRODUCT_FAIL, resultVO);
						}
					}
					else if (inService == AMFShopManagementServicesType.GET_PRODUCT_BY_NO)
					{
						if (resultVO.result is ProductVO)
						{
							var pVO:ProductVO = resultVO.result as ProductVO;
							
							_productVO.productName = Tools.replaceRestrictedString(pVO.name);
							_productVO.productDescription = Tools.replaceRestrictedString( pVO.description );
							
							sendNotification(NotificationType.GET_PRODUCT_BY_NO_SUCCESS);
						}
						else
						{
							sendNotification(NotificationType.GET_PRODUCT_BY_NO_FAIL, resultVO);
						}
					}
					else if (inService == AMFShopManagementServicesType.GET_PRODUCT_STOCK)
					{
						if (_shopVOService.setShopProductStock(resultVO.result, _productVO))
						{
							sendNotification(NotificationType.GET_PRODUCT_STOCK_SUCCESS);
						}
						else
						{
							sendNotification(NotificationType.GET_PRODUCT_STOCK_FAIL, resultVO);
						}
					}
					
					return true;
				}
				
			}
			
			
			return false;
		}
		
	}
}