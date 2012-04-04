package com.etm.utils
{

	public class DigitalUtil
	{
		/**
		 * tests a number against a range and if out of range, locks to the closest extreme
		 * @param value test value
		 * @param min
		 * @param max
		 * @return
		 */
		public static function clamp(value:Number, min:Number, max:Number):Number
		{
			return Math.max(min, Math.min(max, value));
		}

		/**
		 * returns whether or not a is equa to be within a specified tolerance
		 * @param a
		 * @param b
		 * @param tolerance
		 * @return
		 */
		public static function nearEquals(a:Number, b:Number, tolerance:Number=.1):Boolean
		{
			return Math.abs(a - b) < tolerance;
		}

		/**
		 * return a value between a and b according to the proportion of hte ratio
		 * @param a
		 * @param b
		 * @param ratio
		 * @return
		 */
		public static function interpolate(a:Number, b:Number, ratio:Number=.5):Number
		{
			return a * (1 - ratio) + b * ratio;
		}
	}
}
