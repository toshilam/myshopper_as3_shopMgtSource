package myShopper.shopMgtModule.appHeader.view 

{
	import myShopper.common.data.AlerterVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.display.ApplicationDisplayObject;
	import myShopper.common.display.button.Button;
	import myShopper.common.display.Menu;
	import myShopper.common.emun.AlerterType;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.MessageID;
	import myShopper.common.emun.ServiceID;
	import myShopper.common.events.AlerterEvent;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.events.ServiceEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.net.FacebookService;
	import myShopper.common.utils.Alert;
	import myShopper.common.utils.Tracer;
	import myShopper.common.utils.TweenerEffect;
	import myShopper.fl.button.TextButton;
	import myShopper.fl.ConfirmAlerter;
	import myShopper.shopMgtModule.appHeader.enum.AssetID;
	import myShopper.shopMgtModule.appHeader.enum.NotificationType;
	import myShopper.shopMgtModule.appHeader.HeaderMain;
	import myShopper.shopMgtModule.appHeader.view.component.ApplicationHeader;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class HeaderMenuMediator extends ApplicationMediator implements IMediator 
	{
		private var _appHeader:ApplicationHeader;
		public function get appHeader():ApplicationHeader 
		{
			if (!_appHeader) _appHeader = (container as HeaderMain).appHeader;
			return _appHeader;
		}
		
		protected var _service:FacebookService;
		protected var _bfButton:TextButton;
		
		public function HeaderMenuMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
		{
			super(inMediatorName, inViewComponent);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			_service = serviceManager.getAsset(ServiceID.FACEBOOK);
			
			if (!_service)
			{
				throw(new UninitializedError(multitonKey + ' : HeaderMenuMediator : onRegister : unable to retreve service!')); 
			}
			
			_service.addEventListener(ServiceEvent.CONNECT_SUCCESS, serviceEventHandler);
			_service.addEventListener(ServiceEvent.CONNECT_FAIL, serviceEventHandler);
			_service.addEventListener(ServiceEvent.DISCONNECTED, serviceEventHandler);
		}
		
		private function serviceEventHandler(e:ServiceEvent):void 
		{
			if (_bfButton)
			{
				_bfButton.text = getMessage(e.type == ServiceEvent.CONNECT_SUCCESS ? MessageID.tt0005 : MessageID.tt0003);
			}
		}
		
		override public function listNotificationInterests():Array 
		{
			return [NotificationType.SET_HEADER_MENU];
		}

		override public function handleNotification(note:INotification):void 
		{
			var body:Object = note.getBody();
			
			
			switch (note.getName()) 
			{
				
				case NotificationType.SET_HEADER_MENU:
				{
					if (!(body is XML)) 
					{
						echo('handleNotification : no data found for setting header menu');
						return;
					}
					
					var menuXML:XML = body as XML;
					var b:Button;
					
					var menu:Menu = appHeader.subDisplayObjectList.getDisplayObjectByID(AssetID.HEADER_MENU) as Menu;
					if (menu)
					{
						//remove all non logged in button
						menu.removeAllButton();
						/*var numItem:int = menu.subDisplayObjectList.length;
						for (var i:int = 0; i < numItem; i++)
						{
							b = menu.subDisplayObjectList.getDisplayObjectByIndex(i) as Button;
							if (b)
							{
								if (b.hasEventListener(ButtonEvent.CLICK))
								{
									b.removeEventListener(ButtonEvent.CLICK, mouseEventHandler);
								}
								menu.removeApplicationChild(b);
							}
						}*/
						
						//add logged in button
						var numItem:int = menuXML.button.length();
						
						if (numItem)
						{
							
							for (var j:int = 0; j < numItem; j++)
							{
								//var xmlItem:XML = vo.settingXML.children()[j];
								var xmlItem:XML = menuXML.button[j];
								b = assetManager.getData(xmlItem.@Class, AssetLibID.AST_COMMON);
								
								if (b)
								{
									b.addEventListener(ButtonEvent.CLICK, mouseEventHandler);
									menu.addApplicationChild(b, xmlItem, false);
									b.showPage(TweenerEffect.setAlphaWithDelay(1, 1, 0.3 * j));
									
									if (b.id == AssetID.BTN_FB_LOGIN_OUT)
									{
										_bfButton = b as TextButton;
										_bfButton.text = getMessage(_service.isConnected() ? MessageID.tt0005 : MessageID.tt0003);
										
										CONFIG::air
										{
											_bfButton.closePage(TweenerEffect.setAlpha(0,.3));
										}
									}
								}
								else
								{
									echo('target display object not found : ' + xmlItem.@Class, this, 0xff0000);
								}
							}
							
							appHeader.onStageResize(appHeader.stage);
						}
					}
					
					break;
				}
			}
		}
		
		private function mouseEventHandler(e:ButtonEvent):void 
		{
			var b:Button = e.targetButton as Button;
			if (b.id == AssetID.BTN_USER_LOGOUT)
			{
				var title:String = getMessage(MessageID.CONFIRM_TITLE);
				var txt:String = getMessage(MessageID.CONFIRM_LOGOUT);
				if (title && txt)
				{
					var alerter:ApplicationDisplayObject = Alert.show(new AlerterVO(b.id, AlerterType.CONFIRM, '', null, title, txt));
					if (alerter && alerter is ConfirmAlerter)
					{
						ConfirmAlerter(alerter).addEventListener(AlerterEvent.CONFIRM, userLogoutHandler);
					}
					else
					{
						echo('mouseEventHandler : unable to get alerter');
					}
				}
				else
				{
					echo('mouseEventHandler : unable to get message text');
				}
				
			}
			else
			{
				sendNotification(ButtonEvent.CLICK, e.targetButton);
			}
			
		}
		
		private function userLogoutHandler(e:AlerterEvent):void 
		{
			e.targetDisplayObject.removeEventListener(AlerterEvent.CONFIRM, userLogoutHandler);
			sendNotification(ButtonEvent.CLICK, AssetID.BTN_USER_LOGOUT);
		}
		
	}
}