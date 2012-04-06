package com.etm.net.connector
{
	import com.etm.core.Config;
	import com.etm.core.Etm;
	import com.etm.utils.Debug;
	import com.etm.utils.Util;

	import flash.events.AsyncErrorEvent;
	import flash.events.ErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	import flash.net.Responder;

	/**
	 *AMF连接器，用于创建AMF连接
	 *
	 */
	public class AMFConnector extends Connector
	{

		/**
		 * 创建一个AMF连接器
		 * @param command_name 调用的服务名称
		 * @param command_args 传递的参数
		 * @param gateWay 通信地址
		 *
		 */
		public function AMFConnector(command_name:String, command_args:Object, gateway:String, retryCount:int=0)
		{
			_serverAdress=gateway;
			_method="http";
			super(command_name, command_args, retryCount);
			attachHeader();
		}

		private var _netConnection:NetConnection;

		/**
		 * @inheritDoc
		 */
		override protected function clear():void
		{
			super.clear();
			removeListeners();
			_netConnection.close();
		}

		/**
		 * @inheritDoc
		 */
		override protected function doExecute():void
		{
			_netConnection=new NetConnection();
			if (!_netConnection.connected)
			{
				addListeners();
				_netConnection.connect(_serverAdress);
			}
			_netConnection.objectEncoding=ObjectEncoding.AMF3;
			var _amfResponder:Responder=new Responder(onCallSuccess, onCallError);
			var args:Array=[_commandName, _amfResponder];
			args.push(_commandArgs);
			_netConnection.call.apply(_netConnection, args);
			super.doExecute();
			Debug.info("Send AMF request {0} to {1}", this, _commandArgs, destination);
		}

		private function attachHeader():void
		{
			_netConnection.addHeader("Authorization", false, Util.generateHeader(_commandArgs, Config.getConfig(Config.SESSION_ID)));
		}

		private function addListeners():void
		{
			if (_netConnection == null)
				return;
			_netConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatusEvent);
			_netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);
			_netConnection.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			_netConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onLoadError);
		}

		private function onCallError(error:Object):void
		{
			Debug.error("Receive AMF error {0} from {1}", this, error, destination);
			var errMsg:String=(error == null) ? "AMF Unknow Error." : error.faultString;
			this.notifyError(this);
		}


		private function onCallSuccess(result:Object):void
		{
			Debug.info("Receive AMF response {0} from {1}", this, result, destination);
			_data=result;
			if (_data.code == 200)
				notifyComplete(this);
			else
				notifyError(this);
		}

		private function onLoadError(event:ErrorEvent):void
		{
			var errMsg:String=event.text;
			Debug.error("Receive AMF error {0} from {1}", this, errMsg, destination);
			this.notifyError(this);
		}

		private function onNetStatusEvent(event:NetStatusEvent):void
		{
			if (event.info.level == 'error')
			{
				var errorInfo:String=event.info.code;
				Debug.error("Receive AMF error {0} from {1}", this, errorInfo, destination);
				this.notifyError(this);
			}
		}

		private function removeListeners():void
		{
			if (_netConnection == null)
				return;
			_netConnection.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatusEvent);
			_netConnection.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);
			_netConnection.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			_netConnection.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, onLoadError);
		}
	}
}
