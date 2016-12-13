package myShopper.shopMgtModule.appFooter.view.component 
{
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import myShopper.common.display.ApplicationDisplayObject;
	import myShopper.common.interfaces.IApplicationDisplayObject;
	
	/**
	 * ...
	 * @author Toshi
	 */
	public class ApplicationFooter extends ApplicationDisplayObject
	{
		/*private var _footerMenu:FooterMenu;
		public function get footerMenu():FooterMenu { return _footerMenu; }
		private var _footerBar:FooterBar
		public function get footerBar():FooterBar { return _footerBar; }*/
		
		public function ApplicationFooter() 
		{
			super();
		}
		
		override public function addApplicationChild(inApplicationDisplayObject:IApplicationDisplayObject, inSettingSource:Object, /*inStage:Stage,*/ autoShowPage:Boolean = true):IApplicationDisplayObject 
		{
			/*if (inApplicationDisplayObject is FooterMenu) 
			{
				_footerMenu = inApplicationDisplayObject as FooterMenu;
			}
			else if (inApplicationDisplayObject is FooterBar) 
			{
				_footerBar = inApplicationDisplayObject as FooterBar;
				Tweener.addTween( _footerBar.bg, TweenerEffect.setGlow(1, 'easeOutSine', 0x000000, 10, 5, .7));*/
			
			return super.addApplicationChild(inApplicationDisplayObject, inSettingSource/*, inStage*/);
		}
		
		override protected function initDisplayObjectPosition(inAppStage:Stage, inAutoAdjust:Boolean = true, inException:Array = null):void 
		{
			super.initDisplayObjectPosition(inAppStage, false, inException);
		}
		
		
	}

}