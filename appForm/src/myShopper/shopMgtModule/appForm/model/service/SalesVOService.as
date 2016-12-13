package myShopper.shopMgtModule.appForm.model.service 
{
	import myShopper.common.data.shop.ShopCategoryFormVO;
	import myShopper.common.data.shop.ShopCategoryList;
	import myShopper.common.data.shop.ShopProductFormVO;
	import myShopper.common.data.user.UserShoppingRecordProductVO;
	import myShopper.common.data.VOList;
	import myShopper.common.utils.Tools;
	/**
	 * ...
	 * @author Toshi Lam
	 */
	public class SalesVOService 
	{
		private var _categoryList:ShopCategoryList;
		
		public function SalesVOService(inCategoryList:ShopCategoryList) 
		{
			_categoryList = inCategoryList;
		}
		
		public function clear():void
		{
			_categoryList = null;
		}
		
		public function getProductByKeyword(inValue:String, inMaxRecord:int = 5):VOList
		{
			var voList:VOList = new VOList('');
			var numCategory:int = _categoryList.length;
			var reg:RegExp = new RegExp(inValue, "ig");
			
			for (var i:int = 0; i < numCategory; i++)
			{
				var categoryVO:ShopCategoryFormVO = _categoryList.getVO(i) as ShopCategoryFormVO;
				if (categoryVO)
				{
					var numProduct:int = categoryVO.numberOfProduct;
					for (var j:int = 0; j < numProduct; j++)
					{
						var productVO:ShopProductFormVO = categoryVO.productList.getVO(j) as ShopProductFormVO;
						if (productVO)
						{
							var pName:String = productVO.productName;
							var pID:String = productVO.productID;
							
							if (pName.search(reg) >= 0 || pID.search(reg) >= 0)
							{
								voList.addVO( productVO );
								
								if (voList.length >= inMaxRecord)
								{
									return voList;
								}
							}
						}
					}
				}
			}
			
			return voList;
		}
		
	}

}