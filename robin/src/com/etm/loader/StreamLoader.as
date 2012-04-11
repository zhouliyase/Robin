package com.etm.loader
{
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;

	public class StreamLoader extends AbstractLoader
	{
		protected var _loader:URLStream;
		
		public function StreamLoader(url:String)
		{
			super(url);
			_loader=new URLStream();
			_loader.addEventListener(Event.COMPLETE,onCompleteHandler);
			addLoaderEventListeners(_loader);
		}
		
		override protected function clear():void
		{
			removeLoaderEventListeners(_loader);
			super.clear();
		}
		
		override protected function doExecute():void
		{
			super.doExecute();
			_loader.load(new URLRequest(_url));
			_content=new ByteArray();
		}
		
		override protected function onCompleteHandler(evt:Event):void
		{
			var bytes:ByteArray=_content as ByteArray;
			_loader.readBytes(bytes,bytes.length,_loader.bytesAvailable);
			super.onCompleteHandler(evt);
		}
		override protected function onProgressHandler(evt:ProgressEvent):void
		{
			var bytes:ByteArray=_content as ByteArray;
			_loader.readBytes(bytes,bytes.length,_loader.bytesAvailable);
			super.onProgressHandler(evt);
		}
	}
}