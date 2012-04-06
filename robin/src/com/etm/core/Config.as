package com.etm.core
{
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getTimer;

	/**
	 * Some SecretData don't want to be seen easily.
	 * 此处修改通信加密认证Key
	 * */
	[SecretData(secret_key="#secret_key#", consumer_Key="#consumer_key#", authMethod="HMAC-SHA1", authVersion="1.0")]
	/**
	 * 配合GDP,包含游戏所有基本配置。其中与GDP约定的几个参数为：
	 * 1.webbase：游戏主文件的存放目录；
	 * 2.gateway: 后台gateway地址；
	 * 3.lang:语言；
	 * 4.help:    游戏帮助页面地址；
	 * */
	public class Config
	{
		public static const SECRET_KEY_CFG:String="secret_key";
		public static const CONSUMER_KEY_CFG:String="consumer_Key";
		public static const AUTH_METHOD_CFG:String="authMethod";
		public static const AUTH_VERSION_CFG:String="authVersion";


		public static const GATEWAY_CFG:String="gateway";
		public static const SERVER_ADDRESS_CFG:String="server_address";

		public static const SESSION_MESSAGE:int=0x33;
		public static const LOG_IN:int=0x11;

		public static const SESSION_ID:String="session_id";



		private static var local:Dictionary=new Dictionary();
		private static var _serverTime:Number=0; //服务器时间
		private static var _syncTime:Number=0; //本地时间

		/**
		 * 与后台通信的gateway,以"/"结尾
		 *
		 */
		public static function get gateWay():String
		{
			var url:String=Config.getConfig("gateway");
			if (url && url.lastIndexOf("/") == (url.length - 1))
			{
				url=url.substring(0, url.length - 1);
			}
			return url;
		}

		/**
		 *获取配置,优先获取通过Flashvar传入的外部配置
		 * @param name 参数名
		 */
		public static function getConfig(name:String):*
		{
			var value:Object;

			if (Etm.stage)
			{
				value=Etm.stage.loaderInfo.parameters[name];
			}
			if (value)
				return value;
			value=Config.local[name];
			if (value is Function)
			{
				return value();
			}
			return value;
		}

		/**
		 * 当前语言版本类型，如"cn","en"
		 * */
		public static function get lang():String
		{
			return getConfig("lang");
		}


		/**
		 *设置参数
		 * @param name 参数名
		 * @param value 参数值
		 *
		 */
		public static function setConfig(name:String, value:*):void
		{
			Config.local[name]=value;
		}

		/**
		 * 游戏放置的根目录
		 * */
		public static function get webbase():String
		{
			var _webbase:String=Config.getConfig("webbase");
			if (!_webbase)
				_webbase="";
			//如果没有以“/”结尾，加上，防止拼凑全路径时出错
			if ((_webbase.length) && (_webbase.lastIndexOf("/") != (_webbase.length - 1)))
				_webbase+="/";

			return _webbase;
		}

		/**
		 *当前服务器时间
		 */
		public static function get systemTime():Number
		{
			return getTimer() - _syncTime + _serverTime;
		}

		/**
		 *
		 * @param time
		 */
		public static function set systemTime(time:Number):void
		{
			_serverTime=time;
			_syncTime=getTimer();
		}

		/**
		 * 对配置进行初始化
		 * @param config 自定义配置文件加载的路径
		 */
		etm_internal static function init():void
		{
			//对需要保密的使用 ‘SecretData’元标签的数据解析
			var metadatas:XMLList=describeType(Config).factory.metadata.(@name == "SecretData").arg;
			var numSecrets:int=metadatas.length();
			for (var i:int=0; i < numSecrets; i++)
			{
				setConfig(metadatas[i].@key, String(metadatas[i].@value));
			}
		}

		//从对象解析配置,不覆盖已存在属性
		etm_internal static function parseFromObject(objConfig:Object):void
		{
			for (var conf:String in objConfig)
			{
				if (!getConfig(conf))
					setConfig(conf, objConfig[conf]);
			}
		}

		//从xml解析配置,不覆盖已存在属性
		etm_internal static function parseFromXML(xmlConfig:XML):void
		{
			for each (var conf:XML in xmlConfig.children())
			{
				if (!getConfig(conf.localName()))
					setConfig(conf.localName(), conf.toString());
			}
		}
	}
}
