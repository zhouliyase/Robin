package com.etm.net.connector
{
	import flash.utils.ByteArray;

	public class MessageObject
	{
		public function MessageObject()
		{
		}
		public var type:int;
		public var data:Object;
		public var code:int;

		public function parseFromBytes(bytes:ByteArray):void
		{

		}

		public function parseToBytes():ByteArray
		{
			return null;
		}
	}
}
