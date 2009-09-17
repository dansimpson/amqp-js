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
	import flash.external.ExternalInterface;
	
	import org.ds.amqp.connection.Channel;
	import org.ds.amqp.connection.Connection;
	import org.ds.amqp.protocol.Body;
	import org.ds.amqp.protocol.basic.BasicPublish;
	import org.ds.amqp.protocol.exchange.ExchangeDeclare;
	import org.ds.amqp.protocol.exchange.ExchangeDeclareOk;
	import org.ds.amqp.protocol.exchange.ExchangeDelete;
	import org.ds.amqp.protocol.exchange.ExchangeDeleteOk;
	import org.ds.amqp.protocol.headers.Basic;
	import org.ds.fsm.StateMachine;

	public class Exchange extends StateMachine
	{
		private static var count		:uint	= 0;
		
		public 	static var DECLARED		:String = "Declared";
		public 	static var DELETED		:String = "Deleted";
		
		protected var id		:uint;
		protected var channel	:Channel;
		protected var exchange	:String = "";
		protected var type		:String = "";
		protected var active	:Boolean = false;
		
		public function Exchange(connection:Connection, options:*)
		{
			super("Null");
			
			id			= ++count;
			channel 	= connection.channel;
			exchange 	= options.exchange;

			var declare:ExchangeDeclare = new ExchangeDeclare();
			for(var k:* in options) {
				declare[k] = options[k];
			}
			
			channel.send(declare, onDeclare);		
		}
		
		public function get isDeclared():Boolean {
			return state == DECLARED;
		}
		
		public function deleteExchange():void {

			var method:ExchangeDelete = new ExchangeDelete();
			method.exchange = exchange;
			channel.send(method, onDelete);
		}
		
		
		public function onDelete(result:ExchangeDeleteOk):void {
			state = DELETED;
		}
		
		
		public function onDeclare(result:ExchangeDeclareOk):void {
			state = DECLARED;
			
			if(ExternalInterface.available) {
				ExternalInterface.call("AMQPClient.onExchangeDeclare", exchange);
			}
		}
		
		public function get exchangeName():String {
			return exchange;
		}
		
		public function get exchangeId():uint {
			return id;
		}
		
		public function publish(routingKey:String, message:*):void {
			
			var pub:BasicPublish = new BasicPublish();
			pub.exchange = exchange;
			pub.routingKey = routingKey;
			
			pub.body = new Body();
			pub.body.data = message;
			
			pub.header = new Basic();
			pub.header.bodySize = pub.body.length;

			channel.send(pub);
		}
		
	}
}