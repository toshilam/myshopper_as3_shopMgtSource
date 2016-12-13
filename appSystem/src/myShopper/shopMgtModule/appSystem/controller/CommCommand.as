package myShopper.shopMgtModule.appSystem.controller
{
	import myShopper.common.emun.CommunicationType;
	import myShopper.common.interfaces.ICommServiceRequest;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.utils.Tracer;
	import myShopper.shopMgtModule.appSystem.enum.ProxyID;
	import myShopper.shopMgtModule.appSystem.model.AMFRemoteProxy;
	import myShopper.shopMgtModule.appSystem.model.FacebookProxy;
	import myShopper.shopMgtModule.appSystem.model.FMSRemoteProxy;
	import myShopper.shopMgtModule.appSystem.model.RTMFPRemoteProxy;
	import myShopper.shopMgtModule.appSystem.model.WSRemoteProxy;
	import org.puremvc.as3.multicore.interfaces.IApplicationMediator;
	import org.puremvc.as3.multicore.interfaces.IApplicationProxy;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CommCommand extends SimpleCommand implements ICommand
	{
		override public function execute( note:INotification ):void
		{
			var request:ICommServiceRequest = note.getBody() as ICommServiceRequest;
			
			if (request)
			{
				switch(request.communicationType)
				{
					case CommunicationType.USER_LOGIN_SUCCESS:
					{
						//once user loggin (AMF) then try to login to FMS
						//fms.initAsset();
						ws.initAsset();
						rtmfp.initAsset();
						break;
					}
					case CommunicationType.USER_LOGOUT:
					{
						//fms.tearDownAsset();
						ws.tearDownAsset();
						amf.tearDownAsset();
						rtmfp.tearDownAsset();
					}
					
					case CommunicationType.FB_LOGIN_OUT:
					case CommunicationType.FB_REQUEST_PERMISSION:
					{
						fb.initAsset(request.communicationType);
						break;
					}
				}
				
			}
			
		}
		
		private function get fb():FacebookProxy
		{
			return facade.retrieveProxy(ProxyID.FACEBOOK) as FacebookProxy
		}
		
		private function get ws():WSRemoteProxy
		{
			return facade.retrieveProxy(ProxyID.WS) as WSRemoteProxy
		}
		
		private function get rtmfp():RTMFPRemoteProxy
		{
			return facade.retrieveProxy(ProxyID.RTMFP) as RTMFPRemoteProxy
		}
		
		/*private function get fms():FMSRemoteProxy
		{
			return facade.retrieveProxy(ProxyID.FMS) as FMSRemoteProxy
		}*/
		
		private function get amf():AMFRemoteProxy
		{
			return facade.retrieveProxy(ProxyID.AMF) as AMFRemoteProxy
		}
	}
}