package org.ds.amqp.protocol
{
	import org.ds.amqp.AMQP;
	import org.ds.amqp.transport.Buffer;
	
	
	public class Body extends Payload
	{
		protected var _data:String;
		
		public function Body()
		{
			_type = AMQP.FRAME_BODY;
		}
		
		public override function serialize():Buffer {
			var buffer:Buffer = new Buffer();
			buffer.writeUTFBytes(_data);
			return buffer;
		}
		
		public function deserialize(buf:Buffer):void {
			_data = buf.readUTFBytes(buf.length);
		}
		
		public function get data():String {
			return _data;
		}
	}
}