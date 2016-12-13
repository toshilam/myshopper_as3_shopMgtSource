package myShopper.shopMgtModule.appFooter.model
{
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.FileType;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.FileEvent;
	import myShopper.common.interfaces.IApplicationDisplayObject;
	import myShopper.common.interfaces.IDataManager;
	import myShopper.common.net.FileLoader;
	import myShopper.common.utils.Tracer;
	import myShopper.shopMgtModule.appFooter.view.component.ApplicationFooter;
	import org.puremvc.as3.multicore.enum.NotificationType;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	
	public class AssetProxy extends ApplicationProxy
	{
		public static const SETTING_NODE:String = 'applicationFooter';
		
		private var _xmlConfig:XML;
		
		public function AssetProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		
		override public function onRegister():void
		{
			trace(AssetLibID.AST_COMMON, AssetLibID.AST_FOOTER, AssetLibID.AST_HEADER);
			Tracer.echo(multitonKey + ' : ' + getProxyName() + " : onRegister() ");
			
			data = xmlManager.getAsset(AssetLibID.XML_COMMON);
			_xmlConfig = data..applicationFooter[0];
			initAsset();
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			Tracer.echo(multitonKey + ' : ' + getProxyName() + ' : initAsset', this);
			Tracer.echo(_xmlConfig, this);
			
			sendNotification(NotificationType.ADD_HOST, new DisplayObjectVO(_xmlConfig.@id, new ApplicationFooter(), _xmlConfig) );
			
			var numElement:int = _xmlConfig..element.length();
			for (var i:int = 0; i < numElement; i++)
			{
				var xml:XML = _xmlConfig..element[i];
				var id:String = xml.@id;
				var o:IApplicationDisplayObject = assetManager.getData(xml.@Class, AssetLibID.AST_FOOTER);
				trace(id, o);
				sendNotification(NotificationType.ADD_CHILD, new DisplayObjectVO(id, o, xml) );
			}
			
			//sendNotification(ApplicationEvent.INIT_ASSET_COMPLETE, applicationHeader);
		}
		
	}
}