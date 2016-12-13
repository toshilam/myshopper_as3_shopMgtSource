package myShopper.shopMgtModule.appForm.controller
{
	import myShopper.amf.common.data.ResultVO;
	import myShopper.common.data.service.CommVOService;
	import myShopper.common.emun.AMFUserServicesType;
	import myShopper.common.emun.FMSServicesType;
	import myShopper.common.emun.VOID;
	import myShopper.common.events.ChatEvent;
	import myShopper.common.interfaces.IModuleMain;
	import myShopper.common.utils.Tracer;
	import myShopper.shopMgtCommon.emun.CommunicationType;
	import myShopper.shopMgtModule.appForm.enum.MediatorID;
	import myShopper.shopMgtModule.appForm.enum.NotificationType;
	import myShopper.shopMgtModule.appForm.enum.ProxyID;
	import myShopper.shopMgtModule.appForm.model.AssetProxy;
	import myShopper.shopMgtModule.appForm.model.CommunicationProxy;
	import myShopper.shopMgtModule.appForm.model.ShopChatFormProxy;
	import myShopper.shopMgtModule.appForm.ModuleFacade;
	import myShopper.shopMgtModule.appForm.view.ShopCustomerChatMediator;
	import org.puremvc.as3.multicore.interfaces.IApplicationMediator;
	import org.puremvc.as3.multicore.interfaces.IApplicationProxy;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.IContainerMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.interfaces.IRemoteDataProxy;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	import org.puremvc.as3.multicore.patterns.observer.Notification;

	public class ChatCommand extends SimpleCommand implements ICommand
	{
		override public function execute( note:INotification ):void
		{
			var name:String = note.getName();
			var fromUID:String
			var mediator:IApplicationMediator;
			var proxy:IRemoteDataProxy;
			var mediatorName:String;
			var resultVO:ResultVO
			var data:Object;
			switch(name)
			{
				case ChatEvent.END_SHOP_CHAT:
				{
					resultVO = note.getBody() as ResultVO;
					if (resultVO)
					{
						data = resultVO.result;
						
						fromUID = CommVOService.getFromUIDByFMSDataObj(data);
						
						if (fromUID)
						{
							mediatorName = AssetProxy.getChatProxyMediatorName( fromUID );
							
							var chatMediator:ShopCustomerChatMediator = facade.retrieveMediator(mediatorName) as ShopCustomerChatMediator;
							if (chatMediator)
							{
								chatMediator.handleNotification(new Notification(NotificationType.END_CUSTOMER_CHAT));
							}
						}
					}
					break;
				}
				case ChatEvent.SEND_SHOP_MESSAGE:
				{
					(facade.retrieveProxy(String(note.getBody())) as IRemoteDataProxy).getRemoteData(FMSServicesType.SEND_SHOP_CHAT_MESSAGE, note);
					break;
				}
				case ChatEvent.RECEIVE_SHOP_MESSAGE:
				{
					resultVO = note.getBody() as ResultVO;
					if (resultVO)
					{
						data = resultVO.result;
						
						//the chat msg sent from
						fromUID = CommVOService.getFromUIDByFMSDataObj(data);
						
						if (fromUID)
						{
							//use same name in both mediator and proxy for easier remove later on
							mediatorName = AssetProxy.getChatProxyMediatorName( fromUID );
							//var proxyName:String = getProxyIDByEventType(name) + fromID;
							
							if 
							(
								!facade.hasMediator(mediatorName) && 
								!facade.hasProxy(mediatorName)
							)
							{
								//store user message into commVOList
								if (!new CommVOService(moduleMain.voManager.getAsset(VOID.COMM_INFO)).setCommInfo(resultVO))
								{
									Tracer.echo(multitonKey + ' ChatCommand : execute : unable to store user message into vo list');
								}
								
								//if proxy/mediator is not created, flashing user (walked in user) button
								comm.request(CommunicationType.SHOP_RECEIVE_CHAT_MESSAGE, fromUID);
								
								/*mediator = new ShopCustomerChatMediator(mediatorName, moduleMain);
								proxy = new ShopChatFormProxy(mediatorName, moduleMain);
								
								facade.registerMediator( mediator );
								facade.registerProxy( proxy );
								
								proxy.initAsset(note);*/
							}
							else
							{
								Tracer.echo(multitonKey + ' : ChatCommand : execute : proxy or mediator has already created : setRemoteData ' + name);
								
								(facade.retrieveProxy(mediatorName) as ShopChatFormProxy).setRemoteData(resultVO.service, resultVO);
								
								//if object already created, set index to top
								mediator = facade.retrieveMediator(mediatorName) as IApplicationMediator;
								
								if (mediator is IContainerMediator)
								{
									IContainerMediator(mediator).setIndex();
								}
							}
						}
						else
						{
							Tracer.echo(multitonKey + ' : ChatCommand : execute : unable to retrieve "fromID" data : ' + resultVO.result);
						}
					}
					else
					{
						Tracer.echo(multitonKey + ' : ChatCommand : execute : unknown data type : ' + note.getBody());
					}
					
					
					break;
				}
			}
		}
		
		private function get comm():CommunicationProxy
		{
			return facade.retrieveProxy(ProxyID.COMM) as CommunicationProxy;
		}
		
		private function get moduleMain():IModuleMain
		{
			return (facade as ModuleFacade).module;
		}
	}
}