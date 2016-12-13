package myShopper.shopMgtModule.appMain
{
	import adobe.utils.ProductManager;
	import flash.desktop.NativeApplication;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.BrowserInvokeEvent;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.net.SharedObject;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.setTimeout;
	import myShopper.common.Config;
	import myShopper.common.data.SetupVO;
	import myShopper.common.display.ApplicationDisplayObject;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.FileType;
	import myShopper.common.emun.RequestType;
	import myShopper.common.events.FileEvent;
	import myShopper.common.events.ModuleEvent;
	import myShopper.common.interfaces.IApplicationDisplayObject;
	import myShopper.common.interfaces.IDisplayObjectList;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.net.FileLoader;
	import myShopper.common.net.LocalDataService;
	import myShopper.common.resources.AssetManager;
	import myShopper.common.resources.ServiceManager;
	import myShopper.common.resources.SettingManager;
	import myShopper.common.resources.VOManager;
	import myShopper.common.resources.XMLManager;
	import myShopper.common.utils.Tools;
	import myShopper.common.utils.Tracer;
	
	CONFIG::debug
	import net.hires.debug.Stats;
	
	/**
	 * ...
	 * @author Toshi Lam
	 */
	public class Main extends Sprite//ApplicationDisplayObject
	{
		[Embed(source = "../../../../../../../asset/assetMain/ScreenMobile.swf")]
		private var Screen:Class;
		
		private var mcScreen:MovieClip;
		
		[Embed(source="../../../../../../../../xml/shop-management/shopMgtConfig-pc.xml", mimeType="application/octet-stream")]
		private const xmlConfig:Class;
		
		CONFIG::debug
		{
			[Embed(source="../../../../../../../../xml/setting/shopMgt/settingCommon.xml", mimeType="application/octet-stream")]
			private const xmlSetting:Class;
		}
		
		CONFIG::release
		{
			[Embed(source="../../../../../../../../xml/setting/shopMgt/settingCommon-release.xml", mimeType="application/octet-stream")]
			private const xmlSetting:Class;
		}
		
		
		[Embed(source="../../../../../../../../xml/setting/shopMgt/settingShop.xml", mimeType="application/octet-stream")]
		private const xmlSettingShop:Class;
		
		private var flashvars:Object;
		private var arrArguments:Array = [];
		
		CONFIG::debug
		private var txt:TextField;
		
		//public namespace ns_air = "http://ns.adobe.com/air/application/3.9";
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
			NativeApplication.nativeApplication.addEventListener(BrowserInvokeEvent.BROWSER_INVOKE, browserInvokeEventHandler);
			//NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, invokeEventHandler);
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, exitingEventHandler);
			
			CONFIG::debug
			{
				var stats:Stats = stage.addChild(new Stats()) as Stats;
				stats.mouseChildren = stats.mouseEnabled = false;
				
				txt = stage.addChild(new TextField()) as TextField;
				txt.autoSize = TextFieldAutoSize.LEFT
				txt.width = 500;
				txt.height 500;
				txt.x = txt.y = 200;
				txt.mouseEnabled = false;
				
				var serverString:String = unescape(Capabilities.serverString); 
				var reportedDpi:Number = Number(serverString.split("&DP=", 2)[1]);
				txt.appendText('\npixelAspectRatio : ' + Capabilities.pixelAspectRatio);
				txt.appendText('\nos : ' + Capabilities.os);
				txt.appendText('\nscreenDPI : ' + Capabilities.screenDPI);
				txt.appendText('\nscreenResolutionX : ' + Capabilities.screenResolutionX);
				txt.appendText('\nscreenResolutionY : ' + Capabilities.screenResolutionY);
				txt.appendText('\nserverString : ' + serverString);
				txt.appendText('\nversion : ' + Capabilities.version);
				txt.appendText('\nreportedDpi : ' + reportedDpi);
				
				txt.visible = false;
			}
			
			
			
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			Tracer.echo('Main : init : application startup!', this, 0xff0000);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
			
			/* loading screen */
			mcScreen = new Screen() as MovieClip;
			addChild( mcScreen );
			
			//trace(CONFIG::air, CONFIG::mobile, CONFIG::desktop);
			
			new Updater().initializeUpdater();
			
			//wait for browserInvoke if any, else init app in 1.5sec
			setTimeout(onInvoke, 1500);
		}
		
		
		private function browserInvokeEventHandler(e:BrowserInvokeEvent = null):void 
		{
			CONFIG::debug
			{
				txt.appendText('\nbrowserInvokeEventHandler : ' + e.arguments);
			}
			
			arrArguments = e.arguments;
			
		}
		
		/*private function invokeEventHandler(e:InvokeEvent):void 
		{
			CONFIG::debug
			{
				txt.appendText('invokeEventHandler : ' + e.arguments);
			}
			
			onInvoke(e.arguments);
			
		}*/
		
		private function onInvoke():void
		{
			//var appVersion:String = NativeApplication.nativeApplication.applicationDescriptor.ns_air::versionNumber[0];
			var appXML:XML = NativeApplication.nativeApplication.applicationDescriptor; 
			var ns:Namespace = appXML.namespace(); 
			var appVersion:String = appXML.ns::versionNumber;
			
			CONFIG::debug
			{
				txt.appendText('\nonInvoke');
				txt.appendText('\nversionNumber : ' + appVersion);
			}
			
			
			//flashvars = loaderInfo.parameters;
			//var version:String = !flashvars.version ? 'v0.0.0.0' : flashvars.version;
			flashvars = arrArguments.length ? Tools.rawURIToObj(arrArguments[0]) : { };
			flashvars[SettingManager.APP_VERSION] = appVersion;
			
			var so:SharedObject = SharedObject.getLocal(Tools.spaceToHyphen(Config.APPLICATION_TITLE), '/');
			if (so && so.data[LocalDataService.SETTING])
			{
				CONFIG::debug
				{
					txt.appendText('\nSO setting : ' + so.data[LocalDataService.SETTING][RequestType.LOCAL_DATA_LANGUAGE]);
				}
				
				var language:String = so.data[LocalDataService.SETTING][RequestType.LOCAL_DATA_LANGUAGE];
				flashvars.l = Tools.isLangCode(language) ? language : flashvars.l;
				
				var userData:Object = so.data[LocalDataService.SETTING][RequestType.LOCAL_DATA_USER_INFO];
				flashvars.e = userData && userData.email ? userData.email : '';
			}
			
			CONFIG::debug
			{
				txt.appendText('\nlanguage : ' + flashvars.l);
			}
			
			
			var loader:FileLoader = new FileLoader();
			loader.addEventListener(FileEvent.COMPLETE, loaderEventHandler);
			loader.load('appSystem.swf', FileType.TYPE_SWF, 'appSystem' );
		}
		
		
		
		
		private function loaderEventHandler(e:FileEvent):void 
		{
			var systemModule:IModuleMain = Loader(e.loader).content as IModuleMain;
			systemModule.addEventListener(ModuleEvent.MODULE_READY_ALL, moduleEventHandler, false, 0, true);
			addChildAt(systemModule as ApplicationDisplayObject,0);
			
			var vo:SetupVO = new SetupVO('setup', new AssetManager(), new XMLManager(), new SettingManager(), new ServiceManager(), new VOManager());
			vo.parameters = flashvars;
			
			vo.xmlManager.addAsset(new XML( new xmlConfig), AssetLibID.XML_CONFIG);
			vo.xmlManager.addAsset(new XML( new xmlSetting), AssetLibID.XML_COMMON);
			vo.xmlManager.addAsset(new XML( new xmlSettingShop), AssetLibID.XML_SHOP_MGT);
			
			systemModule.setup(this, vo);
			
			
			//NativeApplication.nativeApplication.exit(); 
		}
		
		private function moduleEventHandler(e:ModuleEvent):void 
		{
			
			removeChild( mcScreen );
			mcScreen = null;
		}
		
		private function exitingEventHandler(e:Event):void 
		{
			//new ProductManager("airappinstaller").launch("-launch " + NativeApplication.nativeApplication.applicationID + " " + NativeApplication.nativeApplication.publisherID);  
		}
		
	}
	
}