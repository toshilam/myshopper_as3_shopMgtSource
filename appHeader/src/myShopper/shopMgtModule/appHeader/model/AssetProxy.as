package myShopper.shopMgtModule.appHeader.model
{
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.FileType;
	import myShopper.common.emun.RequestType;
	import myShopper.common.emun.ServiceID;
	import myShopper.common.net.LocalDataService;
	import myShopper.common.net.LocalDataServiceRequest;
	import myShopper.shopMgtModule.appHeader.enum.NotificationType;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.FileEvent;
	import myShopper.common.interfaces.IDataManager;
	import myShopper.common.net.FileLoader;
	import myShopper.common.utils.Tracer;
	import myShopper.shopMgtModule.appHeader.view.component.ApplicationHeader;
	import org.puremvc.as3.multicore.enum.NotificationType;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	
	public class AssetProxy extends ApplicationProxy
	{
		public static const SETTING_NODE:String = 'applicationHeader';
		
		private var _xmlConfig:XML;
		private var _localDataService:LocalDataService;
		
		public function AssetProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		
		override public function onRegister():void
		{
			Tracer.echo(multitonKey + ' : ' + getProxyName() + " : onRegister() ");
			
			_localDataService = serviceManager.getAsset(ServiceID.LOCAL_DATA);
			data = xmlManager.getAsset(AssetLibID.XML_COMMON);
			_xmlConfig = data..applicationHeader[0];
			initAsset();
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			Tracer.echo(multitonKey + ' : ' + getProxyName() + ' : initAsset', this);
			Tracer.echo(_xmlConfig, this);
			
			sendNotification(org.puremvc.as3.multicore.enum.NotificationType.ADD_HOST, new DisplayObjectVO(_xmlConfig.@id, new ApplicationHeader(), _xmlConfig));
			
			var numElement:int = _xmlConfig..element.length();
			for (var i:int = 0; i < numElement; i++)
			{
				var xml:XML = _xmlConfig..element[i];
				trace(xml.@id);
				sendNotification(org.puremvc.as3.multicore.enum.NotificationType.ADD_CHILD, new DisplayObjectVO(xml.@id, assetManager.getData(xml.@Class, AssetLibID.AST_HEADER), xml) );
			}
			
			//sendNotification(ApplicationEvent.INIT_ASSET_COMPLETE, applicationHeader);
		}
		
		public function setHeaderMenu(isLogged:Boolean = false):Boolean
		{
			var menuXML:XML = _xmlConfig..menu[isLogged ? 1 : 0];
			
			if (menuXML)
			{
				sendNotification(myShopper.shopMgtModule.appHeader.enum.NotificationType.SET_HEADER_MENU, menuXML);
				return true;
			}
			
			echo('setHeaderMenu : no matched xml found');
			return false;
		}
		
		public function getCurrentLanguage():String
		{
			return language;
		}
		
		//to be used for desktop/mobile app
		public function setLanguage(inValue:String):void
		{
			_localDataService.request(new LocalDataServiceRequest('', RequestType.LOCAL_DATA_LANGUAGE, inValue))
		}
	}
}