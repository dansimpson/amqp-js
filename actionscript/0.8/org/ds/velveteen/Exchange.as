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
	import org.ds.amqp.connection.Connection;
	import org.ds.amqp.events.MethodEvent;
	import org.ds.amqp.protocol.Body;
	import org.ds.amqp.protocol.basic.BasicPublish;
	import org.ds.amqp.protocol.exchange.ExchangeDeclare;
	import org.ds.amqp.protocol.exchange.ExchangeDeclareOk;
	import org.ds.amqp.protocol.exchange.ExchangeDelete;
	import org.ds.amqp.protocol.exchange.ExchangeDeleteOk;
	import org.ds.amqp.protocol.headers.Basic;
	import org.ds.amqp.transport.Frame;
	import org.ds.amqp.transport.Transmission;
	import org.ds.fsm.StateMachine;

	public class Exchange extends StateMachine
	{
		public static var DECLARED		:String = "Declared";
		public static var DELETED		:String = "Deleted";
		
		protected var conn		:Connection;
		protected var exchange	:String = "";
		protected var type		:String = "";
		protected var active	:Boolean = false;
		
		public function Exchange(connection:Connection, options:*)
		{
			super("Null");
			
			conn 		= connection;
			exchange 	= options.exchange;

			var declare:ExchangeDeclare = new ExchangeDeclare();
			for(var k:* in options) {
				declare[k] = options[k];
			}
			
			conn.addEventListener(ExchangeDeclareOk.EVENT, onDeclare);
			conn.sendFrame(new Frame(declare));
						
		}
		
		public function get isDeclared():Boolean {
			return state == DECLARED;
		}
		
		public function deleteExchange():void {
			
			
			
			var method:ExchangeDelete = new ExchangeDelete();
			method.exchange = exchange;
			
			conn.addEventListener(ExchangeDeleteOk.EVENT, onDelete);
			conn.sendFrame(new Frame(method));
		}
		
		
		public function onDelete(e:MethodEvent):void {
			state = DELETED;
			conn.removeEventListener(ExchangeDeleteOk.EVENT, onDelete);
		}
		
		
		public function onDeclare(e:MethodEvent):void {
			conn.removeEventListener(ExchangeDeclareOk.EVENT, onDeclare);
			state = DECLARED;
		}
		
		public function get exchangeName():String {
			return exchange;
		}
		
		public function publish(routingKey:String, message:*):void {
			
			var pub:BasicPublish = new BasicPublish();
			pub.exchange = exchange;
			pub.routingKey = routingKey;

			var transmission:Transmission = new Transmission(pub);
			
			transmission.body = new Body();
			transmission.body.data = message;
			
			transmission.header = new Basic();
			transmission.header.bodySize = transmission.body.length;
			
			conn.send(transmission);
		}
		
	}
}