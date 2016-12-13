package myShopper.shopMgtModule.appForm.model
{
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.shop.ShopCategoryFormVO;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.shop.ShopProductFormVO;
	import myShopper.common.data.VO;
	import myShopper.common.emun.AMFServicesErrorID;
	import myShopper.common.emun.VOID;
	import myShopper.common.interfaces.ICommServiceRequest;
	import myShopper.common.interfaces.IVO;
	import myShopper.common.utils.Tools;
	import myShopper.shopMgtCommon.data.service.ShopVOService;
	import myShopper.shopMgtCommon.emun.AMFShopManagementServicesType;
	import myShopper.shopMgtCommon.emun.AssetID;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.emun.CommunicationType;
	import myShopper.shopMgtCommon.ShopMgtShopInfoVO;
	import myShopper.shopMgtModule.appForm.enum.AssetClassID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationRemoteProxy;
	
	public class ShopProductInfoProxy extends ApplicationRemoteProxy //ApplicationProxy implements IRemoteDataProxy
	{
		
		private var _swfAddress:SWFAddressProxy;
		private function get swfAddress():SWFAddressProxy
		{
			if (!_swfAddress) _swfAddress = facade.retrieveProxy(ProxyID.SWF_ADDRESS) as SWFAddressProxy;
			return _swfAddress;
		}
		
		/*private var _amf:AMFRemoteProxy;
		private function get amf():AMFRemoteProxy
		{
			if (!_amf) _amf = facade.retrieveProxy(ProxyID.AMF) as AMFRemoteProxy;
			return _amf;
		}*/
		
		
		private var _shopInfoVO:ShopMgtShopInfoVO;
		private var _targetNode:XML;
		private var _voService:ShopVOService;
		
		//currently selected product vo
		private var _selectedProductVO:ShopProductFormVO;
		public function get selectedProductVO():ShopProductFormVO 
		{
			return _selectedProductVO;
		}
		
		//currently selected category vo
		private var _selectedCategoryVO:ShopCategoryFormVO;
		public function get selectedCategoryVO():ShopCategoryFormVO 
		{
			return _selectedCategoryVO;
		}
		
		
		public function ShopProductInfoProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		
		override public function onRegister():void
		{
			super.onRegister();
			//echo("onRegister() ");
			
			_shopInfoVO = voManager.getAsset(VOID.MY_SHOP_INFO);
			var xml:XML = xmlManager.getAsset(AssetLibID.XML_SHOP_MGT);
			
			if (!_shopInfoVO || !xml)
			{
				echo('onRegister : unable to get shop info vo/xml');
				throw(new UninitializedError('onRegister : unable to get shop info vo/xml'));
			}
			
			_voService = new ShopVOService(_shopInfoVO);
			
			var windowNode:XML = xml..windowElements[0]
			_targetNode = windowNode.*.(@id == AssetID.BTN_SHOP_PRODUCT)[0];
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			_swfAddress = null;
			//_amf = null;
			_shopInfoVO = null;
			_targetNode = null;
			_voService = null;
			_selectedCategoryVO = null;
			_selectedProductVO = null;
			
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			if (inAsset is ICommServiceRequest)
			{
				//var classID:String = getAssetIDByCommType(String(inAsset));
				var classID:String = _targetNode.@Class.toString();
				if (classID)
				{
					
					if (_shopInfoVO)
					{
						sendNotification
						(
							NotificationType.ADD_DISPLAY_PRODUCT, 
							new DisplayObjectVO(classID, assetManager.getData(classID, AssetLibID.AST_SHOP_MGT), _targetNode, _shopInfoVO) 
						);
						
						//get product category and product detail info
						getRemoteData(AMFShopManagementServicesType.GET_CATEGORY_PRODUCT, new VO('', language) );
					}
					else
					{
						echo('initAsset : unable to get user login vo');
					}
					
				}
				else
				{
					echo('initAsset : unknow page id : ' + ICommServiceRequest(inAsset).communicationType);
				}
			}
		}
		
		/*private function getAssetIDByCommType(inID:String):String
		{
			switch(inID)
			{
				case CommunicationType.SHOP_MGT_PRODUCT: return AssetClassID.FORM_SHOP_PRODUCT;
			}
			
			return null;
		}*/
		
		override public function getRemoteData(inService:String, inData:Object = null):Boolean
		{
			var requestData:Object;
			//get lang code, if lang code not specified, use system one
			var langCode:String = (inData is IVO && Tools.isLangCode((inData as IVO).selectedLangCode)) ? (inData as IVO).selectedLangCode : language;
			
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
					sendNotification(NotificationType.RESULT_GET_CATEGORY_PRODUCT);
					//productPageHandler(); //handle page
					return true;
				}
				
				requestData =	{
									c_user_id:_shopInfoVO.uid,
									lang:langCode
								};
			}
			else
			{
				echo('getRemoteData : : unknown service type ' + inService, this, 0xff0000);
				return false;
			}
			
			//amf.call(AMFShopManagementServicesType.GET_CATEGORY_PRODUCT, requestData);
			call(AMFShopManagementServicesType.GET_CATEGORY_PRODUCT, requestData);
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
					
					/*if (inService == AMFShopManagementServicesType.UPDATE_ABOUT)
					{
						sendNotification(NotificationType.UPDATE_ABOUT_FAIL, resultVO);
					}*/
					
					//retry
					getRemoteData(AMFShopManagementServicesType.GET_CATEGORY_PRODUCT, new VO('', language) );
					return false;
				}
				else
				{
					if (inService == AMFShopManagementServicesType.GET_CATEGORY_PRODUCT)
					{
						//once data is set, value will be autometically set in display object form
						//change on 19/12/2011, not easy for managing those vo, use sendNotification instead of
						if ( !_voService.setShopCategory(resultVO.result) )
						{
							echo('setRemoteData : fail setting data into vo');
							//retry
							getRemoteData(AMFShopManagementServicesType.GET_CATEGORY_PRODUCT, new VO('', language) );
							return false;
						}
						
						sendNotification(NotificationType.RESULT_GET_CATEGORY_PRODUCT);
					}
					
					
					return true;
				}
				
			}
			
			return false;
		}
		
		
		
	}
}