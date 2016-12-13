package myShopper.shopMgtModule.appRCShopMgt.model
{
	import flash.text.Font;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.CommunicationType;
	import myShopper.common.emun.FileType;
	import myShopper.common.emun.FontID;
	import myShopper.common.emun.MessageID;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.FileEvent;
	import myShopper.common.interfaces.IDataManager;
	import myShopper.common.net.CommunicationService;
	import myShopper.common.net.FileLoader;
	import myShopper.common.utils.Tracer;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtModule.appRCShopMgt.enum.AssetClassID;
	import myShopper.shopMgtModule.appRCShopMgt.enum.PageID;
	import myShopper.shopMgtModule.appRCShopMgt.enum.ProxyID;
	import myShopper.shopMgtModule.appRCShopMgt.model.vo.PageVO;
	import myShopper.shopMgtModule.appRCShopMgt.view.component.ApplicationShopMgt;
	import org.puremvc.as3.multicore.enum.NotificationType;
	import myShopper.shopMgtModule.appRCShopMgt.enum.NotificationType;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	import pl.mateuszmackowiak.nativeANE.dialogs.NativeAlertDialog;
	import pl.mateuszmackowiak.nativeANE.events.NativeDialogEvent;
	
	public class AssetProxy extends ApplicationProxy
	{
		public static const SETTING_NODE:String = 'applicationShopMgt';
		
		private var _xmlConfig:XML;
		private var _shopInfo:ShopInfoVO;
		private var _userInfo:UserInfoVO;
		
		private var _currPage:String;
		
		public function AssetProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		private var _loginProxy:LoginScanPageProxy;
		private function get loginProxy():LoginScanPageProxy
		{
			if (!_loginProxy)
			{
				_loginProxy = facade.retrieveProxy(ProxyID.LOGIN_SCAN_PAGE) as LoginScanPageProxy;
			}
			return _loginProxy;
		}
		
		
		override public function onRegister():void
		{
			super.onRegister();
			
			data = xmlManager.getAsset(AssetLibID.XML_SHOP_MGT);
			_xmlConfig = data..applicationShopMgt[0];
			
			_shopInfo = voManager.getAsset(VOID.MY_SHOP_INFO);
			_userInfo = voManager.getAsset(VOID.MY_USER_INFO);
			
			if (!_xmlConfig || !_userInfo)
			{
				echo('onRegister : unable to retrieve xml/user info');
				throw(new UninitializedError('onRegister : unable to retrieve xml/user info'));
			}
			
			_currPage = null;
			initAsset();
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			echo('initAsset');
			//Tracer.echo(_xmlConfig, this);
			
			sendNotification(org.puremvc.as3.multicore.enum.NotificationType.ADD_HOST, new DisplayObjectVO('', new ApplicationShopMgt(), null) );
			
			/*var numElement:int = _xmlConfig.element.length();
			for (var i:int = 0; i < numElement; i++)
			{
				var xml:XML = _xmlConfig.element[i];
				trace(xml.@id);
				sendNotification(NotificationType.ADD_CHILD, new DisplayObjectVO(xml.@id.toString(), assetManager.getData(xml.@Class.toString(), AssetLibID.APP_SHOP_MGT), xml, _shopInfo) );
			}*/
			
			if (!_userInfo.isLogged)
			{
				pageChangeHandler(PageID.LOGIN);
			}
			
		}
		
		public function previousPage():void
		{
			switch(_currPage)
			{
				case PageID.LOGIN:
				case PageID.MAIN_MENU:		return;
				case PageID.LOGIN_SCAN:		
				{
					changePage(PageID.LOGIN, true);
					return;
				}
				case PageID.PRODUCT_SCAN:	
				{
					changePage(PageID.MAIN_MENU);
					return;
				}
			}
		}
		
		public function changePage(inPageID:String, inDirect:Boolean = false ):void
		{
			if (_currPage == inPageID || !getClassIDByPageID(inPageID))
			{
				echo('changePage : same page/unknown id found : ' + inPageID);
				return;
			}
			
			if (!inDirect && inPageID == PageID.LOGIN)
			{
				logoutHandler();
				return;
			}
			
			pageChangeHandler(inPageID);
			
		}
		
		private function logoutHandler():void 
		{
			NativeAlertDialog.showAlert( getMessage(MessageID.CONFIRM_LOGOUT) , getMessage(MessageID.CONFIRM_TITLE) ,  Vector.<String>(["OK","CANCEL"]) , 
			function answerHandler(event:NativeDialogEvent):void{
				//event.preventDefault(); 
				var buttonPressed:String = event.index;// the index of the pressed button
				// IMPORTANT: 
				//default behavior is to remove the default listener "someAnswerFunction()" and to call the dispose()
				//
				trace(event);
				
				if (event.index == '0')
				{
					loginProxy.tearDownAsset();
					pageChangeHandler(PageID.LOGIN);
				}
			});
		}
		
		private function pageChangeHandler(inPageID:String):void 
		{
			_currPage = inPageID;
			
			sendNotification
			(
				myShopper.shopMgtModule.appRCShopMgt.enum.NotificationType.VIEW_PAGE, 
				new PageVO
				(
					'', 
					inPageID, 
					assetManager.getData(getClassIDByPageID(inPageID) , AssetLibID.AST_SHOP_MGT)
				)
			);
		}
		
		private function getClassIDByPageID(inPageID:String):String 
		{
			switch(inPageID)
			{
				case PageID.LOGIN:			return AssetClassID.LOGIN_PAGE;
				case PageID.MAIN_MENU:		return AssetClassID.MENU_PAGE;
				case PageID.LOGIN_SCAN:		
				case PageID.PRODUCT_SCAN:	return AssetClassID.SCAN_PAGE;
			}
			
			return '';
		}
		
	}
}