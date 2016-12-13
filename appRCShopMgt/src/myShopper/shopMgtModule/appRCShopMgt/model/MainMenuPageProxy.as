package myShopper.shopMgtModule.appRCShopMgt.model 
{
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.VOID;
	import myShopper.shopMgtModule.appRCShopMgt.enum.ProxyID;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	
	public class MainMenuPageProxy extends ApplicationProxy //implements IResponder 
	{
		
		private var _myUserInfo:UserInfoVO;
		
		public function MainMenuPageProxy(inName:String, inData:Object = null) 
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
			
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			echo('initAsset : ' + inAsset);
			
		}
		
		
	}
}