package myShopper.shopMgtModule.appForm.model.service 
{
	import myShopper.common.data.user.UserInfoVO;
	import myShopper.common.interfaces.IVO;
	/**
	 * ...
	 * @author Toshi Lam
	 */
	public class UserVOService 
	{
		//private var _vo:UserInfoVO;
		
		public function UserVOService(/*inVO:UserInfoVO*/) 
		{
			//_vo = inVO;
		}
		
		
		
		/*public static function setMyUserInfo(inValue:Object, inVO:IVO):Boolean
		{
			var result:Object = inValue;
			var _vo:UserInfoVO = inVO as UserInfoVO;
			
			if (_vo && result['u_id'] != null)
			{
				_vo.isLogged = true;
				
				_vo.firstName = result['u_first_name'];
				_vo.lastName = result['u_last_name'];
				_vo.no = result['u_no'];
				_vo.uid = result['u_id'];
				_vo.token = result['u_token'];
				_vo.activated = result['u_activated'];
				_vo.ageRange = result['u_age_range'];
				_vo.country = result['u_country'];
				_vo.district = result['u_district'];
				_vo.email = result['u_email'];
				_vo.interest = result['u_interest'];
				_vo.lat = result['u_lat'];
				_vo.lng = result['u_lng'];
				_vo.password = result['u_password'];
				_vo.phone = result['u_phone'];
				_vo.sex = result['u_sex'];
				_vo.subscribeNews = result['u_subscribe_news'];
				
				var arrBirthday:Array = String(result['u_birthday']).split('-');;
				_vo.day = arrBirthday[0];
				_vo.month = arrBirthday[1];
				_vo.year = arrBirthday[2];
				
				_vo.isShopExist = result['isShopExist'] === true;
				
				return true;
			}
			
			return false;
		}*/
		
	}

}