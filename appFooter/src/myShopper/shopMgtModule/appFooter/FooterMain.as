package myShopper.shopMgtModule.appFooter
{
	import myShopper.common.interfaces.IApplicationDisplayObject;
	import myShopper.common.interfaces.IVO;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import myShopper.common.display.ModuleMain;
	import myShopper.shopMgtModule.appFooter.view.component.ApplicationFooter;
	
	/**
	 * NOTE: moudle main itself will not be added into display list.
	 * which means the stage/parent/root are null
	 * @author Toshi Lam
	 */
	public class FooterMain extends ModuleMain 
	{
		public static const NAME:String = 'footerMain';
		
		private var _appFooter:ApplicationFooter;
		public function get appFooter():ApplicationFooter { return _appFooter; }
		public function set appFooter(inValue:ApplicationFooter):void 
		{
			_appFooter = inValue;
		}
		
		public function FooterMain():void 
		{
			super();
			_moduleName = NAME;
		}
		
		/**
		 * this function will be called once this module is being loaded, and connected to be application shell
		 * @param	inContainer - the container assigned by application shell
		 * @param	inSetupVO - all needed resources
		 * @return	true if successfully set
		 */
		override public function setup(inContainer:DisplayObjectContainer, inSetupVO:IVO = null):Boolean 
		{
			if ( super.setup(inContainer, inSetupVO) )
			{
				ModuleFacade.getInstance(_moduleName).startup(this);
				
				return true;
			}
			
			return false;
		}
		
	}
	
}