package myShopper.shopMgtModule.appRCSystem.model
{
	import flash.text.Font;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.FileType;
	import myShopper.common.emun.FontID;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.FileEvent;
	import myShopper.common.interfaces.IDataManager;
	import myShopper.common.net.FileLoader;
	import myShopper.common.utils.Tools;
	import myShopper.common.utils.Tracer;
	import myShopper.shopMgtModule.appRCSystem.Config;
	import myShopper.shopMgtModule.appRCSystem.enum.PartsID;
	import myShopper.shopMgtModule.appRCSystem.model.service.LoaderService;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	
	public class AssetProxy extends ApplicationProxy
	{
		private static const RESOURCE_NODE_LIST:Array = ['settings', 'assets', 'langs', 'modules'];
		private static const RESOURCE_LIST:Array = ['appCommon'];
		
		private var loader:FileLoader;
		
		//number of file have been loaded
		private var _numQueueLoaded:uint;
		private var _numResourceLoaded:uint;
		private var _currResourceIndex:uint;
		
		private var _xmlConfig:XML;
		
		private var _moduleLoaderService:LoaderService;
		private var _assetLoaderService:LoaderService;
		private var _settingLoaderService:LoaderService;
		private var _langLoaderService:LoaderService;
		
		private var _loadQueue:Array = new Array();
		private var _loadedModule:Array = new Array(); //list of module id which has loaded 
		
		public function AssetProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		override public function onRegister():void
		{
			if (CONFIG::air)
			{
				configLoadedHandler(new FileEvent(FileEvent.COMPLETE, null, '', FileType.TYPE_XML, AssetLibID.XML_CONFIG, xmlManager.getAsset(AssetLibID.XML_CONFIG)));
			}
			else
			{
				//load loader xml
				loader = new FileLoader();
				loader.addEventListener(FileEvent.COMPLETE, configLoadedHandler);
				loadAsset(AssetLibID.XML_CONFIG, Config.CONFIG_URL, FileType.TYPE_XML);
				Tracer.echo(getProxyName() + " : onRegister() ");
			}
			
		}
		
		
		public function loadAsset(inID:String, inURL:String, inFileType:String):void
		{
			loader.load(inURL, inFileType, inID)
		}
		
		
		private function configLoadedHandler(e:FileEvent):void 
		{
			Tracer.echo(getProxyName() + " : onFileLoaded : type : " + e.fileType + ", id : " + e.fileID);
			
			getDataManager(e.fileType).addAsset(e.fileType == FileType.TYPE_XML ? new XML(e.data) : e.data, e.fileID);
			
			if (e.fileType == FileType.TYPE_XML && e.fileID == AssetLibID.XML_CONFIG)
			{
				_xmlConfig = XML(e.data);
				setData( _xmlConfig );
				
				//replace lang code
				var langNode:XML = _xmlConfig[RESOURCE_NODE_LIST[2]][0];
				langNode.@url = Tools.formatString(langNode.@url, [language]);
				
				_settingLoaderService = new LoaderService(_xmlConfig[RESOURCE_NODE_LIST[0]][0], RESOURCE_LIST[0]);
				_assetLoaderService = new LoaderService(_xmlConfig[RESOURCE_NODE_LIST[1]][0], RESOURCE_LIST[0]);
				_langLoaderService = new LoaderService(_xmlConfig[RESOURCE_NODE_LIST[2]][0], RESOURCE_LIST[0]);
				_moduleLoaderService = new LoaderService(_xmlConfig[RESOURCE_NODE_LIST[3]][0], RESOURCE_LIST[0]);
				
				_moduleLoaderService.addEventListener(FileEvent.COMPLETE, appLoadedHandler);
				_settingLoaderService.addEventListener(FileEvent.COMPLETE, appLoadedHandler);
				_assetLoaderService.addEventListener(FileEvent.COMPLETE, appLoadedHandler);
				_langLoaderService.addEventListener(FileEvent.COMPLETE, appLoadedHandler);
				
				//var event:String = ;
				_moduleLoaderService.addEventListener(FileEvent.COMPLETE_ALL_FILE, appLoadedHandler);
				_settingLoaderService.addEventListener(FileEvent.COMPLETE_ALL_FILE, appLoadedHandler);
				_assetLoaderService.addEventListener(FileEvent.COMPLETE_ALL_FILE, appLoadedHandler);
				_langLoaderService.addEventListener(FileEvent.COMPLETE_ALL_FILE, appLoadedHandler);
				
				//note moudle should always be loaded and the end
				//modified on 03122011, module loaded first (avoid out dated as code caeched in fla), and notify command once other asset loaded
				_loadQueue.push(_moduleLoaderService.load, _settingLoaderService.load, _assetLoaderService.load, _langLoaderService.load);
				
				loadNextResource();
			}
			
		}
		
		private function appLoadedHandler(e:FileEvent):void 
		{
			var fileID:String = e.fileID;
			
			var targetManager:IDataManager = getDataManager(e.fileType);
			
			if (!targetManager.hasAsset(fileID))
			{
				targetManager.addAsset(e.fileType == FileType.TYPE_XML ? new XML(e.data) : e.data, fileID);
			}
			else
			{
				echo('appLoadedHandler : asset data already exist : ' + fileID);
			}
			
			
			if 
			(
				_settingLoaderService.isLoadComplete && 
				_assetLoaderService.isLoadComplete && 
				_langLoaderService.isLoadComplete &&
				_moduleLoaderService.isLoadComplete
			)
			{
				//register embeded font
				var font:Class = assetManager.getData(FontID.DFH_W7, AssetLibID.AST_COMMON);
				Font.registerFont(font);
				
				var embeddedFonts:Array = Font.enumerateFonts(false);
				for (var i:Number = 0; i < embeddedFonts.length; i++)
				{
					var item:Font = embeddedFonts[i];
					Tracer.echo("[" + i + "] name:" + item.fontName + ", style: " + item.fontStyle + ", type: " + item.fontType, this, 0xff0000);
				}
				
				
				while (_loadedModule.length)
				{
					sendNotification(FileEvent.COMPLETE_ALL_FILE, _loadedModule.splice(0, 1)[0]);
				}
				
				return;
				
			}
			else
			{
				if (isModule(fileID))
				{
					//if it's module asset, push it into an array and notify command once all other asset loaded
					_loadedModule.push(fileID);
				}
				else
				{
					sendNotification(FileEvent.COMPLETE, fileID);
				}
				
			}
			
			if (e.type == FileEvent.COMPLETE_ALL_FILE)
			{
				loadNextResource(); //load next pack of file
			}
		}
		
		
		private function loadNextResource():int
		{
			if 		(_numQueueLoaded >= _loadQueue.length) return -1;
			else 	_loadQueue[_numQueueLoaded]();
			
			return ++_numQueueLoaded;
		}
		
		private function isModule(inID:String):Boolean
		{
			switch(inID)
			{
				case AssetLibID.APP_HEADER: 
				case AssetLibID.APP_FOOTER:
				case AssetLibID.APP_FORM: 
				case AssetLibID.APP_SHOP_MGT: return true;
			}
			
			return false;
		}
		
		private function getDataManager(inContentType:String):IDataManager
		{
			if (inContentType == FileType.TYPE_XML) return xmlManager;
			if (inContentType == FileType.TYPE_SWF) return assetManager;
			
			return null;
		}
		
	}
}