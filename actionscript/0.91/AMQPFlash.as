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

package {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	
	import org.ds.amqp.connection.Connection;
	import org.ds.amqp.protocol.Method;
	import org.ds.amqp.protocol.queue.QueueBindOk;
	import org.ds.fsm.StateEvent;
	import org.ds.logging.LogEvent;
	import org.ds.logging.Logger;
	import org.ds.velveteen.Exchange;
	import org.ds.velveteen.Queue;


	public class AMQPFlash extends Sprite
	{
		private var logger		:Logger 	= new Logger(1);
		private var connection	:Connection	= null;
		
		//coming soon
		private var queues		:* = {};
		
		private var queue		:Queue;
		private var exchanges	:* = {};
		
		
		public function AMQPFlash()
		{
			initAPI();
		}


		/**
		 * External Interface API
		 */ 
		private function initAPI():void {
			ExternalInterface.addCallback("configure", 		api_configure);
			ExternalInterface.addCallback("connect", 		api_connect);
			ExternalInterface.addCallback("disconnect", 	api_disconnect);
			ExternalInterface.addCallback("exchange", 		api_declare_exchange);			
			ExternalInterface.addCallback("subscribe", 		api_subscribe);
			ExternalInterface.addCallback("unsubscribe", 	api_unsubscribe);			
			ExternalInterface.addCallback("publish",		api_publish);			
			ExternalInterface.addCallback("bind", 			api_bind);
			ExternalInterface.addCallback("unbind", 		api_unbind);			
			ExternalInterface.addCallback("setLogLevel", 	api_set_log_level);

			//by default we enable logging
			ExternalInterface.call("AMQPClient.onApiReady");
		}
				
		/**
		 * Allows default passing from the javascript implementation
		 */ 
		private function api_configure(options:*):void {
			if(options.logLevel) {
				logger.addEventListener(LogEvent.ENTRY, onLogEntry);
				logger.level = options.logLevel;
			}
		}
				
		private function api_connect(params:*):void {
			connection = new Connection(params);
			connection.addEventListener(Connection.READY, 	onConnect);
			connection.addEventListener(Connection.CLOSED, 	onDisconnect);
		}
		
				
		private function api_disconnect():void {
			connection.disconnect();
		}


		private function api_subscribe(opts:*):void {
			queue = new Queue(connection, opts, onDeliver);
			queue.addEventListener(Queue.DECLARED, onQueueDeclared);
		}
		
		
		private function api_unsubscribe(queue:String):void {
		}
		
				
		private function api_publish(exchange:String, routingKey:String, payload:*):void {
			var ex:Exchange = exchanges[exchange];
			if(ex) {
				ex.publish(routingKey, payload);
			} else {
				Logger.log("Exchange not declared: ", exchange);
			}
		}
		
		private function api_declare_exchange(opts:*):void {
			exchanges[opts.exchange] = new Exchange(connection, opts);
			exchanges[opts.exchange].addEventListener(Exchange.DECLARED, onExchangeDeclared);
		}
		

		private function api_bind(queueName:String, exchange:String, routingKey:String):void {
			
			
			var ex:Exchange = exchanges[exchange];
			if(ex) {
				queue.bind(ex, routingKey);
			} else {
				Logger.log("Exchange not declared: ", exchange);
			}
		}
		
		private function api_unbind(queue:String, exchange:String, routingKey:String):void {
		}
		
		private function api_set_log_level(lvl:uint):void {
			Logger.level = lvl;
		}
		
		
		private function api_send_method(klass:String, opts:*):void {
		}		
		
		
		/**
		 * Helpers
		 */
		 private function createMethod(klass:Class, opts:*):Method {
		 	var m:Method = new klass();
		 	if(opts) {
				for(var k:* in opts) {
					m[k] = opts[k];
				}
			}
		 	return m;	 	
		 }
		 
		
		/**
		 * Events to send to the client
		 */		 
		 private function onConnect(e:Event):void {
		 	ExternalInterface.call("AMQPClient.onConnect");
		 	ExternalInterface.call("AMQPClient.onReady");
		 }

		 private function onDisconnect(e:Event):void {
		 	ExternalInterface.call("AMQPClient.onDisconnect");
		 }
		 		 
		 private function onLogEntry(e:LogEvent):void {
		 	ExternalInterface.call("AMQPClient.onLogEntry", e.toString());
		 }
		 
		 private function onQueueDeclared(e:StateEvent):void {
		 	var queue:Queue = e.target as Queue;
		 	queues[queue.name] = queue;
		 	ExternalInterface.call("AMQPClient.onQueueDeclare", queue.name);
		 }
		 
		 private function onBind(e:Event):void {
		 	var queue:Queue = e.target as Queue;
		 	queues[queue.name] = queue;
		 	ExternalInterface.call("AMQPClient.onBind", queue.name);
		 }
		 
		private function onExchangeDeclared(e:StateEvent):void {
		 	var ex:Exchange = e.target as Exchange;
		 	ExternalInterface.call("AMQPClient.onExchangeDeclare", ex.exchangeName);
		 }
		 
		 private function onDeliver(m:*):void {
		 	ExternalInterface.call("AMQPClient.onReceive", m);
		 }	
	}
}
