package myShopper.shopMgtModule.appShopMgt.view 

{
	import caurina.transitions.Tweener;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.shop.ShopInfoVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.display.ApplicationDisplayObject;
	import myShopper.common.display.Menu;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.MessageID;
	import myShopper.common.emun.SWFClassID;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.ButtonEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.interfaces.IVO;
	import myShopper.common.utils.TweenerEffect;
	import myShopper.fl.shopMgt.MyStatus;
	import myShopper.shopMgtCommon.event.ShopMgtEvent;
	import myShopper.shopMgtModule.appShopMgt.enum.NotificationType;
	import myShopper.shopMgtModule.appShopMgt.enum.AssetID;
	import myShopper.shopMgtModule.appShopMgt.ShopMgtMain;
	import myShopper.shopMgtModule.appShopMgt.view.component.ApplicationShopMgt;
	import org.puremvc.as3.multicore.enum.NotificationType;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class MyStatusMediator extends ApplicationMediator implements IMediator 
	{
		private var _appShop:ApplicationShopMgt;
		public function get appShop():ApplicationShopMgt 
		{
			if (!_appShop) _appShop = (container as ShopMgtMain).appShop;
			return _appShop;
		}
		
		public function get myStatus():MyStatus
		{
			return appShop.myStatus;
		}
		
		
		
		public function MyStatusMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
		{
			super(inMediatorName, inViewComponent);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			
		}
		
		override public function listNotificationInterests():Array 
		{
			return	[
						org.puremvc.as3.multicore.enum.NotificationType.ADD_CHILD, 
						myShopper.shopMgtModule.appShopMgt.enum.NotificationType.UPDATE_STATUS_FAIL,
						myShopper.shopMgtModule.appShopMgt.enum.NotificationType.UPDATE_STATUS_SUCCESS,
					];
		}

		override public function handleNotification(note:INotification):void 
		{
			var vo:DisplayObjectVO = note.getBody() as DisplayObjectVO;
			
			switch (note.getName()) 
			{   
				case org.puremvc.as3.multicore.enum.NotificationType.ADD_CHILD:
				{
					if (vo.id == AssetID.MY_STATUS) 
					{
						appShop.myStatus = appShop.addApplicationChild(vo.displayObject, vo.settingXML) as MyStatus;
						if (vo.data is ShopInfoVO)
						{
							myStatus.setInfo(vo.data as IVO);
						}
						
						myStatus.btnSend.tooltip = getMessage(MessageID.tt1013);
						
						startListener();
					}
					break;
				}
				case myShopper.shopMgtModule.appShopMgt.enum.NotificationType.UPDATE_STATUS_FAIL:
				case myShopper.shopMgtModule.appShopMgt.enum.NotificationType.UPDATE_STATUS_SUCCESS:
				{
					startListener();
					break;
				}
			}
		}
		
		override public function startListener():void 
		{
			
			myStatus.btnSend.addEventListener(ButtonEvent.CLICK, buttonEventHandler);
			
			myStatus.btnSend.startListener();
			myStatus.btnSend.onMouseOver = function():void
			{
				Tweener.addTween(myStatus.btnSend, TweenerEffect.setGlow(1, 'easeOutSine', 0xFF0000, 5, 5, 1));
			}
			myStatus.btnSend.onMouseOut = function():void
			{
				Tweener.addTween(myStatus.btnSend, TweenerEffect.resetGlow());
			}
		}
		
		override public function stopListener():void
		{
			
			Tweener.addTween(myStatus.btnSend, TweenerEffect.resetGlow());
			
			myStatus.btnSend.removeEventListener(ButtonEvent.CLICK, buttonEventHandler);
			
			myStatus.btnSend.stopListener();
			myStatus.btnSend.onMouseOver = null;
			myStatus.btnSend.onMouseOut = null;
		}
		
		
		/*private function windownButtonEventHandler(e:ButtonEvent):void 
		{
			switch(e.targetButton)
			{
				
			}
		}*/
		
		private function buttonEventHandler(e:ButtonEvent):void 
		{
			switch(e.targetButton)
			{
				case myStatus.btnSend:
				{
					var result:* = myStatus.isValid();
					if (result === true)
					{
						stopListener();
						
						sendNotification(ShopMgtEvent.SHOP_UPDATE_STATUS);
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
}