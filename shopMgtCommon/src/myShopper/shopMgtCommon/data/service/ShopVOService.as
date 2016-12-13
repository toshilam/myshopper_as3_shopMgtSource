package myShopper.shopMgtCommon.data.service 
{
	import com.chewtinfoil.utils.DateUtils;
	import myShopper.amf.shop.data.CategoryVO;
	import myShopper.amf.shop.data.ProductVO;
	import myShopper.common.data.FileImageVO;
	import myShopper.common.data.service.ImageVOService;
	import myShopper.common.data.service.ShopperVOService;
	import myShopper.common.data.shop.ShopCategoryFormVO;
	import myShopper.common.data.shop.ShopCustomPageVO;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.shop.ShopNewsVO;
	import myShopper.common.data.shop.ShopOrderExtraVO;
	import myShopper.common.data.shop.ShopOrderList;
	import myShopper.common.data.shop.ShopOrderVO;
	import myShopper.common.data.shop.ShopProductFormVO;
	import myShopper.common.data.shop.ShopProductStockVO;
	import myShopper.common.data.shopper.ShopperCategoryList;
	import myShopper.common.data.user.UserShoppingCartProductVO;
	import myShopper.common.data.user.UserShoppingCartVO;
	import myShopper.common.data.VOList;
	import myShopper.common.emun.FileType;
	import myShopper.common.emun.OrderExtraTypeID;
	import myShopper.common.emun.OrderStatusID;
	import myShopper.common.emun.PageID;
	import myShopper.common.utils.DateUtil;
	import myShopper.common.utils.Tools;
	import myShopper.common.utils.Tracer;
	import myShopper.shopMgtCommon.data.ShopMgtSalesVO;
	import myShopper.shopMgtCommon.ShopMgtShopInfoVO;
	/**
	 * ...
	 * @author Toshi Lam
	 */
	public class ShopVOService 
	{
		private var _shopInfo:ShopMgtShopInfoVO;
		
		public function ShopVOService(inInfoVO:ShopMgtShopInfoVO) 
		{
			_shopInfo = inInfoVO;
		}
		
		public function clear():void
		{
			_shopInfo = null;
		}
		
		//use common instead
		/*public static function getFinalTotalByVO(inVO:ShopOrderVO):Number
		{
			var subTotal:Number = myShopper.common.data.service.ShopVOService.getOrderSubTotalByVO(inVO.productList);
			var extraTotal:Number = myShopper.common.data.service.ShopVOService.getOrderExtraTotalByVO(inVO.extraList);
			var shippingFee:Number = Number(inVO.shippingFee) ? Number(inVO.shippingFee) : 0;
			
			return subTotal + extraTotal + shippingFee;
		}*/
		
		public static function getSalesInvoiceNo(inShopVO:ShopInfoVO):String
		{
			//TODO : think a way of creating an unique no for multi-user use
			var now:Date = new Date();
			var month:String = String(now.getMonth() + 1);
			month = month.length == 1 ? '0' + month : month;
			
			var day:String = now.getDate().toString();
			day = day.length == 1 ? '0' + day : day;
			
			return inShopVO.shopNo + '-' + now.getFullYear().toString() + month + day + '-' + now.getTime();
		}
		
		public static function getOrderExtraArrayByVO(inVOList:VOList):Array
		{
			var numItem:int = inVOList.length;
			var arrExtra:Array = new Array();
			for (var i:int = 0; i < numItem; i++)
			{
				var vo:ShopOrderExtraVO = inVOList.getVO(i) as ShopOrderExtraVO;
				if (vo)
				{
					var objExtra:Object = new Object();
					objExtra['e_name'] = vo.name;
					objExtra['e_type'] = vo.type;
					objExtra['e_total'] = vo.total;
					
					arrExtra.push(objExtra);
				}
			}
			
			return arrExtra;
		}
		
		public function setDeleteSales(inData:Object):Boolean
		{
			var orderNo:String = inData ? inData['o_no'] : null;
			
			if (orderNo)
			{
				var orderList:ShopOrderList = _shopInfo.shopClosedOrderList;
				var numItem:int = orderList.length;
				for (var i:int = 0; i < numItem; i++)
				{
					var vo:ShopOrderVO = _shopInfo.shopClosedOrderList.getVO(i) as ShopOrderVO;
					if (vo && vo.orderNo == orderNo)
					{
						vo.isDelete = true;
						return true;
					}
				}
			}
			
			
			return false;
		}
		
		
		public static function getArrayCBOrderStatusByXML(inXML:XML):Array
		{
			var arrStatus:Array = new Array();
			if (inXML)
			{
				
				var numItem:int = inXML.*.length();
				for (var i:int = 0; i < numItem; i++)
				{
					var targetNode:XML = inXML.*[i];
					var data:String = targetNode.@data.toString();
					var label:String = targetNode.@label.toString();
					
					if (data != OrderStatusID.ORDER_PREPARE_DELIVERY && data != OrderStatusID.ORDER_DELIVERING && data != OrderStatusID.ORDER_DELIVERED)
					{
						continue;
					}
					
					arrStatus.push( { data:data, label:label } );
				}
				
				
			}
			
			return arrStatus;
		}
		
		public static function isShopLogoImage(inData:Object):Boolean
		{
			return inData && inData['i_path'] == FileType.PATH_SHOP_LOGO;
		}
		
		public static function isShopBGImage(inData:Object):Boolean
		{
			return inData && inData['i_path'] == FileType.PATH_SHOP_BG;
		}
		
		public static function getShopImageObj(inData:FileImageVO, inShopID:String):Object
		{
			return ImageVOService.getRemoteImageObj(inData, inShopID);
		}
		
		public function setShopInfo(inData:Object, inCategoryList:ShopperCategoryList):ShopMgtShopInfoVO 
		{
			if (inData == null || inData['s_user_id'] == null) 
			{
				Tracer.echo('ShopService : addShopInfo : data property not found s_no', this, 0xff0000 );
				return null;
			}
				
			//if (_shopInfo.id != inData['s_no'])
			//{
				//use s_no (will be translated to {hksp1-XXXXXX} in server side) as vo ID 
				var vo:ShopMgtShopInfoVO = _shopInfo;
				vo.shopNo = inData['s_no'];
				vo.uid = inData['s_user_id'];
				vo.payPalEmail = inData['s_paypal_email'];
				vo.payPalFirstName = inData['s_paypal_first_name'];
				vo.payPalLastName = inData['s_paypal_last_name'];
				vo.name = inData['s_name'];
				vo.phone = inData['s_phone'];
				//vo.productType = inData['s_product_type'];
				vo.intro = inData['s_intro'];
				//vo.room = inData['s_room'];
				//vo.house = inData['s_house'];
				//vo.street = inData['s_street'];
				vo.address = inData['s_address']; 
				vo.district = inData['s_district'];
				vo.area = inData['s_area_no'];
				vo.city = inData['s_city'];
				vo.state = inData['s_state'];
				vo.country = inData['s_country'];
				vo.lat = Number(inData['s_lat']);
				vo.lng = Number(inData['s_lng']);
				vo.status = inData['s_status'];
				vo.currency = int(inData['s_currency']);
				vo.tax = Number(inData['s_tax'] ? inData['s_tax'] : 0);
				vo.paypalAccVerified = String(inData['s_paypal_verified']) == '1';
				
				ShopperVOService.setShopperCategoryListByCategoryNoArray(inData['s_product_type'], vo.productTypeList, inCategoryList);
				vo.productType = ShopperVOService.getCategoryStringBySelectedShopperCategory(vo.productTypeList);
				
				//vo.infoApproved = inData['isApproved'] === true;
				setIsShopInfoApproved(inData);
				return vo;
			//}
			
			return null
		}
		
		public function setIsShopInfoApproved(inData:Object):Boolean
		{
			if (inData == null || inData['isApproved'] == null) 
			{
				Tracer.echo('ShopService : setIsShopInfoApproved : data property not found isApproved', this, 0xff0000 );
				return false;
			}
			
			var vo:ShopInfoVO = _shopInfo;
			vo.infoApproved = inData['isApproved'] === true;
			
			return true;
		}
		
		//NOT USED?
		/*public function setIsShopPaypalAccVerified(inData:Object):Boolean
		{
			if (inData == null || inData['isApproved'] == null) 
			{
				Tracer.echo('ShopService : setIsShopInfoApproved : data property not found isApproved', this, 0xff0000 );
				return false;
			}
			
			var vo:ShopInfoVO = _shopInfo;
			vo.infoApproved = inData['isApproved'] === true;
			
			return true;
		}*/
		
		public function setShopOrder(inData:Object, inIsClosedOrder:Boolean = false):ShopInfoVO 
		{
			if (inData == null || !(inData is Array) /*|| !inData['o_timeStamp']*/) 
			{
				Tracer.echo('ShopService : setShopOrder : unknown data type : ' + inData, this, 0xff0000 );
				return null;
			}
			var vo:ShopMgtShopInfoVO = _shopInfo;
			var shopOrderList:ShopOrderList = inIsClosedOrder ? vo.shopClosedOrderList : vo.shopOrderList;
			
			//the time which requested data
			//shopOrderList.timeStamp = inData['o_timeStamp'];
			
			//clear all previous added data
			shopOrderList.clear();
			
			
			var numItem:int = (inData as Array).length;
			
			for (var i:int = 0; i < numItem; i++)
			{
				var data:Object = inData[i];
				
				//var oVO:ShopOrderVO = new ShopOrderVO(data['o_no']);
				var oVO:ShopMgtSalesVO = new ShopMgtSalesVO(data['o_no']);
				oVO.address = data['o_address']; //ship to
				oVO.dateTime = DateUtil.getDateStringByUTCDateString( String(data['o_date_time']) );
				oVO.orderNo = data['o_no'];
				oVO.invoiceNo = data['o_invoice_no'];
				oVO.remark = Tools.replaceRestrictedString(data['o_remark']); //remark by user
				oVO.shippingRemark = Tools.replaceRestrictedString(data['o_shipping_remark']); //remark by shop
				oVO.shippingMethod = data['o_shipping_method'];
				oVO.status = data['o_status'];
				oVO.total = Number(data['o_total']) ? data['o_total'] : '0';
				oVO.shippingFee = Number(data['o_shipping_fee']) ? data['o_shipping_fee'] : '0'; 
				oVO.finalTotal = data['o_final_total']; //final total may be null if it is online order
				oVO.paid = Number(data['o_user_paid']) ? data['o_user_paid'] : oVO.finalTotal; //if o_user_paid not set, means online order
				oVO.payKey = data['o_pay_key'];
				oVO.email = data['o_email'];
				oVO.phone = data['o_phone'];
				oVO.isRead = data['o_read'] == '1';
				oVO.shopCurrency = data['o_currency'];
				oVO.payMethod = data['o_pay_type'];
				
				oVO.userInfoVO.uid = data['o_user_id'];
				oVO.userInfoVO.firstName = data['u_first_name'];
				
				oVO.isDelete = String(data['o_is_delete']) == '1';
				shopOrderList.addVO(oVO);
			}
			
			return vo;
			
		}
		
		public function setShopOrderProduct(inData:Object, inOrderVO:ShopOrderVO):ShopInfoVO 
		{
			if (inData == null || !(inData is Array) || !(inOrderVO is ShopOrderVO) )
			{
				Tracer.echo('ShopService : setShopOrderProduct : unknown data type : ' + inData, this, 0xff0000 );
				return null;
			}
			var vo:ShopInfoVO = _shopInfo;
			
			inOrderVO.productList.clear();
			
			var numItem:int = (inData as Array).length;
			
			for (var i:int = 0; i < numItem; i++)
			{
				var data:Object = inData[i];
				
				var oVO:UserShoppingCartProductVO = new UserShoppingCartProductVO('');
				oVO.productNo = data['o_product_no'];
				oVO.productCategoryNo = data['o_category_no'];
				oVO.productPrice = data['o_price'];
				oVO.productDiscount = data['o_discount'];
				oVO.qty = data['o_qty'];
				oVO.productTax = data['o_tax'];
				oVO.productCategoryName = data['c_category'];
				//oVO.productName = data['p_name']; //CHANGED : 04062012 : avoid language problem
				oVO.productName = data['p_id'];
				
				var imageData:Object = data['i_image'];
				if (imageData)
				{
					ImageVOService.setImageVO(oVO.getPhotoVO(), imageData)
					//oVO.photoFileVO.data = imageData['i_data'];
					//oVO.photoFileVO.name = imageData['i_name'];
					//oVO.photoFileVO.path = imageData['i_path'];
				}
			
				
				
				inOrderVO.productList.addVO(oVO);
			}
			
			return vo;
			
		}
		
		
		
		public function setShopLogo(inData:Object):ShopInfoVO
		{
			var vo:ShopInfoVO = _shopInfo/*.getVOByUID(inData['i_user_id']) as ShopInfoVO;*/
			if (vo == null) return null;
			
			return ImageVOService.setImageVO(vo.logoFileVO, inData) ? vo : null;
			
			//vo.logoFileVO.name = inData['i_name'];
			//vo.logoFileVO.data = inData['i_data'];
			//vo.logoFileVO.path = inData['i_path'];
			
			//return vo;
		}
		
		public function setShopBG(inData:Object):ShopInfoVO
		{
			var vo:ShopInfoVO = _shopInfo/*.getVOByUID(inData['i_user_id']) as ShopInfoVO;*/
			if (vo == null) return null;
			
			return ImageVOService.setImageVO(vo.bgFileVO, inData) ? vo : null;
			
			//vo.bgFileVO.name = inData['i_name'];
			//vo.bgFileVO.data = inData['i_data'];
			//vo.bgFileVO.path = inData['i_path'];
			//
			//return vo;
		}
		
		public function setShopLogoByVO(inData:FileImageVO):ShopInfoVO
		{
			var vo:ShopInfoVO = _shopInfo/*.getVOByUID(inData['i_user_id']) as ShopInfoVO;*/
			if (vo == null || inData == null) return null;
			
			//vo.logoFileVO.name = inData.name;
			//vo.logoFileVO.data = inData.data;
			//vo.logoFileVO.path = inData.path;
			//vo.logoFileVO.size = inData.size;
			//vo.logoFileVO.type = inData.type;
			ImageVOService.setImageVOByVO(vo.logoFileVO, inData);
			return vo;
		}
		
		public function setShopBGByVO(inData:FileImageVO):ShopInfoVO
		{
			var vo:ShopInfoVO = _shopInfo/*.getVOByUID(inData['i_user_id']) as ShopInfoVO;*/
			if (vo == null || inData == null) return null;
			
			//vo.bgFileVO.name = inData.name;
			//vo.bgFileVO.data = inData.data;
			//vo.bgFileVO.path = inData.path;
			//vo.bgFileVO.size = inData.size;
			//vo.bgFileVO.type = inData.type;
			ImageVOService.setImageVOByVO(vo.bgFileVO, inData);
			return vo;
		}
		
		
		public function setShopProductImage(inData:Object):ShopInfoVO
		{
			var vo:ShopInfoVO = _shopInfo/*.getVOByUID(inData['i_user_id']) as ShopInfoVO;*/
			if (!vo) return null;
			
			var categoryVO:ShopCategoryFormVO = vo.productCategoryList.getVOByCategoryNo(inData['i_category_no']) as ShopCategoryFormVO;
			if (!categoryVO) return null;
			
			var index:int = inData['i_index'] != undefined ? inData['i_index'] : 0;
			var imageVO:FileImageVO = ShopProductFormVO(categoryVO.productList.getVOByProductNo(inData['i_product_no'])).getPhotoVO(index);
			if (!imageVO) return null;
			
			ImageVOService.setImageVO(imageVO, inData);
			//imageVO.data = inData['i_data'];
			//imageVO.name = inData['i_name'];
			//imageVO.path = inData['i_path'];
			//imageVO.size = inData['i_size'];
			//imageVO.type = inData['i_type'];
			imageVO.userID = inData['i_user_id'];
			
			return vo;
		}
		
		public function setShopCustomImage(inData:Object):ShopInfoVO
		{
			var vo:ShopInfoVO = _shopInfo/*.getVOByUID(inData['i_user_id']) as ShopInfoVO;*/
			if (!vo) return null;
			
			var customVO:ShopCustomPageVO = vo.customPageList.getVOByPageNo(inData['i_extra']) as ShopCustomPageVO;
			if (!customVO) return null;
			
			var imageVO:FileImageVO = customVO.photoFileVO;
			if (!imageVO) return null;
			
			ImageVOService.setImageVO(imageVO, inData);
			//imageVO.data = inData['i_data'];
			//imageVO.name = inData['i_name'];
			//imageVO.path = inData['i_path'];
			//imageVO.size = inData['i_size'];
			//imageVO.type = inData['i_type'];
			imageVO.userID = inData['i_user_id'];
			
			return vo;
		}
		
		public function setShopAbout(inData:Object):ShopInfoVO
		{
			var vo:ShopInfoVO = _shopInfo/*.getVOByUID(inData['a_user_id']) as ShopInfoVO;*/
			if (vo == null || !inData) return null;
			
			var title:String = inData['a_title'];
			var about:String = inData['a_about'];
			
			//about
			vo.aboutTitle = title ? Tools.replaceRestrictedString(title) : '';
			vo.about = about ? Tools.replaceRestrictedString(about) : '';
			
			return vo
		}
		
		public function setShopNews(inData:Object):ShopInfoVO
		{
			var vo:ShopInfoVO = _shopInfo/*.getVOByUID(inData['c_user_id']) as ShopInfoVO;*/
			if (vo == null) return null;
			
			if (inData is Array && (inData as Array).length > 0)
			{
				var arrResult:Array = inData as Array;
				
				for (var i:int = 0; i < arrResult.length; i++)
				{
					var newsData:Object = arrResult[i];
					
					var newsNo:String = newsData['n_no'];
					
					if (newsNo)
					{
						var content:String = newsData['n_content'];
						var date:String = DateUtil.getDateStringByUTCDateString( String(newsData['n_date_time']) );
						var title:String = newsData['n_title'];
						
						content = content ? Tools.replaceRestrictedString(content) : '';
						title = title ? Tools.replaceRestrictedString(title) : '';
						
						var newsVO:ShopNewsVO = _shopInfo.newList.getVOByID(newsNo) as ShopNewsVO;
						
						if (newsVO)
						{
							newsVO.content = content
							newsVO.date = date;
							newsVO.title = title;
						}
						else
						{
							newsVO = new ShopNewsVO(newsNo, title, content, date);
							_shopInfo.newList.addVO(newsVO);
						}
					}
					else
					{
						Tracer.echo('ShopVOService : setShopNews : unknown data type : ' + newsData, this, 0xff0000);
						return null;
					}
				}
			}
			else
			{
				Tracer.echo('ShopVOService : setShopNews : no data get from server!', this, 0xff0000);
			}
			
			return vo;
		}
		
		public function setShopCustom(inData:Object):ShopInfoVO
		{
			if (!_shopInfo) return null;
			
			if (inData is Array && (inData as Array).length > 0)
			{
				var arrResult:Array = inData as Array;
				
				//_shopInfo.customPageList.clear();
				
				for (var i:int = 0; i < arrResult.length; i++)
				{
					var data:Object = arrResult[i];
					
					var no:String = data['c_no'];
					
					if (no)
					{
						var content:String = data['c_content'];
						var date:String = DateUtil.getDateStringByUTCDateString( String(data['c_date_time']) );
						var title:String = data['c_title'];
						var name:String = data['c_name'];
						var id:String = data['c_id'];
						
						content = content ? Tools.replaceRestrictedString(content) : '';
						title = title ? Tools.replaceRestrictedString(title) : '';
						name = name ? Tools.replaceRestrictedString(name) : '';
						
						var vo:ShopCustomPageVO = _shopInfo.customPageList.getVOByPageNo(no) as ShopCustomPageVO;
						
						if (vo)
						{
							vo.pageContent = content;
							vo.date = date;
							vo.pageTitle = title;
							vo.pageName = name;
						}
						else
						{
							vo = new ShopCustomPageVO(no, no, id, name, title, content, date);
							_shopInfo.customPageList.addVO(vo);
						}
					}
					else
					{
						Tracer.echo('ShopVOService : setShopNews : unknown data type : ' + data, this, 0xff0000);
						return null;
					}
				}
			}
			else
			{
				Tracer.echo('ShopVOService : setShopNews : no data get from server!', this, 0xff0000);
			}
			
			return _shopInfo;
		}
		
		public function setShopCategory(inData:Object):ShopInfoVO
		{
			var vo:ShopInfoVO = _shopInfo/*.getVOByUID(inData['c_user_id']) as ShopInfoVO;*/
			if (vo == null) return null;
			
			//category
			if (inData is Array && (inData as Array).length > 0)
			{
				var arrResult:Array = inData as Array;
				
				for (var i:int = 0; i < arrResult.length; i++)
				{
					var categoryInfo:CategoryVO = arrResult[i] as CategoryVO;
					
					if (categoryInfo)
					{
						//if it's private category, no set needed / NOTE: in shopMgt case, no need to skip
						//if ((categoryInfo.isPrivate)) continue;
						
						//if no product under this category, no set needed / NOTE: in shopMgt case, no need to skip
						//if (!(categoryInfo.product is Array) || !(categoryInfo.product as Array).length) continue;
						
						// shop/{hksp-xxxxxx}/shop-products/{catagory} //url to be handle by swfAddress proxy?
						var url:String = PageID.SHOP + '/' + vo.shopNo + '/' + PageID.SHOP_PRODUCT + '/' + Tools.spaceToHyphen(categoryInfo.category);
						
						var categoryVO:ShopCategoryFormVO;
						
						if (!vo.productCategoryList.hasVO(categoryInfo.no))
						{
							categoryVO = new ShopCategoryFormVO(categoryInfo.no, categoryInfo.category, categoryInfo.isPrivate == '1' ? true : false, categoryInfo.no, categoryInfo.dateTime, url);
							vo.productCategoryList.addVO(categoryVO);
							
						}
						else
						{
							//if data already exist, replace it, as it may be out dated
							categoryVO = vo.productCategoryList.getVOByID(categoryInfo.no) as ShopCategoryFormVO;
							categoryVO.categoryName = categoryInfo.category;
							categoryVO.isPrivate = categoryInfo.isPrivate;
							categoryVO.categoryURL = url;
							categoryVO.createDateTime = categoryInfo.dateTime;
							
						}
						
						
						
						if (categoryInfo.product is Array && (categoryInfo.product as Array).length)
						{
							//no need to set numberOfProduct, it will be autometically counted from productList
							//categoryVO.numberOfProduct = (categoryInfo.product as Array).length;
							//prodcut vo from server, and categoryInfo vo which just updated
							setShopProduct(categoryInfo.product as Array, categoryVO);
						}
						
					}
					else
					{
						Tracer.echo('ShopVOService : setShopCategory : unknown data type : ' + arrResult[i], this, 0xff0000);
						return null;
					}
					
				}
			}
			
			return vo;
		}
		
		//will be call by setShopCategory()
		public function setShopProduct(inData:Array, inCategoryInfo:ShopCategoryFormVO):Boolean
		{
			if (!(inData is Array) && !(inCategoryInfo is ShopCategoryFormVO))
			{
				Tracer.echo('ShopVOService : setShopProduct : unknown data type : ' + inData  + inCategoryInfo, this, 0xff0000);
				return false;
			}
			
			//product
			if (inData is Array && (inData as Array).length > 0)
			{
				var arrResult:Array = inData as Array;
				
				for (var i:int = 0; i < arrResult.length; i++)
				{
					var pVO:ProductVO = arrResult[i] as ProductVO;
					if (pVO)
					{
						// shop/{hksp-xxxxxx}/shop-products/{catagory} //url to be handle by swfAddress proxy?
						var url:String = inCategoryInfo.categoryURL + '/' + Tools.spaceToHyphen(pVO.pid);
						
						if(!inCategoryInfo.productList.hasVO(pVO.no))
						{
							inCategoryInfo.productList.addVO
							(
								new ShopProductFormVO
								(
									pVO.no, 
									pVO.no, 
									pVO.pid, 
									Tools.replaceRestrictedString(pVO.name), 
									pVO.price, 
									Tools.replaceRestrictedString( pVO.description ),
									pVO.currency,
									Tools.replaceRestrictedString(pVO.category),
									pVO.dateTime,
									url,
									inCategoryInfo.categoryName,
									pVO.shopperCategoryNo,
									pVO.shopperProductNo,
									pVO.fbID,
									pVO.shopperProductTypeNo,
									pVO.discount,
									pVO.unit,
									pVO.tax
								)
							)
						}
						else
						{
							//if data already exist, replace it, as it may be out dated
							var productVO:ShopProductFormVO = inCategoryInfo.productList.getVOByID(pVO.no) as ShopProductFormVO;
							
							productVO.productCategoryNo = pVO.category;
							productVO.productCurrency = pVO.currency;
							productVO.productDateTime = pVO.dateTime;
							productVO.productDescription = Tools.replaceRestrictedString( pVO.description );
							productVO.productID = pVO.pid;
							productVO.productName = Tools.replaceRestrictedString(pVO.name);
							productVO.productNo = pVO.no;
							productVO.productPrice = pVO.price;
							productVO.productURL = url;
							productVO.productCategoryName = Tools.replaceRestrictedString(inCategoryInfo.categoryName);
							productVO.shopperCategoryNo = pVO.shopperCategoryNo;
							productVO.shopperProductNo = pVO.shopperProductNo;
							productVO.productFBID = pVO.fbID;
							productVO.shopperProductTypeNo = pVO.shopperProductTypeNo;
							productVO.productDiscount = pVO.discount;
							productVO.productUnit = pVO.unit;
							productVO.productTax = pVO.tax;
						}
					}
					else
					{
						Tracer.echo('ShopVOService : setShopProduct : unknown data type : pVO : ' + pVO, this, 0xff0000);
						return false;
					}
					
				}
			}
			
			return true;
		}
		
		public function setShopProductStock(inData:Object, inProductVO:ShopProductFormVO):Boolean
		{
			if (inData['s_num_stock'] != undefined && inData['s_num_stock'] != null)
			{
				inProductVO.productStock.numStock = int(inData['s_num_stock']);
				return true;
			}
			
			return false;
		}
		
		public function setDeleteShopProductStock(inData:Object, inProductVO:ShopProductFormVO):Boolean
		{
			if (setShopProductStock(inData, inProductVO) && inData['s_no'] != undefined && inData['s_no'] != null)
			{
				var numItem:int = inProductVO.productStock.length;
				var stockNo:String = inData['s_no'];
				
				for (var i:int = 0; i < numItem; i++)
				{
					var vo:ShopProductStockVO = inProductVO.productStock.getVO(i) as ShopProductStockVO;
					if (vo && vo.stockNo == stockNo)
					{
						vo.isDeleted = true;
						return true;
					}
					
				}
			}
			
			return false;
		}
		
		public function setShopProductStockHistory(inData:Object, inProductVO:ShopProductFormVO):Boolean
		{
			if (inData is Array)
			{
				inProductVO.productStock.clear();
				
				var arrData:Array = inData as Array;
				var numItem:int = arrData.length;
				for (var i:int = 0; i < numItem; i++)
				{
					var data:Object = arrData[i];
					if (data)
					{
						var vo:ShopProductStockVO = new ShopProductStockVO(i.toString());
						vo.numStock = Number(data['s_stock']);
						vo.productID = inProductVO.productID;
						vo.productName = inProductVO.productName;
						vo.productNo = inProductVO.productNo;
						vo.stockID = data['s_id'];
						vo.stockNo = data['s_no'];
						vo.dateTime = DateUtil.getDateStringByUTCDateString( String(data['s_date_time']) );
						vo.isDeleted = String(data['s_is_delete']) == '1';
						inProductVO.productStock.addVO(vo);
					}
				}
				
				return true;
			}
			
			return false;
		}
		
	}

}