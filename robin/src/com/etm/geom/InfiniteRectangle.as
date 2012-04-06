package com.etm.geom
{

	import com.etm.utils.DigitalUtil;

	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * An extension of Rectangle that allows for x, y, width and height to be infinite
	 *
	 */
	public class InfiniteRectangle extends Rectangle
	{
		/**
		 * a fully infinite rectangle
		 * @return
		 */
		public static function get FULL_RECT():InfiniteRectangle
		{
			return new InfiniteRectangle(Number.NEGATIVE_INFINITY, Number.NEGATIVE_INFINITY, Number.POSITIVE_INFINITY, Number.POSITIVE_INFINITY);
		}

		/**
		 * An extension of Rectangle that allows for x, y, width and height to be infinite
		 * @param x X postion
		 * @param y Y position
		 * @param width the width of the rectangle
		 * @param height the height of the rectangle
		 */
		public function InfiniteRectangle(x:Number=0, y:Number=0, width:Number=0, height:Number=0)
		{
			super(x, y, width, height);
		}

		public override function intersection(toIntersect:Rectangle):Rectangle
		{
			var l:Number=DigitalUtil.clamp(toIntersect.left, this.left, this.right);
			var r:Number=DigitalUtil.clamp(toIntersect.right, this.left, this.right);
			var t:Number=DigitalUtil.clamp(toIntersect.top, this.top, this.bottom);
			var b:Number=DigitalUtil.clamp(toIntersect.bottom, this.top, this.bottom);

			if (t >= b || l >= r) // don't bother rendering if the texture is off screen
			{
				return new InfiniteRectangle();
			}
			else
			{
				return new InfiniteRectangle(l, t, r - l, b - t);
			}
		}

		public override function clone():Rectangle
		{
			return new InfiniteRectangle(this.x, this.y, this.width, this.height);
		}

		public override function get right():Number
		{
			return this.left == Number.NEGATIVE_INFINITY ? this.width : super.right;
		}

		public override function get bottom():Number
		{
			return this.top == Number.NEGATIVE_INFINITY ? this.height : super.bottom;
		}

		public override function get bottomRight():Point
		{
			return new Point(this.bottom, this.right);
		}

		public override function get size():Point
		{
			return new Point(this.width, this.height);
		}
	}
}

