package org.ds.amqp.connection
{

	public class Channel
	{
		private var _number	:uint 	= 0;
		private var _queue	:Array 	= [];
		
		public function Channel(number:uint)
		{
			_number = number;
		}
		
		public function send(data:*):void {

		}
		
		public function receive(data:*):void {
			
		}

	}
}