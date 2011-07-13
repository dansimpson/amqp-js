package org.ds.amqp.connection
{
	import org.ds.amqp.AMQP;
	import org.ds.amqp.events.MethodEvent;
	import org.ds.amqp.protocol.Method;
	import org.ds.amqp.protocol.channel.ChannelOpen;
	import org.ds.amqp.protocol.channel.ChannelOpenOk;
	import org.ds.amqp.protocol.channel.ChannelClose;
	import org.ds.amqp.protocol.channel.ChannelCloseOk;
	import org.ds.amqp.transport.Frame;
	import org.ds.fsm.StateMachine;
	import org.ds.logging.Logger;
	

	public class Channel extends StateMachine
	{
		protected var _stream		:Stream;
		protected var _number		:uint;
		protected var _queue		:Array 			= [];
		protected var _method		:Method			= null;
		
		protected var _expecting	:Array			= null;
		protected var _callback		:Function		= null;
		
		public function Channel(number:uint, stream:Stream, autoOpen:Boolean=true) {
			
			_number = number;
			_stream = stream;
			
			if(autoOpen) {
				open();
			}
			
			super("CLOSED");
		}

		
		public function open():void {
			write(new ChannelOpen(), onChannelOpen);
		}

		public function close():void {
			write(new ChannelClose(), onChannelClose);
		}
		
		public function send(method:Method, cb:Function=null):void {
			_queue.push({
				method		: method,
				callback	: cb
			});
			
			flush();
		}
		
		public function flush():void {
			
			while(_queue.length > 0) {
				if(!isBusy) {
					
					var call:* = _queue.shift();
					write(call.method, call.callback);
					
				} else {
					break;
				}
			}
		}
		
		
		public function write(method:Method, callback:Function=null):void {
			
			if(Logger.debugging) {
				method.print();
			}
			
			_stream.writeFrame(new Frame(method), _number);
			
			if(method.hasContent) {
				_stream.writeFrame(new Frame(method.header), _number);
				_stream.writeFrame(new Frame(method.body), _number);
			}
			
			if(method.expectsResponse) {
				_expecting  = method.responses;
				_callback	= callback;
			}
			
		}
		
		
		
		/**
		 * Process the frame and deliver it to the proper recipient via
		 * callback
		 */ 
		public function receive(frame:Frame):void {
	
			switch(frame.type) {
				
				case AMQP.FRAME_METHOD:
					
					_method = frame.method;
					
					//if we are not expecting any more
					//data for this assembly, then handle it
					if(!_method.hasContent) {
						onDataReady();
					}

					break;
				case AMQP.FRAME_HEADER:
				
					//continue building assembly
					if(_method != null) {
						_method.header = frame.header;
					} else {
						Logger.log("Unexpected Header Frame");
					}
					
					break;
				case AMQP.FRAME_BODY:
						
					//finish building assembly
					if(_method != null) {
						_method.body = frame.body;
						onDataReady();
					} else {
						Logger.log("Unexpected Body Frame");
					}
					
					break;
				case AMQP.FRAME_HEARTBEAT:
					
					//not sure what to do here
					
					break;
				default:
					Logger.log("Unhandled Frame Type");
					break;
			}
		}
		
		/**
		 * once prepared, the method with optional body and
		 * header is sent via an event and listeners can
		 * proceed as defined by the implementation
		 */
		private function onDataReady():void {
						
			if(_method) {
				
				
				if(Logger.debugging) {
					_method.print();
				}
				
				//check to see if this a channel specific message
				handleChannelMessages(_method);
				
				
				//check to see if the methiod
				if(_expecting) {
					for(var i:int = 0;i < _expecting.length;i++) {
						if(_method is _expecting[i]) {
							
							//call the appropriate method
							//and make the object not busy
							if(_callback != null) {
								_callback(_method);
							}
							
							_callback  = null;
							_expecting = null;
							
							//send out any messages
							flush();
							
							break;
						}
					}
				}
				
				//send an event to anyone who cares
				dispatchEvent(new MethodEvent(_method));
			}
			
			
			
			_method   = null;
		}
		
		public function get isBusy():Boolean {
			return _expecting != null;
		}
		
		protected function handleChannelMessages(method:Method):void {
		}
		
		protected function onChannelOpen(cok:ChannelOpenOk):void {
			state = "OPEN";
		}

		protected function onChannelClose(cok:ChannelCloseOk):void {
			state = "CLOSED";
		}


	}
}