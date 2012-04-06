package com.etm.starling.display
{

	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;

	/**
	 * Takes multiple textures and adds them to the sprite.  Connects on X or Y axis.
	 * Useful for cases of re-joining a large textue.
	 *
	 */
	public class CompositeImage extends Sprite
	{
		/**
		 *
		 * @param textures a Vector.<Texture> containin the various images to be linked
		 * @param linkAxis axis value to use for linking.  Use com.byxb.Tiling for values.
		 */
		public function CompositeImage(textures:Vector.<Texture>, linkAxis:String="x_axis")
		{
			super();
			var d:uint=0;
			for each (var texture:Texture in textures)
			{
				var img:Image=new Image(texture);
				if (linkAxis == TileSprite.X_AXIS)
				{
					img.x=d;
					d+=texture.frame ? texture.frame.width : texture.width;
				}
				else
				{
					img.y=d;
					d+=texture.frame ? texture.frame.height : texture.height;
				}
				addChild(img)
			}
			this.flatten();
		}
	}
}
