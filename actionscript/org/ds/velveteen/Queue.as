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
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.ds.amqp.connection.Connection;
	import org.ds.amqp.events.MethodEvent;
	import org.ds.amqp.events.TransmissionEvent;
	import org.ds.amqp.protocol.Payload;
	import org.ds.amqp.protocol.basic.BasicConsume;
	import org.ds.amqp.protocol.basic.BasicDeliver;
	import org.ds.amqp.protocol.queue.QueueBind;
	import org.ds.amqp.protocol.queue.QueueDeclare;
	import org.ds.amqp.protocol.queue.QueueDeclareOk;
	import org.ds.amqp.transport.Frame;
	import org.ds.amqp.transport.Transmission;
	import org.ds.logging.Logger;
	
	public class Queue extends EventDispatcher
	{
		protected var ready		:Boolean = false;
		protected var conn		:Connection;
		protected var name		:String;
		protected var tag		:String;
		protected var cb		:Function;
		
		protected var bindings	:* = {
		};
		
		protected var buffer	:Array = new Array();
		
		public function Queue(connection:Connection, queueName:String, options:*=null)
		{
			conn = connection;
			name = queueName;
			
			conn.addEventListener(QueueDeclareOk.EVENT, onQueueDeclareOk);
			conn.addEventListener(BasicDeliver.EVENT, onReceive);
			
			var declare:QueueDeclare = new QueueDeclare();
			declare.queue 		= name;
			declare.autoDelete	= true;

			if(options) {
				for(var k:* in options) {
					declare[k] = options[k];
				}
			}
			
			connection.sendFrame(new Frame(declare));
		}
		

		
		public function subscribe(callback:Function):void {
		
			cb = callback;
			
            var consume:BasicConsume = new BasicConsume();
           	
            consume.queue = name;
            consume.consumerTag = name;
            consume.noAck = true;
            
            if(ready) {
            	conn.sendFrame(new Frame(consume));
            } else {
            	buffer.push(consume);
            }
		}
		
		public function unsubscribe():void {
		}
		
		public function bind(exchange:Exchange, routingKey:String="", callback:Function=null, blockCalls:Boolean=false):Queue {
			

			var bind:QueueBind = new QueueBind();
			bind.exchange 	= exchange.name;
			bind.queue 		= name;
			bind.routingKey = routingKey;
			
			bindings[exchange.name + "/" + routingKey] = {
				exchange	: exchange.name,
				routingKey	: routingKey,
				callback	: callback,
				blockCalls	: blockCalls
			};
			
			if(ready) {
				conn.sendFrame(new Frame(bind));
			} else {
				buffer.push(bind);
			}
			

			return this;	
		}
		
		public function unbind(exchange:Exchange, options:*=null):Queue {
			return this;
		}
					
		/*
		* Event Handlers
		*/
		protected function onQueueDeclareOk(e:MethodEvent):void {
			while(buffer.length > 0) {
				conn.sendFrame(new Frame((buffer.shift() as Payload)));
			}
			ready = true;
		}		
		
		protected function onReceive(e:Event):void {
			
			Logger.log("Msg Rcvd");
			
			var t:Transmission 	= (e as TransmissionEvent).instance;
			var m:BasicDeliver 	= t.method as BasicDeliver;
			var b:* 			= bindings[m.exchange + "/" + m.routingKey];
			
			if(b != null) {				
				trace("Exchange Msg Rcvd");
				b.callback(t.body.data);
				if(b.blockCalls) {
					return;
				}
			}
			
			cb(t.body.data);
		}
		


	}
}