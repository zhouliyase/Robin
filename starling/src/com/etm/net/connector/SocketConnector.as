package com.etm.net.connector
{
	import com.etm.core.Config;
	import com.etm.net.manager.SocketManager;
	import com.etm.utils.Debug;
	import com.etm.utils.objectencoder.ObjectEncoder;

	/**
	 * Socket连接器，用于进行Socket通信
	 *
	 */
	public class SocketConnector extends Connector
	{
		/**
		 *创建socket连接器，发送一次socket请求
		 * @param command_name 调用接口名称
		 * @param command_args 调用参数
		 *
		 */
		public function SocketConnector(command_name:String, command_args:Object=null, retryCount:int=0)
		{
			_method="socket";
			_serverAdress=SocketManager.instance.host;
			super(command_name, command_args, retryCount);
		}


		override protected function doExecute():void
		{
			super.doExecute();
			SocketManager.instance.send(Config.SESSION_MESSAGE, _commandArgs, onCompleteHandler, onErrorHandler);
			Debug.info("Send SFS request to {0},params is {1}", this, _commandName, _commandArgs);
		}

		protected function onCompleteHandler(result:Object):void
		{
			Debug.info("Get SFS response from {0},result is {1}", this, _commandName, result);
			_data=result;
			if (_data.code == 200)
				notifyComplete(this);
			else
				notifyError(this);
		}


		/**
		 *   @private
		 */
		protected function onErrorHandler(fault:Object):void
		{
			Debug.error("Get SFS error from {0},error is {1}", this, _commandName, fault);
			notifyError(this);
		}

	}
}
