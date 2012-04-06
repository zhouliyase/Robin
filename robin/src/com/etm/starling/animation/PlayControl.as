package com.etm.starling.animation
{
	import starling.animation.IAnimatable;
	import starling.display.MovieClip;
	import starling.events.Event;

	public class PlayControl implements IAnimatable
	{
		private var mc:MovieClip;
		private var commands:Array;
		private var times:int;
		private var mpositon:int;
		public function PlayControl(mc:MovieClip,...commands)
		{
			this.mc=mc;
			this.commands=commands;
			mc.addEventListener(Event.COMPLETE,onComplete);
			mpositon=0;
			doTween();
		}
		public function advanceTime(pastedTime:Number):void
		{
			mc.advanceTime(pastedTime);
		}
		public function dispose():void
		{
			mc.removeEventListener(Event.COMPLETE,onComplete);
		}
		private function doTween():void
		{
			var pc:PlayCommand=commands[mpositon];
			times=pc.loop;
			mc.play(pc.name);
		}
		private function onComplete(e:Event):void
		{
			times--;
			if(times==0)
			{
				mpositon++;
				if(mpositon>=commands.length)
					mpositon=0;
				doTween();
			}
		}
	}
}