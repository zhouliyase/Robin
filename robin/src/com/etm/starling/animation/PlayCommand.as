package com.etm.starling.animation
{

	public class PlayCommand
	{
		private var mname:Array;
		private var mloop:Array;

		/**
		 *a mc tween to control mc play flow
		 * @param name state to play,when has multiple name split by ',',select one randomly every time it runs
		 * @param loop number to loop,when has two number joint by '-',select one between the range
		 *
		 */
		public function PlayCommand(name:String, loop:Object)
		{
			mname=name.split(",");
			mloop=[];
			if (loop is int)
			{
				mloop.push(loop);
			}
			else if (loop is String)
			{
				mloop=(loop as String).split("-")
				mloop[0]=parseInt(mloop[0]);
				mloop[1]=parseInt(mloop[1]);
			}
		}

		public function get name():String
		{
			if (mname.length == 1)
				return mname[0];
			else
				return mname[Math.floor(Math.random() * mname.length)];
		}

		public function get loop():int
		{
			if (mloop.length == 1)
				return mloop[0];
			else
				return Math.ceil(mloop[0] + (mloop[1] - mloop[0]) * Math.random());
		}

	}
}
