package myShopper.shopMgtModule.appRCShopMgt.model 
{
	import com.greygreen.net.p2p.events.P2PEvent;
	import com.greygreen.net.p2p.model.P2PPacket;
	import flash.utils.setTimeout;
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.FMS.FMSRequestVO;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.RTMFPServicesType;
	import myShopper.common.emun.ServiceID;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.ServiceEvent;
	import myShopper.common.interfaces.IResponder;
	import myShopper.common.net.RemoteService;
	import myShopper.common.net.RTMFPServiceConnection;
	import myShopper.common.net.ServiceRequest;
	import myShopper.common.server.AMFResultFactory;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtModule.appRCShopMgt.enum.AssetClassID;
	import myShopper.shopMgtModule.appRCShopMgt.enum.NotificationType;
	import myShopper.shopMgtModule.appRCShopMgt.enum.PageID;
	import myShopper.shopMgtModule.appRCShopMgt.enum.ProxyID;
	import myShopper.shopMgtModule.appRCShopMgt.model.vo.PageVO;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	
	
	public class ProductScanPageProxy extends ApplicationProxy implements IResponder 
	{
		
		private var _service:RemoteService;
		private var _rtmfp:RTMFPServiceConnection;
		private var _myUserInfo:UserInfoVO;
		
		public function ProductScanPageProxy(inName:String, inData:Object = null) 
		{
			super(inName, inData);
		}
		
		private function get asset():AssetProxy
		{
			return facade.retrieveProxy(ProxyID.ASSET) as AssetProxy
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			
			_myUserInfo = voManager.getAsset(VOID.MY_USER_INFO);
			
			if (!_myUserInfo || !(_myUserInfo is UserInfoVO))
			{
				throw(new UninitializedError("unable to get asset mapInfo/myUser VO or user info list"));
			}
			
			//_service = serviceManager.getAsset(ServiceID.FMS_SHOP);
			_service = serviceManager.getAsset(ServiceID.RTMFP);
			if (!_service || !(_service is RemoteService))
			{
				echo('onRegister : unable to get remote service from serviceManager');
				return;
			}
			
			_rtmfp = _service.serviceConnection as RTMFPServiceConnection;
			_rtmfp.addEventListener(ServiceEvent.RESPONSE, rtmfpEventHandler);
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			echo('initAsset : ' + inAsset);
			
		}
		
		private function rtmfpEventHandler(e:ServiceEvent):void 
		{
			echo(e.data);
			//var event:P2PEvent = e.data as P2PEvent;
			
			if (e.type == ServiceEvent.RESPONSE)
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
					case RTMFPServicesType.RC_CREATE_PRODUCT:
					{
						if (resultVO.result === true)
						{
							sendNotification(NotificationType.LOGIN_SUCCESS);
							asset.changePage(PageID.MAIN_MENU);
						}
						
						break;
					}
				}
			}
		}
		
		public function call(inServiceName:String, inData:Object = null):void
		{
			echo('calling : ' + inServiceName, this, 0xFF0000);
			
			
			if (!_rtmfp.isConnected() || !_myUserInfo.token)
			{
				echo('calling : ' + inServiceName + ' : Error! user is not logged yet!');
				return;
			}
			
			var requestData:Object;
			
			switch(inServiceName)
			{
				case RTMFPServicesType.RC_CREATE_PRODUCT:
				{
					
					requestData = 	{
										u_token:_myUserInfo.token,
										product_code:inData
									};
					break;
				}
				default:
				{
					echo('call : unknown service type : ' + inServiceName);
					return;
				}
			}
			
			remoteCall('', new FMSRequestVO(inServiceName, null, requestData));
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
		
		
		
		/*private function getMapDataProxy(inName:String):IRemoteDataProxy
		{
			return facade.retrieveProxy(inName) as IRemoteDataProxy
		}*/
	}
}