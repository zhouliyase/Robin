package com.etm.starling.animation
{
	public class MCTween
	{
		private var mname:Array;
		private var mloop:Array;
		/**
		 *a mc tween to control mc play flow 
		 * @param name state to play,when has multiple name split by ',',select one randomly every time it runs
		 * @param loop number to loop,when has mutiple number split by ',',select one randomly every time it runs
		 * 
		 */		
		public function MCTween(name:String,loop:String)
		{
			mname=name.split(",");
			mloop=loop.split(",");
		}

		public function get name():String
		{
			if(mname.length==1)
				return mname[0];
			else
				return mname[Math.floor(Math.random()*mname.length)];
		}


		public function get loop():int
		{
			if(mloop.length==1)
				return parseInt(mloop[0]);
			else
				return parseInt(mloop[Math.floor(Math.random()*mloop.length)]);
		}

	}
}