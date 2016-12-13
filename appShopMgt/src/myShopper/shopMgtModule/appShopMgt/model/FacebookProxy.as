package myShopper.shopMgtModule.appShopMgt.model 
{
	import flash.net.Responder;
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.service.FacebookVOService;
	import myShopper.common.data.service.ImageVOService;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.FacebookServicesType;
	import myShopper.common.emun.FileType;
	import myShopper.common.emun.ServiceID;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.ServiceEvent;
	import myShopper.common.interfaces.IFacebookResponder;
	import myShopper.common.interfaces.IResponder;
	import myShopper.common.net.FacebookService;
	import myShopper.common.net.ServiceRequest;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationFBProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	
	public class FacebookProxy extends ApplicationFBProxy
	{
		//public static const NAME:String = "AMFRemoteProxy";
		
		//private var _service:FacebookService;
		private var _fbVOService:FacebookVOService;
		private var _myUserInfo:UserInfoVO;
		//private var _fdFriendList:FbFriendList;
		
		public function FacebookProxy(inName:String, inData:Object = null) 
		{
			super(inName, inData);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			//_service = serviceManager.getAsset(ServiceID.FACEBOOK);
			_myUserInfo = voManager.getAsset(VOID.MY_USER_INFO);
			//_responder = new Responder(result, fault);
			
			if (/*!_service ||*/ !_myUserInfo)
			{
				throw(new UninitializedError('onRegister : unable to get fb'));
			}
			
			_fbVOService = new FacebookVOService(_myUserInfo.fbFriendList);
			
			//_service.addEventListener(ServiceEvent.CONNECT_FAIL, serviceEventHandler);
			_service.addEventListener(ServiceEvent.CONNECT_SUCCESS, serviceEventHandler);
			_service.addEventListener(ServiceEvent.DISCONNECTED, serviceEventHandler);
			
			//if connected and havent got data from fb, get fd data
			if (_service.isConnected() && !_myUserInfo.fbFriendList.length)
			{
				call(FacebookServicesType.GET_ME_FRIENDS);
			}
		}
		
		private function serviceEventHandler(e:ServiceEvent):void 
		{
			if (e.type == ServiceEvent.CONNECT_SUCCESS && !_myUserInfo.fbFriendList.length)
			{
				call(FacebookServicesType.GET_ME_FRIENDS);
			}
			else if (e.type == ServiceEvent.DISCONNECTED)
			{
				_myUserInfo.fbFriendList.clear();
			}
		}
		
		
		
		
		override public function initAsset(inAsset:Object = null):void 
		{
			//Tracer.echo(multitonKey + ' : ' + getProxyName() + ' : initAsset', this, 0xff0000);
		}
		
		
		
		/*override public function fbResult(inData:Object, inFault:Object):Boolean
		{
			if (super.fbResult(inData, inFault, inHandleError))
			{
				
			}
			
			return false;
			
		}*/
		
		override public function result(data:Object):void 
		{
			super.result(data);
			
			if (data is Array)
			{
				_fbVOService.setFbFriendList(data);
				
				echo('result : number of FB fd : ' + _myUserInfo.fbFriendList.length);
				
				
			}
			else
			{
				echo('result : error getting fd data');
			}
		}
		
		override public function fault(info:Object):void 
		{
			super.fault(info);
			//no need to handle error for get fb friend, as this data should no permission required
		}
		
	}
}