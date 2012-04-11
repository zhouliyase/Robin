package com.etm.loader
{
	import com.etm.core.Config;
	import com.etm.tasks.ParallelTask;
	import com.etm.tasks.TaskEvent;
	import com.etm.utils.Debug;
	
	import flash.events.Event;
	import flash.utils.Dictionary;

	public class QLoader extends ParallelTask
	{
		private static var _loaders:Dictionary=new Dictionary();

		public static function getLoader(id:String, bandWidth:int=3, retryCount:uint=0):QLoader
		{
			var loader:QLoader=_loaders[id];
			if (!loader)
			{
				loader=new QLoader(id, bandWidth, retryCount);
				_loaders[id]=loader;
			}
			return loader;
		}

		public function QLoader(id:String, bandWidth:int=3, retryCount:uint=0)
		{
			super(bandWidth, 0, 999999, retryCount);
			_queues=new Dictionary();
			_idIndex=new Dictionary(true);
		}

		private var _queues:Dictionary;
		private var _idIndex:Dictionary;
		/**
		 *增加一个加载项
		 * @param url 加载地址
		 * @param type 加载类型
		 * @param cache 是否缓存
		 * @return 承担加载的loader
		 *
		 */
		public function add(url:String, type:String="auto", cache:Boolean=true, param:Object=null):AbstractLoader
		{
			if (type == "auto")
			{
				var file:String=autoMatch(url);
				switch (file)
				{
					case "swf":
					case "jpeg":
					case "png":
					case "jpg":
						type=ResourceType.ASSET_FORMAT;
						break;
					case "xml":
						type=ResourceType.XML_DATA_FORMAT;
						break;
					case "json":
						type=ResourceType.JSON_DATA_FORMAT;
						break;
					case "txt":
					case "html":
						type=ResourceType.TEXT_DATA_FORMAT;
						break;
					default:
						type=ResourceType.BINARY_DATA_FORMAT;
						break;
				}
			}
			var loader:AbstractLoader;
			switch (type)
			{
				case ResourceType.ASSET_FORMAT:
					if (param&&param.context)
						loader=new AssetsLoader(url, param.context);
					else
						loader=new AssetsLoader(url);
					break;
				case ResourceType.BINARY_DATA_FORMAT:
				case ResourceType.JSON_DATA_FORMAT:
				case ResourceType.TEXT_DATA_FORMAT:
				case ResourceType.XML_DATA_FORMAT:
					loader=new DataLoader(url, type);
					break;
				case ResourceType.STREAM_FORMAT:
					loader=new StreamLoader(url);
					break;
			}
			loader.preventCache=!cache;
			enqueue(loader);
			_queues[url]=loader;
			if (param&&param.id)
				_idIndex[param.id]=loader;
			return loader;
		}

		/**
		 *获取对应url的加载内容，需要此资源已经加载完毕
		 * @param url 资源的url
		 * @return 加载的内容
		 *
		 */
		public function getContent(url:String):Object
		{
			var loader:AbstractLoader=_queues[url];
			if (loader.isCompleted)
				return loader.content;
			else
				return null;
		}
		public function getItemLoader(url:String):AbstractLoader
		{
			return _queues[url];
		}
		public function getContentById(id:String):Object
		{
			var loader:AbstractLoader=_idIndex[id];
			if (loader.isCompleted)
				return loader.content;
			else
				return null;
		}
		public function getItemLoaderById(id:String):AbstractLoader
		{
			return _idIndex[id];
		}

		/**
		 * 启动加载
		 *
		 */
		public function start():void
		{
			execute();
		}
		public function loadFromConfig(url:String):void
		{
			var configLoader:DataLoader=new DataLoader(url,ResourceType.XML_DATA_FORMAT);
			configLoader.addEventListener(TaskEvent.TASK_COMPLETE,onParseConfig);
			configLoader.addEventListener(TaskEvent.TASK_ERROR,onLoadConfigError);
			configLoader.load();
		}
		
		private function onParseConfig(event:TaskEvent):void
		{
			var cl:DataLoader=event.task as DataLoader;
			var band:int=parseInt(cl.content.numConnections);
			var isLazy:Boolean=Boolean(cl.content.lazy);
			Config.setConfig("webbase",cl.content.webbase.toString());
			for each(var file:XML in cl.content.files)
			{
				var item:AbstractLoader=add(file.url,file.type?file.type:"auto",Boolean(file.preventCache));
				item.retryCount=parseInt(file.maxTries);
			}
			if(!isLazy)
				start();
		}
		
		private function onLoadConfigError(event:TaskEvent):void
		{
			Debug.warn("Can't load load config file.");
			notifyError(event.task);
		}
		

		private function autoMatch(url:String):String
		{
			var type:String=String(url.match(/\.[^.]+$/)[0]).substr(1).toLowerCase();
			return type;
		}
	}
}
