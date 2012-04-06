package com.etm.net.connector
{
	import com.adobe.crypto.HMAC;
	import com.adobe.crypto.MD5;
	import com.adobe.crypto.SHA1;
	import com.etm.core.Config;
	import com.etm.core.Etm;
	import com.etm.tasks.Task;
	import com.etm.utils.Debug;
	import com.etm.utils.Util;
	import com.etm.utils.objectencoder.ObjectEncoder;

	/**
	 * 连接器的基类，通过继承此类来实现不同的连接方式
	 *
	 */
	public class Connector extends Task
	{

		/**
		 *创建一个连接器
		 * @param gateway　通信地址
		 * @param command_name　通信接口
		 * @param params　通信参数
		 * @param needAuth　是否安全验证
		 *
		 */
		public function Connector(commandName:String, commandArgs:Object=null, retryCount:int=0)
		{
			super(0, 999999, retryCount);
			_commandName=commandName;
			_commandArgs=commandArgs;
			generateParam(commandArgs);
		}

		protected var _commandArgs:Object;
		protected var _commandName:String;
		protected var _msgId:uint;
		protected var _serverAdress:String;
		protected var _method:String;

		protected var _data:Object;



		/**
		 * 获取消息id
		 *
		 */
		public function get msgId():uint
		{
			return _msgId;
		}

		public function get data():Object
		{
			return _data;
		}


		/**
		 *生成请求参数
		 * @param value 传入参数
		 *
		 */
		protected function generateParam(value:Object):void
		{
			value.command=_commandName;
			value.id=_msgId=Util.messageId;
		}

		protected function get destination():String
		{
			return _serverAdress + _commandName;
		}
	}
}
