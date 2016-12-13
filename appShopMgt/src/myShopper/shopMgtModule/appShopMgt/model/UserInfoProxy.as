package myShopper.shopMgtModule.appShopMgt.model
{
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.data.map.MapInfoVO;
	import myShopper.common.data.user.UserInfoList;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.emun.AMFServicesErrorID;
	import myShopper.common.emun.AssetLibID;
	import myShopper.common.emun.FMSServicesType;
	import myShopper.common.emun.VOID;
	import myShopper.shopMgtCommon.data.service.ShopMgtUserVOService;
	import myShopper.shopMgtCommon.data.ShopMgtUserInfoVO;
	import myShopper.shopMgtCommon.emun.AMFShopManagementServicesType;
	import myShopper.shopMgtModule.appShopMgt.enum.NotificationType;
	import myShopper.shopMgtModule.appShopMgt.enum.ProxyID;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.proxy.ApplicationProxy;
	
	public class UserInfoProxy extends ApplicationProxy implements IRemoteDataProxy
	{
		private var _amf:AMFRemoteProxy;
		private function get amf():AMFRemoteProxy
		{
			if (!_amf) _amf = facade.retrieveProxy(ProxyID.AMF) as AMFRemoteProxy;
			return _amf;
		}
		
		//a list of walked in user
		private var _userInfo:UserInfoList;
		private var _userVOService:ShopMgtUserVOService;
		
		public function UserInfoProxy(inName:String, inData:Object)
		{
			super( inName, inData );
		}
		
		
		override public function onRegister():void
		{
			super.onRegister();
			
			_userInfo = voManager.getAsset(VOID.USER_INFO);
			
			if (!_userInfo || !(_userInfo is UserInfoList))
			{
				echo("unable to get asset user VO");
				throw(new UninitializedError("unable to get asset user VO "));
			}
			
			_userVOService = new ShopMgtUserVOService(_userInfo);
		}
		
		override public function initAsset(inAsset:Object = null):void 
		{
			echo('initAsset');
		}
		
		/* INTERFACE org.puremvc.as3.multicore.interfaces.IRemoteDataProxy */
		
		public function getRemoteData(inService:String, inData:Object = null):Boolean
		{
			var requestData:Object;
			
			//shop itself info
			var userInfo:UserInfoVO = voManager.getAsset(VOID.MY_USER_INFO);
			
			if (userInfo && userInfo.isLogged && _userInfo)
			{
				//if (inService == AMFShopManagementServicesType.GET_CUSTOMERS_INFO_BY_ID)
				//{
					//var arrData:Array = new Array();
					//var numItem:int = _userInfo.length;
					
					//CHANGE : 06042012 : not used currently
					/*for (var i:int = 0; i < numItem; i++)
					{
						var vo:ShopMgtUserInfoVO = _userInfo.getVO(i) as ShopMgtUserInfoVO;
						if (vo)
						{
							//check, if vo contain uid but has no user info, get from server
							if (vo.uid && !vo.firstName)
							{
								arrData.push( { u_id:vo.uid } );
							}
						}
						
					}*/
					
					//if no matched vo, return
					//if (!arrData.length) return false;
					//
					//requestData = arrData;
				//}
				///*else if (inService == AMFShopManagementServicesType.UPDATE_ABOUT)
				//{
					//requestData = { a_user_id:userInfo.uid, a_about:_shopInfoVO.about, a_title:_shopInfoVO.aboutTitle };
				//}*/
				//else
				//{
					//echo('getRemoteData : : unknown service type ' + inService, this, 0xff0000);
					//return false;
				//}
			}
			else
			{
				echo('getRemoteData : unable to get user/shop vo');
				return false;
			}
			
			amf.call(inService, requestData);
			return true;
		}
		
		public function setRemoteData(inService:String, inData:Object):Boolean
		{
			var resultVO:ResultVO = inData as ResultVO;
			
			if (resultVO)
			{
				if ( resultVO.code != AMFServicesErrorID.NONE )
				{
					echo('setRemoteData : fail getting data from server');
					
					/*if (inService == AMFShopManagementServicesType.UPDATE_ABOUT)
					{
						sendNotification(NotificationType.UPDATE_ABOUT_FAIL, resultVO);
					}*/
					
					return false;
				}
				else
				{
					if (inService == FMSServicesType.USER_WALK_IN_SHOP || inService == FMSServicesType.USER_WALK_OUT_SHOP)
					{
						var targetFunc:Function = inService == FMSServicesType.USER_WALK_IN_SHOP ? _userVOService.addCustomerInfo : _userVOService.removeCustomerInfo;
						
						//once data is set, value will be autometically set in display object form
						if ( !(targetFunc is Function) || !targetFunc(resultVO.result) )
						{
							echo('setRemoteData : fail setting data vo : ' + inService);
						}
						else
						{
							sendNotification(NotificationType.UPDATE_CUSTOMER_LIST);
							
							//get walked in + logged customer(user) info from server
							//getRemoteData(AMFShopManagementServicesType.GET_CUSTOMERS_INFO_BY_ID);
						}
					}
					/*else if (inService == AMFShopManagementServicesType.GET_CUSTOMERS_INFO_BY_ID)
					{
						var result:Array = resultVO.result as Array;
						if (result && result.length)
						{
							var numItem:int = result.length;
							for (var i:int = 0; i < numItem; i++)
							{
								//once data is set, value will be autometically set in display object form
								if ( !_userVOService.setUserInfo(result[i]) )
								{
									echo('setRemoteData : fail setting data into user vo : ' + result[i]);
								}
							}
						}
						
					}*/
					
					return true;
				}
				
			}
			
			
			return false;
		}
		
		
		
		
	}
}