package myShopper.shopMgtModule.appShopMgt
{
	import myShopper.common.interfaces.IApplicationDisplayObject;
	import myShopper.common.interfaces.IVO;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import myShopper.common.display.ModuleMain;
	import myShopper.shopMgtModule.appShopMgt.view.component.ApplicationShopMgt;
	
	/**
	 * NOTE: moudle main itself will not be added into display list.
	 * which means the stage/parent/root are null
	 * @author Toshi Lam
	 */
	public class ShopMgtMain extends ModuleMain 
	{
		public static const NAME:String = 'shopMgtMain';
		
		private var _appShop:ApplicationShopMgt;
		public function get appShop():ApplicationShopMgt { return _appShop; }
		public function set appShop(inValue:ApplicationShopMgt):void 
		{
			_appShop = inValue;
		}
		
		public function ShopMgtMain():void 
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