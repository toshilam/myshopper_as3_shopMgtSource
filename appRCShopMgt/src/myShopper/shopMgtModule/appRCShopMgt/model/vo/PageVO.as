package myShopper.shopMgtModule.appRCShopMgt.model.vo 
{
	import myShopper.common.data.VO;
	import myShopper.common.display.ApplicationDisplayObject;
	/**
	 * ...
	 * @author Toshi
	 */
	public class PageVO extends VO
	{
		public var name:String; //name of page
		public var displayObject:ApplicationDisplayObject;
		
		public function PageVO(inID:String, inName:String, inDisplayObject:ApplicationDisplayObject) 
		{
			super(inID);
			name = inName;
			displayObject = inDisplayObject;
		}
		
	}

}