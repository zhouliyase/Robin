package com.etm.starling.texture
{
	import flash.geom.Point;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	public class TextureBin
	{
		private var _textureAtlas:TextureAtlas;
		private var pivotPoint:Object;
		public function TextureBin(obj:Object)
		{
			_textureAtlas=new TextureAtlas(Texture.fromBitmapData(obj.texture),obj.config);
			pivotPoint=obj.registers;
		}
		public function getPivotPoint(prefix:String=""):Point
		{
			if(pivotPoint[prefix])
				return pivotPoint[prefix];
			else
				return pivotPoint["#global#"];
		}
		public function getTextures(prefix:String="",lables:Vector.<String>=null):Vector.<Texture>
		{
			return _textureAtlas.getTextures(prefix,lables);
		}
		
		public function get textureAtlas():TextureAtlas
		{
			return _textureAtlas;
		}
	}
}