package myShopper.shopMgtModule.appShopMgt.controller 

{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import myShopper.common.display.button.Button;
	import myShopper.common.emun.AssetID;
	import myShopper.common.interfaces.IButton;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.utils.Tracer;
	import myShopper.shopMgtModule.appShopMgt.enum.MediatorID;
	import myShopper.shopMgtModule.appShopMgt.enum.ProxyID;
	import myShopper.shopMgtModule.appShopMgt.model.WindowAssetProxy;
	import myShopper.shopMgtModule.appShopMgt.ModuleFacade;
	import myShopper.shopMgtModule.appShopMgt.view.WindowInfoMenuMediator;
	import org.puremvc.as3.multicore.interfaces.IApplicationProxy;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	import org.puremvc.as3.multicore.patterns.observer.Notification;
    
	
	public class WindowCommand extends SimpleCommand 
	{
		
		override public function execute(note:INotification):void 
		{
			
			var id:String;
			
			if		(note.getBody() is String) 	id = String(note.getBody());
			else if	(note.getBody() is Button) 	id = Button(note.getBody()).id;
			
			var moduleFacade:ModuleFacade = facade as ModuleFacade;
			
			/*if (note.getName() == WindowEvent.CREATE)
			{
				
				switch(id)
				{
					case AssetID.BTN_USER_MANAGEMENT_INFO:
					{
						//if mediator already exist (window already on stage), ignore request
						if (!facade.hasMediator(MediatorID.WINDOW_SETTING_MENU))
						{
							facade.registerMediator(new WindowInfoMenuMediator(MediatorID.WINDOW_SETTING_MENU, moduleFacade.module));
							windowProxy.initAsset(id);
						}
						
						
						break;
					}
					default:
					{
						Tracer.echo(multitonKey + ' : ButtonCommand : no matched id found : ' + id, this, 0xff0000);
					}
				}
			}
			else if (note.getName() == WindowEvent.CLOSE)
			{
				switch(id)
				{
					case AssetID.BTN_USER_MANAGEMENT_INFO:
					{
						trace(facade.removeMediator(MediatorID.WINDOW_SETTING_MENU));
						break;
					}
				}
			}*/
		}
		
		private function get windowProxy():IApplicationProxy
		{
			return facade.retrieveProxy(ProxyID.WINDOW) as IApplicationProxy;
		}
	}
}