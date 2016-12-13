package myShopper.shopMgtModule.appHeader.view.component 
{
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import myShopper.common.display.ApplicationDisplayObject;
	import myShopper.common.interfaces.IApplicationDisplayObject;
	
	/**
	 * ...
	 * @author Toshi
	 */
	public class ApplicationHeader extends ApplicationDisplayObject
	{
		/*private var _headerMenu:HeaderMenu;
		public function get headerMenu():HeaderMenu { return _headerMenu; }
		
		private var _logo:Logo;
		public function get logo():Logo { return _logo; }
		
		private var _headerNetvigator:HeaderNetvigator;
		public function get headerNetvigator():HeaderNetvigator { return _headerNetvigator; }
		
		private var _headerMenuButtonList:IButtonList;*/
		
		public function ApplicationHeader() 
		{
			super();
		}
		
		override public function initDisplayObject(inSettingSource:Object, inStage:Stage):void 
		{
			//addEventListener(ApplicationUserEvent.RESULT_USER_LOGIN, userEventHandler);
			//addEventListener(ApplicationUserEvent.RESULT_USER_LOGOUT, userEventHandler);
			
			super.initDisplayObject(inSettingSource, inStage);
		}
		
		override public function destroyDisplayObject():void 
		{
			//removeEventListener(ApplicationUserEvent.RESULT_USER_LOGIN, userEventHandler);
			//removeEventListener(ApplicationUserEvent.RESULT_USER_LOGOUT, userEventHandler);
			
			super.destroyDisplayObject();
		}
		
		override public function addApplicationChild(inApplicationDisplayObject:IApplicationDisplayObject, inSettingSource:Object, /*inStage:Stage,*/ autoShowPage:Boolean = true):IApplicationDisplayObject 
		{
			//if (inApplicationDisplayObject is HeaderMenu && _headerMenu == null) _headerMenu = inApplicationDisplayObject as HeaderMenu;
			//if (inApplicationDisplayObject is Logo && _logo == null) _logo = inApplicationDisplayObject as Logo;
			//if (inApplicationDisplayObject is HeaderNetvigator && _headerNetvigator == null) _headerNetvigator = inApplicationDisplayObject as HeaderNetvigator;
			
			return super.addApplicationChild(inApplicationDisplayObject, inSettingSource/*, inStage*/);
		}
		
		/*private function userEventHandler(e:ApplicationUserEvent):void 
		{
			switch(e.type)
			{
				case ApplicationUserEvent.RESULT_USER_LOGIN:
				case ApplicationUserEvent.RESULT_USER_LOGOUT:
				{
					if (e.data != null && e.data is IButtonList)
					{
						_headerMenuButtonList = e.data as IButtonList;
						
						_headerMenu.addEventListener(ApplicationEvent.BUTTONS_REMOVED, headerMenuEventHandler);
						_headerMenu.removeButtons();
					}
					break;
				}
			}
		}*/
		
		/*private function headerMenuEventHandler(e:ApplicationEvent):void 
		{
			//Tracer.echo('headerMenuEventHandler : addButtons : ' + _headerMenuButtonList,this, 0xff0000);
			_headerMenu.addButtons(_headerMenuButtonList);
			for (var i:int = 0; i < _headerMenu.buttonList.length; i++)
			{
				_headerMenu.buttonList.getButtonByIndex(i).addListener(this);
			}
			
		}*/
		
	}

}