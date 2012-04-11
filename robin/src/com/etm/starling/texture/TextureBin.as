package com.etm.starling.texture
{
	import avmplus.getQualifiedClassName;
	
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.filters.BitmapFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	public class TextureBin
	{
		private var pivotPoint:Point;
		private var origin:BitmapData;
		private var processedTextrueAtlas:Dictionary;
		private var config:XML;
		public function TextureBin(content:Object)
		{
			origin=content.texture.clone();
			config=new XML(content.config);
			pivotPoint=new Point(parseInt(config.@pivotX),parseInt(config.@pivotY));
			processedTextrueAtlas=new Dictionary();
		}
		public function getPivotPoint():Point
		{
			return pivotPoint;
		}
		public function dispose():void
		{
			origin.dispose();
			origin=null;
		}
		public function getTextures(prefix:String="",lables:Vector.<String>=null):Vector.<Texture>
		{
			var ta:TextureAtlas=processedTextrueAtlas["origin"];
			if(ta)
				return ta.getTextures(prefix,lables);
			if(!origin)
				throw new Error("The original source is disposed.");
			var o:BitmapData=origin.clone();
			ta=new TextureAtlas(Texture.fromBitmapData(o),config);
			processedTextrueAtlas["origin"]=ta;
			return ta.getTextures(prefix,lables);
		}
		public function getColorTransformTextures(colorTransform:ColorTransform,prefix:String="",lables:Vector.<String>=null,cache:Boolean=true):Vector.<Texture>
		{
			var ta:TextureAtlas=processedTextrueAtlas[colorTransform.toString()];
			if(ta)
				return ta.getTextures(prefix,lables);
			
			if(!origin)
				throw new Error("The original source is disposed.");
			var color:BitmapData=origin.clone();
			color.colorTransform(color.rect,colorTransform);
			ta=new TextureAtlas(Texture.fromBitmapData(color),config);
			if(cache)
				processedTextrueAtlas[colorTransform.toString()]=ta;
			return ta.getTextures(prefix,lables);
		}
		//TODO not tested
		public function getFilterTextures(filter:BitmapFilter,prefix:String="",lables:Vector.<String>=null,cache:Boolean=true):Vector.<Texture>
		{
			var type:String=getQualifiedClassName(filter);
			var ta:TextureAtlas=processedTextrueAtlas[type];
			if(ta)
				return ta.getTextures(prefix,lables);
			
			if(!origin)
				throw new Error("The original source is disposed.");
			var bfrect:Rectangle=origin.generateFilterRect(origin.rect,filter);
			var bf:BitmapData=new BitmapData(bfrect.width,bfrect.height);
			bf.applyFilter(origin,origin.rect,new Point(-bfrect.x,-bfrect.y),filter);
			ta=new TextureAtlas(Texture.fromBitmapData(bf),config);
			if(cache)
				processedTextrueAtlas[type]=ta;
			return ta.getTextures(prefix,lables);
		}
	}
}