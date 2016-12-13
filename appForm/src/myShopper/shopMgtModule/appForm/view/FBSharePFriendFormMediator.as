package myShopper.shopMgtModule.appForm.view 
{
	import caurina.transitions.Tweener;
	import com.facebook.graph.Facebook;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import myShopper.common.data.AlerterVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.facebook.FbFriendList;
	import myShopper.common.data.facebook.FbFriendVO;
	import myShopper.common.data.facebook.FbShareProductVO;
	import myShopper.common.data.shop.ShopProductFormVO;
	import myShopper.common.display.Menu;
	import myShopper.common.emun.AlerterType;
	import myShopper.common.emun.MessageID;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.events.WindowEvent;
	import myShopper.common.interfaces.IForm;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.utils.Alert;
	import myShopper.common.utils.TweenerEffect;
	import myShopper.fl.button.FBFriendButton;
	import myShopper.fl.form.facebook.FBSharePFriendForm;
	import myShopper.fl.FormAlerter;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtModule.appForm.enum.AssetClassID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.FormMain;
	import myShopper.shopMgtModule.appForm.view.component.ApplicationForm;
	import org.puremvc.as3.multicore.interfaces.IContainerMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.interfaces.ITabFormMediator;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class FBSharePFriendFormMediator extends ApplicationMediator implements IContainerMediator, ITabFormMediator
	{
		private const NUM_PAGE_DATA:int = 8;
		
		private var _appForm:ApplicationForm;
		public function get appForm():ApplicationForm 
		{
			if (!_appForm) _appForm = (container as FormMain).appForm;
			return _appForm;
		}
		
		public function getForm():IForm { return form; }
		
		private var _alert:FormAlerter;
		
		private var form:FBSharePFriendForm;
		private var _productShareFriendVO:FbShareProductVO;
		
		public function FBSharePFriendFormMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
		{
			super(inMediatorName, inViewComponent);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			//_messageService = new MessageService(xmlManager as XMLManager, AssetLibID.XML_LANG_COMMON, 'string');
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			
			Alert.close();
			//if (form) appForm.removeApplicationChild(form);
			
			/*if (form.txtEmail.hasEventListener(FocusEvent.FOCUS_IN))
			{
				form.txtEmail.removeEventListener(FocusEvent.FOCUS_IN, buttonEventHandler, false);
				form.txtPassword.removeEventListener(FocusEvent.FOCUS_IN, buttonEventHandler, false);
			}*/
			
			stopListener()
			form = null;
			//_messageService = null;
			_alert = null;
			_productShareFriendVO = null;
		}
		
		override public function listNotificationInterests():Array 
		{
			return [NotificationType.ADD_FORM_FB_SHARE_P_FRIEND, NotificationType.FB_SHARE_P_FRIEND_FAIL, NotificationType.FB_SHARE_P_FRIEND_SUCCESS, NotificationType.FB_NO_PERMISSION];
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
				case NotificationType.ADD_FORM_FB_SHARE_P_FRIEND:
				{
					_productShareFriendVO = vo.data as FbShareProductVO;
					
					if (_productShareFriendVO && _productShareFriendVO.fdList is FbFriendList && _productShareFriendVO.product is ShopProductFormVO)
					{
						//form =  appForm.addApplicationChild(vo.displayObject, vo.settingXML) as FBSharePFriendForm;
						form =  Alert.show(new AlerterVO('', AlerterType.DISPLAY_OBJECT, '', vo.displayObject)) as FBSharePFriendForm;
						form.setInfo(_productShareFriendVO);
						//form.txtMessage.text = _productShareFriendVO.product.productDescription;
						form.mcPagingController.initController(_productShareFriendVO.fdList.length, NUM_PAGE_DATA);
						pagingHandler(null);
						
						startListener();
						
						break;
					}
					
					//if shop info and product info not found, alert + remove mediator and proxy
					//so no "break" needed.
					
				}
				case NotificationType.FB_SHARE_P_FRIEND_FAIL:
				case NotificationType.FB_SHARE_P_FRIEND_SUCCESS:
				{
					//Alert.close();
					
					var title:String = note.getName() == NotificationType.FB_SHARE_P_FRIEND_SUCCESS ? getMessage(MessageID.SUCCESS_TITLE) : getMessage(MessageID.ERROR_TITLE);
					var message:String = note.getName() == NotificationType.FB_SHARE_P_FRIEND_SUCCESS ? getMessage(MessageID.SUCCESS_SEND) : getMessage(MessageID.ERROR_GET_DATA) + '<br />' + getMessage(MessageID.ERROR_TRY_LATER);
					
					//Alert.show(new AlerterVO('', AlerterType.MESSAGE, '', null, title, message));
					
					createFormAlert(message, form.txtMessage);
					break;
				}
				
				case NotificationType.FB_NO_PERMISSION:
				{
					//close form, error to be handle by system
					sendNotification(WindowEvent.CLOSE, mediatorName);
					break;
				}
			}
			
			
		}
		
		private function pagingHandler(e:ApplicationEvent = null):void 
		{
			if (form && form.mcPagingController.totalPage)
			{
				(form.holder.content as Menu).removeAllButton();
				
				var startIndex:int = form.mcPagingController.currPage * NUM_PAGE_DATA;
				
				for (var i:int = startIndex; i < startIndex + NUM_PAGE_DATA; i++)
				{
					var fbVO:FbFriendVO = _productShareFriendVO.fdList.getVO(i) as FbFriendVO;
					if (fbVO)
					{
						var b:FBFriendButton = assetManager.getData(AssetClassID.BTN_FB_SHARE_PRODUCT, AssetLibID.AST_FORM);
						if (b)
						{
							form.holder.addApplicationChild(b, null, false);
							b.setInfo(fbVO);
							b.logo.load(Facebook.getImageUrl(fbVO.id));
							
							Tweener.addTween(b, TweenerEffect.setGlow(0, 'easeOutSine', 0x000000));
						}
					}
				}
			}
			
		}
		
		public function setIndex(inIndex:int = -1):void 
		{
			if (!form) return;
			
			appForm.setChildIndex(form, inIndex == -1 ? appForm.numChildren - 1 : inIndex);
		}
		
		override public function startListener():void 
		{
			if (!form) return;
			
			if (!form.btnSend.hasEventListener(ButtonEvent.CLICK))
			{
				form.btnClose.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
			}
			
			form.btnSend.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
			
			form.mcPagingController.addEventListener(ApplicationEvent.MORE, pagingHandler);
			
			/*if (!form.txtEmail.hasEventListener(FocusEvent.FOCUS_IN))
			{
				form.txtEmail.addEventListener(FocusEvent.FOCUS_IN, buttonEventHandler, false, 0, true);
				form.txtPassword.addEventListener(FocusEvent.FOCUS_IN, buttonEventHandler, false, 0, true);
			}*/
			
			
			//form.addEventListener(ApplicationEvent.PAGE_CLOSED, formEventHandler);
			form.btnSend.startListener();
			form.btnSend.onMouseOver = function():void
			{
				Tweener.addTween(form.btnSend, TweenerEffect.setGlow(1, 'easeOutSine', 0xFF0000, 10, 5, .5));
			}
			form.btnSend.onMouseOut = function():void
			{
				Tweener.addTween(form.btnSend, TweenerEffect.resetGlow());
			}
		}
		
		override public function stopListener():void 
		{
			if (!form) return;
			
			//form.btnClose.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			form.btnSend.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			
			form.mcPagingController.removeEventListener(ApplicationEvent.MORE, pagingHandler);
			
			form.btnSend.stopListener();
			form.btnSend.onMouseOver = null;
			form.btnSend.onMouseOut = null;
		}
		
		
		
		private function buttonEventHandler(e:Event):void 
		{
			if (_alert)
			{
				form.removeApplicationChild(_alert);
				_alert = null;
			}
			if (e is ButtonEvent)
			{
				switch(ButtonEvent(e).targetButton)
				{
					case form.btnClose:
					{
						sendNotification(WindowEvent.CLOSE, mediatorName);
						break;
					}
					case form.btnSend:
					{
						var result:* = form.isValid();
						if (result === true)
						{
							stopListener();
							sendNotification(ApplicationEvent.SHARE, form.vo);
						}
						/*else
						{
							createFormAlert(MessageID.FORM_MISSING_INFO, (result as Vector.<DisplayObject>)[0]);
						}*/
						break;
					}
				}
			}
			
		}
		
		private function createFormAlert(inMessage:String, inItem:DisplayObject):void 
		{
			if (form)
			{
				_alert = Alert.create(new AlerterVO('', '', '', null, '', inMessage)) as FormAlerter;
				form.addApplicationChild(_alert, null);
				_alert.x = inItem.x + inItem.width;
				_alert.y = inItem.y - _alert.height;
			}
			
		}
		
		
	}
}