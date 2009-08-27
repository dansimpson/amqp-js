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
	import org.ds.amqp.transport.Buffer;
	import org.ds.logging.Logger;
	
	public dynamic class Payload
	{
		
		protected var _type:int = 0;
		
		public function Payload()
		{
		}
				
		public function serialize():Buffer {
			return null;
		}
			
		public function print():void {
		}
		
		public function printObj(name:String, obj:Object):void {
			var msg:String = "--- Begin " + name + " ---\n";
			
			if(obj is String) {
				msg += obj + "\n";
			} else {
				for(var k:* in obj) {
					msg += k + " = " + obj[k] + ";\n";
				}
			}
			msg += "---- End " + name + " ----\n";
			
			Logger.debug(msg);
		}
	
		public function get frameType():int {
			return _type;
		}
	}
}