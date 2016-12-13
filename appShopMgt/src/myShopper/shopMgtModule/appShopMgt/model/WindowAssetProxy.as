package myShopper.shopMgtModule.appShopMgt.model
{
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.AssetID;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.FileType;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.FileEvent;
	import myShopper.common.interfaces.IDataManager;
	import myShopper.common.net.FileLoader;
	import myShopper.common.utils.Tracer;
	import org.puremvc.as3.multicore.enum.NotificationType;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	
	public class WindowAssetProxy extends ApplicationProxy
	{
		public static const SETTING_NODE:String = 'applicationUserMgt';
		
		private var _xmlConfig:XML;
		private var _userInfo:UserInfoVO;
		
		public function WindowAssetProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		
		override public function onRegister():void
		{
			super.onRegister();
			
			data = xmlManager.getAsset(AssetLibID.XML_SHOP_MGT);
			_xmlConfig = data..windowElements[0];
			
			_userInfo = voManager.getAsset(VOID.MY_USER_INFO);
			if (!_userInfo)
			{
				echo('onRegister : unable to get user info vo');
				throw(new UninitializedError('onRegister : unable to get user info vo'));
			}
			
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			echo('initAsset');
			//Tracer.echo(_xmlConfig, this);
			var windowID:String = String(inAsset);
			var xml:XML;
			/*if (windowID == AssetID.BTN_USER_MANAGEMENT_INFO)
			{
				//xml = _xmlConfig.*.(@id == AssetID.INFO_MENU)[0];
				xml = _xmlConfig.*.(@id == AssetID.BTN_USER_MANAGEMENT_INFO)[0];
				if (xml)
				{
					sendNotification
					(
						NotificationType.ADD_CHILD, 
						new DisplayObjectVO
						(
							xml.@id.toString(), 
							assetManager.getData(xml.@Class.toString(), AssetLibID.AST_USER_MGT), 
							xml, 
							_userInfo
						) 
					);
				}
			}*/
			
			/*var numElement:int = _xmlConfig..element.length();
			for (var i:int = 0; i < numElement; i++)
			{
				var xml:XML = _xmlConfig..element[i];
				trace(xml.@id);
				sendNotification(NotificationType.ADD_CHILD, new DisplayObjectVO(xml.@id.toString(), assetManager.getData(xml.@Class.toString(), AssetLibID.AST_USER_MGT), xml, _userInfo) );
			}*/
			
			//sendNotification(ApplicationEvent.INIT_ASSET_COMPLETE, applicationHeader);
		}
		
		
		
	}
}