package myShopper.shopMgtModule.appHeader.view 

{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.service.ShopVOService;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.display.ApplicationDisplayObject;
	import myShopper.common.display.Menu;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.CommunicationType;
	import myShopper.common.emun.MessageID;
	import myShopper.common.emun.SWFClassID;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.events.VOEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.text.Font;
	import myShopper.common.utils.Tracer;
	import myShopper.fl.header.HeaderNetvigator;
	import myShopper.shopMgtModule.appHeader.enum.AssetID;
	import myShopper.shopMgtModule.appHeader.HeaderMain;
	import myShopper.shopMgtModule.appHeader.view.component.ApplicationHeader;
	import org.puremvc.as3.multicore.enum.NotificationType;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class HeaderMediator extends ApplicationMediator implements IMediator 
	{
		private var _appHeader:ApplicationHeader;
		public function get appHeader():ApplicationHeader 
		{
			if (!_appHeader) _appHeader = (container as HeaderMain).appHeader;
			return _appHeader;
		}
		
		private var _netvigator:HeaderNetvigator;
		private var _shopInfo:ShopInfoVO;
		private var _userInfo:UserInfoVO;
		
		public function HeaderMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
		{
			super(inMediatorName, inViewComponent);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			
			_shopInfo = voManager.getAsset(VOID.MY_SHOP_INFO);
			_userInfo = voManager.getAsset(VOID.MY_USER_INFO);
			
			if (!_shopInfo || !_userInfo)
			{
				throw(new UninitializedError(multitonKey + " : " + mediatorName + " : unable to get vo data"));
			}
			
			_shopInfo.addEventListener(VOEvent.VALUE_CHANGED, voEventHandler);
			
			//mainStage.addEventListener(Event.RESIZE, stageEventHandler);
		}
		
		
		
		private function voEventHandler(e:VOEvent):void 
		{
			if (e.propertyName == 'shopNo' && _userInfo.isLogged)
			{
				refresh();
			}
		}
		
		private function refresh(inStatus:String = CommunicationType.USER_DISCONNECTED):void 
		{
			if (_shopInfo.shopNo && _netvigator && _userInfo.isLogged)
			{
				var inIsConnected:Boolean = inStatus == CommunicationType.USER_CONNECTED;
				var url:String = ShopVOService.getShopPageURL(httpHost, _shopInfo.shopNo, language);
				var message:String = getMessage(MessageID.tt1006) + url;
				message += '  [' + (getMessage(inIsConnected ? MessageID.tt0062 : inStatus == CommunicationType.USER_DISCONNECTED ? MessageID.tt0063 : MessageID.tt0064)) + ']';
				_netvigator.txt.text = message;
				
				_netvigator.isOnline = inIsConnected;
				
				if (!_netvigator.hasEventListener(MouseEvent.CLICK))
				{
					_netvigator.txt.addEventListener(MouseEvent.CLICK, textEventHandler, false, 0, true);
				}
				
			}
		}
		
		private function textEventHandler(e:MouseEvent):void 
		{
			if (_shopInfo.shopNo && _netvigator && _userInfo.isLogged)
			{
				navigateToURL(new URLRequest(ShopVOService.getShopPageURL(httpHost, _shopInfo.shopNo, language)), "_blank"); 
			}
		}
		
		override public function listNotificationInterests():Array 
		{
			return [NotificationType.ADD_HOST, NotificationType.ADD_CHILD, myShopper.shopMgtModule.appHeader.enum.NotificationType.UPDATE_CONNECTION_STATUS];
		}

		override public function handleNotification(note:INotification):void 
		{
			var body:Object = note.getBody();
			var vo:DisplayObjectVO;
			
			if (body is DisplayObjectVO)
			{
				vo = body as DisplayObjectVO;
			}
			
			switch (note.getName()) 
			{
				case NotificationType.ADD_HOST:
				{
					(container as HeaderMain).appHeader = container.view.addApplicationChild(vo.displayObject, vo.settingXML, /*_mainStage,*/ false) as ApplicationHeader ;
					break;
				}
				
				case NotificationType.ADD_CHILD:
				{
					vo = note.getBody() as DisplayObjectVO;
					
					if 
					(
						vo.id == AssetID.LOGO 		||
						vo.id == AssetID.NETVIGATOR ||
						vo.id == AssetID.BAR
					) 
					{
						if (vo.id == AssetID.LOGO)
						{
							appHeader.addApplicationChild(vo.displayObject, vo.settingXML/*, appHeader.stage*/).addEventListener(ButtonEvent.CLICK, mouseEventHandler);
						}
						else if (vo.id == AssetID.NETVIGATOR)
						{
							_netvigator = appHeader.addApplicationChild(vo.displayObject, vo.settingXML/*, appHeader.stage*/) as HeaderNetvigator;
							_netvigator.txt.defaultTextFormat = Font.getTextFormat( { font:SWFClassID.SANS } );
							_netvigator.txt.embedFonts = false;
							//_netvigator.mouseChildren = false;
							_netvigator.useHandCursor = _netvigator.buttonMode = true;
							
							refresh();
						}
						else
						{
							appHeader.addApplicationChild(vo.displayObject, vo.settingXML/*, appHeader.stage*/);
						}
					}
					
					else if 
					(
						vo.id == AssetID.HEADER_MENU ||
						vo.id == AssetID.WINDOWS_MENU
					) 
					{
						
						var menu:Menu = appHeader.addApplicationChild(vo.displayObject, vo.settingXML/*, appHeader.stage*/) as Menu;
						var numItem:int = 0;
						var buttonNode:XML;
						
						if (vo.id == AssetID.HEADER_MENU)
						{
							
							numItem = vo.settingXML.menu[0].button.length();
							buttonNode = vo.settingXML.menu[0];
						}
						else
						{
							numItem = vo.settingXML..button.length();
							buttonNode = vo.settingXML;
						}
						
						if (numItem)
						{
							for (var i:int = 0; i < numItem; i++)
							{
								//var xmlItem:XML = vo.settingXML.children()[i];
								var xmlItem:XML = buttonNode..button[i];
								
								CONFIG::mobile
								{
									if (xmlItem.@id == AssetID.BTN_FULLSCREEN)
									{
										continue;
									}
								}
								
								var b:ApplicationDisplayObject = assetManager.getData(xmlItem.@Class, AssetLibID.AST_COMMON);
								
								if (b)
								{
									menu.addApplicationChild(b, xmlItem/*, appHeader.stage*/);
									menu.addEventListener(ApplicationEvent.CHILD_REMOVED, menuEventHandler); //for handling button get removed
									b.addEventListener(ButtonEvent.CLICK, mouseEventHandler);
								}
								else
								{
									echo('target display object not found : ' + xmlItem.@Class, this, 0xff0000);
								}
							}
							
							_appHeader.onStageResize(appHeader.stage);
						}
						
					}
					else
					{
						echo('no matched id found for : ' + note.getName(), this, 0xFF0000);
					}
					break;
				}
				case myShopper.shopMgtModule.appHeader.enum.NotificationType.UPDATE_CONNECTION_STATUS:
				{
					refresh(String(note.getBody()));
					break;
				}
			}
		}
		
		private function menuEventHandler(e:ApplicationEvent):void 
		{
			if (e.targetDisplayObject.hasEventListener(ButtonEvent.CLICK))
			{
				e.targetDisplayObject.removeEventListener(ButtonEvent.CLICK, mouseEventHandler);
			}
		}
		
		private function mouseEventHandler(e:ButtonEvent):void 
		{
			sendNotification(ButtonEvent.CLICK, e.targetButton);
		}
		
	}
}