package com.etm.starling.display
{
	import com.etm.utils.*;

	import flash.geom.Point;
	import flash.geom.Rectangle;

	import starling.display.Image;
	import starling.textures.SubTexture;
	import starling.textures.Texture;

	/**
	 * An Image that stretches the texture to fit the required size.
	 *
	 */
	public class StretchImage extends LargeImage
	{

		/**
		 * An Image that stretches the texture to fit the required size.
		 * @param texture  A texture that will be stretched
		 * @param boundingRect  Where the image should be displayed.
		 * @param viewport the initial viewable area of the image
		 * @param trimTexture how much of the texture to trim to solve for UV imprecision issues with thin textures.
		 */
		public function StretchImage(texture:Texture, boundingRect:Rectangle=null, viewport:Rectangle=null, trimTexture:uint=0):void
		{
			//very thin textures frequently have blurry edges due to precision issues with UV.  Trimming a pixel off each side can overcome the issue.
			var trimTextureW:uint=Math.floor(DigitalUtil.clamp(trimTexture, 0, Math.floor((texture.width - 1) / 2)));
			var trimTextureH:uint=Math.floor(DigitalUtil.clamp(trimTexture, 0, Math.floor((texture.height - 1) / 2)));
			var r:Rectangle=new Rectangle(0, 0, texture.width, texture.height);
			r.inflate(-trimTextureW, -trimTextureH);
			texture=new SubTexture(texture, r);

			super(texture, boundingRect, viewport);
			_uPerPixel=1 / boundingRect.width;
			_vPerPixel=1 / boundingRect.height;
		}

		protected override function buildTextureCoords(drawArea:Rectangle):void
		{

			if (!isOnScreen)
				return;

			var left:Number=_boundingRect.width == Number.POSITIVE_INFINITY ? 0 : (drawArea.left - _boundingRect.left) * _uPerPixel;
			var right:Number=_boundingRect.width == Number.POSITIVE_INFINITY ? 1 : left + drawArea.width * _uPerPixel;
			var top:Number=_boundingRect.height == Number.POSITIVE_INFINITY ? 0 : (drawArea.top - _boundingRect.top) * _vPerPixel;
			var bottom:Number=_boundingRect.height == Number.POSITIVE_INFINITY ? 1 : top + drawArea.height * _vPerPixel;

			mVertexData.setTexCoords(0, left, top);
			mVertexData.setTexCoords(1, right, top);
			mVertexData.setTexCoords(2, left, bottom);
			mVertexData.setTexCoords(3, right, bottom);
		}
	}
}
