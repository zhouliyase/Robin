package com.etm.event
{
	import flash.events.Event;

	public class SocketEvent extends Event
	{
		/**
		 *连接成功
		 */
		public static const CONNECTION:String="connection";
		/**
		 *连接丢失
		 */
		public static const CONNECTION_LOST:String="connection_lost";
		/**
		 *连接恢复
		 */
		public static const CONNECTION_RESUME:String="connection_resume";

		/**
		 *登陆成功
		 */
		public static const LOGIN:String="login";
		/**
		 *登出成功
		 */
		public static const LOGOUT:String="logout";
		/**
		 *登录失败
		 */
		public static const LOGIN_ERROR:String="login_error";

		/**
		 *自由会话消息
		 */
		public static const SESSION_MESSAGE:String="session_message";

		public var data:Object;

		public function SocketEvent(type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.data=data;
			super(type, bubbles, cancelable);
		}
	}
}
