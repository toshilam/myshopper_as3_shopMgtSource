package myShopper.shopMgtModule.appForm.model
{
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.FileImageVO;
	import myShopper.common.data.map.MapInfoVO;
	import myShopper.common.data.shop.ShopCustomPageVO;
	import myShopper.common.data.shop.ShopInfoList;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.shop.ShopProductFormVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.AMFServicesErrorID;
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
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationRemoteProxy;
	
	public class FileInfoProxy extends ApplicationRemoteProxy//ApplicationProxy implements IRemoteDataProxy
	{
		
		/*private var _swfAddress:SWFAddressProxy;
		private function get swfAddress():SWFAddressProxy
		{
			if (!_swfAddress) _swfAddress = facade.retrieveProxy(ProxyID.SWF_ADDRESS) as SWFAddressProxy;
			return _swfAddress;
		}*/
		
		/*private var _amf:AMFRemoteProxy;
		private function get amf():AMFRemoteProxy
		{
			if (!_amf) _amf = facade.retrieveProxy(ProxyID.AMF) as AMFRemoteProxy;
			return _amf;
		}*/
		
		private var _shopInfo:ShopMgtShopInfoVO;
		private var _userInfo:UserInfoVO;
		private var _voService:ShopVOService;
		
		public function FileInfoProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		
		override public function onRegister():void
		{
			super.onRegister();
			
			_shopInfo = voManager.getAsset(VOID.MY_SHOP_INFO);
			_userInfo = voManager.getAsset(VOID.MY_USER_INFO);
			
			if (!_shopInfo || !_userInfo)
			{
				echo("onRegister : unable to get asset shopInfo VO");
				throw(new UninitializedError("onRegister : unable to get asset shopInfo VO"));
			}
			
			_voService = new ShopVOService(_shopInfo);
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			echo('initAsset');
		}
		
		//to get/manage data before sending via AMF proxy
		override public function getRemoteData(inService:String, inData:Object = null):Boolean
		{
			if (!_userInfo.isLogged) return false;
			
			var requestData:Object;
			
			if (AMFShopServicesType.DOWNLOAD_IMAGE)
			{
				/*var vo:FileImageVO = inData as FileImageVO;
					
				if (vo.path == FileType.PATH_SHOP_LOGO)
				{
					//check whather the image data already exist
					if (!_shopInfo.logoFileVO.data)
					{
						requestData = 	{ 
											i_user_id:_userInfo.uid, 
											i_path:vo.path
										}
					}
					else
					{
						//sendNotification(NotificationType.UPDATE_INFO);
						return true;
					}
				}
				else */if (inData is ShopProductFormVO)
				{
					var productVO:ShopProductFormVO = inData as ShopProductFormVO;
					
					for (var i:int = 0; i < ShopProductFormVO.NUM_PHOTO; i++)
					{
						if (!productVO.getPhotoVO(i).data)
						{
							requestData = 	{ 
												i_user_id:_userInfo.uid, 
												i_path:productVO.getPhotoVO().path,
												i_category_no:productVO.productCategoryNo,
												i_product_no:productVO.productNo,
												i_index:i.toString() //which image to be got from
											}
							
							//amf.call(AMFShopServicesType.DOWNLOAD_IMAGE, requestData);
							call(AMFShopServicesType.DOWNLOAD_IMAGE, requestData);
						}
					}
					
					//sendNotification(NotificationType.UPDATE_INFO);
					return true;
				}
				else if (inData is ShopCustomPageVO)
				{
					var customVO:ShopCustomPageVO = inData as ShopCustomPageVO;
					
					if (!customVO.photoFileVO.data)
					{
						requestData = 	{ 
											i_user_id:_userInfo.uid, 
											i_path:customVO.photoFileVO.path,
											i_extra:customVO.pageNo
										}
					}
					else
					{
						//sendNotification(NotificationType.UPDATE_INFO);
						return true;
					}
				}
				else
				{
					echo('getRemoteData : download image : unknown data type ' + inData);
					return false;
				}
				
				//amf.call(AMFShopServicesType.DOWNLOAD_IMAGE, requestData);
				call(AMFShopServicesType.DOWNLOAD_IMAGE, requestData);
				return true;
			}
			
			return false;
		}
		
		override public function setRemoteData(inService:String, inData:Object):Boolean
		{
			if (inService == AMFShopServicesType.DOWNLOAD_IMAGE)
			{
				var resultVO:ResultVO = inData as ResultVO;
				
				if (resultVO && resultVO.code == AMFServicesErrorID.NONE)
				{
					if (resultVO.result && resultVO.result['i_path'] && resultVO.result['i_path'] == FileType.PATH_SHOP_PRODUCT)
					{
						if (_voService.setShopProductImage(resultVO.result))
						{
							//no need to send vo to mediator, as those mediators have already held the vo object
							//sendNotification(NotificationType.UPDATE_INFO);
							
							return true;
						}
						
					}
					if (resultVO.result && resultVO.result['i_path'] && resultVO.result['i_path'] == FileType.PATH_SHOP_CUSTOM)
					{
						if (_voService.setShopCustomImage(resultVO.result))
						{
							//no need to send vo to mediator, as those mediators have already held the vo object
							//sendNotification(NotificationType.UPDATE_INFO);
							
							return true;
						}
						
					}
					else
					{
						echo(' setRemoteData : no image data downloaded : ' + resultVO.result, this, 0xff0000);
					}
				}
				else
				{
					echo('setRemoteData : fail getting data from server');
				}
			}
			
			return false;
		}
		
	}
}