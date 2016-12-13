package myShopper.shopMgtModule.appForm.model.service 
{
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.interfaces.IVO;
	import myShopper.common.resources.XMLManager;
	import myShopper.common.utils.Tracer;
	/**
	 * ...
	 * @author Toshi Lam
	 */
	public class MessageService 
	{
		private var _xmlManager:XMLManager;
		private var _assetLibID:String;
		private var _nodeName:String;
		
		public function MessageService(inXMLManager:XMLManager, inAssetLibID:String, inNodeName:String) 
		{
			_xmlManager = inXMLManager;
			_assetLibID = inAssetLibID;
			_nodeName = inNodeName;
		}
		
		public function getMessage(inID:String):String
		{
			if (hasData())
			{
				var xmlList:XMLList = _xmlManager.getData(_nodeName, _assetLibID);
				if (xmlList && xmlList.length())
				{
					var xml:XML = xmlList.(@id == inID)[0];
					if (xml)
					{
						return xml.toString();
					}
					
					Tracer.echo('MessageService : getMessage : target xml node not found!', this, 0xff0000);
				}
				
				Tracer.echo('MessageService : getMessage : no data found!', this, 0xff0000);
			}
			else
			{
				Tracer.echo('MessageService : getMessage : data object are not set yet!', this, 0xff0000);
				
			}
			
			return null;
		}
		
		
		private function hasData():Boolean
		{
			return _xmlManager && _assetLibID && _nodeName;
		}
	}

}