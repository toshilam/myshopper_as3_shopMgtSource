package myShopper.shopMgtModule.appShopMgt.view.component 
{
	import flash.display.Stage;
	import myShopper.common.display.ApplicationDisplayObject;
	import myShopper.common.interfaces.IApplicationDisplayObject;
	import myShopper.common.utils.Tools;
	import myShopper.fl.ApplicationBG;
	import myShopper.fl.shopMgt.CustomerMenu;
	import myShopper.fl.shopMgt.MyMenu;
	import myShopper.fl.shopMgt.MyQuickMenu;
	import myShopper.fl.shopMgt.MyStatus;
	import myShopper.fl.shopMgt.ShopLogo;
	
	/**
	 * ...
	 * @author Toshi
	 */
	public class ApplicationShopMgt extends ApplicationDisplayObject
	{
		private var _bg:ApplicationBG;
		public function get bg():ApplicationBG { return _bg; }
		public function set bg(value:ApplicationBG):void 
		{
			_bg = value;
		}
		
		private var _logo:ShopLogo;
		public function get logo():ShopLogo { return _logo; }
		public function set logo(value:ShopLogo):void 
		{
			_logo = value;
		}
		
		private var _myStatus:MyStatus;
		public function get myStatus():MyStatus { return _myStatus; }
		public function set myStatus(value:MyStatus):void 
		{
			_myStatus = value;
		}
		
		private var _myQuickMenu:MyQuickMenu;
		public function get myQuickMenu():MyQuickMenu { return _myQuickMenu; }
		public function set myQuickMenu(value:MyQuickMenu):void 
		{
			_myQuickMenu = value;
		}
		
		private var _customerMenu:CustomerMenu;
		public function get customerMenu():CustomerMenu { return _customerMenu; }
		public function set customerMenu(value:CustomerMenu):void 
		{
			_customerMenu = value;
		}
		
		private var _myMenu:MyMenu;
		public function get myMenu():MyMenu { return _myMenu; }
		public function set myMenu(value:MyMenu):void 
		{
			_myMenu = value;
		}
		
		//a holder contains all the window item
		private var _windowHolder:ApplicationDisplayObject;
		public function get windowHolder():ApplicationDisplayObject { return _windowHolder; }
		
		public function ApplicationShopMgt() 
		{
			super();
		}
		
		override public function initDisplayObject(inSettingSource:Object, inStage:Stage):void 
		{
			super.initDisplayObject(inSettingSource, inStage);
			_windowHolder = addApplicationChild(new ApplicationDisplayObject(), null) as ApplicationDisplayObject;
		}
		
		override public function addApplicationChild(inApplicationDisplayObject:IApplicationDisplayObject, inSettingSource:Object, autoShowPage:Boolean = true):IApplicationDisplayObject 
		{
			var o:IApplicationDisplayObject = super.addApplicationChild(inApplicationDisplayObject, inSettingSource, autoShowPage);
			
			if (_windowHolder)
			{
				//window holder should always be on top
				setChildIndex(_windowHolder, numChildren - 1);
			}
			
			return o;
		}
		
		override public function onStageResize(inAppStage:Stage):void 
		{
			super.onStageResize(inAppStage);
			
			if (_bg)
			{
				//_bg.width = inAppStage.stageWidth;
				//_bg.height = inAppStage.stageHeight;
				
				if (_logo)
				{
					//_logo.x = 40;
					//_logo.y = 130;
					
					if (_myStatus)
					{
						_myStatus.x = _logo.x;
						_myStatus.y = _logo.y + _logo.height + 10;
						
						if (_myQuickMenu)
						{
							_myQuickMenu.x = _myStatus.x;
							_myQuickMenu.y = _myStatus.y + _myStatus.height + 10;
						}
					}
				}
				
				if (_myMenu)
				{
					var adjustY:Number = 45;
					
					if (ApplicationDisplayObject.isMobile())
					{
						adjustY *= Tools.getScalingFactorByDPI();
					}
					
					_myMenu.x = (inAppStage.stageWidth - _myMenu.width) / 2;
					_myMenu.y = inAppStage.stageHeight - _myMenu.height - adjustY;
					
					
				}
			}
		}
		
	}

}