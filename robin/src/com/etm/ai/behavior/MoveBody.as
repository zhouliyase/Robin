package com.etm.ai.behavior
{
	import com.etm.geom.Vector2D;

	/**
	 * Base class for moving characters.
	 */
	public class MoveBody
	{
		protected var _edgeBehavior:String=WRAP;
		protected var _mass:Number=1.0;
		protected var _maxSpeed:Number=5;
		protected var _position:Vector2D;
		protected var _velocity:Vector2D;
		protected var _x:Number;
		protected var _y:Number;
		protected var _heading:Number;

		// potential edge behaviors
		public static const WRAP:String="wrap";
		public static const BOUNCE:String="bounce";

		/**
		 * Constructor.
		 */
		public function MoveBody()
		{
			_position=new Vector2D();
			_velocity=new Vector2D();
		}


		/**
		 * Handles all basic motion. Should be called on each frame / timer interval.
		 */
		public function update(dt:Number):void
		{
			// make sure velocity stays within max speed.
			_velocity.truncate(_maxSpeed);

			// add velocity to position
			_position=_position.add(_velocity);

			// handle any edge behavior
			bounce();

			// update position of sprite
			x=position.x;
			y=position.y;
			// rotate heading to match velocity
			_heading=_velocity.angle;
		}

		/**
		 * Causes character to bounce off edge if edge is hit.
		 */
		private function bounce():void
		{
			if (position.x > 1200)
			{
				position.x=1200;
				velocity.x*=-1;
			}
			else if (position.x < 0)
			{
				position.x=0;
				velocity.x*=-1;
			}

			if (position.y > 600)
			{
				position.y=600;
				velocity.y*=-1;
			}
			else if (position.y < 0)
			{
				position.y=0;
				velocity.y*=-1;
			}
		}

		/**
		 * Sets / gets what will happen if character hits edge.
		 */
		public function set edgeBehavior(value:String):void
		{
			_edgeBehavior=value;
		}

		public function get edgeBehavior():String
		{
			return _edgeBehavior;
		}

		/**
		 * Sets / gets mass of character.
		 */
		public function set mass(value:Number):void
		{
			_mass=value;
		}

		public function get mass():Number
		{
			return _mass;
		}

		/**
		 * Sets / gets maximum speed of character.
		 */
		public function set maxSpeed(value:Number):void
		{
			_maxSpeed=value;
		}

		public function get maxSpeed():Number
		{
			return _maxSpeed;
		}

		/**
		 * Sets / gets position of character as a Vector2D.
		 */
		public function set position(value:Vector2D):void
		{
			_position=value;
			x=_position.x;
			y=_position.y;
		}

		public function get position():Vector2D
		{
			return _position;
		}

		/**
		 * Sets / gets velocity of character as a Vector2D.
		 */
		public function set velocity(value:Vector2D):void
		{
			_velocity=value;
		}

		public function get velocity():Vector2D
		{
			return _velocity;
		}

		/**
		 * Sets x position of character. Overrides Sprite.x to set internal Vector2D position as well.
		 */
		public function set x(value:Number):void
		{
			_x=value;
			_position.x=_x;
		}

		/**
		 * Sets y position of character. Overrides Sprite.y to set internal Vector2D position as well.
		 */
		public function set y(value:Number):void
		{
			_y=value;
			_position.y=_y;
		}

		public function get x():Number
		{
			return _x;
		}

		public function get y():Number
		{
			return _y;
		}

	}
}
