package myShopper.shopMgtCommon.data 
{
	import myShopper.common.data.SearchVO;
	import myShopper.common.data.VO;
	
	/**
	 * ...
	 * @author Toshi Lam
	 */
	public class SalesCheckVO extends VO 
	{
		public static const DEFAULT_RECORD_COUNT:int = 50;
		
		public var searchVO:SearchVO;
		
		//public var fromDate:String;
		//public var toDate:String;
		//public var count:int;
		//public var index:int;
		public var shippingMethod:String; //order= / sales=OrderShipmentID.SHOP_SALES
		
		public function SalesCheckVO(inID:String, inFromDate:String, inToDate:String, inCount:int, inIndex:int, inShippingMethod:String ) 
		{
			super(inID);
			searchVO = new SearchVO(inID);
			searchVO.fromDate = inFromDate;
			searchVO.toDate = inToDate;
			searchVO.count = inCount;
			searchVO.index = inIndex;
			
			shippingMethod = inShippingMethod;
		}
		
	}

}