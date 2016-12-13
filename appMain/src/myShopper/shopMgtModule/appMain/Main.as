package myShopper.shopMgtModule.appMain
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import myShopper.common.emun.FileType;
	import myShopper.common.events.FileEvent;
	import myShopper.common.events.ModuleEvent;
	import myShopper.common.interfaces.IApplicationDisplayObject;
	import myShopper.common.interfaces.IDisplayObjectList;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.net.FileLoader;
	import myShopper.common.utils.Tracer;
	import myShopper.fl.loading.Loading;
	
	
	/**
	 * ...
	 * @author Toshi Lam
	 */
	[SWF(backgroundColor = 0x808080)]
	public class Main extends Sprite implements IApplicationDisplayObject
	{
		[Embed(source = "../../../../../../mainSource/appMain/src/myShopper/module/appMain/loading.swf")]
		private var LoadIcon:Class;
		
		private var loading:Loading;
		
		//[Embed(source = "../../../../../../../asset/assetMain/ScreenMobile.swf")]
		//private var Screen:Class;
		
		private var mcScreen:MovieClip;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			Tracer.echo('Main : init : application startup!', this, 0xff0000);
			
			/* loading screen */
			loading = new Loading(new LoadIcon() as Sprite);
			addChild( loading );
			//mcScreen = new Screen() as MovieClip;
			//addChild( mcScreen );
			
			var loader:FileLoader = new FileLoader();
			loader.addEventListener(FileEvent.COMPLETE, loaderEventHandler);
			loader.load('appSystem.swf', FileType.TYPE_SWF, 'appSystem' );
			
		}
		
		private function loaderEventHandler(e:FileEvent):void 
		{
			var systemModule:IModuleMain = Loader(e.loader).content as IModuleMain;
			systemModule['addEventListener'](ModuleEvent.MODULE_READY_ALL, moduleEventHandler, false, 0, true);
			addChildAt(systemModule as DisplayObject,0);
			systemModule.setup(this/*, new SetupVO('setup', new AssetManager(), new XMLManager(), new SettingManager())*/);
			
		}
		
		private function moduleEventHandler(e:ModuleEvent):void 
		{
			loading.destory();
			removeChild( loading );
			loading = null;
			//removeChild( mcScreen );
			//mcScreen = null;
		}
		
		/* INTERFACE myShopper.common.interfaces.IApplicationDisplayObject */
		
		protected var _isClosed:Boolean;
		
		protected var _id:String;
		
		public function get id():String 
		{
			return _id;
		}
		
		public function set id(value:String):void 
		{
			_id = value;
		}
		
		protected var _XMLSetting:XML;
		
		public function get XMLSetting():XML 
		{
			return _XMLSetting;
		}
		
		protected var _subDisplayObjectList:IDisplayObjectList;
		
		public function get subDisplayObjectList():IDisplayObjectList 
		{
			return _subDisplayObjectList;
		}
		
		public function initDisplayObject(inSettingSource:Object, inStage:Stage):void 
		{
			
		}
		
		public function addApplicationChild(inApplicationDisplayObject:IApplicationDisplayObject, inSettingSource:Object, /*inStage:Stage,*/ autoShowPage:Boolean = true):IApplicationDisplayObject 
		{
			return null;
		}
		
		public function addApplicationChildAt(inApplicationDisplayObject:IApplicationDisplayObject, inSettingSource:Object, /*inStage:Stage,*/ inIndex:uint = 0, autoShowPage:Boolean = true):IApplicationDisplayObject 
		{
			return null;
		}
		
		public function removeApplicationChild(inApplicationDisplayObject:IApplicationDisplayObject, autoClosePage:Boolean = true):void 
		{
			
		}
		
		public function hasApplicationChild(inApplicationDisplayObject:IApplicationDisplayObject):Boolean 
		{
			return false;
		}
		
		public function onStageResize(inApp:Stage):void 
		{
			
		}
		
		public function get isClosed():Boolean 
		{
			return _isClosed;
		}
		
		public function closePage(inObjTweenerEffect:Object = null):void 
		{
			
		}
		
		public function showPage(inObjTweenerEffect:Object = null):void 
		{
			
		}
		
	}
	
}