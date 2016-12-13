package myShopper.shopMgtModule.appSystem.view 
{
	import flash.display.InteractiveObject;
	import flash.display.Shape;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import myShopper.common.data.AlerterVO;
	import myShopper.common.display.ApplicationDisplayObject;
	import myShopper.common.display.ModuleMain;
	import myShopper.common.emun.AssetID;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.ServiceID;
	import myShopper.common.emun.SWFClassID;
	import myShopper.common.events.FileEvent;
	import myShopper.common.events.ServiceEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.net.ExternalService;
	import myShopper.common.ui.InputManager;
	import myShopper.common.ui.TabbingManager;
	import myShopper.common.utils.Alert;
	import myShopper.common.utils.ToolTip;
	import myShopper.fl.ui.DialogManager;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class SystemMediator extends ApplicationMediator
	{
		private var _externalService:ExternalService;
		
		public function SystemMediator(inName:String, viewComponent:Object) 
		{
			super(inName, viewComponent as IModuleMain);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			
			var main:ModuleMain = container as ModuleMain;
			main.stage.scaleMode = StageScaleMode.NO_SCALE;
            main.stage.align = StageAlign.TOP_LEFT;
			main.stage.addEventListener(Event.RESIZE, stageEventHandler);
			main.stage.stageFocusRect = false;
			
			_externalService = serviceManager.getAsset(ServiceID.EXTERNAL);
			_externalService.addEventListener(ServiceEvent.RESPONSE, externalServiceHandler);
		}
		
		private function externalServiceHandler(e:ServiceEvent):void 
		{
			//handle mouse wheel for firefox and chrome
			//type need to be matched with js side
			if (e.response.request.type == 'DOMMouseScroll')
			{
				var obj : InteractiveObject = null;
				
				var event:Object = e.response.data;
				var mousePoint:Point = new Point(mainStage.mouseX, mainStage.mouseY);
				var objects:Array = mainStage.getObjectsUnderPoint(mousePoint);
				var numItem:int = objects.length;
				for (var i : int = numItem - 1; i >= 0; i--) 
				{
					if (objects[i] is InteractiveObject) 
					{
						obj = objects[i] as InteractiveObject;
						break;
					}
					else 
					{
						if (objects[i] is Shape && (objects[i] as Shape).parent)
						{
							obj = (objects[i] as Shape).parent;
							break;
						}
					}
				}

				if (obj) 
				{
					var mEvent:MouseEvent = new MouseEvent(MouseEvent.MOUSE_WHEEL, true, false, mousePoint.x, mousePoint.y, obj, event.ctrlKey, event.altKey, event.shiftKey, false, Number(event.delta));
					
					obj.dispatchEvent(mEvent);
				}

			}
		}
		
		private function stageEventHandler(e:Event):void 
		{
			container.onStageResize(ModuleMain(container).stage);
			
			//
			//Alert.show(new AlerterVO('', '', '', container, 'TESTING', 'successfully tested'))
		}
        
		
		override public function listNotificationInterests():Array 
		{
			return [FileEvent.COMPLETE];
		}

		override public function handleNotification(note:INotification):void 
		{
			switch (note.getName()) 
			{
				case FileEvent.COMPLETE:
				{
					var assetID:String = String(note.getBody());
					
					if (assetID == AssetLibID.AST_COMMON)
					{
						//once asset common loaded into asset manager, init Alert
						Alert.getInstance(container as ApplicationDisplayObject, container.assetManager);
						TabbingManager.getInstance().stage = mainStage;
						ToolTip.getInstance(mainStage);
					}
					else if (assetID == AssetLibID.AST_SHOP_MGT_MOB)
					{
						DialogManager.assetManager = assetManager;
						DialogManager.stage = mainStage;
						
						InputManager.getInstance(
													container as ApplicationDisplayObject, 
													mainStage, 
													assetManager.getData(SWFClassID.INPUT_EDITOR, AssetLibID.AST_SHOP_MGT_MOB)
												);
					}
					break;
				}
				default:
				{
					
				}
			}
		}

	}
}