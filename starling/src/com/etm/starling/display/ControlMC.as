package com.etm.starling.display
{
	import com.etm.starling.animation.MCTween;
	import com.etm.starling.texture.TextureBin;
	
	import flash.geom.Point;
	
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	public class ControlMC extends MovieClip
	{
		private var mtextureatlas:TextureAtlas;
		public function ControlMC(atlas:TextureAtlas, pivot:Point=null,fps:Number=12)
		{
			super(atlas.getTextures(), fps);
			mtextureatlas=atlas;
			if(pivot)
			{
				pivotX=pivot.x;
				pivotY=pivot.y;
			}
		}
		private var mtween:Array;
		private var mpositon:uint;
		public function playTween(...tweens):void
		{
			if(tweens.length==0)
			{
				play();
			}
			else
			{
				mtween=tweens;
				mpositon=0;
				doTween();
			}
		}
		
		private function onComplete(e:Event):void
		{
			times--;
			if(!mtween ||mtween.length==0)
			{
				this.removeEventListener(Event.COMPLETE,onComplete);
				return;
			}
			if(times==0)
			{
				mpositon++;
				if(mpositon>=mtween.length)
					mpositon=0;
				doTween();
			}
		}
		private var times:int;
		private function doTween():void
		{
			var t:MCTween=mtween[mpositon];
			changeTextures(mtextureatlas.getTextures(t.name));
			times=t.loop;
			gotoAndPlay(0);
			if(times==0)
				play();
			else
				addEventListener(Event.COMPLETE,onComplete);
		}
		
	}
}