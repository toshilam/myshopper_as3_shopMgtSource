package myShopper.shopMgtModule.appRCSystem.model
{
	import myShopper.common.Config;
	import myShopper.common.emun.ServiceID;
	import myShopper.common.net.LocalDataService;
	import myShopper.common.utils.Tools;
	import myShopper.shopMgtModule.appRCSystem.SystemMain;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	
	public class LocalDataProxy extends ApplicationProxy
	{
		protected var _service:LocalDataService;
		
		
		public function LocalDataProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			
			
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			//TODO : use userID as key instead of using APPLICATION_TITLE as different users may use the same computer?
			//if so change logic getInstance when user successfully logged-in
			//or keep using APPLICATION_TITLE as data wont be shown, and it can help clear up other users' unfinish tasks?
			//or add one more data level (change data struture) each user has it own data in 'so' object? but it cost more 'so' stroage
			//_service = LocalDataService.getInstance(Tools.spaceToHyphen(Config.APPLICATION_TITLE));
			_service = LocalDataService.getInstance(Tools.spaceToHyphen(SystemMain.NAME));
			if 
			( 
				!_service ||
				!serviceManager.addAsset(_service, ServiceID.LOCAL_DATA) 
			)
			{
				throw(new UninitializedError(multitonKey + ' : onRegister : unable to register service'));
			}
		}
		
		
	}
}