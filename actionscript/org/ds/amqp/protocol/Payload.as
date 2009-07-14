package org.ds.amqp.protocol
{
	import org.ds.amqp.transport.Buffer;
	import org.ds.logging.Logger;
	
	public class Payload
	{
		
		protected var _type:int = 0;
		
		public function Payload()
		{
		}
				
		public function serialize():Buffer {
			return null;
		}
			
		public function print():void {
		}
	
		public function get frameType():int {
			return _type;
		}
	}
}