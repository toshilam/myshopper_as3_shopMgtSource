package myShopper.shopMgtModule.appForm.controller
{
	import myShopper.common.emun.AMFShopperServicesType;
	import myShopper.common.emun.AMFShopServicesType;
	import myShopper.common.events.ShopEvent;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class AssetCommand extends SimpleCommand implements ICommand
	{
		override public function execute( note:INotification ):void
		{
			//get area for register form
			(facade.retrieveProxy(ProxyID.ASSET) as IRemoteDataProxy).getRemoteData(getTypeByEvent(note.getName()), note.getBody());
		}
		
		private function getTypeByEvent(inValue:String):String
		{
			switch(inValue)
			{
				case ShopEvent.GET_COUNTRY:		return AMFShopperServicesType.GET_ACTIVE_COUNTRY;
				case ShopEvent.GET_CITY:		return AMFShopperServicesType.GET_CITY_BY_STATE_ID;
				case ShopEvent.GET_STATE:		return AMFShopperServicesType.GET_STATE_BY_COUNTRY_ID;
				case ShopEvent.GET_AREA:		return AMFShopperServicesType.GET_CITY_AREA;
			}
			
			return '';
		}
		
		
	}
}