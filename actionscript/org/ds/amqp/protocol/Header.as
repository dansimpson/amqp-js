package org.ds.amqp.protocol
{
	import org.ds.amqp.AMQP;
	import org.ds.amqp.transport.Buffer;
	
	
	public class Header extends Payload
	{
		protected var _classId:int = -1;
		public var bodySize:uint = 0;
		
		public function Header()
		{
			_type = AMQP.FRAME_HEADER;
		}
		
		public function writeProperties(buffer:Buffer):void {	
		}
		
		public function readProperties(buffer:Buffer):void {
		}
		
		public override function serialize():Buffer {
			
			var buffer:Buffer = new Buffer();
			buffer.writeShort(_classId);
			buffer.writeShort(0); //weight
			
			//body size - long
			buffer.writeUnsignedInt(0);
			buffer.writeUnsignedInt(bodySize);
			
			//property flags
			buffer.writeFlag();
			
			writeProperties(buffer);
			
			buffer.flush();
			
			return buffer;
		}
		
		public function deserialize(buffer:Buffer):void {
			buffer.readShort(); //weight
			
			//body size
			buffer.readUnsignedInt(); 
			bodySize = buffer.readUnsignedInt();

			//property flags
			buffer.readFlag(); 
			
			readProperties(buffer);
		}

	}
}