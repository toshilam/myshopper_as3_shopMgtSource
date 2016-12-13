package myShopper.shopMgtModule.appShopMgt.model
{
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.FileImageVO;
	import myShopper.common.data.map.MapInfoVO;
	import myShopper.common.data.shop.ShopInfoList;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.shop.ShopProductFormVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.AMFShopServicesType;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.FileType;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.FileEvent;
	import myShopper.common.interfaces.IDataManager;
	import myShopper.common.net.FileLoader;
	import myShopper.common.utils.Tracer;
	import myShopper.shopMgtCommon.data.service.ShopVOService;
	import myShopper.shopMgtCommon.ShopMgtShopInfoVO;
	import myShopper.shopMgtModule.appShopMgt.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	
	public class FileInfoProxy extends ApplicationProxy implements IRemoteDataProxy
	{
		
		/*private var _swfAddress:SWFAddressProxy;
		private function get swfAddress():SWFAddressProxy
		{
			if (!_swfAddress) _swfAddress = facade.retrieveProxy(ProxyID.SWF_ADDRESS) as SWFAddressProxy;
			return _swfAddress;
		}*/
		
		/*private var _productInfo:ProductInfoProxy;
		private function get productInfo():ProductInfoProxy
		{
			if (!_productInfo) _productInfo = facade.retrieveProxy(ProxyID.PRODUCT) as ProductInfoProxy;
			return _productInfo;
		}*/
		
		private var _amf:AMFRemoteProxy;
		private function get amf():AMFRemoteProxy
		{
			if (!_amf) _amf = facade.retrieveProxy(ProxyID.AMF) as AMFRemoteProxy;
			return _amf;
		}
		
		private var _shopInfo:ShopMgtShopInfoVO;
		private var _userInfo:UserInfoVO;
		private var _voService:ShopVOService;
		
		public function FileInfoProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		
		override public function onRegister():void
		{
			echo(multitonKey + ' : ' + getProxyName() + " : onRegister() ");
			
			_shopInfo = voManager.getAsset(VOID.MY_SHOP_INFO);
			_userInfo = voManager.getAsset(VOID.MY_USER_INFO);
			if (!_shopInfo || !_userInfo)
			{
				echo("onRegister : unable to get asset shopInfo VO");
				throw(new UninitializedError('onRegister : unable to get asset shopInfo VO'));
			}
			
			_voService = new ShopVOService(_shopInfo);
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			echo('initAsset');
		}
		
		//to get/manage data before sending via AMF proxy
		public function getRemoteData(inService:String, inData:Object = null):Boolean
		{
			var requestData:Object;
			
			if (_userInfo && _userInfo.isLogged && _userInfo.isShopExist)
			{
				if (AMFShopServicesType.DOWNLOAD_IMAGE)
				{
					var vo:FileImageVO = inData as FileImageVO;
						
					if (!vo) 
					{
						echo('getRemoteData : download image : FileImageVO not found : ' + inData , this, 0xff0000);
						//sendNotification(RESULT_FAULT);
						return false;
					}
					
					if (vo.path == FileType.PATH_SHOP_LOGO)
					{
						//check whather the image data already exist
						if (!_shopInfo.logoFileVO.data)
						{
							requestData = 	{ 
												i_user_id:_shopInfo.uid, 
												i_path:vo.path
											}
						}
						else
						{
							//sendNotification(NotificationType.UPDATE_INFO);
							return true;
						}
					}
					else if (vo.path == FileType.PATH_SHOP_BG)
					{
						if (!_shopInfo.bgFileVO.data)
						{
							requestData = 	{ 
												i_user_id:_shopInfo.uid, 
												i_path:vo.path
											}
						}
						else
						{
							//sendNotification(NotificationType.UPDATE_INFO);
							return true;
						}
					}
					/*else if (vo.path == FileType.PATH_SHOP_PRODUCT)
					{
						var productVO:ShopProductFormVO = productInfo.selectedProductVO;
						
						if (!productVO.photoFileVO.data)
						{
							requestData = 	{ 
												i_user_id:shopInfo.uid, 
												i_path:vo.path,
												i_category_no:productVO.productCategoryNo,
												i_product_no:productVO.productNo
											}
						}
						else
						{
							sendNotification(NotificationType.UPDATE_INFO);
							return true;
						}
					}*/
					else
					{
						echo('getRemoteData : download image : unknown file type ' + vo.path, this, 0xff0000);
						return false;
					}
					
					amf.call(AMFShopServicesType.DOWNLOAD_IMAGE, requestData);
					return true;
				}
			}
			
			
			
			return false;
		}
		
		public function setRemoteData(inService:String, inData:Object):Boolean
		{
			var resultVO:ResultVO = inData as ResultVO;
			if (!resultVO) 
			{
				echo('setRemoteData : unknown data object!');
				return false;
			}
			
			var vo:ShopInfoVO;
			var data:Object = resultVO.result;
			
			if (inService == AMFShopServicesType.DOWNLOAD_IMAGE)
			{
				if (data)
				{
					if (ShopVOService.isShopLogoImage(data))
					{
						vo = _voService.setShopLogo(data);
						
						if (vo)
						{
							//no need to send vo to mediator, as those mediators have already held the vo object
							//and need to send notification, as logo object ifself is listening on vo data change event
							//sendNotification(NotificationType.UPDATE_INFO);
							
							return true;
						}
						
					}
					else if (ShopVOService.isShopBGImage(data))
					{
						vo = _voService.setShopBG(data);
						
						if (vo)
						{
							//no need to send vo to mediator, as those mediators have already held the vo object
							//and need to send notification, as logo object ifself is listening on vo data change event
							//sendNotification(NotificationType.UPDATE_INFO);
							
							return true;
						}
						
					}
					/*else if (data['i_path'] == FileType.PATH_SHOP_PRODUCT)
					{
						vo = _voService.setShopProductImage(data);
						
						if (vo)
						{
							//no need to send vo to mediator, as those mediators have already held the vo object
							sendNotification(NotificationType.UPDATE_INFO);
							
							return true;
						}
						
					}*/
					else
					{
						echo(' setRemoteData : unknown image  type ' + data['i_path'], this, 0xff0000);
					}
				}
				else
				{
					echo(' setRemoteData : no image data is downloaded ' + data, this, 0xff0000);
				}
			}
			
			return false;
		}
		
	}
}