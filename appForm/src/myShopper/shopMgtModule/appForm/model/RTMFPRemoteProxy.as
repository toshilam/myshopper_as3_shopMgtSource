package myShopper.shopMgtModule.appForm.model 
{
	import com.greygreen.net.p2p.events.P2PEvent;
	import com.greygreen.net.p2p.model.P2PPacket;
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.FMS.FMSRequestVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.RTMFPServicesType;
	import myShopper.common.emun.ServiceID;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.ServiceEvent;
	import myShopper.common.interfaces.IResponder;
	import myShopper.common.net.CommServiceRequest;
	import myShopper.common.net.CommunicationService;
	import myShopper.common.net.RemoteService;
	import myShopper.common.net.RTMFPServiceConnection;
	import myShopper.common.net.ServiceRequest;
	import myShopper.common.server.AMFResultFactory;
	import myShopper.shopMgtCommon.emun.CommunicationType;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	
	public class RTMFPRemoteProxy extends ApplicationProxy implements IResponder 
	{
		
		private var _service:RemoteService;
		private var _rtmfp:RTMFPServiceConnection;
		private var _myUserInfo:UserInfoVO;
		
		public function RTMFPRemoteProxy(inName:String, inData:Object = null) 
		{
			super(inName, inData);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			
			_myUserInfo = voManager.getAsset(VOID.MY_USER_INFO);
			_service = serviceManager.getAsset(ServiceID.RTMFP);
			
			if (!_myUserInfo || !_service)
			{
				throw(new UninitializedError("unable to get VO/service"));
			}
			
			_rtmfp = _service.serviceConnection as RTMFPServiceConnection;
			_rtmfp.rtmfpConnection.addEventListener(P2PEvent.PEER_CONNECTED, p2pEventHandler);
			_rtmfp.rtmfpConnection.addEventListener(P2PEvent.PEER_DISCONNECTED, p2pEventHandler);
			_rtmfp.addEventListener(ServiceEvent.RESPONSE, fmsEventHandler);
		}
		
		private function p2pEventHandler(e:P2PEvent):void 
		{
			echo('p2pEventHandler : ' + e.info);
			//_rtmfp.rtmfpConnection.send( { a:'aaa' }, RTMFPServiceConnection.METHOD_NAME);
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			echo('initAsset');
		}
		
		private function fmsEventHandler(e:ServiceEvent):void 
		{
			var packet:P2PPacket = e.data as P2PPacket;
			
			if (!packet)
			{
				echo('rtmfpEventHandler : ' + e.type + ' : unknown data!' );
				return;
			}
			
			var resultVO:ResultVO = AMFResultFactory.convert(packet.data);
			
			if (!resultVO)
			{
				echo('rtmfpEventHandler : ' + e.type + ' : unknown data : ' + packet.data );
				return;
			}
			
			switch(resultVO.service)
			{
				case RTMFPServicesType.RC_LOGIN:
				{
					if (resultVO.result && resultVO.result.u_token === _myUserInfo.token)
					{
						call(resultVO.service, true);
					}
					
					break;
				}
				case RTMFPServicesType.RC_CREATE_PRODUCT:
				{
					//first try to open sales window
					sendNotification(CommunicationService.NOTIFICATION, new CommServiceRequest(multitonKey, CommunicationType.SHOP_MGT_SALES, CommunicationService.NOTIFICATION));
					//add product
					sendNotification(NotificationType.ADD_SALES_PRODUCT, resultVO.result);
					break;
				}
			}
		}
		
		public function call(inServiceName:String, inData:Object = null):void
		{
			if (!_myUserInfo.isLogged)
			{
				echo('calling : ' + inServiceName + ' : Error! user is not logged yet!');
				return;
			}
			
			echo('calling : ' + inServiceName, this, 0xFF0000);
			var fmsRequestVO:FMSRequestVO = new FMSRequestVO(inServiceName, null, inData );
			
			remoteCall('', fmsRequestVO);
		}
		
		private function remoteCall(inService:String, inData:Object):void 
		{
			_service.request(new ServiceRequest(inService, inData, this));
		}
		
		
		//NOTE : no call back from service for FMS currently
		public function result(data:Object):void 
		{
			
		}
		
		public function fault(info:Object):void 
		{
		
		}
		
	}
}