package myShopper.shopMgtCommon.data 
{
	import myShopper.common.data.shop.ShopOrderVO;
	import myShopper.common.data.shop.ShopProductFormVO;
	import myShopper.common.data.shop.ShopProductList;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.data.VO;
	import myShopper.common.data.VOList;
	import myShopper.common.interfaces.IVO;
	
	/**
	 * ...
	 * @author Toshi
	 */
	public class ShopMgtSalesVO extends ShopOrderVO 
	{
		//public var userInfoVO:UserInfoVO;
		//public var orderNo:String;  //db no
		//public var invoiceNo:String; //sp-xxxxxx-xxxxx-xxxx
		//public var remark:String;
		//public var total:String; //total product price
		//public var finalTotal:String; //total product price + extra + tax + any other
		//public var shopCurrency:int; //used in shopMgt only
		//public var dateTime:String; 
		//public var payMethod:String; //TODO : to be created by user
		//public var paid:String; //total paid by customer
		
		//contains UserShoppingCartProductVO
		//protected var _productList:ShopProductList;
		//public function get productList():ShopProductList { return _productList; }
		
		//contains a list of extra fee/discount/product
		//protected var _extraList:VOList;
		//public function get extraList():VOList { return _extraList; }
		
		public var withPrint:Boolean;
		public var printSize:int; //A4 / 80mm
		
		public function ShopMgtSalesVO(inID:String/*, inLangCode:String=''*/) 
		{
			super(inID);
			withPrint = false;
			printSize = -1;
			//clear();
			//userInfoVO = new UserInfoVO(inID);
			//
			//_productList = new ShopProductList(inID);
			//_extraList = new VOList(inID);
		}
		
		/**
		 * 
		 * @param	inProductNo
		 * @return	-1 if not found, else index of the product vo in ShopProductList
		 */ 
		/*public function isProductExist(inProductNo:String):int
		{
			var numItem:int = _productList.length;
			for (var i:int = 0; i < numItem; i++)
			{
				var vo:ShopProductFormVO = _productList.getVO(i) as ShopProductFormVO;
				if (vo && vo.productNo == inProductNo)
				{
					return i;
				}
			}
			
			return -1;
		}*/
		
		/*override public function clone():IVO 
		{
			throw new Error('ShopMgtSalesVO : clone : cannot be cloned!');
		}*/
		
		/*override public function clear():void 
		{
			super.clear();
			if(userInfoVO) userInfoVO.clear();
			if(_productList) _productList.clear();
			if(_extraList) _extraList.clear();
			
			//userInfoVO = null;
			//_productList = null;
			//_extraList = null;
			shopCurrency = -1;
			orderNo = invoiceNo = remark = payMethod = total = dateTime = paid = finalTotal = '';
			//txtShippingCompany = txtShippingNo = '';
		}*/
	}

}