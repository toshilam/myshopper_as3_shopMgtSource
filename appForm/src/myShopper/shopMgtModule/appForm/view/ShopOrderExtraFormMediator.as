package myShopper.shopMgtModule.appForm.view 
{
	//import fl.controls.ComboBox;
	import fl.data.DataProvider;
	import caurina.transitions.Tweener;
	import flash.display.DisplayObject;
	import myShopper.common.Config;
	import myShopper.common.data.AlerterVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.shop.ShopOrderExtraVO;
	import myShopper.common.emun.AlerterType;
	import myShopper.common.emun.AssetXMLNodeID;
	import myShopper.common.emun.MessageID;
	import myShopper.common.emun.SWFClassID;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.events.WindowEvent;
	import myShopper.common.interfaces.IForm;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.text.Font;
	import myShopper.common.utils.Alert;
	import myShopper.common.utils.TweenerEffect;
	import myShopper.fl.FormAlerter;
	import myShopper.fl.shopMgt.form.ShopMgtOrderExtraForm;
	import myShopper.fl.shopMgt.form.ShopMgtOrderForm;
	import myShopper.fl.ui.DialogManager;
	import myShopper.fl.window.BaseWindow;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtModule.appForm.enum.AssetClassID;
	import myShopper.shopMgtModule.appForm.enum.MediatorID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.FormMain;
	import myShopper.shopMgtModule.appForm.view.component.ApplicationForm;
	import org.puremvc.as3.multicore.interfaces.IContainerMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.interfaces.ITabFormMediator;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	
	public class ShopOrderExtraFormMediator extends ApplicationMediator implements IContainerMediator, ITabFormMediator
	{
		private var _appForm:ApplicationForm;
		public function get appForm():ApplicationForm 
		{
			if (!_appForm) _appForm = (container as FormMain).appForm;
			return _appForm;
		}
		
		public function getForm():IForm { return form; }
		
		//private var _shopInfoVO:ShopInfoVO;
		private var _alert:FormAlerter;
		
		private var form:ShopMgtOrderExtraForm;
		private var _window:BaseWindow;
		private var _orderExtraVO:ShopOrderExtraVO;
		private var _xmlOrderExtra:XML;
		
		public function ShopOrderExtraFormMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
		{
			super(inMediatorName, inViewComponent);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			_xmlOrderExtra = xmlManager.getData(AssetXMLNodeID.ORDER_EXTRA, AssetLibID.XML_LANG_COMMON)[0];
			
			if (!_xmlOrderExtra)
			{
				throw(new UninitializedError('ShopOrderMediator : onRegister : unable to retreve shop vo/xml'));
			}
			
			//listen to window holder parent object, once order detail form is removed, remove this extra form as well
			//appForm.addEventListener(ApplicationEvent.CHILD_REMOVED, applicationEventHandler, false, 0, true);
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
			//_window.mcScrollBar.scrollTarget = null;
			
			//to be removed from Alert.close
			//if (_window) appForm.removeApplicationChild(_window, false);
			Alert.close(false);
			
			//appForm.removeEventListener(ApplicationEvent.CHILD_REMOVED, applicationEventHandler);
			
			stopListener();
			_alert = null;
			_appForm = null;
			form = null;
			_window = null;
			//_shopInfoVO = null;
			_orderExtraVO = null;
			//_statusXML = null;
		}
		
		
		
		override public function listNotificationInterests():Array 
		{
			var arr:Array = null;
			
			if (mediatorName == MediatorID.SHOP_MGT_ORDER_EXTRA)
			{
				arr = 	[
							NotificationType.ADD_FORM_SHOP_ORDER_EXTRA
							//14/11/2013 no to listen to WindowEvent.CLOSE notification, as add form changed to Alert
							//WindowEvent.CLOSE //listen mediator close event from order from. 
						];
			}
			else if(mediatorName == MediatorID.SHOP_MGT_SALES_EXTRA)
			{
				arr = [NotificationType.ADD_FORM_SHOP_SALES_EXTRA];
			}
			
			return arr;
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
				case NotificationType.ADD_FORM_SHOP_ORDER_EXTRA:
				case NotificationType.ADD_FORM_SHOP_SALES_EXTRA:
				{
					_window = vo.displayObject as BaseWindow;
					_orderExtraVO = vo.data as ShopOrderExtraVO;
					
					if (_window && _orderExtraVO)
					{
						form = _window.addApplicationChild(assetManager.getData(AssetClassID.FORM_SHOP_ORDER_EXTRA, AssetLibID.AST_SHOP_MGT), null, false) as ShopMgtOrderExtraForm;
						
						//_window.txtTitle.embedFonts = false;
						//_window.txtTitle.defaultTextFormat = Font.getTextFormat( { size:18, letterSpacing:2, font:SWFClassID.SANS } );
						setTextField(_window.txtTitle, language == Config.LANG_CODE_EN);
						
						//appForm.addApplicationChild(_window, vo.settingXML, false);
						Alert.show(new AlerterVO(mediatorName, AlerterType.DISPLAY_OBJECT, '', _window, '', '', vo.settingXML, false));
						
						_window.showPage(TweenerEffect.setAlpha(1));
						_window.setSize(350, form.height + 100);
						_window.x = mainStage.stageWidth - _window.width >> 1;
						_window.y = mainStage.stageHeight - _window.height >> 1;
						_window.isDragable = false;
						form.cbType.dataProvider = new DataProvider(_xmlOrderExtra);
						
						CONFIG::mobile
						{
							new DialogManager().addHandler(form.cbType, _xmlOrderExtra);
						}
						
						form.setInfo(_orderExtraVO);
						
						startListener();
						
						
					}
					
					break;
				}
				//case WindowEvent.CLOSE:
				//{
					//remove this mediator as well when related order form is closed
					//if (note.getBody() == MediatorID.SHOP_MGT_ORDER_DETAIL)
					//{
						//stopListener();
						//sendNotification(WindowEvent.CLOSE, mediatorName);
					//}
					//return;
				//}
				
			}
			
			if(_window) _window.isBusy = false;
		}
		
		
		//set window display object to the top of appFrom container
		public function setIndex(inIndex:int = -1):void 
		{
			if (!_window) return;
			
			appForm.setChildIndex(_window, inIndex == -1 ? appForm.numChildren - 1 : inIndex);
		}
		
		override public function startListener():void 
		{
			if (!form || !_window) return;
			
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
			
			
			if (!_window.btnClose.hasEventListener(ButtonEvent.CLICK))
			{
				_window.btnClose.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
			}
			
			
		}
		
		override public function stopListener():void
		{
			if (!form || !_window) return;
			
			form.btnSend.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			Tweener.addTween(form.btnSend, TweenerEffect.resetGlow());
			form.btnSend.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			
			form.btnSend.stopListener();
			form.btnSend.onMouseOver = null;
			form.btnSend.onMouseOut = null;
			
			
			//_window.btnClose.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			
		}
		
		private function buttonEventHandler(e:ButtonEvent):void 
		{
			switch(e.targetButton)
			{
				case _window.btnClose:
				{
					//sendNotification(WindowEvent.CLOSE, _window);
					sendNotification(WindowEvent.CLOSE, mediatorName);
					break;
				}
				
				case form.btnSend:
				{
					var result:* = form.isValid();
					
					if (result === true)
					{
						var eventType:String = mediatorName == MediatorID.SHOP_MGT_ORDER_EXTRA ? ShopMgtEvent.SHOP_ADD_ORDER_EXTRA : ShopMgtEvent.SHOP_ADD_SALES_EXTRA;
						sendNotification(eventType, _orderExtraVO);
						sendNotification(WindowEvent.CLOSE, mediatorName);
					}
					else
					{
						createFormAlert(getMessage(MessageID.FORM_MISSING_INFO), (result as Vector.<DisplayObject>)[0]);
					}
					break;
				}
			}
		}
		
		private function createFormAlert(inMessage:String, inItem:DisplayObject):void 
		{
			//var _form:ApplicationDisplayObject = _window.currPageIndex == 0 ? form : form2;
			if (form)
			{
				_alert = form.addApplicationChild(Alert.create(new AlerterVO('', '', '', null, '', inMessage)), null) as FormAlerter;
				_alert.autoClose();
				_alert.x = inItem.x - _alert.width;
				_alert.y = inItem.y - _alert.height;
				_alert = null;
			}
			
		}
	}
}