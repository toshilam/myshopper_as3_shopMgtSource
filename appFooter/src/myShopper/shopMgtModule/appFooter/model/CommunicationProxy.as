package myShopper.shopMgtModule.appFooter.model
{
	import myShopper.common.emun.CommunicationType;
	import myShopper.common.emun.ServiceID;
	import myShopper.common.interfaces.ICommServiceRequest;
	import myShopper.common.interfaces.IResponder;
	import myShopper.common.net.CommServiceRequest;
	import myShopper.common.net.CommunicationService;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	
	public class CommunicationProxy extends ApplicationProxy implements IResponder
	{
		private var _communicationService:CommunicationService;
		
		public function CommunicationProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			
			_communicationService = serviceManager.getAsset(ServiceID.COMMUNICATION);
			
			if ( !(_communicationService is CommunicationService) )
			{
				echo('onRegister : unable to get communication service');
			}
			
			_communicationService.request(new CommServiceRequest(multitonKey, '', CommunicationService.ADD_COMMUNICATOR, null, this));
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			
		}
		
		//to notify event to other module
		public function request(inCommType:String, inData:Object = null):Boolean
		{
			if (_communicationService)
			{
				switch(inCommType)
				{
					case myShopper.common.emun.CommunicationType.SHOPPER_CONTACT_US:
					case myShopper.common.emun.CommunicationType.SHOPPER_WEB_VIEW:
					{
						_communicationService.request(new CommServiceRequest(multitonKey, inCommType, CommunicationService.NOTIFICATION, inData));
						break;
					}
					default:
					{
						echo('request : unknown communication type : ' + inCommType);
						return false;
					}
				}
				
				return true;
			}
			else
			{
				echo('request : no communication service avaliable!')
			}
			
			return false;
		}
		
		//notification by other module
		public function result(inData:Object):void 
		{
			if (inData is ICommServiceRequest)
			{
				var request:ICommServiceRequest = inData as ICommServiceRequest;
				
				echo('result : received a request from : ' + request.communicatorID + ' : requesting : ' + request.communicationType);
				//if(request.communicationType
				
				switch(request.communicationType)
				{
					//case CommunicationType.USER_REGISTER: //to be handler via swfaddress proxy
					case CommunicationType.USER_LOGIN_SUCCESS: 
					case CommunicationType.USER_LOGOUT: 
					{
						sendNotification(CommunicationService.NOTIFICATION, request);
						break;
					}
				}
			}
		}
		
		public function fault(info:Object):void 
		{
			echo('fault : received : ' + info);
		}
		
	}
}