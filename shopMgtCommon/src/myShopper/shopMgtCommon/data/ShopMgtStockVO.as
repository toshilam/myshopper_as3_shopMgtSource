package myShopper.shopMgtCommon.data 
{
	import myShopper.common.data.SearchVO;
	import myShopper.common.data.shop.ShopProductStockVO;
	import myShopper.common.data.VO;
	
	/**
	 * internally used between Mediator and Proxy
	 * @author Toshi Lam
	 */
	public class ShopMgtStockVO extends ShopProductStockVO 
	{
		public var searchVO:SearchVO;
		
		public function ShopMgtStockVO(inID:String) 
		{
			super(inID);
			searchVO = new SearchVO(inID);
			
		}
		
	}

}