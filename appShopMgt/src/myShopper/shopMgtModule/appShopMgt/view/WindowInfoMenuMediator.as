package myShopper.shopMgtModule.appShopMgt.view 

{
	import caurina.transitions.Tweener;
	import flash.display.DisplayObject;
	import flash.text.AntiAliasType;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.display.ApplicationDisplayObject;
	import myShopper.common.display.Menu;
	import myShopper.common.emun.AssetID;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.FontID;
	import myShopper.common.emun.SWFClassID;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.text.Font;
	import myShopper.common.utils.TweenerEffect;
	import myShopper.fl.button.ArrowTextButton;
	import myShopper.fl.shopMgt.button.ShopMenuButton;
	//import myShopper.fl.shopMgt.SimpleWindow;
	import myShopper.shopMgtModule.appShopMgt.event.WindowEvent;
	import myShopper.shopMgtModule.appShopMgt.ShopMgtMain;
	import myShopper.shopMgtModule.appShopMgt.view.component.ApplicationShopMgt;
	import org.puremvc.as3.multicore.enum.NotificationType;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class WindowInfoMenuMediator extends ApplicationMediator implements IMediator 
	{
		private var _appShop:ApplicationShopMgt;
		public function get appShop():ApplicationShopMgt 
		{
			if (!_appShop) _appShop = (container as ShopMgtMain).appShop;
			return _appShop;
		}
		
		//private var _infoMenu:SimpleWindow;
		
		
		
		public function WindowInfoMenuMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
		{
			super(inMediatorName, inViewComponent);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			
			/*if (_infoMenu)
			{
				appShop.windowHolder.removeApplicationChild(_infoMenu);
				_infoMenu = null;
			}*/
			
			_appShop = null;
		}
		
		override public function listNotificationInterests():Array 
		{
			return [NotificationType.ADD_CHILD];
		}

		override public function handleNotification(note:INotification):void 
		{
			var vo:DisplayObjectVO = note.getBody() as DisplayObjectVO;
			
			switch (note.getName()) 
			{   
				case NotificationType.ADD_CHILD:
				{
					/*if (vo.id == AssetID.BTN_USER_MANAGEMENT_INFO) 
					{
						var menuXML:XML = vo.settingXML;
						
						_infoMenu = vo.displayObject as SimpleWindow;
						
						_infoMenu.x = (mainStage.stageWidth - _infoMenu.width) / 2;
						_infoMenu.y = (mainStage.stageHeight - _infoMenu.height) / 2;
						_infoMenu.btnClose.addEventListener(ButtonEvent.CLICK, windowEventHandler);
						
						//_infoMenu.txtTitle.embedFonts = true;
						_infoMenu.txtTitle.antiAliasType = AntiAliasType.ADVANCED;
						_infoMenu.txtTitle.defaultTextFormat = Font.getTextFormat( { size:16, letterSpacing:2, font:Font.getDefaultFontByLang(language) } );
						
						_infoMenu.txtTitle.textColor = 0xffffff;
						_infoMenu.txtTitle.autoSize = TextFieldAutoSize.LEFT;
						
						appShop.windowHolder.addApplicationChild(_infoMenu, menuXML);
						
						var numItem:int = menuXML..button.length();
						for (var i:int = 0; i < numItem; i++)
						{
							var targetNode:XML = menuXML..button[i];
							if (targetNode && targetNode.@Class.length())
							{
								var b:ShopMenuButton = assetManager.getData(targetNode.@Class.toString(), AssetLibID.APP_SHOP_MGT);
								if (b)
								{
									//TODO : set text format doesn't work?? /REASON : always assign textFormat before assign text
									b.btnText.txt.embedFonts = true;
									b.btnText.txt.defaultTextFormat = Font.getTextFormat( { size:15, letterSpacing:2, font:Font.getDefaultFontByLang(language) } );
									b.addEventListener(ButtonEvent.CLICK, buttonEventHandler, false, 0, true);
									
									_infoMenu.holder.addApplicationChild(b, targetNode);
								}
							}
							
						}
						
						_infoMenu.mcScrollBar.refresh();
						//trace('@@@', _infoMenu.mcScrollBar.height, _infoMenu.mcScrollBar.scrollBarThumb.height);
					}*/
					break;
				}
			}
		}
		
		private function windowEventHandler(e:ButtonEvent):void 
		{
			
			sendNotification(WindowEvent.CLOSE, AssetID.BTN_USER_MANAGEMENT_INFO);
		}
		
		private function buttonEventHandler(e:ButtonEvent):void 
		{
			switch(e.type)
			{
				/*case ButtonEvent.OVER:
				case ButtonEvent.OUT:
				{
					var color:uint = e.type == ButtonEvent.OVER ? 0x009999 : 0x000000;
					Tweener.addTween(e.targetButton as DisplayObject, TweenerEffect.setGlow(1, 'easeOutSine', color, 3, 5, 1) );
					break;
				}*/
			}
		}
		
		
	}
}