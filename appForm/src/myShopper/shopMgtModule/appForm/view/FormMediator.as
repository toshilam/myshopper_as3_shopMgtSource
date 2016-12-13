package myShopper.shopMgtModule.appForm.view 
{
	import myShopper.common.data.DisplayObjectVO;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.shopMgtModule.appForm.FormMain;
	import myShopper.shopMgtModule.appForm.view.component.ApplicationForm;
	import org.puremvc.as3.multicore.enum.NotificationType;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.ApplicationMediator;
	
	public class FormMediator extends ApplicationMediator implements IMediator 
	{
		/*private var _appFooter:ApplicationFooter;
		public function get appFooter():ApplicationFooter 
		{
			if (!_appFooter) _appFooter = (container as FooterMain).appFooter;
			return _appFooter;
		}*/
		
		public function get form():ApplicationForm
		{
			return (container as FormMain).appForm;
		}
		
		public function FormMediator(inMediatorName:String = null, inViewComponent:IModuleMain = null) 
		{
			super(inMediatorName, inViewComponent);
		}
		
		override public function onRegister():void 
		{
			super.onRegister();
			
		}
		
		override public function listNotificationInterests():Array 
		{
			return [NotificationType.ADD_HOST];
		}

		override public function handleNotification(note:INotification):void 
		{
			var body:Object = note.getBody();
			var vo:DisplayObjectVO;
			
			if (body is DisplayObjectVO)
			{
				vo = body as DisplayObjectVO;
			}
			
			
			switch (note.getName()) 
			{   
				case NotificationType.ADD_HOST:
				{
					(container as FormMain).appForm = container.view.addApplicationChild(vo.displayObject, vo.settingXML,  false) as ApplicationForm;
					break;
				}
				
				
			}
		}
		
		
	}
}