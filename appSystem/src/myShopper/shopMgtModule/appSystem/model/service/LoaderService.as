package myShopper.shopMgtModule.appSystem.model.service 
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.FileEvent;
	import myShopper.common.net.FileLoader;
	import myShopper.common.utils.Tracer;
	
	//
	//[Event(name = "Complete", type = "myShopper.common.events.FileEvent")]
	//[Event(name = "CompleteAll", type = "myShopper.common.events.FileEvent")]
	//[Event(name = "ioError", type = "myShopper.common.events.FileEvent")]
	/**
	 * ...
	 * @author Toshi Lam
	 */
	public class LoaderService extends EventDispatcher implements IEventDispatcher 
	{
		private var _xmlLoader:XML;
		private var _targetLoadNode:XML;
		private var _targetNodeName:String;
		private var _url:String;
		private var _numLoaded:int;
		
		private var loader:FileLoader;
		
		private var _isLoadComplete:Boolean;
		public function get isLoadComplete():Boolean 
		{
			return _isLoadComplete;
		}
		
		public function LoaderService(inXMLLoader:XML, inNodeID:String) 
		{
			_xmlLoader = inXMLLoader;
			_targetNodeName = inNodeID;
			
			loader = new FileLoader();
			loader.addEventListener(FileEvent.COMPLETE, onFileLoaded);
			
			_numLoaded = 0;
			_isLoadComplete = false;
		}
		
		
		public function load():Boolean
		{
			if (_isLoadComplete)
			{
				Tracer.echo('LoaderService : load : all those are completely loaded!', this, 0xff0000);
				return false;
			}
			if (!_xmlLoader.@url.length())
			{
				Tracer.echo('LoaderService : load : url is not defined!', this, 0xff0000);
				return false;
			}
			
			_url = _xmlLoader.@url;
			
			if ( !_xmlLoader.children().(@id == _targetNodeName).length() )
			{
				Tracer.echo('LoaderService : load : targeted node not found : ' + _targetNodeName, this, 0xff0000);
				return false;
			}
			
			_targetLoadNode = _xmlLoader.children().(@id == _targetNodeName)[0];
			
			if (loadNextResource() == -1)
			{
				Tracer.echo('LoaderService : load : no file can be loaded : ' + _targetNodeName, this, 0xff0000);
				dispatchEvent(new FileEvent(FileEvent.IO_ERROR));
			}
			
			return true;
		}
		
		
		private function loadAsset(inID:String, inURL:String, inFileType:String):void
		{
			loader.load(_url + inURL, inFileType, inID)
		}
		
		
		private function onFileLoaded(e:FileEvent):void 
		{
			Tracer.echo("LoaderService : onFileLoaded : type : " + e.fileType + ", id : " + e.fileID);
			
			if (loadNextResource() == -1)
			{
				
				_isLoadComplete = true;
				
				_xmlLoader = null;
				_targetNodeName = null;
				loader.removeEventListener(FileEvent.COMPLETE, onFileLoaded);
				loader = null;
				
				dispatchEvent(new FileEvent(FileEvent.COMPLETE_ALL_FILE, e.loader, e.fileURL, e.fileType, e.fileID, e.data));
			}
			else
			{
				dispatchEvent(e.clone());
			}
		}
		
		
		private function loadNextResource():int
		{
			if (_numLoaded >= _targetLoadNode.children().length()) return -1;
			
			loadAsset
			(
				_targetLoadNode.children()[_numLoaded].@id, 
				_targetLoadNode.children()[_numLoaded].@url, 
				String(_targetLoadNode.children()[_numLoaded].@type).toLowerCase()
			);
			
			return ++_numLoaded;
		}
		
		
	}

}