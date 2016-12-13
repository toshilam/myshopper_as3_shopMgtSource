package myShopper.shopMgtModule.appRCSystem.model 
{
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.AlerterVO;
	import myShopper.common.emun.AlerterType;
	import myShopper.common.emun.AMFShopperServicesType;
	import myShopper.common.emun.AMFUserServicesType;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.MessageID;
	import myShopper.common.emun.ServiceID;
	import myShopper.common.events.ServiceEvent;
	import myShopper.common.interfaces.IResponder;
	import myShopper.common.net.RemoteService;
	import myShopper.common.net.ServiceRequest;
	import myShopper.common.server.AMFResultFactory;
	import myShopper.common.utils.Alert;
	import myShopper.common.utils.Tracer;
	import myShopper.shopMgtModule.appRCSystem.Config;
	import myShopper.shopMgtModule.appRCSystem.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	public class AMFRemoteProxy extends ApplicationProxy implements IResponder 
	{
		//public static const NAME:String = "AMFRemoteProxy";
		
		private var _service:RemoteService;
		private var _xmlConfig:XML;
		
		public function AMFRemoteProxy(inName:String, inData:Object = null) 
		{
			super(inName, inData);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			NetConnection.defaultObjectEncoding = ObjectEncoding.AMF3;
			
			_service = new RemoteService();
			
			if ( serviceManager.addAsset(_service, ServiceID.AMF) )
			{
				_service.serviceConnection.addEventListener(ServiceEvent.FAULT, serviceEventHandler);
				_service.serviceConnection.addEventListener(ServiceEvent.CONNECT_FAIL, serviceEventHandler);
			}
			else
			{
				echo('initAsset : unable to create service controller!', this, 0xff0000);
			}
			
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			echo('initAsset');
			
			data = xmlManager.getAsset(AssetLibID.XML_COMMON);
			var xml:XML = data..services[0];
			
			var _xmlConfig:XML = xml..element.(@id == ServiceID.AMF)[0];
			if (_xmlConfig)
			{
				if (!_xmlConfig.@host.length())
				{
					echo('initAsset : no host url found!');
					return;
				}
				
				var amfServer:String = _xmlConfig.@host + '/' + Config.AMF_GATEWAY;
				
				echo('initAsset : connecting amf : ' +amfServer );
				_service.connect(amfServer);
			}
			else
			{
				echo('initAsset : no matched node found!', this, 0xff0000);
			}
		}
		
		public function tearDownAsset():void
		{
			echo('tearDownAsset : logout');
			remoteCall(AMFUserServicesType.USER_LOGOUT, null);
		}
		
		private function serviceEventHandler(e:ServiceEvent):void 
		{
			Alert.show(new AlerterVO('', AlerterType.MESSAGE, '', '', getMessage(MessageID.ERROR_TITLE), getMessage(MessageID.ERROR_CONNECT)));
		}
		
		public function call(inService:String, inData:Object = null):Boolean
		{
			echo('calling : ' + inService, this, 0xFF0000);
			
			
			remoteCall(inService, inData);
			return true;
		}
		
		private function remoteCall(inService:String, inData:Object):void 
		{
			_service.request(new ServiceRequest(inService, inData, this));
		}
		
		public function result(inData:Object):void 
		{
			echo('result : ' + inData, this, 0xFF0000);
			
			if (inData)
			{
				var result:ResultVO = (!(inData is ResultVO)) ? AMFResultFactory.convert(inData) : inData as ResultVO;
				
				if (result)
				{
					echo('result : handling : ' + result.service, this, 0x000000);
					resultHandler(result);
				}
				else
				{
					echo('result : unknown data type : ' + inData, this, 0xFF0000);
				}
				
			}
		}
		
		public function fault(info:Object):void 
		{
			echo('fault : ' + info, this, 0xFF0000);
		}
		
		private function resultHandler(result:ResultVO):void 
		{
			switch(result.service)
			{
				case AMFShopperServicesType.GET_PRODUCT_CATEGORY:
				//case AMFShopperServicesType.GET_COUNTRY_AREA:
				//case AMFShopperServicesType.GET_ACTIVE_CITY:
				case AMFShopperServicesType.GET_ACTIVE_COUNTRY:
				{	
					var proxy:IRemoteDataProxy = getRemoteDataProxy(getProxyIDByServiceType(result.service)) as IRemoteDataProxy
					if (proxy)
					{
						proxy.setRemoteData(result.service, result);
					}
					else
					{
						echo('resultHandler : unable to retrieve proxy object : ' + result.service);
					}
					
					break;
				}
				
				
				default:
				{
					echo('result : no matched action found : ' + result.service);
				}
			}
		}
		
		private function getProxyIDByServiceType(inService:String):String 
		{
			if 		(inService == AMFShopperServicesType.GET_PRODUCT_CATEGORY) 					return ProxyID.CONTENT;
			//else if (inService == AMFShopperServicesType.GET_COUNTRY_AREA) 						return ProxyID.CONTENT;
			//else if (inService == AMFShopperServicesType.GET_ACTIVE_CITY) 						return ProxyID.CONTENT;
			else if (inService == AMFShopperServicesType.GET_ACTIVE_COUNTRY) 					return ProxyID.CONTENT;
			return 	null;
		}
		
		private function getRemoteDataProxy(inName:String):IRemoteDataProxy
		{
			return facade.retrieveProxy(inName) as IRemoteDataProxy
		}
		
	}
}