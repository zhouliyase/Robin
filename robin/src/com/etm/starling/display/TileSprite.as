package com.etm.starling.display
{

	import com.etm.geom.InfiniteRectangle;
	import com.etm.utils.*;

	import de.polygonal.ds.pooling.DynamicObjectPool;

	import flash.geom.Point;
	import flash.geom.Rectangle;

	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.textures.Texture;

	/**
	 * An image that uses a Vector.<Texture> to create a composite image which is then tileable along at least one axis.
	 *
	 */
	public class TileSprite extends Sprite
	{
		public static const X_AXIS:String="x_axis";
		public static const Y_AXIS:String="y_axis";

		private var _boundingRect:Rectangle;
		private var _tilePool:DynamicObjectPool;
		private var _factory:compositeImageFactory;
		private var _offset:Point;
		private var _tileX:Boolean;
		private var _tileY:Boolean;
		private var _tileH:uint;
		private var _tileW:uint;
		private var _tileCountX:uint=0;
		private var _tileCountY:uint=0;

		/**
		 * The size of a single composite tile.
		 * @return
		 */
		public function get tileWidth():uint
		{
			return _tileW;
		}

		public function get tileHeight():uint
		{
			return _tileH;
		}

		public override function get width():Number
		{
			return _tileW * _tileCountX;
		}

		/**
		 * An image that uses a Vector.<Texture> to create a composite image which is then tileable along at least one axis.
		 * @param textures Vector.<Texture> holding textures that will be linked along an axis to make a composite texture.
		 * @param boundingRect Where the image should be displayed.
		 * @param viewport the initial viewable area of the image
		 * @param offset the upper left corner of the composite tile.
		 * @param tileAxis Indicates which axes are able to scroll.  Use com.byxb.geom.Tiling for axis constants
		 */
		public function TileSprite(textures:Vector.<Texture>, boundingRect:Rectangle=null, viewport:Rectangle=null, offset:Point=null, tileAxis:String=X_AXIS)
		{
			super();
			_boundingRect=boundingRect;
			_boundingRect||=InfiniteRectangle.FULL_RECT;
			_factory=new compositeImageFactory(textures);
			_tilePool=new DynamicObjectPool(null, null, _factory);
			_tileX=tileAxis == X_AXIS ? true : false;
			_tileY=tileAxis == Y_AXIS ? true : false;
			var ci:CompositeImage=_tilePool.get() as CompositeImage;
			_tileW=ci.width;
			_tileH=ci.height;
			_tilePool.reclaim();
			_offset=offset;
			_offset||=new Point();
			_offset.x=_boundingRect.x == Number.NEGATIVE_INFINITY ? 0 : _boundingRect.x;
			_offset.y=_boundingRect.y == Number.NEGATIVE_INFINITY ? 0 : _boundingRect.y;
			show(viewport);
		}

		/**
		 * Sets the visible area of the image and builds as many tiles as needed.
		 * @param viewport
		 * @param offset
		 */
		public function show(viewport:Rectangle, offset:Point=null):void
		{
			offset||=new Point();
			if (!viewport)
			{
				this.addChild(_tilePool.get() as DisplayObject);
				return;
			}

			var xTilesNeeded:uint=_tileX ? getTileCount(_tileW, viewport.width) : 1;
			var yTilesNeeded:uint=_tileY ? getTileCount(_tileH, viewport.height) : 1;
			if (_tileCountX + _tileCountY == 0)
			{
				for (var j:uint=0; j < xTilesNeeded; j++)
				{
					for (var i:uint=0; i < yTilesNeeded; i++)
					{

						buildTile(j, i);

					}
				}
				_tileCountX=xTilesNeeded;
				_tileCountY=yTilesNeeded;
			}

			while (_tileCountX < xTilesNeeded)
			{
				for (i=0; i < _tileCountY; i++)
				{
					buildTile(_tileCountX, i);
				}
				_tileCountX++
			}

			while (_tileCountY < yTilesNeeded)
			{
				for (i=0; i < _tileCountX; i++)
				{
					buildTile(i, _tileCountY);
				}
				_tileCountY++
			}
		}

		private function getTileCount(tileSide:Number, coverRange:Number):uint
		{
			return Math.ceil((coverRange) / tileSide) + 1;
		}

		/**
		 * pulls a tile from a pool of tiles.
		 * @param col
		 * @param row
		 */
		private function buildTile(col:uint, row:uint):void
		{
			var ci:CompositeImage=_tilePool.get() as CompositeImage;
			ci.x=_offset.x + col * _tileW;
			ci.y=_offset.y + row * _tileH;
			ci.touchable=false;
			addChild(ci)
		}

		public override function dispose():void
		{
			_tilePool.free();
		}
	}

}
import com.etm.starling.display.CompositeImage;

import de.polygonal.ds.Factory;

import starling.textures.Texture;

/**
 * builds the pool elements
 *
 */
internal class compositeImageFactory implements Factory
{
	private var _textures:Vector.<Texture>;


	public function compositeImageFactory(textures:Vector.<Texture>)
	{
		_textures=textures;
	}

	/**
	 * creates a new Composite image for the pool manager.
	 * @return
	 */
	public function create():Object
	{
		return new CompositeImage(_textures);
	}
}
