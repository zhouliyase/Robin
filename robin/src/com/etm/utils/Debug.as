package com.etm.utils
{
	import com.demonsters.debugger.MonsterDebugger;
	import com.etm.core.Etm;
	import com.etm.utils.objectencoder.ObjectEncoder;
	
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.system.System;
	import flash.utils.Timer;

	public class Debug
	{
		public static const CONSOLE_OUTPUT:String="console_output";
		public static const TOOLS_OUTPUT:String="tools_output";
		public static const TRACE_OUTPUT:String="trace_output";

		/**
		 * 开关日志打印
		 * @default true
		 */
		public static var allowLog:Boolean=false;
		/**
		 *是否打印错误
		 * @default true
		 */
		public static var showError:Boolean=true;
		/**
		 *是否打印警告
		 * @default true
		 */
		public static var showWarning:Boolean=true;
		/**
		 *是否打印一般日志
		 * @default true
		 */
		public static var showInfo:Boolean=true;
	
		private static var _logOutput:String=Debug.TRACE_OUTPUT;

		private static var RED:uint=0xCC0000;
		private static var GREEN:uint=0x00CC00;
		private static var BLUE:uint=0x6666CC;
		private static var PINK:uint=0xCC00CC;
		private static var YELLOW:uint=0xCCCC00;


		/**
		 *打印日志
		 * @param message 日志消息，可包含{0},{1}...，依次被rests里的参数所替换
		 * @param target 输出日志的对象
		 * @param rests 用于替换的参数
		 *
		 */
		public static function info(message:String, target:Object=null, ... rests):void
		{
			if (allowLog && showInfo)
				send(generateMessage(message, rests),target, GREEN, "info");
		}

		/**
		 *打印错误
		 * @param message 错误消息，可包含{0},{1}...，依次被rests里的参数所替换
		 * @param target 输出错误的对象
		 * @param rests 用于替换的参数
		 *
		 */
		public static function error(message:String, target:Object=null, ... rests):void
		{
			if (allowLog && showError)
				send(generateMessage(message, rests),target, RED, "error");
		}

		/**
		 *打印警告
		 * @param message 警告消息，可包含{0},{1}...，依次被rests里的参数所替换
		 * @param target 输出警告的对象
		 * @param rests 用于替换的参数
		 *
		 */
		public static function warn(message:String, target:Object=null, ... rests):void
		{
			if (allowLog && showWarning)
				send(generateMessage(message, rests),target, YELLOW, "warn");
		}

		/**
		 *
		 * 打印内存使用情况
		 *
		 */
		public static function memory():void
		{
			send("TotalMemory useage:" + System.totalMemory,null, BLUE);
		}
		/**
		 *打印帧率 
		 * 
		 */		
		public static function frameRate():void
		{
			if (Etm.stage)
				send("Current frame rate:" + Etm.stage.frameRate,null, BLUE);
		}

		/**
		 *日志打印的方式
		 * @default Debug.TRACE_OUTPUT
		 */
		public static function get output():String
		{
			return _logOutput;
		}

		/**
		 * @private
		 */
		public static function set output(value:String):void
		{
			_logOutput=value;
		}


		private static function send(value:String, target:Object,color:uint, consoleLevel:String="info"):void
		{
			if (_logOutput == TRACE_OUTPUT)
			{
				trace(consoleLevel.toUpperCase()+":"+timestamp()+targetName(target)+value);
			}
			else if (_logOutput == CONSOLE_OUTPUT)
			{
				if (ExternalInterface.available)
				{
					try
					{
						ExternalInterface.call("function(text){if (window.console) window.console." + consoleLevel + "(text);}", timestamp()+targetName(target)+value);
					}
					catch (e:Error)
					{

					}
				}
			}
			else if(_logOutput == TOOLS_OUTPUT)
			{
				MonsterDebugger.trace(target,value,"",consoleLevel.toUpperCase(),color);
			}
		}

		private static function timestamp():String
		{
			return "[" + new Date().toString() + "]";
		}

		private static function targetName(target:Object):String
		{
			if (target)
				return "[" + Reflection.tinyClassName(target) + "]";
			else
				return "";
		}

		private static function generateMessage(msg:String, rest:Array):String
		{
			for (var i:int=0; i < rest.length; i++)
			{
				var paramString:String;
				if (Reflection.isSimple(rest[i]))
				{
					paramString=rest[i].toString();
				}
				else
				{
					paramString=new ObjectEncoder(rest[i], ObjectEncoder.JSON, false).JsonString;
				}
				msg=msg.replace(new RegExp("\\{" + i + "\\}", "g"), paramString);
			}
			return msg;
		}
	}
}

