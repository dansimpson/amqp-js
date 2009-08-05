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

package org.ds.amqp.protocol
{
	import org.ds.amqp.AMQP;
	import org.ds.amqp.transport.Buffer;
	
	public class Method extends Payload
	{
		
		protected var _classId		:int 		= -1;
		protected var _methodId		:int 		= -1;
		protected var _content		:Boolean 	= false;
		protected var _synchronous	:Boolean 	= false;
		protected var _responses	:Array		= [];
		
		public function Method() {
			_type = AMQP.FRAME_METHOD;
		}
		
		public function writeArguments(buffer:Buffer):void {	
		}
		
		public function readArguments(buffer:Buffer):void {
		}
		
		public override function serialize():Buffer {
			var buffer:Buffer = new Buffer();
			buffer.writeShort(_classId);
			buffer.writeShort(_methodId);
			writeArguments(buffer);
			buffer.flush();
			return buffer;
		}
		
		public function deserialize(buffer:Buffer):void {
			buffer.position = 0;
			buffer.readShort();
			buffer.readShort();
			readArguments(buffer);
		}		
				
		public function toString():String {
			 return _classId + "/" + _methodId;
		}
		
		public function get hasContent():Boolean {
			return _content;
		}
	}
}