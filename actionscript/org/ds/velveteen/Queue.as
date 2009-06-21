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

package org.ds.velveteen
{
	import flash.events.EventDispatcher;
	
	import org.ds.amqp.connection.Connection;
	import org.ds.amqp.diagnostics.Logger;
	import org.ds.amqp.events.MethodEvent;
	import org.ds.amqp.protocol.Exchange;
	import org.ds.amqp.protocol.basic.Consume;
	import org.ds.amqp.protocol.queue.Declare;
	import org.ds.amqp.protocol.queue.DeclareOk;
	
	public class Queue extends EventDispatcher
	{
		protected var ready	:Boolean = false;
		protected var conn	:Connection;
		protected var name	:String;
		
		public function Queue(connection:Connection, queueName:String, options:*=null)
		{
			conn = connection;
			name = queueName;
			
			conn.addEventListener(new DeclareOk().toString(), onQueueDeclareOk);
			
			var declare:Declare = new Declare();
			declare.queue 		= name;
			
			if(options) {
				for(var k:* in options) {
					declare[k] = options[k];
				}
			}
			
			declare.send(connection);
		}
		

		
		public function subscribe():void {
		}
		
		public function unsubscribe():void {
		}
		
		public function bind(exchange:Exchange, options:*=null):Queue {
			return this;	
		}
		
		public function unbind(exchange:Exchange, options:*=null):Queue {
			return this;
		}
					
		/*
		* Event Handlers
		*/
		protected function onQueueDeclareOk(e:MethodEvent):void {
			ready = true;
			var r:DeclareOk = e.instance as DeclareOk;
			Logger.log(r.consumerCount, r.messageCount, r.queue);
		}		
		
		protected function onRecieve(e:MethodEvent):void {
			if(e.instance is Consume) {
				var c:Consume = e.instance as Consume;
				
				if(c.queue == name) {
					//we have a message
				}
				
				//we have a message
			}
		}
		


	}
}