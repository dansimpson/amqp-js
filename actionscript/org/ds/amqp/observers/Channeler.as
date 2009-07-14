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

package org.ds.amqp.observers
{
	import org.ds.amqp.connection.Connection;
	import org.ds.amqp.events.MethodEvent;
	import org.ds.amqp.protocol.channel.Open;
	import org.ds.amqp.protocol.connection.OpenOk;
	import org.ds.amqp.transport.Frame;
	import org.ds.logging.Logger;
	
	public class Channeler extends Observer
	{
		public function Channeler(connection:Connection)
		{
			super(connection);

			on(new OpenOk().toString(), onOpenOk);
			on(new org.ds.amqp.protocol.channel.OpenOk().toString(), onChannelOpen);
		}
		
		protected function get connection():Connection {
			return target as Connection;
		}
		
		protected function onChannelOpen(e:MethodEvent):void {
			Logger.log("Connection Ready");
			connection.state = Connection.READY;
		}
		protected function onOpenOk(e:MethodEvent):void {
			Frame.CHANNEL = 1;
			var open:Open = new Open();
			open.send(connection);
        }
	}
}