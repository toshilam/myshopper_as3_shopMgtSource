package myShopper.shopMgtModule.appRCShopMgt.view 
{
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.shopMgtCommon.emun.AssetLibID;
	import myShopper.shopMgtModule.appRCShopMgt.enum.NotificationType;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class SoundMediator extends ApplicationMediator implements IMediator 
	{
		
		public function SoundMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
		{
			super(inMediatorName, inViewComponent);
		}
		
		override public function onRemove():void 
		{
			super.onRemove();
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			
		}
		
		override public function listNotificationInterests():Array 
		{
			return [ NotificationType.PLAY_SOUND ];
		}
		
		override public function handleNotification(note:INotification):void 
		{
			switch(note.getName())
			{
				case NotificationType.PLAY_SOUND:
				{
					if (note.getBody() is String)
					{
						play([String(note.getBody())], AssetLibID.AST_SHOP_MGT, 1);
					}
					
					
					break;
				}
			}
		}
		
		public function play(inDataIDs:Array, inAssetID:String, inVolLevel:Number = -1, inStartTime:Number = 0, inLoop:int = 0):void
		{
			playSound( inDataIDs, inAssetID,  inVolLevel, inStartTime, inLoop );
		}
		
		
	}
}