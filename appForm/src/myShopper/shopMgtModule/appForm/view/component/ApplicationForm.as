package myShopper.shopMgtModule.appForm.view.component 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;
	import myShopper.common.display.ApplicationDisplayObject;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.interfaces.IApplicationDisplayObject;
	import myShopper.common.interfaces.IForm;
	import myShopper.common.ui.TabbingManager;
	import myShopper.fl.window.BaseWindow;
	
	/**
	 * ...
	 * @author Toshi
	 */
	public class ApplicationForm extends ApplicationDisplayObject
	{
		private var tabbingManager:TabbingManager;
		
		public function ApplicationForm() 
		{
			super();
			tabbingManager = TabbingManager.getInstance();
		}
		
		override public function addApplicationChild(inApplicationDisplayObject:IApplicationDisplayObject, inSettingSource:Object, autoShowPage:Boolean = true):IApplicationDisplayObject 
		{
			var obj:IApplicationDisplayObject = super.addApplicationChild(inApplicationDisplayObject, inSettingSource, autoShowPage);
			dispatchEventByChild(obj as DisplayObject);
			
			return obj;
		}
		
		override public function addApplicationChildAt(inApplicationDisplayObject:IApplicationDisplayObject, inSettingSource:Object, inIndex:uint = 0, autoShowPage:Boolean = true):IApplicationDisplayObject 
		{
			var isTop:Boolean = inIndex >= numChildren - 1;
			var obj:IApplicationDisplayObject = super.addApplicationChildAt(inApplicationDisplayObject, inSettingSource, inIndex, autoShowPage);
			
			if (isTop)
			{
				dispatchEventByChild(inApplicationDisplayObject as DisplayObject);
			}
			
			return obj;
		}
		
		override public function setChildIndex(child:DisplayObject, index:int):void 
		{
			var isTop:Boolean = index >= numChildren - 1;
			
			super.setChildIndex(child, index);
			
			
			//disable tab if the displayobject is not on the top of container
			/*var numItem:int = subDisplayObjectList.length;
			for (var i:int = 0; i < numItem; i++)
			{
				var d:ApplicationDisplayObject = subDisplayObjectList.getDisplayObjectByIndex(i) as ApplicationDisplayObject;
				if (d is BaseWindow)
				{
					d.tabEnabled = false;
					d.tabChildren = false;
				}
			}
			
			if (child is DisplayObjectContainer)
			{
				var container:DisplayObjectContainer = child as DisplayObjectContainer;
				container.tabEnabled = true;
				container.tabChildren = true;
			}*/
			
			if (isTop && child )
			{
				dispatchEventByChild(child);
			}
		}
		
		public function removeAllWindow():void
		{
			var numItem:int = subDisplayObjectList.length;
			var arrWindow:Vector.<BaseWindow> = new Vector.<BaseWindow>();
			
			for (var i:int = 0; i < numItem; i++)
			{
				var target:BaseWindow = subDisplayObjectList.getDisplayObjectByIndex(i) as BaseWindow;
				if (target)
				{
					arrWindow.push(target);
				}
			}
			
			while (arrWindow.length)
			{
				var targetWindow:BaseWindow = arrWindow.splice(0, 1)[0];
				targetWindow.btnClose.dispatchEvent(new ButtonEvent(ButtonEvent.CLICK, targetWindow.btnClose));
			}
		}
		
		public function dispatchEventByChild(inChild:DisplayObject):void
		{
			inChild.dispatchEvent(new ApplicationEvent(ApplicationEvent.SET_INDEX, inChild));
		}
	}

}