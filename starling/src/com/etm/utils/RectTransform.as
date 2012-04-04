
package com.etm.utils
{

	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class RectTransform
	{
		/**
		 * gets a bounding box for a rotated rectangle
		 * @param rectangle
		 * @param angle
		 * @return
		 */
		public static function rotateRect(rectangle:Rectangle, angle:Number):Rectangle
		{

			var ct:Number=Math.cos(angle);
			var st:Number=Math.sin(angle);

			var hct:Number=rectangle.height * ct;
			var wct:Number=rectangle.width * ct;
			var hst:Number=rectangle.height * st;
			var wst:Number=rectangle.width * st;
			//trace(angle*180/Math.PI);
			if (angle > 0)
			{
				if (angle < Math.PI / 2)
				{
					//	trace("0 < angle < 90");
					// 0 < angle < 90
					var y_min:Number=rectangle.topLeft.y;
					var y_max:Number=rectangle.topLeft.y + hct + wst;
					var x_min:Number=rectangle.topLeft.x - hst;
					var x_max:Number=rectangle.topLeft.x + wct;
				}
				else
				{
					// 90 <= angle <= 180
					//	trace("// 90 <= angle <= 180");
					y_min=rectangle.topLeft.y + hct;
					y_max=rectangle.topLeft.y + wst;
					x_min=rectangle.topLeft.x - hst + wct;
					x_max=rectangle.topLeft.x;
				}
			}
			else
			{
				if (angle > -Math.PI / 2)
				{
					//	trace("-90 < angle <= 0");
					// -90 < angle <= 0
					y_min=rectangle.topLeft.y + wst;
					y_max=rectangle.topLeft.y + hct;
					x_min=rectangle.topLeft.x;
					x_max=rectangle.topLeft.x + wct - hst;
				}
				else
				{
					//	trace("-180 <= angle <= -90");
					// -180 <= angle <= -90
					y_min=rectangle.topLeft.y + wst + hct;
					y_max=rectangle.topLeft.y;
					x_min=rectangle.topLeft.x + hct;
					x_max=rectangle.topLeft.x - hst;
				}
			}
			return new Rectangle(x_min, y_min, x_max - x_min, y_max - y_min);
		}

		public static function scaleRect(rect:Rectangle, scaleX:Number=1, scaleY:Number=1):void
		{
			rect.x*=scaleX;
			rect.y*=scaleY;
			rect.width*=scaleX;
			rect.height*=scaleY;
		}

		/**
		 * determines the center point of a rectangle
		 * @param rect
		 * @return
		 */
		public static function rectCenter(rect:Rectangle):Point
		{
			return new Point(rect.x + (rect.right - rect.left) / 2, rect.y + (rect.bottom - rect.top) / 2);
		}
	}
}
