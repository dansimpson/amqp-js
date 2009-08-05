package org.ds.amqp.transport
{
	import org.ds.amqp.protocol.Body;
	import org.ds.amqp.protocol.Header;
	import org.ds.amqp.protocol.Method;
	
	public class Transmission
	{
		protected var _method	:Method;
		protected var _header	:Header;
		protected var _body		:Body;

		public function Transmission(method:Method)
		{
			_method = method;
		}
		
		
		public function get method():Method {
			return _method;
		}
		public function set method(method:Method):void {
			_method = method;
		}		

		public function get header():Header {
			return _header;
		}
		public function set header(header:Header):void {
			_header = header;
		}
		
		public function get body():Body {
			return _body;
		}
		public function set body(body:Body):void {
			_body = body;
		}	
			
		public function get hasContent():Boolean {
			return _header != null && _body != null;
		}
		
		public function get frames():Array {
			var items:Array = new Array();
			
			items.push(new Frame(_method));
			
			if(hasContent) {
				items.push(new Frame(_header));
				items.push(new Frame(_body));
			}
			
			return items;
		}
		

	}
}