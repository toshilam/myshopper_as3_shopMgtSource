package myShopper.shopMgtModule.appShopMgt.model
{
	import flash.text.Font;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.CommunicationType;
	import myShopper.common.emun.FileType;
	import myShopper.common.emun.FontID;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.FileEvent;
	import myShopper.common.interfaces.IDataManager;
	import myShopper.common.net.CommunicationService;
	import myShopper.common.net.FileLoader;
	import myShopper.common.utils.Tracer;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtModule.appShopMgt.view.component.ApplicationShopMgt;
	import org.puremvc.as3.multicore.enum.NotificationType;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	
	public class AssetProxy extends ApplicationProxy
	{
		public static const SETTING_NODE:String = 'applicationShopMgt';
		
		private var _xmlConfig:XML;
		private var _shopInfo:ShopInfoVO;
		private var _userInfo:UserInfoVO;
		
		public function AssetProxy(inName:String, inData:Object)
		{
			super( inName, inData );
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
			
			initAsset();
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			echo('initAsset');
			//Tracer.echo(_xmlConfig, this);
			
			sendNotification(NotificationType.ADD_HOST, new DisplayObjectVO('', new ApplicationShopMgt(), null) );
			
			var numElement:int = _xmlConfig.element.length();
			for (var i:int = 0; i < numElement; i++)
			{
				var xml:XML = _xmlConfig.element[i];
				trace(xml.@id);
				sendNotification(NotificationType.ADD_CHILD, new DisplayObjectVO(xml.@id.toString(), assetManager.getData(xml.@Class.toString(), AssetLibID.APP_SHOP_MGT), xml, _shopInfo) );
			}
			
			if (!_userInfo.isLogged)
			{
				sendNotification(ShopMgtEvent.LOGIN);
			}
			
		}
		
	}
}