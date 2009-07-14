package org.ds.fsm
{
	import flash.events.Event;

	public class StateEvent extends Event
	{
		public function StateEvent(state:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(state, bubbles, cancelable);
		}
	}
}