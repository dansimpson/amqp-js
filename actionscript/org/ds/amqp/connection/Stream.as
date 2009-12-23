package org.ds.amqp.connection
{
	import flash.net.Socket;
	
	import org.ds.amqp.AMQP;
	import org.ds.amqp.transport.Buffer;
	import org.ds.amqp.transport.Frame;

	public class Stream extends Socket
	{
		/*
		 * used for aggregating chunked data
		 */
		private var frame	:Frame  = null;
		private var buffer	:Buffer = null;
		
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
			
			if(frame == null) {
				frame = new Frame();
			}
			
			/*
			 * read the important header fields of the frame
			 * along with the payload size
			 */
			if(!frame.headerComplete) {
				frame.type 	   			= readUnsignedByte();
				frame.channel  			= readUnsignedShort();
				frame.contentSize		= readUnsignedInt();
				frame.headerComplete	= true;
			}
			
			if(buffer == null) {
				buffer = new Buffer();
			}

			if(frame.contentSize > 0 && buffer.length < frame.contentSize) {
				readBytes(buffer, buffer.length, Math.min(bytesAvailable, frame.contentSize - buffer.length));
				
				if(frame.contentSize == buffer.length) {
					frame.content 		  = buffer;
					frame.contentComplete = true;
				}
			}
			
			if(bytesAvailable > 0) {
				frame.valid = readUnsignedByte() == AMQP.FRAME_END;
				
				if(!frame.valid) {
					throw new Error("Invalid Frame!");
				}
			}
			
			if(frame.contentComplete && frame.valid) {
				
				var dup:Frame = frame;
				
				frame 	= null;
				buffer 	= null;
				
				return dup;
				
			}
			
			return null;
		}				
	}
}