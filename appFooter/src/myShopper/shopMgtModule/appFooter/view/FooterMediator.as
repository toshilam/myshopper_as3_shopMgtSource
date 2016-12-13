package myShopper.shopMgtModule.appFooter.view 

{
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import myShopper.common.Config;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.display.ApplicationDisplayObject;
	import myShopper.common.display.Menu;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.CommunicationType;
	import myShopper.common.emun.SWFClassID;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.text.Font;
	import myShopper.common.utils.Tools;
	import myShopper.common.utils.Tracer;
	import myShopper.fl.button.TextButton;
	import myShopper.shopMgtModule.appFooter.enum.AssetID;
	import myShopper.shopMgtModule.appFooter.FooterMain;
	import myShopper.shopMgtModule.appFooter.view.component.ApplicationFooter;
	import org.puremvc.as3.multicore.enum.NotificationType;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class FooterMediator extends ApplicationMediator implements IMediator 
	{
		private var _appFooter:ApplicationFooter;
		public function get appFooter():ApplicationFooter 
		{
			if (!_appFooter) _appFooter = (container as FooterMain).appFooter;
			return _appFooter;
		}
		
		private var _menu:Menu;
		
		public function FooterMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
		{
			super(inMediatorName, inViewComponent);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			
		}
		
		override public function listNotificationInterests():Array 
		{
			return [NotificationType.ADD_HOST, NotificationType.ADD_CHILD, CommunicationType.USER_LOGIN_SUCCESS, CommunicationType.USER_LOGOUT];
		}

		override public function handleNotification(note:INotification):void 
		{
			var body:Object = note.getBody();
			var vo:DisplayObjectVO;
			
			if (body is DisplayObjectVO)
			{
				vo = body as DisplayObjectVO;
			}
			
			if(body is ApplicationMediator){}
			
			switch (note.getName()) 
			{   
				case NotificationType.ADD_HOST:
				{
					(container as FooterMain).appFooter = container.view.addApplicationChild(vo.displayObject, vo.settingXML, /*_mainStage,*/ false) as ApplicationFooter ;
					break;
				}
				
				case NotificationType.ADD_CHILD:
				{
					
					
					if (vo.id == AssetID.BAR) 
					{
						appFooter.addApplicationChild(vo.displayObject, vo.settingXML/*, _mainStage*/);
					}
					
					else if (vo.id == AssetID.FOOTER_MENU) 
					{
						_menu = appFooter.addApplicationChild(vo.displayObject, vo.settingXML/*, _mainStage*/) as Menu;
						var numItem:int = vo.settingXML..button.length();
						var buttonNode:XML = vo.settingXML;
						
						if (numItem)
						{
							for (var i:int = 0; i < numItem; i++)
							{
								var xmlItem:XML = buttonNode..button[i];
								var b:TextButton = assetManager.getData(xmlItem.@Class, AssetLibID.AST_COMMON);
								if (b)
								{
									//b.txt.embedFonts = false;
									//b.txt.defaultTextFormat = Font.getTextFormat( { font:SWFClassID.SANS } );
									
									setTextField(b.txt, false, Font.getTextFormat({ font:SWFClassID.SANS }) );
									
									b.addEventListener(ButtonEvent.CLICK, mouseEventHandler);
									_menu.addApplicationChild(b, xmlItem, false);
									
									//b.txt.text = b.txt.text.toUpperCase();
									
								}
								else
								{
									echo('target display object not found : ' + xmlItem.@Class, this, 0xff0000);
								}
							}
							
							appFooter.onStageResize(appFooter.stage);
							
							stopListener();
						}
						
					}
					else
					{
						echo('no matched id found for : ' + note.getName(), this, 0xFF0000);
					}
					break;
				}
				
				case CommunicationType.USER_LOGIN_SUCCESS:
				{
					startListener();
					break;
				}
				case CommunicationType.USER_LOGOUT:
				{
					stopListener();
					break;
				}
			}
		}
		
		override public function startListener():void 
		{
			super.startListener();
			
			if (_menu)
			{
				var numItem:int = _menu.subDisplayObjectList.length;
				for (var i:int = 0; i < numItem; i++)
				{
					var b:TextButton = _menu.subDisplayObjectList.getDisplayObjectByIndex(i) as TextButton;
					if (b)
					{
						b.mouseEnabled = true;
						b.startListener();
						b.alpha = 1;
						
					}
				}
				
			}
		}
		
		override public function stopListener():void 
		{
			super.stopListener();
			
			if (_menu)
			{
				var numItem:int = _menu.subDisplayObjectList.length;
				for (var i:int = 0; i < numItem; i++)
				{
					var b:TextButton = _menu.subDisplayObjectList.getDisplayObjectByIndex(i) as TextButton;
					if (b)
					{
						b.mouseEnabled = false;
						b.stopListener();
						b.alpha = .5;
					}
				}
				
			}
		}
		
		private function mouseEventHandler(e:ButtonEvent):void 
		{
			//var id:String = e.targetButton.id;
			//
			//switch(id)
			//{
				//case AssetID.BTN_SHOPPER_ABOUT:
				//case AssetID.BTN_SHOPPER_SERVICE:
				//case AssetID.BTN_SHOPPER_BENEFIT:
				//case AssetID.BTN_SHOPPER_PROCEDURE:
				//case AssetID.BTN_SHOPPER_HOWTO:
				//{
					//
					//navigateToURL(new URLRequest(getURLByID(id)), "_blank"); 
					//break;
					//
				//}
				//default:
				//{
					sendNotification(ButtonEvent.CLICK, e.targetButton);
				//}
			//}
		}
		
		/*private function getURLByID(id:String):String 
		{
			
			switch(id)
			{
				//TODO if more languages available 
				case AssetID.BTN_SHOPPER_ABOUT:			return Tools.formatString(Config.URL_SHOPPER_ABOUT, [Config.LANG_CODE_EN]); 
				//case AssetID.BTN_SHOPPER_SERVICE:		return httpHost + Config.URL_SHOPPER_SERVICE;
				//case AssetID.BTN_SHOPPER_BENEFIT:		return httpHost + Config.URL_SHOPPER_BENEFIT;
				case AssetID.BTN_SHOPPER_PROCEDURE:		return Tools.formatString(Config.URL_SHOPPER_PROCEDURE, [Config.LANG_CODE_EN]);
				case AssetID.BTN_SHOPPER_HOWTO:			return Tools.formatString(Config.URL_SHOPPER_HOWTO, [Config.LANG_CODE_EN]);
			}
			
			return httpHost;
		}*/
	}
}