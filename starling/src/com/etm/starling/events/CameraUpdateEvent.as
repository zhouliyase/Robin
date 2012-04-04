package com.etm.starling.events
{

	import flash.geom.Rectangle;

	import starling.events.Event;

	/**
	 * An Event that is dispatched by CameraSprite to indicate that it has updated
	 * @author Justin Church  - Justin [at] byxb [dot] com
	 *
	 */
	public class CameraUpdateEvent extends Event
	{

		/**
		 * Event type - "cameraUpdate";
		 */
		public static const CAMERA_UPDATE:String="cameraUpdate";
		/**
		 * The viewport that is now visible post-move.
		 */
		public var viewport:Rectangle;

		/**
		 * An Event that is dispatched by CameraSprite to indicate that it has updated
		 * @param viewport
		 * @param bubbles
		 */
		public function CameraUpdateEvent(viewport:Rectangle, bubbles:Boolean=false)
		{
			this.viewport=viewport;
			super(CAMERA_UPDATE, bubbles);
		}
	}
}
