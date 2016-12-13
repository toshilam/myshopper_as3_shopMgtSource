package myShopper.shopMgtModule.appShopMgt.view 

{
	import caurina.transitions.Tweener;
	import flash.display.DisplayObject;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import myShopper.common.Config;
	import myShopper.common.data.communication.CommList;
	import myShopper.common.data.communication.UserShopCommList;
	import myShopper.common.data.communication.UserShopCommVOList;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.display.ApplicationDisplayObject;
	import myShopper.common.display.Menu;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.SWFClassID;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.events.VOEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.text.Font;
	import myShopper.common.utils.TweenerEffect;
	import myShopper.fl.button.ArrowTextButton;
	import myShopper.fl.shopMgt.MyQuickMenu;
	import myShopper.shopMgtCommon.emun.AssetID;
	import myShopper.shopMgtModule.appShopMgt.enum.AssetID;
	import myShopper.shopMgtModule.appShopMgt.enum.NotificationType;
	import myShopper.shopMgtModule.appShopMgt.ShopMgtMain;
	import myShopper.shopMgtModule.appShopMgt.view.component.ApplicationShopMgt;
	import org.puremvc.as3.multicore.enum.NotificationType;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class MyQuickMenuMediator extends ApplicationMediator implements IMediator 
	{
		private var _appShop:ApplicationShopMgt;
		public function get appShop():ApplicationShopMgt 
		{
			if (!_appShop) _appShop = (container as ShopMgtMain).appShop;
			return _appShop;
		}
		
		private var _shopInfoVO:ShopInfoVO;
		private var _commList:UserShopCommList;
		
		public function get myQuickMenu():MyQuickMenu
		{
			return appShop.myQuickMenu;
		}
		
		
		
		public function MyQuickMenuMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
		{
			super(inMediatorName, inViewComponent);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			_shopInfoVO = voManager.getAsset(VOID.MY_SHOP_INFO);
			_commList = voManager.getAsset(VOID.COMM_SHOP_USER_INFO);
			
			if (!_shopInfoVO || !_commList)
			{
				throw(new UninitializedError('MyQuickMenuMediator : onRegister : unable to retreve info vo'));
			}
			
			_commList.addEventListener(VOEvent.VALUE_CHANGED, voEventHandler);
		}
		
		private function voEventHandler(e:VOEvent):void 
		{
			if (e.propertyName == 'numUnRead')
			{
				upadteNumNewMessage();
			}
		}
		
		override public function listNotificationInterests():Array 
		{
			return 	[
						org.puremvc.as3.multicore.enum.NotificationType.ADD_CHILD, 
						myShopper.shopMgtModule.appShopMgt.enum.NotificationType.UPDATE_NUM_NEW_ORDER,
						myShopper.shopMgtModule.appShopMgt.enum.NotificationType.UPDATE_NUM_NEW_MESSAGE
					];
		}

		override public function handleNotification(note:INotification):void 
		{
			var vo:DisplayObjectVO = note.getBody() as DisplayObjectVO;
			var b:ArrowTextButton;
			switch (note.getName()) 
			{   
				case org.puremvc.as3.multicore.enum.NotificationType.ADD_CHILD:
				{
					if (vo.id == myShopper.shopMgtModule.appShopMgt.enum.AssetID.MY_QUICK_MENU) 
					{
						var menuXML:XML = vo.settingXML;
						
						appShop.myQuickMenu = appShop.addApplicationChild(vo.displayObject, menuXML) as MyQuickMenu;
						
						var numItem:int = menuXML..button.length();
						for (var i:int = 0; i < numItem; i++)
						{
							var targetNode:XML = menuXML..button[i];
							if (targetNode && targetNode.@Class.length())
							{
								b = assetManager.getData(targetNode.@Class.toString(), AssetLibID.AST_COMMON);
								if (b)
								{
									//b.txt.embedFonts = false;
									//b.txt.defaultTextFormat = Font.getTextFormat({ color:0xffffff, size:14, letterSpacing:2, font:SWFClassID.SANS }) ;
									setTextField(b.txt, language == Config.LANG_CODE_EN, Font.getTextFormat({ color:0xffffff, size:14, letterSpacing:2, font:SWFClassID.SANS }));
									
									
									//b.txt.textColor = 0xffffff;
									b.txt.autoSize = TextFieldAutoSize.LEFT;
									
									Tweener.addTween(b, TweenerEffect.setGlow(0, '', 0x000000, 3, 5, 1) );
									
									b.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
									b.addEventListener(ButtonEvent.OVER, buttonEventHandler);
									b.addEventListener(ButtonEvent.OUT, buttonEventHandler);
									
									myQuickMenu.addApplicationChild(b, targetNode);
									
									/*if (b.id == myShopper.shopMgtCommon.emun.AssetID.BTN_Q_ORDER)
									{
										b.onResize = upadteNumNewOrder;
									}*/
									
								}
							}
							
						}
						
						appShop.onStageResize(mainStage);
					}
					break;
				}
				
				case myShopper.shopMgtModule.appShopMgt.enum.NotificationType.UPDATE_NUM_NEW_ORDER:
				{
					upadteNumNewOrder();
					break;
				}
				case myShopper.shopMgtModule.appShopMgt.enum.NotificationType.UPDATE_NUM_NEW_MESSAGE:
				{
					upadteNumNewMessage();
					break;
				}
			}
		}
		
		private function upadteNumNewOrder():void 
		{
			var b:ArrowTextButton = myQuickMenu.subDisplayObjectList.getDisplayObjectByID(myShopper.shopMgtCommon.emun.AssetID.BTN_Q_ORDER) as ArrowTextButton;
			if (b)
			{
				var numUnReadOrder:int = _shopInfoVO.shopOrderList.numUnReadOrder;
				
				var strOrder:String = numUnReadOrder ? '(' + numUnReadOrder.toString() + ')' : '';
				b.appendText(strOrder);
				b.txt.setTextFormat(Font.getTextFormat({ color:0xffffff, size:14, letterSpacing:2, font:language == Config.LANG_CODE_EN ? Font.getDefaultFontByLang(language) : SWFClassID.SANS }));
				if (numUnReadOrder)
				{
					b.txt.setTextFormat(Font.getTextFormat({ color:0xff0000, size:12 }), b.text.length - strOrder.length, b.text.length) ;
				}
				
			}
		}
		
		private function upadteNumNewMessage():void 
		{
			var b:ArrowTextButton = myQuickMenu.subDisplayObjectList.getDisplayObjectByID(myShopper.shopMgtCommon.emun.AssetID.BTN_Q_USER_MESSAGE) as ArrowTextButton;
			if (b)
			{
				var numUnRead:int = _commList.numUnRead;
				//var numItem:int = _commList.length;
				
				/*for (var i:int = 0; i < numItem; i++)
				{
					var commVOList:UserShopCommVOList = _commList.getVO(i) as UserShopCommVOList;
					if (commVOList)
					{
						numUnRead += commVOList.numUnRead;
					}
				}*/
				
				var strOrder:String = numUnRead ? '(' + numUnRead.toString() + ')' : '';
				b.appendText(strOrder);
				b.txt.setTextFormat(Font.getTextFormat({ color:0xffffff, size:14, letterSpacing:2, font:language == Config.LANG_CODE_EN ? Font.getDefaultFontByLang(language) : SWFClassID.SANS })) ;
				if (numUnRead)
				{
					b.txt.setTextFormat(Font.getTextFormat({ color:0xff0000, size:12 }), b.text.length - strOrder.length, b.text.length) ;
				}
				
			}
		}
		
		private function buttonEventHandler(e:ButtonEvent):void 
		{
			switch(e.type)
			{
				case ButtonEvent.OVER:
				case ButtonEvent.OUT:
				{
					var color:uint = e.type == ButtonEvent.OVER ? 0x009999 : 0x000000;
					Tweener.addTween(e.targetButton as DisplayObject, TweenerEffect.setGlow(1, 'easeOutSine', color, 3, 5, 1) );
					break;
				}
				case ButtonEvent.CLICK:
				{
					sendNotification(e.type, e.targetButton);
					break;
				}
			}
		}
		
		
	}
}