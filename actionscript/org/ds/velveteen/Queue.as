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
	import org.ds.amqp.connection.Channel;
	import org.ds.amqp.connection.Connection;
	import org.ds.amqp.events.MethodEvent;
	import org.ds.amqp.protocol.basic.BasicCancel;
	import org.ds.amqp.protocol.basic.BasicCancelOk;
	import org.ds.amqp.protocol.basic.BasicConsume;
	import org.ds.amqp.protocol.basic.BasicConsumeOk;
	import org.ds.amqp.protocol.basic.BasicDeliver;
	import org.ds.amqp.protocol.queue.QueueBind;
	import org.ds.amqp.protocol.queue.QueueDeclare;
	import org.ds.amqp.protocol.queue.QueueDeclareOk;
	import org.ds.amqp.protocol.queue.QueueDelete;
	import org.ds.amqp.protocol.queue.QueueDeleteOk;
	import org.ds.fsm.StateMachine;
	import org.ds.logging.Logger;
	
	public class Queue extends StateMachine
	{
		public 	static var DECLARED		:String = "Declared";
		public 	static var SUBSCRIBED	:String = "Subscribed";
		public 	static var UNSUBSCRIBED	:String = "Unsubscribed";
		public 	static var DELETED		:String = "Deleted";
		
		protected var auto			:Boolean = false;
		protected var channel		:Channel;
		protected var queue			:String;
		protected var callback		:Function;
		protected var pendingBinds	:Array = [];

		public function Queue(connection:Connection, options:*=null, cb:Function=null)
		{
			super("Null");
			
			channel 	= connection.createChannel();
			callback 	= cb;
			
			
			var declare:QueueDeclare = new QueueDeclare();
			if(options) {
				for(var k:* in options) {
					declare[k] = options[k];
				}
				
				if(declare.queue == "auto") {
					auto = true;
					declare.queue = "";
				}
			}
			
			//declare and then subscribe
			channel.send(declare, onQueueDeclare);
		}


		public function get isReady():Boolean {
			return state == DECLARED || state == SUBSCRIBED; 
		}
		
		public function unsubscribe():void {
			
			var cancel:BasicCancel = new BasicCancel();
			cancel.consumerTag = queue;

            channel.send(cancel, onUnsubscribe);
		}
		
		public function onUnsubscribe(ok:BasicCancelOk):void {
			state = UNSUBSCRIBED;
		}
		
		public function destroy(options:*=null):void {
			var dest:QueueDelete = new QueueDelete();
			
			dest.queue = queue;
			dest.ifUnused = options.ifUnused || false;
			dest.ifEmpty = options.ifEmpty || false;
			dest.nowait = options.nowait || false;
			
			channel.send(dest, onDestroy);
		}
		
		public function onDestroy(ok:QueueDeleteOk):void {
			state = DELETED;
			channel.close();
		}
		
		public function bind(exchange:Exchange, routingKey:String="", callback:Function=null):void {

			var bind:QueueBind = new QueueBind();
			bind.exchange 	= exchange.exchangeName;
			bind.queue 		= queue;
			bind.routingKey = routingKey;
			
			if(isReady) {
				channel.send(bind);	
			} else {
				pendingBinds.push(bind);
			}
		}
		
		/**
		 * Not supports by AMQP 08
		 */ 
		public function unbind(exchange:Exchange, options:*=null):Queue {
			return this;
		}
					
					
		/*
		* Callbacks
		*/
		private function onQueueDeclare(result:QueueDeclareOk):void {
			
			queue = result.queue;

			var consume:BasicConsume = new BasicConsume();
            consume.queue 		= queue;
            consume.consumerTag = queue;
            consume.noAck 		= true;
            
            channel.send(consume, onSubscribed);
            
            state = DECLARED;
            
            flushBinds();
		}		
		
		
		
		private function onSubscribed(result:BasicConsumeOk):void {
			channel.addEventListener(BasicDeliver.EVENT, onReceive);
			state = SUBSCRIBED;
		}		
		
		
		private function flushBinds():void {
			
			var bind:QueueBind = null;
			while(pendingBinds.length > 0) {
				 bind = pendingBinds.shift();
				 bind.queue = queue;
				 
				 channel.send(bind);
			}
		}
		
		protected function onReceive(e:MethodEvent):void {
			
			Logger.info("Message Received");
			
			var m:BasicDeliver 	= e.instance as BasicDeliver;
			
			var msg:* = {
				queue		: auto ? "auto" : m.consumerTag,
				exchange	: m.exchange,
				routingKey	: m.routingKey,
				data		: m.body.data
			};
			
			callback(msg)
		}
		

		public function get name():String {
			return queue;
		}
	}
}