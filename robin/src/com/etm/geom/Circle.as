package com.etm.geom
{
	import flash.geom.Point;

	public class Circle
	{
		public var center:Point;
		public var radius:Number;

		public function Circle(x:Number=0, y:Number=0, r:Number=0)
		{
			center=new Point(x, y);
			radius=r;
		}

		public function containPoint(p:Point):Boolean
		{
			return p.subtract(center).length <= radius;
		}

		public function moveTo(x:int, y:int):void
		{
			center.x=x;
			center.y=y;
		}

		public function interact(bounds:Circle):Boolean
		{
			var distance:Number=center.subtract(bounds.center).length;
			if (distance < (radius + bounds.radius))
				return true;
			else
				return false;
		}
	}
}
