package myShopper.shopMgtCommon.data.service 
{
	import myShopper.common.data.service.UserVOService;
	import myShopper.common.data.user.UserInfoList;
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.interfaces.IVO;
	import myShopper.common.utils.Tracer;
	import myShopper.shopMgtCommon.data.ShopMgtUserInfoVO;
	/**
	 * ...
	 * @author Toshi Lam
	 */
	public class ShopMgtUserVOService extends UserVOService
	{
		
		
		public function ShopMgtUserVOService(inInfoList:UserInfoList) 
		{
			super(inInfoList);
		}
		
		/*public function addCustomersInfo(inData:Object):Boolean
		{
			if (inData is Array && inData.length)
			{
				var numItem:int = inData.length;
				
				for (var i:int = 0; i < numItem; i++)
				{
					if (!addCustomerInfo(inData[i]))
					{
						return false;
					}
				}
				
				return true;
			}
			
			return false;
		}*/
		
		public function addCustomerInfo(inData:Object):Boolean 
		{
			var userObj:Object = inData;
			
			
			//id that provided by FMS
			if (userObj && userObj['id'])
			{
				var FMSID:String = userObj['id']
				//add vo if not exist in user info list
				if (_userInfo.getVOByID(FMSID) == null)
				{
					//CHANGED : 06042012 /  only logged user can be connected to fms
					//use FMS ID as VO id, as u_id can be null if the walked in user is not logged in yet
					var vo:ShopMgtUserInfoVO = new ShopMgtUserInfoVO(FMSID);
					vo.ip = userObj['ip'];
					vo.fmsID = FMSID;
					
					//if (userObj['isLoggedUser'] === true)
					//{
						vo.uid = userObj['u_id'];
						vo.firstName = userObj['u_first_name'];
						//vo.lastName = userObj['u_last_name'];
						//vo.sex = userObj['u_sex'];
						//vo.lat = Number(userObj['u_lat']);
						//vo.lng = Number(userObj['u_lng']);
					//}
					_userInfo.addVO(vo);
				}
				else
				{
					Tracer.echo('UserVoService : addUserInfo : user already exist in list : ' + FMSID, this, 0xff0000);
				}
				
				return true;
			}
			
			return false;
		}
		
		public function removeCustomerInfo(inData:Object):Boolean
		{
			var userObj:Object = inData;
			
			//id that provided by FMS
			if (userObj && userObj['id'])
			{
				var FMSID:String = userObj['id']
				
				var userVO:ShopMgtUserInfoVO = _userInfo.getVOByID(FMSID) as ShopMgtUserInfoVO;
				
				if (userVO)
				{
					userVO.clear();
					return _userInfo.removeVO(userVO) is ShopMgtUserInfoVO;
				}
				
				Tracer.echo('UserVoService : removeUserInfo : no matched vo found in list : ' + FMSID, this, 0xff0000);
				return false;
			}
			
			Tracer.echo('UserVoService : removeUserInfo : unknown data type : ' + userObj, this, 0xff0000);
			return false;
		}
		
		
	}

}