package org.ds.amqp.events
{
	import flash.events.Event;
	
	import org.ds.amqp.transport.Transmission;

	public class TransmissionEvent extends Event
	{
		public var instance:Transmission;
		
		public function TransmissionEvent(transmission:Transmission)
		{
			instance = transmission;
			super(transmission.method.toString(), bubbles, cancelable);
		}
		
	}
}