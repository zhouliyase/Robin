package com.etm.starling.display
{
	import com.etm.loader.AbstractLoader;
	import com.etm.loader.StreamLoader;
	import com.etm.tasks.TaskEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.utils.ByteArray;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	
	public class LazyStreamImage extends Sprite
	{
		private var stream:StreamLoader;
		private var radio:Number;
		private var loader:Loader;
		private var image:Image;
		private var loaded:Boolean;
		public function LazyStreamImage(stream:StreamLoader,radio:Number=0.2)
		{
			super();
			this.stream=stream;
			this.radio=radio;
			stream.addEventListener(TaskEvent.TASK_PROGRESS,onProgress);
			stream.addEventListener(TaskEvent.TASK_COMPLETE,onComplete);
			stream.addEventListener(TaskEvent.TASK_ERROR,onError);
			this.radio=radio;
			addEventListener(starling.events.Event.ADDED_TO_STAGE,onStart);
		}
		private function addListener(e:EventDispatcher):void
		{
			e.addEventListener(flash.events.Event.COMPLETE,onParse);
			e.addEventListener(IOErrorEvent.IO_ERROR,onError);
		}
		private function removeListener(e:EventDispatcher):void
		{
			e.addEventListener(flash.events.Event.COMPLETE,onParse);
			e.addEventListener(IOErrorEvent.IO_ERROR,onError);
		}
		
		private function onStart(event:starling.events.Event):void
		{
			if(!loaded)
				stream.load();
		}
		protected function onProgress(event:TaskEvent):void
		{
			if(event.task.completeRate>=radio && event.task.completeRate<1)
			{
				loader=new Loader();
				addListener(loader.contentLoaderInfo);
				loader.loadBytes(stream.content as ByteArray);
				stream.removeEventListener(TaskEvent.TASK_PROGRESS,onProgress);
			}
		}
		protected function onComplete(event:TaskEvent):void
		{
			loaded=true;
			try
			{
				if(loader.contentLoaderInfo.bytesLoaded!=loader.contentLoaderInfo.bytesTotal)
				{
					removeListener(loader.contentLoaderInfo);
					loader.close();
					loader.unloadAndStop();
				}
			}
			catch(e:Error)
			{
			}
			loader=new Loader();
			addListener(loader.contentLoaderInfo);
			loader.loadBytes(stream.content as ByteArray);
		}
		protected function onParse(event:flash.events.Event):void
		{
			removeListener(loader.contentLoaderInfo);
			if(image)
			{
				removeChild(image);
				image.dispose();
			}
			image=Image.fromBitmap(loader.content as Bitmap);
			addChild(image);
			loader.unloadAndStop();
		}
		
		protected function onError(event:flash.events.Event):void
		{
			// TODO Auto-generated method stub
			
		}
	}
}