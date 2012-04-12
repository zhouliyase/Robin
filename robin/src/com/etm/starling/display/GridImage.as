package com.etm.starling.display
{
	import com.etm.geom.InfiniteRectangle;
	
	import de.polygonal.ds.Array2;
	
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
				
		}
		private function getTx(ax:Number):int
		{
			
		}
		private function getTy(ay:Number):int
		{
			
		}
	}
}