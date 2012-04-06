package starling.events
{
	public class StatusEvent extends Event
	{
		public static const START:String="starling_start";
		public static const STOP:String="starling_stop";
		
		public function StatusEvent(type:String, bubbles:Boolean = false)
		{
			super(type, bubbles);
		}
		
	}
}