package com.etm.locale
{
	import com.etm.core.Config;
	import com.etm.core.Etm;
	import com.etm.loader.DataLoader;
	import com.etm.loader.ResourceType;
	import com.etm.net.connector.Connector;
	import com.etm.tasks.SerialTask;
	import com.etm.tasks.Task;
	import com.etm.tasks.TaskEvent;
	import com.etm.utils.Debug;
	import com.etm.utils.Reflection;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequestMethod;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.System;
	import flash.text.Font;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	
	/**
	 *多语言文件加载完毕后派发
	 */
	[Event(type="flash.events.Event", name="complete")]
	/**
	 *多语言服务加载进度，进度只显示完成的文件数目和总数目的比例
	 */
	[Event(type="flash.events.ProgressEvent", name="progress")]
	/**
	 *语言管理器，用于多语言相关文件的加载和调度。多语言相关文件包括多语言文本、多语言样式和多语言字体，
	 * 通过管理器的<code>load</code>方法加载后，就可以通过<code>getText</code>，<code>getStyle</code>方法获取
	 * 相应的文本和文本样式，也可以使用<code>createText</code>直接创建具有特定内容和特定样式的文本框.
	 *
	 */
	public class LocaleManager extends EventDispatcher
	{
		/**
		 *多语言的字体服务
		 */
		public static const FONTS_SERVICE:String="locale.font.get";
		/**
		 *多语言的文字服务
		 */
		public static const LANGUAGE_SERVICE:String="locale.text.getAll";
		/**
		 * 多语言的样式服务
		 */
		public static const STYLE_SERVICE:String="locale.style.get";
		
		private static var _instance:LocaleManager;
		
		/**
		 * 获取语言管理器唯一的实例
		 *
		 */
		public static function get instance():LocaleManager
		{
			if (!_instance)
				_instance=new LocaleManager();
			return _instance;
		}
		
		/**
		 *@private
		 *
		 */
		public function LocaleManager()
		{
			
		}
		
		private var languageSource:XML;
		private var styleSheet:StyleSheet;
		
		/**
		 *从语言文件中获取key值所对应的文本值。如果提供args参数，则使用各个参数值顺序替换文本中的{0},{1}..
		 * @param key 要获取文本的key值
		 * @param args 进行替换的参数
		 * @return 查找的多语言文本
		 *
		 */
		public function getText(key:String, ... args):String
		{
			if (languageSource == null)
			{
				throw new Error("Language resource is not loaded!");
			}
			var result:XML=searchFor(key, languageSource)[0];
			var text:String="undefined";
			if (result == null)
				return text;
			text=result.toString();
			
			if (args && (args.length > 0))
			{
				for (var i:int=0; i < args.length; i++)
				{
					var replaceTxt:String=String(args[i]);
					text=text.replace("{" + i + "}", replaceTxt);
				}
			}
			return text;
		}
		
		/**
		 * 获取特定名称的文本样式
		 * @param name 样式文件中相应样式的名称
		 * @return 样式对应的文本格式
		 * */
		public function getStyle(name:String):TextFormat
		{
			if (name != null)
			{
				var style:Object=styleSheet.getStyle(name);
				return styleSheet.transform(style);
			}
			return null;
		}
		
		/**
		 * 创建一个特定样式和特定内容的文本框
		 * @param style 文本框所应用的样式
		 * @param embedFont 是否使用嵌入的字体 默认为true
		 * @param textOrKey 文本内容或者多语言key值
		 * @param isKey textOrKey是否是多语言key值，默认为false
		 * @return
		 *
		 */
		public function createText(textOrKey:String,style:String, isKey:Boolean=false,embedFont:Boolean=false):TextField
		{
			var tf:TextField=new TextField();
			tf.defaultTextFormat=getStyle(style);
			if (isKey && textOrKey && textOrKey.length)
				textOrKey=this.getText(textOrKey);
			tf.text=textOrKey;
			tf.embedFonts=embedFont;
			return tf;
		}
		
		
		public function createLanguageTask(url:String):DataLoader
		{
			var task:DataLoader=new DataLoader(url,ResourceType.XML_DATA_FORMAT);
			task.addEventListener(TaskEvent.TASK_COMPLETE, onLanguageComplete);
			task.addEventListener(TaskEvent.TASK_ERROR, onLanguageError);
			return task;
		}
		
		public function createStyleTask(url:String):DataLoader
		{
			var task:DataLoader=new DataLoader(url,ResourceType.XML_DATA_FORMAT);
			task.addEventListener(TaskEvent.TASK_COMPLETE, onStyleComplete);
			task.addEventListener(TaskEvent.TASK_ERROR, onStyleError);
			return task;
		}
		
		public function createFontTask(url:String):DataLoader
		{
			var task:DataLoader=new DataLoader(url,ResourceType.BINARY_DATA_FORMAT);
			task.addEventListener(TaskEvent.TASK_COMPLETE, onFontComplete);
			task.addEventListener(TaskEvent.TASK_ERROR, onFontError);
			return task;
		}
		
		private function searchFor(_key:String, source:XML):XMLList
		{
			try
			{
				return source.children().(@name == _key);
			}
			catch (e:Error)
			{
				Debug.error("Language xml data format is not right.", this);
			}
			return null;
		}
		
		private function onLanguageComplete(event:TaskEvent):void
		{
			try
			{
				languageSource=new XML(event.target.data.data as String);
			}
			catch (e:Error)
			{
				languageSource=new XML("");
				Debug.error("Can not parse language file.", this);
			}
		}
		
		private function onLanguageError(event:TaskEvent):void
		{
			languageSource=new XML("");
			Debug.error("Language Service request error.", this);
		}
		
		private function onStyleComplete(event:TaskEvent):void
		{
			var style:StyleSheet=new StyleSheet();
			try
			{
				style.parseCSS(event.target.data.data as String);
			}
			catch (e:Error)
			{
				Debug.error("Can not parse style file.", this);
			}
			styleSheet=style;
		}
		
		private function onStyleError(event:TaskEvent):void
		{
			styleSheet=new StyleSheet();
			Debug.error("Style Service request error.", this);
		}
		
		private function onFontComplete(event:TaskEvent):void
		{
			var loader:Loader=new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, registeFonts);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadFontsError);
			try
			{
				loader.loadBytes((event.task as Connector).data.data as ByteArray,
					new LoaderContext(false, ApplicationDomain.currentDomain));
			}
			catch (e:Error)
			{
				Debug.error("Can not parse font file.", this);
			}
		}
		
		private function onFontError(e:TaskEvent):void
		{
			Debug.error("Font Service request error.", this);
		}
		//TODO register font
		private function registeFonts(e:Event):void
		{
			//获取字体文件里所有可能的字体元件定义，并注册之
			var fontList:Array=Font.enumerateFonts(false);
			for each (var font:Object in fontList)
			{
				try
				{
					var def:Class=Reflection.getClassByInstance(font);
					if (def != Font)
						Font.registerFont(def);
				}
				catch (error:Error)
				{
					Debug.error(font.fontName + " can not be registered.", this);
				}
			}
		}
		
		private function onLoadFontsError(event:IOErrorEvent):void
		{
			Debug.error("Can not parse font file.", this);
		}
		
		private function onProgress(event:TaskEvent):void
		{
			var task:SerialTask=event.task as SerialTask;
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, task.itemsComplete, task.itemsTotal));
		}
		
		private function onComplete(event:TaskEvent):void
		{
			dispatchEvent(new Event(Event.COMPLETE));
			
		}
		/**
		 *加载多语言文本文件，默认从多语言服务进行加载，如指定path的值，则从指定路径进行加载，加载成功后派发
		 * <code>Event.COMPLETE</code>事件
		 * @param path 加载自定义多语言文本文件时指定的文件路径
		 *
		 */
		public  function loadLanguage(url:String):DataLoader
		{
			var loader:DataLoader=createLanguageTask(url);
			loader.load();
			return loader;
		}
		
		public  function loadStyle(url:String):DataLoader
		{
			var loader:DataLoader=createStyleTask(url);
			loader.load();
			return loader;
		}
		
		public  function loadFont(url:String):DataLoader
		{
			var loader:DataLoader=createFontTask(url);
			loader.load();
			return loader;
		}
	}
}
