package com.etm.starling.display
{
	import com.etm.geom.InfiniteRectangle;
	
	import de.polygonal.ds.Array2;
	import de.polygonal.ds.pooling.DynamicObjectPool;
	import de.polygonal.ds.pooling.ObjectPool;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.display.Sprite;
	
	public class GridImage extends Sprite
	{
		private var _grid:Array2;
		private var _viewport:Rectangle;
		private var _offset:Point;
		private var _boundingRect:Rectangle;
		private var _grid_width:int;
		private var _grid_height:int;
		
		public function GridImage(grid:Array2,grid_width:int,grid_height:int,viewport:Rectangle, boundingRect:Rectangle=null,offset:Point=null)
		{
			super();
			_grid=grid;
			_grid_width=grid_width;
			_grid_height=grid_height;
			_viewport=viewport;
			_offset=offset;
			_boundingRect=boundingRect;
			_boundingRect||=InfiniteRectangle.FULL_RECT;
			_offset||=new Point();
			_offset.x=_boundingRect.x == Number.NEGATIVE_INFINITY ? 0 : _boundingRect.x;
			_offset.y=_boundingRect.y == Number.NEGATIVE_INFINITY ? 0 : _boundingRect.y;
			show(viewport);
		}
		public function show(viewport:Rectangle):void
		{
			var sx:int=getTx(viewport.x);
			var sy:int=getTy(viewport.y);
			var ex:int=getTx(viewport.x+viewport.width);
			var ey:int=getTy(viewport.y+viewport.height);
//			removeChildren();
			var ox:Number=sx*_grid_width-viewport.x;
			for(var i:int=sx;i<=ex;i++)
			{
				var oy:Number=sy*_grid_height-viewport.y;
				for(var j:int=sy;j<=ey;j++)
				{
					var lsi:LazyStreamImage=_grid.get(i,j) as LazyStreamImage;
					lsi.x=ox;
					lsi.y=oy;
					addChild(lsi);
					oy+=_grid_height;
				}
				ox+=_grid_width;
			}
		}
		private function getTx(ax:Number):int
		{
			return ax/_grid_width;
		}
		private function getTy(ay:Number):int
		{
			return ay/_grid_height;
		}
	}
}
