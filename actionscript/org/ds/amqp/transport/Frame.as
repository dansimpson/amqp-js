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
	import org.ds.amqp.AMQP;
	import org.ds.amqp.protocol.Body;
	import org.ds.amqp.protocol.Header;
	import org.ds.amqp.protocol.Method;
	import org.ds.amqp.protocol.Payload;

	public class Frame
	{
		public		var contentComplete	:Boolean	= false;
		public		var headerComplete	:Boolean	= false;
		public		var contentSize		:uint		= 0;

		public		var type	:uint 		= AMQP.FRAME_METHOD;
		public		var channel	:uint		= 0;
		public 		var content	:Buffer		= null;
		public		var valid	:Boolean	= true;
		public		var payload	:Payload	= null;

		public function Frame(payLoad:Payload=null)
		{
			if(payLoad != null) {
				payload = payLoad;
				type	= payload.frameType;
				content = payload.serialize();
			}
		}

		//extracts the appropriate Method class from the frame
		public function get method():Method {
			if(content != null && content.length > 0) {
				var method:Method = AMQP.getMethod(content.readUnsignedShort(), content.readUnsignedShort());
				if(method) {
					method.readArguments(content);
					return method;
				}
			}
			return null;
		}

		//build a header from buffer
		public function get header():Header {
			if(content != null && content.length > 0) {

				var header:Header = AMQP.getClass(content.readUnsignedShort());
				if(header) {
					header.deserialize(content);
					return header;
				}
			}
			return null;
		}

		//build a body object from the buffer
		public function get body():Body {
			if(content != null && content.length > 0) {
				var body:Body = new Body();
				body.deserialize(content);
				return body;
			}
			return null;
		}
	}
}