package myShopper.shopMgtModule.appForm.controller
{
	import myShopper.common.emun.PageID;
	import myShopper.common.events.PageEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.utils.Tracer;
	import myShopper.shopMgtModule.appForm.enum.MediatorID;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import myShopper.shopMgtModule.appForm.ModuleFacade;
	import myShopper.shopMgtModule.appForm.view.ModuleJunctionMediator;
	import myShopper.shopMgtModule.appForm.view.UserLoginFormMediator;
	import org.puremvc.as3.multicore.interfaces.IApplicationMediator;
	import org.puremvc.as3.multicore.interfaces.IApplicationProxy;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class PageCommand extends SimpleCommand implements ICommand
	{
		override public function execute( note:INotification ):void
		{
			var e:PageEvent = note.getBody() as PageEvent;
			
			if (e)
			{
				switch(e.pageID)
				{
					/*case PageID.USER_REGISTER:
					{
						
						var mediator:IApplicationMediator = getMediatorByPageID(e.pageID);
						var proxy:IApplicationProxy = getProxyByPageID(e.pageID);
						if (proxy && mediator)
						{
							facade.registerMediator( mediator );
							facade.registerProxy( proxy );
							
							proxy.initAsset(e.pageID);
						}
						else
						{
							Tracer.echo('PageCommand : execute : unable to create proxy or mediator' + e.pageID);
						}
						break;
					}*/
				}
				
			}
			
		}
		
		private function getMediatorIDByPageID(inType:String):String
		{
			//if (inType == PageID.USER_REGISTER) 	return MediatorID.USER_REGISTER;
			
			return null;
		}
		
		private function getProxyIDByPageID(inType:String):String
		{
			//if (inType == PageID.USER_REGISTER) 	return ProxyID.USER_REGISTER;
			
			return null;
		}
		
		private function getMediatorByPageID(inID:String):IApplicationMediator 
		{
			//if (inID == PageID.USER_REGISTER) 	return new UserRegisterFormMediator(MediatorID.USER_REGISTER, moduleMain);
			
			return null;
		}
		
		private function getProxyByPageID(inID:String):IApplicationProxy 
		{
			//if (inID == PageID.USER_REGISTER) 	return new UserRegisterInfoProxy(ProxyID.USER_REGISTER, moduleMain);
			
			return null;
		}
		
		
		private function get moduleMain():IModuleMain
		{
			return (facade as ModuleFacade).module;
		}
	}
}