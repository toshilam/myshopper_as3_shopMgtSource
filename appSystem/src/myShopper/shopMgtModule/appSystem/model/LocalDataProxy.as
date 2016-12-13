package myShopper.shopMgtModule.appSystem.model
{
	
	import myShopper.common.Config;
	import myShopper.common.emun.ServiceID;
	import myShopper.common.utils.Tools;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	import myShopper.common.net.LocalDataService;
	
	CONFIG::air
	{
		import myShopper.common.air.net.LocalSalesDataService;
		import myShopper.common.air.data.SalesDatabase;
	}
	
	
	public class LocalDataProxy extends ApplicationProxy
	{
		
		protected var _service:LocalDataService;
		
		CONFIG::air
		protected var _serviceDB:LocalSalesDataService;
		
		
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
			_service = LocalDataService.getInstance(/*Tools.spaceToHyphen(Config.APPLICATION_TITLE)*/);
			
			if 
			( 
				!_service ||
				!serviceManager.addAsset(_service, ServiceID.LOCAL_DATA) 
			)
			{
				throw(new UninitializedError(multitonKey + ' : onRegister : unable to register service'));
			}
			
			CONFIG::air
			{
				_serviceDB = LocalSalesDataService.getInstance(new SalesDatabase());
				
				if 
				( 
					!_serviceDB ||
					!serviceManager.addAsset(_serviceDB, ServiceID.LOCAL_DATA_DB) 
				)
				{
					throw(new UninitializedError(multitonKey + ' : onRegister : unable to register service'));
				}
			}
		}
		
	}
}