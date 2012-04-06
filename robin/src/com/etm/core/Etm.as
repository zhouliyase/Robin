package com.etm.core
{
	import com.etm.tasks.tick.TickManager;
	import com.etm.utils.Reflection;

	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.system.ApplicationDomain;
	import flash.system.Security;

	use namespace etm_internal;

	public class Etm extends EventDispatcher
	{
		/**
		 * 是否在和后台的交互中使用安全验证。
		 * @default true
		 */
		public static var needAuth:Boolean=true;

		private static var _app:Sprite;

		/**
		 * 检测是否运行在本地环境
		 */
		public static function get isLocal():Boolean
		{
			return Security.sandboxType != Security.REMOTE;
		}

		/**
		 *获取舞台
		 *
		 */
		public static function get stage():Stage
		{
			if (_app)
				return _app.stage;
			else
				return null;
		}

		/**
		 *获取程序根容器
		 */
		public static function get app():Sprite
		{
			return _app;
		}

		/**
		 * 初始化
		 */
		public static function init(app:Sprite):void
		{
			_app=app;
			TickManager.init(_app);
			Config.init();
			Reflection.addApplicationDomain(ApplicationDomain.currentDomain);
		}
	}
}
