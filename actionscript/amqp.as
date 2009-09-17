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
	import org.ds.fsm.StateEvent;
	import org.ds.logging.LogEvent;
	import org.ds.logging.Logger;
	import org.ds.velveteen.Exchange;
	import org.ds.velveteen.Queue;


	public class amqp extends Sprite
	{
		private var logger		:Logger 	= new Logger(1);
		private var connection	:Connection	= null;
		
		//coming soon
		private var queues		:* = {};
		
		//private var queue		:Queue;
		
		private var exchanges	:* = {};
		
		
		public function amqp()
		{
			if(ExternalInterface.available) {
				
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
	
				ExternalInterface.call("AMQPClient.onApiReady");
			}
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


		private function api_subscribe(opts:*):uint {
			var queue:Queue = new Queue(connection, opts, onDeliver);
			queues[queue.queueId] = queue;
			return queue.queueId;
		}
		
		private function api_unsubscribe(queue:String):void {
		}
		
				
		private function api_publish(exchangeId:uint, routingKey:String, payload:*):void {
			var ex:Exchange = exchanges[exchangeId];
			if(ex) {
				ex.publish(routingKey, payload);
			} else {
				Logger.log("Exchange not declared: ", exchangeId);
			}
		}
		
		private function api_declare_exchange(opts:*):uint {
			var exchange:Exchange = new Exchange(connection, opts)
			exchanges[exchange.exchangeId] = exchange;
			return exchange.exchangeId;
		}
		

		private function api_bind(queueId:String, exchangeId:String, routingKey:String):void {

			var ex:Exchange = exchanges[exchangeId];
			if(ex) {
				queues[queueId].bind(ex, routingKey);
			} else {
				Logger.log("Exchange not declared: ", exchangeId);
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
		 
		 private function onDeliver(m:*):void {
		 	ExternalInterface.call("AMQPClient.onReceive", m);
		 }	
	}
}
