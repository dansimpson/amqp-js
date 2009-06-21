/**
---------------------------------------------------------------------------

Copyright (c) 2009 Dan Simpson

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

---------------------------------------------------------------------------
**/

package org.ds.amqp.transport
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	import org.ds.amqp.AMQP;
	import org.ds.amqp.protocol.MessageClass;
	import org.ds.amqp.protocol.Method;
	
	public class Frame
	{
		public		var type	:int 		= AMQP.FRAME_METHOD;
		public		var channel	:int 	 	= 0;
		public 		var payload	:Buffer	 	= null;
		public		var valid	:Boolean	= true;
		public		var length	:uint		= 0;
		
		public function Frame(payload:Buffer=null, channel:int=0)
		{
			this.payload = payload;
			this.channel = channel;
		}

		public function encode(stream:IDataOutput):void {
            stream.writeByte(type);
            stream.writeShort(channel);
            stream.writeUnsignedInt(payload.length);
            stream.writeBytes(payload);
            stream.writeByte(AMQP.FRAME_END);
		}
		
		
		public function decode(stream:IDataInput):Boolean {
			
			type 	= stream.readUnsignedByte();
			channel = stream.readUnsignedShort();
			
			//grab the payload
			payload = new Buffer();
			length	= stream.readInt();
			
			if(length > 0) {
				stream.readBytes(payload, 0, length);
			}
			
			//make sure we did everything correctly (not 100% accurate)
			return valid = (stream.readUnsignedByte() == AMQP.FRAME_END);
		}
		
		
		//extracts the appropriate Method class from the frame
		public function get method():Method {
			if(payload != null && payload.length > 0) {
				var instance:MessageClass = AMQP.getClass(payload.readUnsignedShort());
				if(instance) {
					var method:Method = instance.getMethod(payload.readUnsignedShort());
					method.readFrom(payload);
					return method;
				}
			}
			return null;
		}
		
		//just a class helper
		public static function decode(stream:IDataInput):Frame {
			var frame:Frame = new Frame();
			frame.decode(stream);
			return frame;	
		}
	}
}