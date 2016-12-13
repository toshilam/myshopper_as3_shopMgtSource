package myShopper.shopMgtModule.appHeader.view 
{
	import caurina.transitions.Tweener;
	import flash.events.MouseEvent;
	import myShopper.common.data.AlerterVO;
	import myShopper.common.display.Menu;
	import myShopper.common.emun.AlerterType;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.AssetXMLNodeID;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.text.Font;
	import myShopper.common.utils.Alert;
	import myShopper.common.utils.TweenerEffect;
	import myShopper.fl.button.LabelButton;
	import myShopper.shopMgtModule.appHeader.enum.AssetID;
	import myShopper.shopMgtModule.appHeader.HeaderMain;
	import myShopper.shopMgtModule.appHeader.view.component.ApplicationHeader;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class LanguageMenuMediator extends ApplicationMediator implements IMediator 
	{
		private var _appHeader:ApplicationHeader;
		public function get appHeader():ApplicationHeader 
		{
			if (!_appHeader) _appHeader = (container as HeaderMain).appHeader;
			return _appHeader;
		}
		
		
		public function LanguageMenuMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
		{
			super(inMediatorName, inViewComponent);
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			stopListener();
			Alert.close();
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			var xml:XML = xmlManager.getData(AssetXMLNodeID.LANGUAGES, AssetLibID.XML_COMMON)[0];
			
			if (xml)
			{
				var menu:Menu = Alert.show(new AlerterVO('', AlerterType.DISPLAY_OBJECT, '', new Menu())) as Menu;
				menu.setLayout(Menu.LAYOUT_VERTICAL, 20);
				
				var numItem:int = xml.*.length();
				for (var i:int = 0; i < numItem; i++)
				{
					var xmlNode:XML = xml.*[i];
					var b:LabelButton = assetManager.getData(xmlNode.@Class, AssetLibID.AST_COMMON);
					//b.txt.embedFonts = false;
					//b.txt.defaultTextFormat = Font.getTextFormat( { size:30 } );
					
					setTextField(b.txt, false, Font.getTextFormat( { size:30 } ));
					
					b.extraSpacing = 20;
					
					b.addEventListener(ButtonEvent.CLICK, mouseEventHandler, false, 0, true);
					b.addEventListener(ButtonEvent.OVER, mouseEventHandler, false, 0, true);
					b.addEventListener(ButtonEvent.OUT, mouseEventHandler, false, 0, true);
					
					menu.addApplicationChild(b, xmlNode, false);
					
					
				}
				
				menu.x = mainStage.stageWidth - menu.width >> 1;
				menu.y = (mainStage.stageHeight - menu.height >> 1) + 20;
				
				var duration:int = 1.5;
				Tweener.addTween(menu, TweenerEffect.setMove(menu.x, menu.y - 20, duration, 'easeInOutExpo'));
				Tweener.addTween(menu, TweenerEffect.setBlur(0, 20, .8, duration, 0, 'easeInOutExpo'));
				Tweener.addTween(menu, TweenerEffect.setBlur(0, 0, 0, duration, duration, 'easeInOutExpo'));
				
				startListener();
			}
			
			
			
		}
		
		private function mouseEventHandler(e:ButtonEvent):void 
		{
			var b:LabelButton = e.targetButton as LabelButton;
			
			switch(e.type)
			{
				case ButtonEvent.CLICK:
				{
					sendNotification(ButtonEvent.CLICK, e.targetButton);
					break;
				}
				case ButtonEvent.OVER:
				{
					Tweener.addTween(b.bg , TweenerEffect.setAlpha(.7));
					stopListener();
					break;
				}
				case ButtonEvent.OUT:
				{
					Tweener.addTween(b.bg, TweenerEffect.setAlpha(1));
					startListener();
					break;
				}
			}
			
		}
		
		override public function listNotificationInterests():Array 
		{
			return [/*NotificationType.SET_HEADER_MENU*/];
		}

		override public function handleNotification(note:INotification):void 
		{
			var body:Object = note.getBody();
			
			
			switch (note.getName()) 
			{
				
				
			}
		}
		
		override public function startListener():void 
		{
			super.startListener();
			mainStage.addEventListener(MouseEvent.MOUSE_UP, stageEventHandler);
		}
		
		override public function stopListener():void 
		{
			super.stopListener();
			mainStage.removeEventListener(MouseEvent.MOUSE_UP, stageEventHandler);
		}
		
		private function stageEventHandler(e:MouseEvent):void 
		{
			sendNotification(ButtonEvent.CLICK, AssetID.BTN_CLOSE_LANGUAGE);
		}
		
	}
}