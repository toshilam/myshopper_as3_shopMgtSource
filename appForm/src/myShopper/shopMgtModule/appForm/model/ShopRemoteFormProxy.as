package myShopper.shopMgtModule.appForm.model
{
	import flash.geom.Point;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.VOID;
	import myShopper.common.utils.Barcode;
	import myShopper.shopMgtCommon.emun.AssetID;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtCommon.ShopMgtShopInfoVO;
	import myShopper.shopMgtModule.appForm.enum.AssetClassID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import org.puremvc.as3.multicore.patterns.observer.Notification;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	
	public class ShopRemoteFormProxy extends /*ApplicationRemoteProxy*/ApplicationProxy// implements IRemoteDataProxy
	{
		/*private var _amf:AMFRemoteProxy;
		private function get amf():AMFRemoteProxy
		{
			if (!_amf) _amf = facade.retrieveProxy(ProxyID.AMF) as AMFRemoteProxy;
			return _amf;
		}*/
		
		public function ShopRemoteFormProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		//private var _voService:UserVOService;
		private var _shopInfoVO:ShopMgtShopInfoVO;
		private var _userInfo:UserInfoVO;
		private var _targetNode:XML;
		//private var _shopVOService:ShopVOService;
		
		override public function onRegister():void
		{
			super.onRegister();
			
			_shopInfoVO = voManager.getAsset(VOID.MY_SHOP_INFO);
			_userInfo = voManager.getAsset(VOID.MY_USER_INFO);
			var xml:XML = xmlManager.getAsset(AssetLibID.XML_SHOP_MGT);
			
			
			if (!_shopInfoVO || !xml || !_userInfo)
			{
				echo('onRegister : unable to get shop info vo/xml');
				throw(new UninitializedError('onRegister : unable to get shop info vo/xml'));
			}
			
			//_shopVOService = new ShopVOService(_shopInfoVO);
			
			var windowNode:XML = xml..windowElements[0]
			_targetNode = windowNode.*.(@id == AssetID.BTN_SHOP_S_REMOTE)[0];
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			
			_shopInfoVO = null;
			_userInfo = null;
			//_comm = null;
			//_shopVOService.clear();
			//_shopVOService = null;
			//_amf = null;
			_targetNode = null;
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			if (inAsset is Notification)
			{
				var classID:String = getAssetIDByNoteType(Notification(inAsset).getType());
				if (classID)
				{
					sendNotification
					(
						NotificationType.ADD_FORM_SHOP_REMOTE, 
						new DisplayObjectVO(classID, assetManager.getData(classID, AssetLibID.AST_SHOP_MGT_FORM), _targetNode, Barcode.generateQRCode(_userInfo.token, new Point(300,300)) ) 
					);
					
				}
				else
				{
					echo('initAsset : unknow page id : ' + Notification(inAsset).getType());
				}
			}
		}
		
		private function getAssetIDByNoteType(inID:String):String
		{
			switch(inID)
			{
				case ShopMgtEvent.SHOP_CONNECT_REMOTE: return AssetClassID.FORM_SHOP_REMOTE;
			}
			
			return null;
		}
		
		
		/* INTERFACE org.puremvc.as3.multicore.interfaces.IRemoteDataProxy */
		
		public function getRemoteData(inService:String, inData:Object = null):Boolean
		{
			return false
			/*var requestData:Object;
			
			if (inService == AMFGoogleServicesType.PRINTER_SEARCH)
			{
				
				
				if (_userInfo && _userInfo.isLogged)
				{
					requestData = { g_user_id:_userInfo.uid };
					
				}
				else
				{
					sendNotification(NotificationType.SEARCH_PRINTER_FAIL);
					//echo('getRemoteData : unable to get user/shop vo');
					return false;
				}
				
				
			}
			else if (inService == AMFGoogleServicesType.SET_PRINTER_INFO)
			{
				if (_userInfo && _userInfo.isLogged && _userInfo.printerVO === inData)
				{
					requestData =	{
										p_user_id:_userInfo.uid,
										p_selected_type:_userInfo.printerVO.selectedPrinterType,
										p_selected_pid:_userInfo.printerVO.selectedPrinterID
									};
					
				}
				else
				{
					sendNotification(NotificationType.SET_PRINT_FAIL);
					return false;
				}
			}
			else
			{
				echo('getRemoteData : : unknown service type ' + inService, this, 0xff0000);
				return false;
			}
			
			
			//amf.call(inService, requestData);
			call(inService, requestData);
			return true;*/
		}
		
		public function setRemoteData(inService:String, inData:Object):Boolean
		{
			/*var resultVO:ResultVO = inData as ResultVO;
			
			if (resultVO)
			{
				if (inService == AMFGoogleServicesType.PRINTER_SEARCH)
				{
					if ( resultVO.code != AMFServicesErrorID.NONE )
					{
						echo('setRemoteData : fail getting data from server');
						
						sendNotification(NotificationType.SEARCH_PRINTER_FAIL, resultVO);
						return false;
					}
					else
					{
						if (PrinterVOService.setCloudPrinter(resultVO.result, _userInfo.printerVO))
						{
							sendNotification(NotificationType.SEARCH_PRINTER_SUCCESS);
						}
						else
						{
							sendNotification(NotificationType.SEARCH_PRINTER_FAIL, resultVO);
							echo('setRemoteData : fail setting _newImageVO');
						}
						
						return true;
					}
					
				}
				else if (inService == AMFGoogleServicesType.SET_PRINTER_INFO)
				{
					if ( resultVO.code != AMFServicesErrorID.NONE )
					{
						echo('setRemoteData : fail getting data from server');
						
						sendNotification(NotificationType.SET_PRINT_FAIL, resultVO);
						return false;
					}
					else
					{
						sendNotification(NotificationType.SET_PRINT_SUCCESS);
						
						return true;
					}
				}
			}*/
			
			
			
			return false;
		}
		
	}
}