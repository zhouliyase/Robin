package com.etm.starling.display
{

	import com.etm.utils.*;

	import flash.geom.Point;
	import flash.geom.Rectangle;

	import starling.textures.SubTexture;
	import starling.textures.Texture;

	/**
	 * A large image that loops the texture using UV.
	 *
	 */
	public class ScrollImage extends LargeImage
	{

		private var _texturePosition:Point;
		private var _textureOffset:Point;

		/**
		 * A large image that loops the texture using UV.
		 * @param texture  A texture that tiles along one or bothe axes and fills the texture on that dimension.
		 * @param tileAxis Indicates which axes are able to scroll.  Use com.byxb.geom.Tiling for axis constants
		 * @param boundingRect Where the image should be displayed.
		 * @param textureOffset how much to move the texture.  Expressed in pixels and converted to UV
		 * @param viewport the initial viewable area of the image
		 * @throws Error
		 */
		public function ScrollImage(texture:Texture, boundingRect:Rectangle=null, textureOffset:Point=null, viewport:Rectangle=null):void
		{
			texture.repeat=true;
			if (textureOffset)
			{
				textureOffset.x*=-1;
				textureOffset.y*=-1;
				_textureOffset=textureOffset;
			}
			else
			{
				_textureOffset=new Point();
			}
			_texturePosition=new Point();
			super(texture, boundingRect, viewport);
			if (texture is SubTexture)
			{
				throw new Error("Sub Textures can't be used for ScrollImage.  You may want to try StretchImage.");
			}
		}

		/**
		 * update the UV data to scroll the iamge
		 * @param point
		 * @param viewport
		 */
		public function scrollTo(point:Point=null, viewport:Rectangle=null):void
		{
			if (point)
			{
				_texturePosition=point;
			}
			show(viewport);
		}

		protected override function buildTextureCoords(drawArea:Rectangle):void
		{
			var left:Number=(drawArea.left + _texturePosition.x + _textureOffset.x) * _uPerPixel;
			var right:Number=(drawArea.right + _texturePosition.x + _textureOffset.x) * _uPerPixel;
			var top:Number=(drawArea.top + _texturePosition.y + _textureOffset.y) * _vPerPixel;
			var bottom:Number=(drawArea.bottom + _texturePosition.y + _textureOffset.y) * _vPerPixel;

			mVertexData.setTexCoords(0, left, top);
			mVertexData.setTexCoords(1, right, top);
			mVertexData.setTexCoords(2, left, bottom);
			mVertexData.setTexCoords(3, right, bottom);
		}

	}
}
