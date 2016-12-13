package myShopper.shopMgtCommon.data 
{
	import myShopper.common.data.user.UserInfoVO;
	
	/**
	 * ...
	 * @author Toshi Lam
	 */
	public class ShopMgtUserInfoVO extends UserInfoVO 
	{
		private var _ip:String; //user ip
		private var _fmsID:String; // FMS id
		
		public function ShopMgtUserInfoVO(inVOID:String) 
		{
			super(inVOID);
			clear();
		}
		
		public function get ip():String {return _ip;}
		public function set ip(value:String):void 
		{
			_ip = value;
		}
		
		public function get fmsID():String {return _fmsID;}
		public function set fmsID(value:String):void 
		{
			_fmsID = value;
		}
		
		override public function clear():void 
		{
			super.clear();
			ip = fmsID = '';
		}
		
		
	}

}