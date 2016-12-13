package myShopper.shopMgtModule.appForm.model.service 
{
	import flash.display.DisplayObject;
	import flash.printing.PrintJob;
	import myShopper.common.data.PrinterVO;
	import myShopper.common.utils.Tracer;
	
	import myShopper.common.data.shop.ShopOrderExtraVO;
	import myShopper.common.data.shop.ShopOrderVO;
	import myShopper.common.data.user.UserShoppingCartProductVO;
	import myShopper.common.display.ApplicationDisplayObject;
	import myShopper.common.emun.OrderExtraTypeID;
	import myShopper.common.resources.AssetManager;
	import myShopper.fl.shopMgt.print.ShopMgtInvoice80mm;
	import myShopper.fl.shopMgt.print.ShopMgtInvoiceA4;
	import myShopper.fl.shopMgt.print.ShopMgtInvoiceItemA4;
	import myShopper.common.data.service.ShopVOService;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.ShopMgtShopInfoVO;
	import myShopper.shopMgtModule.appForm.enum.AssetClassID;
	
	CONFIG::desktop
	import flash.printing.PrintUIOptions;
	
	/**
	 * ...
	 * @author Toshi
	 */
	public class PrintVOService 
	{
		public static const SIZE_A4:int = 2;
		public static const SIZE_80MM:int = 1;
		//matched with XML
		//public static const PRINT_TYPE_80MM:int = 1;
		//public static const PRINT_TYPE_A4:int = 2;
		
		private var _assetManager:AssetManager;
		private var _container:ApplicationDisplayObject;
		
		public function PrintVOService(inAssetManager:AssetManager, inContainer:ApplicationDisplayObject)
		{
			_assetManager = inAssetManager;
			_container = inContainer;
		}
		
		public function clear():void
		{
			_assetManager = null;
			_container = null;
		}
		
		public function print(inData:ApplicationDisplayObject, inVO:PrinterVO):Boolean
		{
			if (!PrintJob.isSupported || !inData || !inVO) return false;
			
			_container.addApplicationChild(inData, null, false);
			inData.visible = false;
			
			var myPrintJob:PrintJob = new PrintJob();
			var hasError:Boolean = false;
			
			//TODO : scale page to fit to paper?
			
			CONFIG::web
			{
				if ( myPrintJob.start() )
				{
					try
					{
						myPrintJob.addPage(inData); 
					}
					catch (e:Error)
					{
						hasError = true;
					}
					
					if(!hasError) myPrintJob.send(); 
				}
				else
				{
					hasError = true;
				}
			}
			
			CONFIG::desktop
			{
				if (inVO.selectedPrinterID && PrintJob.printers.indexOf(inVO.selectedPrinterID) == -1)
				{
					Tracer.echo('PrintVOService : print : no target printer found!');
					return false;
				}
				
				var uiOpt:PrintUIOptions = new PrintUIOptions();
				
				if (inVO.selectedPrinterID) myPrintJob.printer = inVO.selectedPrinterID;
				
				if ( myPrintJob.start2(uiOpt, false) )
				{
					try
					{
						myPrintJob.addPage(inData); 
					}
					catch (e:Error)
					{
						hasError = true;
					}
					
					if(!hasError) myPrintJob.send(); 
				}
				else
				{
					myPrintJob.terminate();
					hasError = true;
				}
			}
			
			
			
			_container.removeApplicationChild(inData, false);
			
			return !hasError;
		}
		
		public function getOrderForm(inOrderVO:ShopOrderVO, inShopVO:ShopMgtShopInfoVO, inSize:int = SIZE_A4):ApplicationDisplayObject
		{
			var vo:ShopOrderVO = inOrderVO;
			var _shopInfoVO:ShopMgtShopInfoVO = inShopVO;
			var assetManager:AssetManager = _assetManager;
			
			var subTotal:Number = ShopVOService.getOrderSubTotalByVO(vo.productList);
			var extraTotal:Number = ShopVOService.getOrderExtraTotalByVO(vo.extraList);
			
			var assetID:String = inSize == SIZE_A4 ? AssetClassID.P_FORM_INVOICE_A4 : AssetClassID.P_FORM_INVOICE_80MM;
			var InvoiceA4:ShopMgtInvoiceA4 = assetManager.getData(assetID, AssetLibID.AST_SHOP_MGT_FORM);
			
			InvoiceA4.txtAddress.text = _shopInfoVO.address;
			InvoiceA4.txtChange.text = String(Number(vo.paid) - Number(vo.finalTotal));
			InvoiceA4.txtDate.text = vo.dateTime;
			InvoiceA4.txtName.text = _shopInfoVO.name;
			InvoiceA4.txtNo.text = vo.invoiceNo;
			InvoiceA4.txtOtherTotal.text = extraTotal.toString();
			InvoiceA4.txtPaid.text = vo.paid;
			InvoiceA4.txtPhone.text = 'Tel: ' + _shopInfoVO.phone;
			InvoiceA4.txtSubTotal.text = subTotal.toString();
			InvoiceA4.txtTotal.text = vo.finalTotal;
			
			var i:int;
			var invoiceItemA4:ShopMgtInvoiceItemA4;
			var numItem:int = vo.productList.length;
			for (i = 0; i < numItem; i++)
			{
				assetID = inSize == SIZE_A4 ? AssetClassID.P_FORM_INVOICE_ITEM_A4 : AssetClassID.P_FORM_INVOICE_ITEM_80MM;
				
				var pVO:UserShoppingCartProductVO = vo.productList.getVO(i) as UserShoppingCartProductVO;
				invoiceItemA4 = InvoiceA4.holder.addApplicationChild(assetManager.getData(assetID, AssetLibID.AST_SHOP_MGT_FORM), null, false) as ShopMgtInvoiceItemA4;
				
				//invoiceItemA4.txtPrice.text = ShopVOService.getDiscountedPrice(Number(pVO.productPrice), pVO.productDiscount).toString();
				invoiceItemA4.txtPrice.text = pVO.getPrice().toFixed(2);
				invoiceItemA4.txtAmount.text = String(Number(invoiceItemA4.txtPrice.text) * pVO.qty);
				invoiceItemA4.txtName.text = pVO.productName;
				invoiceItemA4.txtQTY.text = pVO.qty.toString();
				
			}
			
			numItem = vo.extraList.length;
			for (i = 0; i < numItem; i++)
			{
				assetID = inSize == SIZE_A4 ? AssetClassID.P_FORM_INVOICE_ITEM_A4 : AssetClassID.P_FORM_INVOICE_ITEM_80MM;
				
				var eVO:ShopOrderExtraVO = vo.extraList.getVO(i) as ShopOrderExtraVO;
				invoiceItemA4 = InvoiceA4.holder.addApplicationChild(assetManager.getData(assetID, AssetLibID.AST_SHOP_MGT_FORM), null, false) as ShopMgtInvoiceItemA4;
				
				var sign:String = eVO.type == OrderExtraTypeID.FEE ? '' : '-';
				invoiceItemA4.txtAmount.text = sign + eVO.total.toString();
				invoiceItemA4.txtName.text = eVO.name;
				
			}
			
			if (InvoiceA4 is ShopMgtInvoice80mm)
			{
				InvoiceA4.refresh();
			}
			
			return InvoiceA4;
		}
	}

}