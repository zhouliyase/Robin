package com.etm.utils
{

	public class AngleUtil
	{
		/**
		 * Given two angles, return the short angle amount that would make it equal the target
		 * @param value start angle
		 * @param rotation target angle
		 * @return
		 */
		public static function angleModulus(value:Number, rotation:Number):Number
		{
			while (value < -Math.PI)
				value+=Math.PI * 2;
			while (value > Math.PI)
				value-=Math.PI * 2;

			return (value * rotation) < 0 && Math.abs(value - rotation) > Math.PI ? value + Math.PI * 2 * ((rotation > 0) ? 1 : -1) : value;

		}
	}
}
