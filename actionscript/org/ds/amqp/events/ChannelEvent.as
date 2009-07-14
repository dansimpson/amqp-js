package org.ds.amqp.events
{
	import flash.events.Event;

	public class ChannelEvent extends Event
	{
		public static var OPEN:String = "CHANNEL_OPEN";
		
		public function ChannelEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}