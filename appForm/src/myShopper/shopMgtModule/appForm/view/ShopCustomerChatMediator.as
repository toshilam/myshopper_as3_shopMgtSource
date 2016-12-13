package myShopper.shopMgtModule.appForm.view 
{
	import caurina.transitions.Tweener;
	import flash.display.DisplayObject;
	import myShopper.common.Config;
	import myShopper.common.data.AlerterVO;
	import myShopper.common.data.communication.CommVO;
	import myShopper.common.data.communication.CommVOList;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.service.CommVOService;
	import myShopper.common.display.Menu;
	import myShopper.common.emun.SWFClassID;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.events.ChatEvent;
	import myShopper.common.events.WindowEvent;
	import myShopper.common.interfaces.IForm;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.interfaces.IVO;
	import myShopper.common.text.Font;
	import myShopper.common.utils.Alert;
	import myShopper.common.utils.TweenerEffect;
	import myShopper.fl.FormAlerter;
	import myShopper.fl.shopMgt.form.ShopMgtChatForm;
	import myShopper.fl.shopMgt.ShopMgtChatFormItem;
	import myShopper.fl.window.BaseWindow;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.emun.MessageID;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtModule.appForm.enum.AssetClassID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.FormMain;
	import myShopper.shopMgtModule.appForm.view.component.ApplicationForm;
	import org.puremvc.as3.multicore.interfaces.IContainerMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.interfaces.ITabFormMediator;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	/**
	 * NOTE: if mediator class will be used create multiple instance, be sure to check notification is sent by the relate proxy
	 * as notification name is shared among mediator
	 */
	public class ShopCustomerChatMediator extends ApplicationMediator implements IContainerMediator, ITabFormMediator
	{
		private var _appForm:ApplicationForm;
		public function get appForm():ApplicationForm 
		{
			if (!_appForm) _appForm = (container as FormMain).appForm;
			return _appForm;
		}
		
		public function getForm():IForm { return form; }
		
		//private var _messageService:MessageService;
		private var _alert:FormAlerter;
		
		private var form:ShopMgtChatForm;
		private var _window:BaseWindow;
		private var _commVOList:CommVOList;
		//private var _bg:ApplicationDisplayObject;
		
		public function ShopCustomerChatMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
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
			_window.btnClose.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			if (_window) appForm.removeApplicationChild(_window, false);
			
			stopListener()
			_window = null;
			form = null;
			_appForm = null;
			_commVOList = null;
		}
		
		override public function listNotificationInterests():Array 
		{
			return [NotificationType.ADD_FORM_SHOP_CUSTOMER_CHAT, NotificationType.RECEIVE_CUSTOMER_CHAT_MESSAGE];
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
				//this notification will be sent directly from ChatCommand
				case NotificationType.END_CUSTOMER_CHAT:
				{
					stopListener();
					_window.alpha = .6;
					break;
				}
				case NotificationType.ADD_FORM_SHOP_CUSTOMER_CHAT:
				{
					//check if the data is sent by the related object, as this mediator is used multiple time, check if vo is already set
					if (!_commVOList)
					{
						_window = assetManager.getData(SWFClassID.WINDOW_BASE, AssetLibID.AST_COMMON);
						
						_commVOList = vo.data as CommVOList;
						
						if (_window && _commVOList)
						{
							//var menuXML:XML = vo.settingXML;
							
							
							//_window.txtTitle.embedFonts = true;
							//_window.txtTitle.defaultTextFormat = Font.getTextFormat( { size:18, letterSpacing:2, font:Font.getDefaultFontByLang(language) } );
							setTextField(_window.txtTitle, language == Config.LANG_CODE_EN);
							
							_window.txtTitle.text = getMessage(MessageID.WINDOW_CUSTOMER_CHAT_TITLE, 'string', AssetLibID.XML_LANG_SHOP_MGT) + '( ' + vo.id + ' )';
							//_window.txtTitle.text += ' : ' + (chatVO.userInfo.firstName) ? chatVO.userInfo.firstName : getMessage(MessageID.WINDOW_CUSTOMER_NOT_LOGGED, 'string', AssetLibID.XML_LANG_SHOP_MGT);
							appForm.addApplicationChild(_window, null, false) as BaseWindow;
							_window.showPage(TweenerEffect.setAlpha(1));
							
							form = _window.addApplicationChild(vo.displayObject, null) as ShopMgtChatForm;
							form.setInfo(_commVOList);
							
							//TODO : remove : for testing only
							form.txtInput.text = 'Hi, what can I help you?'
							
							_window.x = mainStage.stageWidth - _window.width >> 1;
							_window.y = mainStage.stageHeight - _window.height >> 1;
							_window.setSize(form.width + 10, _window.height);
							
							startListener();
							
							updateChatForm();
						}
						else
						{
							echo('handleNotification : ' + note.getName() + ' : unable to retrieve data');
						}
					}
					
					break;
				}
				case NotificationType.RECEIVE_CUSTOMER_CHAT_MESSAGE:
				{
					var commVOList:CommVOList = note.getBody() as CommVOList;
					
					if (_commVOList === commVOList)
					{
						updateChatForm();
					}
					
					break;
				}
			}
			
			
		}
		
		private function updateChatForm():void 
		{
			if (_commVOList)
			{
				if (form.holder.content is Menu)
				{
					Menu(form.holder.content).removeAllButton();
				}
				
				var numItem:int = _commVOList.length;
				for (var i:int = numItem - 1; i >= 0; i--)
				{
					var commItem:ShopMgtChatFormItem = assetManager.getData(AssetClassID.FORM_SHOP_CUSTOMER_CHAT_ITEM, AssetLibID.AST_SHOP_MGT_FORM);
					var commVO:CommVO = _commVOList.getVO(i) as CommVO;
					
					if (!commItem || !commVO)
					{
						echo('updateChatForm : unable to create chat item object');
						break;
					}
					
					
					form.holder.addApplicationChild(commItem, null, false);
					
					commItem.setInfo(commVO);
					commItem.txtNo.text = String(i + 1) + '.';
					commItem.txtFrom.text = commVO.fromUID ? getMessage(myShopper.common.emun.MessageID.HIMSELF) : getMessage(myShopper.common.emun.MessageID.MYSELF);
				}
				
				form.mcScrollBar.refresh();
			}
			else
			{
				echo('updateChatForm : commVoList not found!');
			}
		}
		
		//set window display object to the top of appFrom container
		public function setIndex(inIndex:int = -1):void 
		{
			if (!form || !_window) return;
			
			appForm.setChildIndex(_window, inIndex == -1 ? appForm.numChildren - 1 : inIndex);
		}
		
		override public function startListener():void 
		{
			if (!form || !_window) return;
			form.mouseChildren = true;
			
			if (!_window.btnClose.hasEventListener(ButtonEvent.CLICK))
			{
				_window.btnClose.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
			}
			
			form.btnSend.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
			form.btnSend.startListener();
			form.btnSend.onMouseOver = function():void
			{
				Tweener.addTween(form.btnSend, TweenerEffect.setGlow(1, 'easeOutSine', 0xFF0000, 10, 5, 1));
			}
			form.btnSend.onMouseOut = function():void
			{
				Tweener.addTween(form.btnSend, TweenerEffect.resetGlow());
			}
		}
		
		override public function stopListener():void 
		{
			if (!form || !_window) return;
			
			form.mouseChildren = false;
			
			//_window.btnClose.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			
			form.btnSend.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			
			form.btnSend.stopListener();
			form.btnSend.onMouseOver = null;
			form.btnSend.onMouseOut = null;
		}
		
		
		private function buttonEventHandler(e:ButtonEvent):void 
		{
			if (_alert)
			{
				form.removeApplicationChild(_alert);
				_alert = null;
			}
			
			switch(e.targetButton)
			{
				case _window.btnClose:
				{
					//appForm.removeApplicationChild(form);
					//sendNotification(WindowEvent.CLOSE, form);
					sendNotification(WindowEvent.CLOSE, mediatorName);
					break;
				}
				case form.btnSend:
				{
					var result:* = form.isValid();
					if (result === true)
					{
						_commVOList.addVO(new CommVO('', '', '', form.txtInput.text, ''));
						//stopListener();
						form.clear();
						updateChatForm();
						sendNotification(ChatEvent.SEND_SHOP_MESSAGE, mediatorName);
					}
					else
					{
						createFormAlert(getMessage(myShopper.common.emun.MessageID.FORM_MISSING_INFO), (result as Vector.<DisplayObject>)[0]);
						
					}
					break;
				}
			}
		}
		
		private function createFormAlert(inMessage:String, inItem:DisplayObject):void 
		{
			if (form)
			{
				_alert = form.addApplicationChild(Alert.create(new AlerterVO('', '', '', null, '', inMessage)), null) as FormAlerter;
				_alert.autoClose(5000);
				_alert.x = inItem.x + inItem.width;
				_alert.y = inItem.y - _alert.height;
				_alert = null;
			}
			
		}
		
		
	}
}