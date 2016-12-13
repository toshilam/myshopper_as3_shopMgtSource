package myShopper.shopMgtCommon 
{
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.shop.ShopOrderList;
	
	/**
	 * ...
	 * @author Toshi
	 */
	public class ShopMgtShopInfoVO extends ShopInfoVO 
	{
		
		protected var _shopClosedOrderList:ShopOrderList;
		public function get shopClosedOrderList():ShopOrderList { return _shopClosedOrderList; }
		
		//protected var _shopClosedSalesList:ShopOrderList;
		//public function get shopClosedSalesList():ShopOrderList { return _shopClosedSalesList; }
		
		public function ShopMgtShopInfoVO(inVOID:String) 
		{
			super(inVOID);
			_shopClosedOrderList = new ShopOrderList(_id);
			//_shopClosedSalesList = new ShopMgtSalesList(_id);
		}
		
		override public function clear():void 
		{
			super.clear();
			_shopClosedOrderList.clear();
			//_shopClosedSalesList.clear();
		}
	}

}