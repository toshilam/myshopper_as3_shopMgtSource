package myShopper.shopMgtModule.appForm.view 
{
	import flash.events.Event;
	import flash.geom.Rectangle;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.service.GoogleVOService;
	import myShopper.common.data.user.UserLoginFormVO;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.SWFClassID;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.events.GoogleEvent;
	import myShopper.common.events.WindowEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.flAIR.WebView;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.FormMain;
	import myShopper.shopMgtModule.appForm.view.component.ApplicationForm;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class GoogleLoginFormMediator extends ApplicationMediator implements IMediator//, ITabFormMediator 
	{
		private var _appForm:ApplicationForm;
		public function get appForm():ApplicationForm 
		{
			if (!_appForm) _appForm = (container as FormMain).appForm;
			return _appForm;
		}
		
		//public function getForm():IForm { return form; }
		
		CONFIG::air
		private var _webView:WebView;
		
		private var _loginVO:UserLoginFormVO;
		//private var form:UserLoginForm;
		
		public function GoogleLoginFormMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
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
			
			//if (form) appForm.removeApplicationChild(form);
			
			CONFIG::air
			{
				if (_webView)
				{
					_webView.stageWebView.removeEventListener(Event.COMPLETE, webViewEventHandler);
					_webView.btnClose.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
					mainStage.removeChild(_webView);
					_webView.destroyDisplayObject();
					_webView = null;
				}
			}
			
			
			
			stopListener()
			//form = null;
			
		}
		
		override public function listNotificationInterests():Array 
		{
			return [NotificationType.ADD_FORM_GOOGLE_LOGIN, NotificationType.USER_GOOGLE_LOGIN_SUCCESS, NotificationType.USER_GOOGLE_LOGIN_FAIL];
		}

		override public function handleNotification(note:INotification):void 
		{
			var body:Object = note.getBody();
			var vo:DisplayObjectVO = body as DisplayObjectVO;
			
			/*if (!vo)
			{
				echo('handleNotification : unknown data type : ' + body);
			}*/
			
			switch(note.getName())
			{
				case NotificationType.ADD_FORM_GOOGLE_LOGIN:
				{
					_loginVO = vo.data as UserLoginFormVO;
					
					var url:String = GoogleVOService.getOAuthURL();
					if (url)
					{
						CONFIG::air
						{
							_webView = mainStage.addChild( assetManager.getData(SWFClassID.WEB_VIEW, AssetLibID.AST_COMMON_AIR)) as WebView;
							
							if (_webView)
							{
								_webView.initDisplayObject(null, mainStage);
								_webView.type = CONFIG::mobile ? WebView.TYPE_MOB : WebView.TYPE_AIR;
								_webView.loadURL(url);
								_webView.stageWebView.addEventListener(Event.COMPLETE, webViewEventHandler);
								_webView.btnClose.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
							}
						}
						
						CONFIG::web
						{
							//TODO call external js
							echo('TODO');
						}
						
					}
					break;
				}
				case NotificationType.USER_GOOGLE_LOGIN_SUCCESS:
				case NotificationType.USER_GOOGLE_LOGIN_FAIL:
				{
					//to be handled by printerMediator
					sendNotification(WindowEvent.CLOSE, mediatorName);
					break;
				}
				
			}
			
			
		}
		
		CONFIG::air
		private function webViewEventHandler(e:Event):void 
		{
			if (_webView)
			{
				//formet
				//Success code=4/y5GTQbWuFTd0PU5YTh9Qg2sSYyb4
				//Denied error=access_denied
				var title:String =  _webView.stageWebView.title;
				
				echo('webViewEventHandler : ' + title);
				
				if (title.indexOf('=') != -1)
				{
					var arrResult:Array = title.split('=');
					var prefix:String = arrResult[0];
					var code:String = arrResult[1];
					
					if (prefix.toLowerCase().indexOf('success') != -1)
					{
						_loginVO.password = code;
						
						sendNotification(GoogleEvent.LOGIN, _loginVO);
						
						//make web view invisible
						_webView.closePage();
					}
					else
					{
						//access denied
						sendNotification(NotificationType.USER_GOOGLE_LOGIN_FAIL);
					}
				}
			}
		}
		
		override public function startListener():void 
		{
			
		}
		
		override public function stopListener():void
		{
			
		}
		
		
	
		private function buttonEventHandler(e:ButtonEvent):void 
		{
			/*if (_alert)
			{
				form.removeApplicationChild(_alert);
				_alert = null;
			}*/
			
			//switch(e.targetButton)
			//{
				//case 
				//default
				//{
					CONFIG::air
					{
						if(_webView.btnClose)
						{
							//appForm.removeApplicationChild(form);
							//sendNotification(WindowEvent.CLOSE, form);
							sendNotification(WindowEvent.CLOSE, mediatorName);
							//break;
						}
					}
				//}
			//}
		}
		
		/*private function createFormAlert(inMessage:String):void 
		{
			if (form)
			{
				_alert = Alert.create(new AlerterVO('', '', '', null, '', inMessage)) as FormAlerter;
				form.addApplicationChild(_alert, null);
				_alert.autoClose(5000);
				_alert.x = form.txtEmail.x + form.txtEmail.width;
				_alert.y = form.txtEmail.y - _alert.height;
				_alert = null;
			}
			
		}*/
		
		
	}
}