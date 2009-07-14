package org.ds.velveteen
{
	import flash.events.EventDispatcher;
	
	import org.ds.amqp.connection.Connection;
	import org.ds.amqp.events.MethodEvent;
	import org.ds.amqp.protocol.exchange.ExchangeDeclare;
	import org.ds.amqp.protocol.exchange.ExchangeDeclareOk;
	import org.ds.amqp.protocol.exchange.ExchangeDelete;
	import org.ds.amqp.protocol.exchange.ExchangeDeleteOk;
	import org.ds.amqp.transport.Frame;

	public class Exchange extends EventDispatcher
	{
		protected var _conn		:Connection;
		protected var _name		:String = "";
		protected var _type		:String = "";
		protected var _ticket	:uint = 0;
		protected var _active	:Boolean = false;
		
		public function Exchange(connection:Connection, name:String, type:String="topic", options:*=null)
		{
			super();
			
			_conn = connection;
			_name = name;
			_type = type;

			_conn.addEventListener(ExchangeDeclareOk.EVENT, onDeclare);
			
						
			var declare:ExchangeDeclare = new ExchangeDeclare();
			declare.exchange 	= name;
			declare.type 	 	= type;
			declare.autoDelete	= true;

			if(options) {
				for(var k:* in options) {
					declare[k] = options[k];
				}
			}
			
			_conn.sendFrame(new Frame(declare));
						
		}
		
		public function deleteExchange():void {
			
			_conn.addEventListener(ExchangeDeleteOk.EVENT, onDelete);
			
			var method:ExchangeDelete = new ExchangeDelete();
			method.exchange = _name;
			
			_conn.sendFrame(new Frame(method));
		}
		
		
		public function onDelete(e:MethodEvent):void {
			_conn.removeEventListener(ExchangeDeleteOk.EVENT, onDelete);
			_active = false;
		}
		
		
		public function onDeclare(e:MethodEvent):void {
			_conn.removeEventListener(ExchangeDeclareOk.EVENT, onDeclare);
			_active = true;
		}
		
		public function get name():String {
			return _name;
		}
		
	}
}