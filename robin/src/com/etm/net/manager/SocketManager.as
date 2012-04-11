package com.etm.net.manager
{
	import com.etm.core.Config;
	import com.etm.event.SocketEvent;
	import com.etm.utils.Debug;
	import com.etm.utils.Util;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	//TODO split to event

	/**
	 * socket连接器
	 *
	 */
	public class SocketManager extends EventDispatcher
	{
		private static var _instance:SocketManager;

		public static function get instance():SocketManager
		{
			if (!_instance)
				_instance=new SocketManager();
			return _instance;
		}

		public function SocketManager()
		{
			var server:String=Config.getConfig(Config.SERVER_ADDRESS_CFG);
			host=server.split(":")[0];
			port=server.split(":")[1];
			_server=new Socket();
			_server.addEventListener(Event.CONNECT, onConnection);
			_server.addEventListener(Event.CLOSE, onClose);
			_server.addEventListener(IOErrorEvent.IO_ERROR, onError);
			_server.addEventListener(ProgressEvent.SOCKET_DATA, onStreamIn);
			_server.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);

			unSendMessage=[];
			_registerQueue=new Dictionary(false);
		}
		private var _len:uint=0;
		private var _package:ByteArray;

		//process incoming data
		private function onStreamIn(event:ProgressEvent):void
		{
			if (_len == 0)
			{
				if (_server.bytesAvailable >= 4)
				{
					_len=_server.readUnsignedShort();
					_package=new ByteArray();
					processPackage();
				}
			}
			else
				processPackage();
		}
		//process package
		private function processPackage():void
		{
			if (_server.bytesAvailable == 0)
			{
				return;
			}
			var type:int=-1;
			try
			{
				// Load the data
				if (_package.length < _len && _server.bytesAvailable > 0)
				{
					var l:uint=_server.bytesAvailable;
					if (l > _len - _package.length)
					{
						l=_len - _package.length;
					}
					_server.readBytes(_package, _package.length, l);
				}
				// Check if we have all the data
				if (_len != 0 && _package.length == _len)
				{
					// Parse the bytes and send them for handeling to the core
					type=_package.readByte();
					var result:Object=_package.readObject();
					switch (type)
					{
						case Config.LOG_IN_SUCCESS:
							onLoginSuccess(result);
							break;
						case Config.LOG_IN_FAILURE:
							onLoginFailure(result);
							break;
						case Config.NETWORK_MESSAGE:
							onSession(result);
							break;
					}
					// Clear the old data
					_len=0;
					type=-1;
					_package=null;
				}
			}
			catch(e:Error)
			{
				if(type!=-1)
				{
					switch (type)
					{
						case Config.LOG_IN_SUCCESS:
						case Config.LOG_IN_FAILURE:
							onLoginFailure(result);
							break;
						case Config.NETWORK_MESSAGE:
							Debug.error("Sesion message error:"+e.message,this);
							break;
					}
				}
				else
				{
					Debug.error("Can't parse package."+e.message,this);
				}
			}

			// Check if there is another package
			if (_len == 0 && _server.bytesAvailable >= 4)
			{
				_len=_server.readUnsignedShort();
				_package=new ByteArray();
				processPackage();
			}
		}
		
		private function onLoginSuccess(result:Object):void
		{
			Config.systemTime=result.timestamp;
			Config.setConfig(Config.TOKEN_CFG,result.token);	
			isLogin=true;
			Debug.info("Login success",this);
			dispatchEvent(new SocketEvent(SocketEvent.LOGIN, result));
			sendUnhandleMsg();
		}
		
		private function onLoginFailure(result:Object):void
		{
			isLogin=false;
			Debug.error("Login error: {0}",this,result);
			dispatchEvent(new SocketEvent(SocketEvent.LOGIN_ERROR, result));
		}
		
		
		
		//handler session message
		private function onSession(result:Object):void
		{
			var handlers:Array=_registerQueue[result.data.id];
			if (handlers)
			{
				if (result.code == 200)
				{
					handlers[0](result);
				}
				else
				{
					handlers[1](result);
				}
				delete _registerQueue[result.id];
			}
			else
			{
				Debug.warn("Message " + result.id + " hasn't been registered.", this);
			}
			dispatchEvent(new SocketEvent(SocketEvent.SESSION_MESSAGE, result));
		}
		
		
		private function onError(event:ErrorEvent):void
		{
			isLogin=false;
			Debug.error(event.text,this);
			dispatchEvent(new SocketEvent(SocketEvent.CONNECTION_LOST,{msg:"Can't connect to the server."}));
		}

		private function onClose(event:Event):void
		{
			isLogin=false;
			Debug.info("Connection closed",this);
			dispatchEvent(new SocketEvent(SocketEvent.CONNECTION_LOST,{msg:"Connection closed."}));
		}
		/**
		 * 服务地址
		 * */
		public var host:String;
		/**
		 * 服务端口
		 * */
		public var port:uint;
		/**
		 * 服务区域
		 * */
		private var _server:Socket;
		private var unSendMessage:Array;
		private var isLogin:Boolean;
		private var isConnecting:Boolean;
		private var isLogining:Boolean;
		private var _registerQueue:Dictionary;

		/**
		 *是否连接
		 *
		 */
		public function get connected():Boolean
		{
			return _server.connected;
		}

		/**
		 *连接到服务器
		 *
		 */
		public function connect():void
		{
			isConnecting=true;
			_server.connect(host, port);
		}

		/**
		 *发送一个socket请求 
		 * @param type 请求类型
		 * @param params 请求参数
		 * @param successHandler 成功处理函数
		 * @param failHandler 失败处理函数
		 * 
		 */		
		public function send(type:int, params:Object, successHandler:Function, failHandler:Function):void
		{
			var id:Number=Util.messageId;
			params.id=id;
			_registerQueue[id]=[successHandler, failHandler];
			var msg:ByteArray=new ByteArray();
			msg.writeObject(params);
			if (connected && isLogin)
			{
				doSend(type, msg);
			}
			else
			{
				unSendMessage.push([type, msg]);
			}
		}
		public function registerMessage(id:int,successHandler:Function, failHandler:Function):void
		{
			_registerQueue[id]=[successHandler, failHandler];
		}
		/**
		 *登录操作 
		 * @param params 登陆参数
		 * 
		 */		
		public function login(params:Object):void
		{
			if (isLogin)
				return;
			var msg:ByteArray=new ByteArray();
			msg.writeUTF(Util.generateHeader(params));
			msg.writeObject(params);
			if (connected)
			{
				doSend(Config.LOG_IN, msg);
			}
			else
			{
				if (!connected && !isConnecting)
					connect();
				loginData=msg;
			}
		}
		
		//login later when server is connected		
		private var loginData:ByteArray;
		private function loginLater():void
		{
			doSend(Config.LOG_IN, loginData);
		}

		//connect server success
		private function onConnection(event:Event):void
		{
			isConnecting=false;
			dispatchEvent(new SocketEvent(SocketEvent.CONNECTION));
			loginLater();
		}


		private function doSend(type:int, msg:ByteArray):void
		{
			var body:ByteArray=new ByteArray();
			body.writeByte(type);
			body.writeBytes(msg,0,msg.length);
			_server.writeShort(body.length);
			_server.writeBytes(body, 0, body.length);
			_server.flush();
		}
		//send cached message
		private function sendUnhandleMsg():void
		{
			while (unSendMessage.length != 0 && connected)
			{
				var usm:Array=unSendMessage.shift();
				doSend(usm[0], usm[1]);
			}
		}
	}
}
