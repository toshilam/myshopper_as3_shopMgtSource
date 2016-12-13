package myShopper.shopMgtModule.appForm.model
{
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.shop.ShopOrderVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.VOID;
	import myShopper.common.interfaces.IVO;
	import myShopper.common.utils.Tools;
	import myShopper.shopMgtCommon.data.service.ShopVOService;
	import myShopper.shopMgtCommon.emun.AMFShopManagementServicesType;
	import myShopper.shopMgtCommon.emun.AssetID;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.ShopMgtShopInfoVO;
	import myShopper.shopMgtModule.appForm.enum.AssetClassID;
	import myShopper.shopMgtModule.appForm.enum.MediatorID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.observer.Notification;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	import myShopper.common.data.service.ShopVOService;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationRemoteProxy;
	
	public class ShopSalesHistoryFormProxy extends ApplicationRemoteProxy //ApplicationProxy implements IRemoteDataProxy
	{
		/*private var _amf:AMFRemoteProxy;
		private function get amf():AMFRemoteProxy
		{
			if (!_amf) _amf = facade.retrieveProxy(ProxyID.AMF) as AMFRemoteProxy;
			return _amf;
		}*/
		
		
		
		public function ShopSalesHistoryFormProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		//private var _voService:UserVOService;
		private var _shopInfoVO:ShopMgtShopInfoVO;
		private var _targetNode:XML;
		private var _voService:myShopper.shopMgtCommon.data.service.ShopVOService;
		private var _currVO:ShopOrderVO;
		
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
			
			_voService = new myShopper.shopMgtCommon.data.service.ShopVOService(_shopInfoVO);
			
			var windowNode:XML = xml..windowElements[0];
			_targetNode = windowNode.*.(@id == AssetID.SHOP_SALES_HISTORY)[0];
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			
			_shopInfoVO = null;
			_currVO = null;
			_voService.clear();
			_voService = null;
			//_amf = null;
			_targetNode = null;
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			var classID:String = _targetNode.@Class.toString();
			
			var note:Notification = inAsset as Notification;
			
			_currVO = note.getBody() as ShopOrderVO;
			if(classID && _currVO)
			{
				sendNotificationToMediator
				(
					MediatorID.SHOP_MGT_SALES_HISTORY,
					NotificationType.ADD_DISPLAY_SALES_HISTORY, 
					new DisplayObjectVO(classID, assetManager.getData(classID, AssetLibID.AST_SHOP_MGT_FORM), _targetNode, _currVO) 
				);
				
				getRemoteData(AMFShopManagementServicesType.GET_ORDER_PRODUCT, _currVO);
				getRemoteData(AMFShopManagementServicesType.GET_ORDER_EXTRA, _currVO);
				
			}
			else
			{
				throw new Error(multitonKey + ' : ' + proxyName + ' : unable to retrieve data : ' + note.getBody());
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
		
		override public function getRemoteData(inService:String, inData:Object = null):Boolean
		{
			var requestData:Object;
			//get lang code, if lang code not specified, use system one
			var langCode:String = (inData is IVO && Tools.isLangCode((inData as IVO).selectedLangCode)) ? (inData as IVO).selectedLangCode : language;
			var userInfo:UserInfoVO = voManager.getAsset(VOID.MY_USER_INFO);
			
			if (inService == AMFShopManagementServicesType.GET_ORDER_PRODUCT)
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
			}
			else
			{
				echo('getRemoteData : : unknown service type ' + inService, this, 0xff0000);
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
				if (inService == AMFShopManagementServicesType.GET_ORDER_PRODUCT)
				{
					//once data is set, value will be autometically set in display object form
					if ( !_voService.setShopOrderProduct(resultVO.result, _currVO) )
					{
						echo('setRemoteData : fail setting data into vo');
					}
					else
					{
						sendNotificationToMediator(MediatorID.SHOP_MGT_SALES_HISTORY, NotificationType.RESULT_GET_SALES_PRODUCT);
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
						sendNotificationToMediator(MediatorID.SHOP_MGT_SALES_HISTORY, NotificationType.RESULT_GET_SALES_EXTRA);
					}
				}
			}
			
			return true;
		}
		
	}
}