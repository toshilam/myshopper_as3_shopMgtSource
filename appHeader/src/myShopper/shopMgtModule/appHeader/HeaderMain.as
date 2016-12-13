package myShopper.shopMgtModule.appHeader
{
	import myShopper.common.interfaces.IApplicationDisplayObject;
	import myShopper.common.interfaces.IVO;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import myShopper.common.display.ModuleMain;
	import myShopper.shopMgtModule.appHeader.view.component.ApplicationHeader;
	
	/**
	 * NOTE: moudle main itself will not be added into display list.
	 * which means the stage/parent/root are null
	 * @author Toshi Lam
	 */
	public class HeaderMain extends ModuleMain 
	{
		public static const NAME:String = 'headerMain';
		
		private var _appHeader:ApplicationHeader;
		public function get appHeader():ApplicationHeader { return _appHeader; }
		public function set appHeader(inValue:ApplicationHeader):void 
		{
			_appHeader = inValue;
		}
		
		public function HeaderMain():void 
		{
			super();
			_moduleName = NAME;
		}
		
		/**
		 * this function will be called once this module is being loaded, and connected to be application shell
		 * @param	inContainer - the container assigned by application shell
		 * @param	inSetupVO - all needed resources
		 * @return
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