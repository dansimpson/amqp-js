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
	import org.ds.amqp.connection.Connection;
	import org.ds.amqp.diagnostics.Logger;
	import org.ds.amqp.transport.Buffer;
	import org.ds.amqp.transport.Frame;
	
	public class Method
	{
		
		protected var _classId	:int = -1;
		protected var _methodId	:int = -1;
		
		public function Method()
		{
		}

		public function get payload():Buffer {
			
			var buffer:Buffer = new Buffer();
			
			buffer.writeShort(_classId);
			buffer.writeShort(_methodId);
			
			writeTo(buffer);
			
			return buffer;
		}
		
		public function writeTo(buf:Buffer):void {	
		}
		
		public function readFrom(buf:Buffer):void {
		}
		
		
		public function send(c:org.ds.amqp.connection.Connection):void {
			c.send(toFrame());
		}
		
		public function toFrame():Frame {
			return new Frame(payload);
			
		}
		
		public function toString():String {
			 return _classId + "/" + _methodId;
		}
		
		public function print():void {
			for(var k:* in this) {
				Logger.log(k as String, this[k] as String);
			}
			
		}
	}
}