package com.etm.starling.display
{
	import com.etm.loader.AbstractLoader;
	import com.etm.loader.StreamLoader;
	import com.etm.tasks.TaskEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.utils.ByteArray;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	
	public class LazyStreamImage extends Sprite
	{
		private var stream:StreamLoader;
		private var radio:Number;
		private var loader:Loader;
		private var image:Image;
		public function LazyStreamImage(stream:StreamLoader,radio:Number=0.2)
		{
			super();
			this.stream=stream;
			this.radio=radio;
			stream.addEventListener(TaskEvent.TASK_PROGRESS,onProgress);
			stream.addEventListener(TaskEvent.TASK_COMPLETE,onComplete);
			stream.addEventListener(TaskEvent.TASK_ERROR,onError);
			loader=new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onParse);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onError);
			stream.load();
			this.radio=radio;
			image=new Image(Texture.fromBitmapData(new BitmapData(1,1)));
			addChild(image);
		}
		protected function onProgress(event:TaskEvent):void
		{
			if(event.task.completeRate>=radio)
			{
				loader.loadBytes(stream.content as ByteArray);
				stream.removeEventListener(TaskEvent.TASK_PROGRESS,onProgress);
			}
		}
		protected function onComplete(event:TaskEvent):void
		{
			try
			{
				if(loader.contentLoaderInfo.bytesLoaded!=loader.contentLoaderInfo.bytesTotal)
					loader.close();
			}
			catch(e:Error)
			{
			}
			loader.unloadAndStop();
			loader.loadBytes(stream.content as ByteArray);
		}
		protected function onParse(event:Event):void
		{
			image.texture=Texture.fromBitmapData((loader.content as Bitmap).bitmapData);
		}
		
		protected function onError(event:Event):void
		{
			// TODO Auto-generated method stub
			
		}
	}
}