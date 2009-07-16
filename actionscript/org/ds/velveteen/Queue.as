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
	
	import org.ds.amqp.connection.Connection;
	import org.ds.amqp.events.MethodEvent;
	import org.ds.amqp.events.TransmissionEvent;
	import org.ds.amqp.protocol.basic.BasicConsume;
	import org.ds.amqp.protocol.basic.BasicConsumeOk;
	import org.ds.amqp.protocol.basic.BasicDeliver;
	import org.ds.amqp.protocol.queue.QueueBind;
	import org.ds.amqp.protocol.queue.QueueDeclare;
	import org.ds.amqp.protocol.queue.QueueDeclareOk;
	import org.ds.amqp.transport.Frame;
	import org.ds.amqp.transport.Transmission;
	import org.ds.fsm.StateMachine;
	import org.ds.logging.Logger;
	
	public class Queue extends StateMachine
	{
		public static var DECLARED		:String = "Declared";
		public static var SUBSCRIBED	:String = "Subscribed";
		public static var UNSUBSCRIBED	:String = "Unsubscribed";
		public static var DELETED		:String = "Deleted";
		
		
		protected var unique		:Number;
		protected var conn			:Connection;
		protected var queue			:String;
		protected var callback		:Function;
		protected var pending		:Array 			= [];
		protected var bindings		:* 				= {};

		public function Queue(connection:Connection, options:*=null, cb:Function=null)
		{
			super("Null");
			
			conn = connection;
			callback = cb;
			
			var declare:QueueDeclare = new QueueDeclare();
			if(options) {
				for(var k:* in options) {
					declare[k] = options[k];
				}
			}
			
			conn.addEventListener(QueueDeclareOk.EVENT, onQueueDeclare);
			conn.sendFrame(new Frame(declare));
		}


		public function get isSubscribed():Boolean {
			return state == SUBSCRIBED;
		}
		
		public function unsubscribe():void {
		}
		
		public function destroy():void {
		}
		
		public function bind(exchange:Exchange, routingKey:String="", callback:Function=null):void {

			var config:* = {
				exchange: exchange,
				routingKey: routingKey,
				callback: callback
			};
			
			if(!isSubscribed) {
				pending.push(config);
				return;
			}
			
			if(!exchange.isDeclared) {
				pending.push(config);
				exchange.addEventListener(Exchange.DECLARED, onExchangeDeclare);
				return;
			}

			var bind:QueueBind = new QueueBind();
			bind.exchange 	= exchange.exchangeName;
			bind.queue 		= queue;
			bind.routingKey = routingKey;
			
			//create the exchange binding
			if(!bindings[exchange.exchangeName]) {
				bindings[exchange.exchangeName] = {
					routes: {}
				}
			}
			
			//create the key binding
			if(!bindings[exchange.exchangeName][routingKey]) {
				bindings[exchange.exchangeName][routingKey] = {
					callback: callback
				}
			}

			conn.sendFrame(new Frame(bind));
		}
		
		
		public function unbind(exchange:Exchange, options:*=null):Queue {
			return this;
		}
					
		/*
		* Event Handlers
		*/
		
		private function onExchangeDeclare(e:MethodEvent):void {
			flushBinds();
		}
		
		private function onQueueDeclare(e:MethodEvent):void {
			
			state = DECLARED;
			
			var declare:QueueDeclareOk = e.instance as QueueDeclareOk;
			queue = declare.queue;
			
			var consume:BasicConsume = new BasicConsume();
            consume.queue 		= queue;
            consume.consumerTag = queue;
            consume.noAck 		= true;
            
			conn.sendFrame(new Frame(consume));
			conn.addEventListener(BasicConsumeOk.EVENT, onSubscribed);
			conn.removeEventListener(QueueDeclareOk.EVENT, onQueueDeclare);
		}		
		
		
		
		private function onSubscribed(e:MethodEvent):void {
			state = SUBSCRIBED;
			conn.addEventListener(BasicDeliver.EVENT, onReceive);
			conn.removeEventListener(BasicConsumeOk.EVENT, onSubscribed);
			flushBinds();
		}		
		
		
		private function flushBinds():void {
			pending.forEach(function(binding:*, i:int, array:Array):void {
				if(binding.exchange.isDeclared) {
					bind(binding.exchange, binding.routingKey, binding.callback);
				}
			}, this);
		}
		
		protected function onReceive(e:Event):void {
			
			Logger.info("Message Received");
			
			var t:Transmission 	= (e as TransmissionEvent).instance;
			var m:BasicDeliver 	= t.method as BasicDeliver;
			var b:* 			= bindings[m.exchange][m.routingKey];
			
			var msg:* = {
				queue		: m.consumerTag,
				exchange	: m.exchange,
				routingKey	: m.routingKey,
				data		: t.body.data
			};

			if(b != null && b.callback is Function) {			
				b.callback(msg);
			}
			
			callback(msg);
		}
		

		public function get name():String {
			return queue;
		}

	}
}