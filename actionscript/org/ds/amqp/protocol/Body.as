package org.ds.amqp.protocol
{
	// import com.adobe.serialization.json.JSON;
	import com.brokenfunction.json.decodeJson;
	import com.brokenfunction.json.encodeJson;
	
	import org.ds.amqp.AMQP;
	import org.ds.amqp.transport.Buffer;
	import org.ds.logging.Logger;
	
	
	public class Body extends Payload
	{
		protected var _data:String;
		
		public function Body()
		{
			_type = AMQP.FRAME_BODY;
		}
		
		public override function serialize():Buffer {
			var buffer	:Buffer = new Buffer();
			buffer.writeUTFBytes(_data);
			return buffer;
		}
		
		public function deserialize(buf:Buffer):void {
			_data = buf.readUTFBytes(buf.length);
		}
		
		public function get data():* {
			// return JSON.decode(_data);
			// return JSON.parse(_data);
			return decodeJson(_data);
		}
		
		public function set data(data:*):void {
			// _data = JSON.encode(data);
			// _data = JSON.stringify(data);
			_data = encodeJson(data);
		}
		
		public function get length():uint {
			return _data.length;
		}
		
		public override function print():void {
			printObj("Data", _data);
		}
	}
}