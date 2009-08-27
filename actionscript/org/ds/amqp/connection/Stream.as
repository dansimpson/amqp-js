package org.ds.amqp.connection
{
	import flash.net.Socket;
	
	import org.ds.amqp.AMQP;
	import org.ds.amqp.protocol.channel.ChannelOpen;
	import org.ds.amqp.transport.Buffer;
	import org.ds.amqp.transport.Frame;
	import org.ds.logging.Logger;

	public class Stream extends Socket
	{
		private var channels:* = {
			current	: 0,
			count	: 0
		};
		
		public function Stream(host:String=null, port:int=0)
		{
			super(host, port);
		}
		
		protected function get channel():uint {
			return channels.count > 0 ? channels.current : 0;
		}
		
		public function openChannels(count:int):void {
			Logger.info("Opening Channels");
			
			channels.count = count;
			for(var i:int = 1;i <= count;i++) {
				channels.current = i;
				writeFrame(new Frame(new ChannelOpen()));
				flush();
			}
		}

		public function writeFrame(frame:Frame):void {
			
			if(frame.payload && Logger.debugging) {
				frame.payload.print();
			}
			
			writeByte(frame.type);
			writeShort(channel);
			writeUnsignedInt(frame.content.length);
            writeBytes(frame.content);
            writeByte(AMQP.FRAME_END);
		}

		public function readFrame():Frame {
			
			var frame:Frame = new Frame();
			
			frame.type 	  = readUnsignedByte();
			frame.channel = readUnsignedShort();
			frame.content = readPayload();
			frame.valid   = readUnsignedByte() == AMQP.FRAME_END;
			
			return frame;
		}
		
		public function readPayload():Buffer {
			var length:uint 	= readUnsignedInt();
			var payload:Buffer 	= new Buffer();
			
			if(length > 0) {
				readBytes(payload, 0, length);
			}
			
			return payload;
		}
				
	}
}