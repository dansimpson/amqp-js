package org.ds.amqp.connection
{
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	
	import org.ds.amqp.AMQP;
	import org.ds.amqp.transport.Buffer;
	import org.ds.amqp.transport.Frame;
	import org.ds.logging.Logger;

	public class Stream extends Socket
	{
		public function Stream(host:String=null, port:int=0)
		{
			super(host, port);

			
		}
		
		public function writeFrame(frame:Frame, channel:uint=0):void {
			writeByte(frame.type);
			writeShort(channel);
			writeUnsignedInt(frame.content.length);
            writeBytes(frame.content);
            writeByte(AMQP.FRAME_END);
            
            flush();
		}

		public function readFrame():Frame {
			
			var frame:Frame = new Frame();
			
			frame.type 	  = readUnsignedByte();
			frame.channel = readUnsignedShort();
			frame.content = readPayload();
			frame.valid   = readUnsignedByte() == AMQP.FRAME_END;
			
			return frame;
		}
		
		protected function readPayload():Buffer {
			var length:uint 	= readUnsignedInt();
			var payload:Buffer 	= new Buffer();
			
			if(length > 0) {
				readBytes(payload, 0, length);
			}
			
			return payload;
		}
		
		

				
	}
}