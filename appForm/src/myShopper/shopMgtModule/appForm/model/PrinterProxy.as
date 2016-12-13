package myShopper.shopMgtModule.appForm.model 
{
	import myShopper.common.data.shop.ShopOrderVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.data.VO;
	import myShopper.common.emun.AMFGoogleServicesType;
	import myShopper.common.emun.PrinterType;
	import myShopper.common.emun.VOID;
	import myShopper.common.resources.AssetManager;
	import myShopper.shopMgtCommon.ShopMgtShopInfoVO;
	import myShopper.shopMgtModule.appForm.FormMain;
	import myShopper.shopMgtModule.appForm.model.service.PrintVOService;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationRemoteProxy;
	
	public class PrinterProxy extends ApplicationRemoteProxy
	{
		
		private var _printService:PrintVOService;
		private var _myUserInfo:UserInfoVO;
		private var _shopInfoVO:ShopMgtShopInfoVO;
		
		public function PrinterProxy(inName:String, inData:Object = null) 
		{
			super(inName, inData);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			
			_myUserInfo = voManager.getAsset(VOID.MY_USER_INFO);
			_shopInfoVO = voManager.getAsset(VOID.MY_SHOP_INFO);
			
			//new object when printing as appForm is not create when onRegister
			//_printService = new PrintVOService(assetManager as AssetManager,  (host as FormMain).appForm);
			if (!_myUserInfo || !_shopInfoVO /*|| !_printService*/)
			{
				throw(new UninitializedError("unable to get VO/service"));
			}
			
			
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			echo('initAsset');
		}
		
		public function print(inVO:VO, inSize:int):Boolean
		{
			if (!_printService)
			{
				_printService = new PrintVOService(assetManager as AssetManager,  (host as FormMain).appForm);
			}
			
			return printOrder(inVO, inSize);
		}
		
		private function printOrder(inOrderVO:VO, inSize:int):Boolean 
		{
			if (!(inOrderVO is ShopOrderVO)) return false;
			
			switch(_myUserInfo.printerVO.selectedPrinterType)
			{
				case PrinterType.SYSTEM:
				{
					return _printService.print(_printService.getOrderForm(inOrderVO as ShopOrderVO, _shopInfoVO, inSize), _myUserInfo.printerVO);
					break;
				}
				case PrinterType.CLOUD:
				{
					return getRemoteData(AMFGoogleServicesType.PRINTER_PRINT, inOrderVO);
					break;
				}
			}
			
			return false;
		}
		
		/* INTERFACE org.puremvc.as3.multicore.interfaces.IRemoteDataProxy */
		
		override public function getRemoteData(inService:String, inData:Object = null):Boolean 
		{
			//TODO implements service
			return false;
			
			
			var requestData:Object;
			
			if (inService == AMFGoogleServicesType.PRINTER_PRINT)
			{
				
				
				if (_userInfo && _userInfo.isLogged)
				{
					requestData = { g_user_id:_userInfo.uid };
					
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
			return false;
		}
		
		
		
	}
}