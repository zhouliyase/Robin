package com.etm.starling.texture
{
	import flash.geom.Point;
	import flash.system.ApplicationDomain;
	
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

		public function get textureAtlas():TextureAtlas
		{
			return _textureAtlas;
		}
	}
}