package myShopper.shopMgtModule.appSystem.controller
{
	import flash.display.LoaderInfo;
	import myShopper.common.display.ApplicationDisplayObject;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.events.ApplicationEvent;
	import myShopper.common.events.FileEvent;
	import myShopper.common.events.ModuleEvent;
	import myShopper.common.interfaces.IApplicationDisplayObject;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.utils.Tracer;
	import myShopper.shopMgtModule.appSystem.enum.MediatorID;
	import myShopper.shopMgtModule.appSystem.enum.ProxyID;
	import myShopper.shopMgtModule.appSystem.model.ContentProxy;
	import myShopper.shopMgtModule.appSystem.SystemMain;
	import myShopper.shopMgtModule.appSystem.view.ApplicationJunctionMediator;
	import myShopper.shopMgtModule.appSystem.view.SystemMediator;
	import org.puremvc.as3.multicore.enum.NotificationType;
	import org.puremvc.as3.multicore.interfaces.IApplicationProxy;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	import org.puremvc.as3.multicore.utilities.pipes.patterns.facade.PipeAwardModule;
	
	public class AssetCommand extends SimpleCommand implements ICommand
	{
		override public function execute(note:INotification):void
		{
			var systemMain:SystemMain = system.getViewComponent() as SystemMain;
			
			
			var loadedAssetID:String = String(note.getBody());
			switch (loadedAssetID)
			{
				case AssetLibID.APP_HEADER: 
				case AssetLibID.APP_FOOTER:
				case AssetLibID.APP_FORM: 
				case AssetLibID.APP_SHOP_MGT: 
				{
					var moduleMain:IModuleMain = (systemMain.assetManager.getAsset(loadedAssetID) as LoaderInfo).content as IModuleMain;
						
					if (moduleMain.setup(getContainerByID(loadedAssetID), systemMain.setupVO))
					{
						sendNotification(NotificationType.CONNECT_MODULE_TO_SHELL, moduleMain.moduleName);
						
						//(facade.retrieveProxy(ProxyID.CONTENT) as ContentProxy).moudleHandler(loadedAssetID, moduleMain);
						
						//start loading other module/asset in background
						if (loadedAssetID == AssetLibID.APP_SHOP_MGT)
						{
							//(facade.retrieveProxy(ProxyID.ASSET_SHOP) as IApplicationProxy).initAsset();
							
							//notify main module to remove loading screen
							(facade as PipeAwardModule).module.dispatchEvent(new ModuleEvent(ModuleEvent.MODULE_READY_ALL));
							
							//notify other module all common app are loaded, used for QQ login for the moment
							//comm.request(CommunicationType.APP_DATA_INITIALIZED);
						}
					}
					else
					{
						Tracer.echo('AssetCommand : unable to init module main : ' + loadedAssetID, this, 0xff0000);
					}
					
					break;
				}
				case AssetLibID.XML_COMMON:
				{
					(facade.retrieveProxy(ProxyID.AMF) as IApplicationProxy).initAsset();
					(facade.retrieveProxy(ProxyID.LOCAL_DATA) as IApplicationProxy).initAsset();
					
					break;
				}
				default:
				{
					Tracer.echo('AssetCommand : loaded asset no need to be connected : ' + loadedAssetID, this, 0xff0000);
				}
			}
				
			
			
		}
		
		private function getContainerByID(inLoadedAssetID:String):ApplicationDisplayObject
		{
			switch (inLoadedAssetID)
			{
				case AssetLibID.APP_HEADER: 	return (system.getViewComponent() as SystemMain).headerContainer;
				case AssetLibID.APP_FOOTER: 	return (system.getViewComponent() as SystemMain).footerContainer;
				case AssetLibID.APP_FORM: 		return (system.getViewComponent() as SystemMain).windowContainer;
				case AssetLibID.APP_SHOP_MGT: 	return (system.getViewComponent() as SystemMain).contentContainer; //shop / shop mgt / user mgt share same container
			}
			
			Tracer.echo('AssetCommand : getContainerByID : no matched id found : ' + inLoadedAssetID, this, 0xff0000);
			return null;
		}
		
		private function get system():SystemMediator
		{
			return facade.retrieveMediator(MediatorID.SYSTEM) as SystemMediator;
		}
	}
}