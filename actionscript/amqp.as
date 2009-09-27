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
	import flash.system.Security;
	
	import org.ds.amqp.connection.Connection;
	import org.ds.logging.LogEvent;
	import org.ds.logging.Logger;
	import org.ds.velveteen.Exchange;
	import org.ds.velveteen.Queue;


	public class amqp extends Sprite
	{
		private var logger		:Logger 	= new Logger();
		private var connection	:Connection	= null;
		
		private var queues		:* = {};
		private var exchanges	:* = {};
		
		
		public function amqp()
		{
			if(ExternalInterface.available) {
				
				Security.allowDomain("*");
				Security.allowInsecureDomain("*");
				
				ExternalInterface.addCallback("connect", 		api_connect);
				ExternalInterface.addCallback("disconnect", 	api_disconnect);
				ExternalInterface.addCallback("exchange", 		api_declare_exchange);
				ExternalInterface.addCallback("subscribe", 		api_subscribe);
				ExternalInterface.addCallback("unsubscribe", 	api_unsubscribe);
				ExternalInterface.addCallback("publish",		api_publish);
				ExternalInterface.addCallback("bind", 			api_bind);
				ExternalInterface.addCallback("unbind", 		api_unbind);
				ExternalInterface.addCallback("setLogLevel", 	api_set_log_level);
	
				//allow all logged messages to pass down to javascript land
				logger.addEventListener(LogEvent.ENTRY, onLogEntry);
	
				ExternalInterface.call("MQ.onLoad");
			}
		}
				
				
		private function api_connect(params:*):void {
			
			Logger.info("Attempting Connection");
			
			connection = new Connection(params);
			connection.addEventListener(Connection.READY, 	onConnect);
			connection.addEventListener(Connection.CLOSED, 	onDisconnect);
		}
		
				
		private function api_disconnect():void {
			
			Logger.info("Disconnecting");
			
			connection.disconnect();
		}


		private function api_subscribe(opts:*):String {
			var queue:Queue = new Queue(connection, opts, onDeliver);
			queues[opts.queue] = queue;
			return opts.queue;
		}
		
		private function api_unsubscribe(queue:String):void {
			if(queues[queue]) {
				(queues[queue] as Queue).unsubscribe();
				delete queues[queue];
			}
		}
		
				
		private function api_publish(exchange:String, routingKey:String, payload:*):void {
			var ex:Exchange = exchanges[exchange];
			if(ex) {
				ex.publish(routingKey, payload);
			} else {
				Logger.log("Exchange not declared: " + exchange);
			}
		}
		
		private function api_declare_exchange(opts:*):String {
			var exchange:Exchange = new Exchange(connection, opts)
			exchanges[exchange.exchangeName] = exchange;
			return exchange.exchangeName;
		}
		

		private function api_bind(queue:String, exchange:String, routingKey:String):void {

			var ex:Exchange = exchanges[exchange];
			if(ex) {
				queues[queue].bind(ex, routingKey);
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
		 * Events to send to the client
		 */		 
		 private function onConnect(e:Event):void {
		 	ExternalInterface.call("MQ.onConnect");
		 }

		 private function onDisconnect(e:Event):void {
		 	ExternalInterface.call("MQ.onDisconnect");
		 }
		 		 
		 private function onLogEntry(e:LogEvent):void {
		 	ExternalInterface.call("MQ.onLogEntry", e.toString());
		 }
		 
		 private function onDeliver(m:*):void {
		 	ExternalInterface.call("MQ.onReceive", m);
		 }	
	}
}
