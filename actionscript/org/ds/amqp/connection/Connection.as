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

package org.ds.amqp.connection
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	
	import org.ds.amqp.AMQP;
	import org.ds.amqp.datastructures.FieldTable;
	import org.ds.amqp.events.ChannelEvent;
	import org.ds.amqp.events.MethodEvent;
	import org.ds.amqp.events.TransmissionEvent;
	import org.ds.amqp.protocol.Header;
	import org.ds.amqp.protocol.Method;
	import org.ds.amqp.protocol.Payload;
	import org.ds.amqp.protocol.channel.ChannelOpenOk;
	import org.ds.amqp.protocol.connection.ConnectionClose;
	import org.ds.amqp.protocol.connection.ConnectionCloseOk;
	import org.ds.amqp.protocol.connection.ConnectionOpen;
	import org.ds.amqp.protocol.connection.ConnectionOpenOk;
	import org.ds.amqp.protocol.connection.ConnectionStart;
	import org.ds.amqp.protocol.connection.ConnectionStartOk;
	import org.ds.amqp.protocol.connection.ConnectionTune;
	import org.ds.amqp.protocol.connection.ConnectionTuneOk;
	import org.ds.amqp.transport.Frame;
	import org.ds.amqp.transport.Transmission;
	import org.ds.fsm.StateMachine;
	import org.ds.logging.Logger;
	
	public class Connection extends StateMachine
	{	
		//stream specific states
		public static var CLOSED		:String = "Closed";
		public static var CONNECTING	:String = "Connecting";
		public static var NEGOTIATING	:String = "Negotiating";
		public static var READY			:String = "Ready";
				
		//for negotiations
		private var authSettings:*	= {
			host	: "127.0.0.1",
			port	: AMQP.PORT,
			user	: "guest",
			password: "guest",
			vhost	: "/"		
		};
		
		//transport and a buffer
		private var stream		:Stream		= null;	
		private var queue		:Array		= new Array();
		
		private var incoming	:Transmission = null;
		
		public function Connection(authenticationSettings:*, autoConnect:Boolean=true)
		{
			
			super(CLOSED);
			
			for(var k:* in authenticationSettings) {
				authSettings[k] = authenticationSettings[k];
			}
			
			stream = new Stream();
            stream.addEventListener(Event.CONNECT, 				onConnect);
            stream.addEventListener(Event.CLOSE, 				onClose);
            stream.addEventListener(IOErrorEvent.IO_ERROR, 		onError);
            stream.addEventListener(ProgressEvent.SOCKET_DATA,	onDataReceived);
            stream.addEventListener(ChannelEvent.OPEN,			onChannelOpen);
			
			//define the state transitions, such that each state
			//changes calls a method for us
			defineTransition("*", CONNECTING, connecting);
			defineTransition("*", NEGOTIATING, negotiating);
			defineTransition("*", CLOSED, disconnected);
			defineTransition("*", READY, ready);
			
			//new ConnectionClose
			addEventListener(ConnectionStart.EVENT		, onConnectionStart);
			addEventListener(ConnectionTune.EVENT		, onConnectionTune);
			addEventListener(ConnectionCloseOk.EVENT	, onConnectionCloseOk);
			addEventListener(ConnectionClose.EVENT		, onConnectionClose);
			addEventListener(ConnectionOpenOk.EVENT		, onConnectionOpenOk);
			addEventListener(ChannelOpenOk.EVENT		, onChannelOpen);
			
			if(autoConnect) {
				connect();
			}
		}


		/*
		* Transitions
		*/
		protected function connecting():void {
		}

		protected function negotiating():void {
			Logger.info("Connected");
			stream.writeUTFBytes("AMQP");
			stream.writeByte(1);
			stream.writeByte(1);
			stream.writeByte(AMQP.PROTOCOL_MAJOR);
			stream.writeByte(AMQP.PROTOCOL_MINOR);
			stream.flush();
		}
				
		protected function connected():void {
		}

		protected function disconnected():void {
			Logger.info("Disconnected");
		}		
		
		protected function ready():void {
			Logger.info("Ready");
		}				
		
		public function connect():Boolean {
			if(isClosed) {
				state = CONNECTING;
				stream.connect(authSettings.host, authSettings.port);
				return true;
			}
			return false;
		}
		
		public function disconnect():void {
			if(!isClosed) {
				stream.close();
			}
		}

		/*
		* Boolean Helpers
		*/
		public function get isConnecting():Boolean {
			return state == CONNECTING;
		}
		
		public function get isClosed():Boolean {
			return state == CLOSED;
		}
		
		public function get isConnected():Boolean {
			return stream.connected;
		}

		public function get isReady():Boolean {
			return state == READY;
		}
		
		//method for high level implementations
		public function send(transmission:Transmission):void {
			if(isReady) {
				transmit(transmission);
			} else {
				enqueue(transmission);
				connect();
			}
		}

		public function sendFrame(frame:Frame):void {
			if(isReady) {
				transmitFrame(frame);
			}
		}
			
		public function enqueue(transmission:Transmission):void {
			queue.push(Transmission);
		}
	
		public function dequeue():Transmission {
			return queue.shift();
		}
		
		//send a method along with it's header and content
		private function transmit(transmission:Transmission):void {
			var frames:Array = transmission.frames;
			frames.forEach(function(frame:Frame,i:int,a:Array):void {
				stream.writeFrame(frame);
			});
			stream.flush();
		}
		
		//send a single frame, of any frame type
		private function transmitFrame(frame:Frame):void {
			stream.writeFrame(frame);
			stream.flush();		
		}
			
		//Move to sessions
		protected function onReady(e:Event):void {
			if(queue.length > 0) {
				send(dequeue());
			}
		}
				
		/*
		* Socket Events
		*/
		protected function onConnect(e:Event):void {		
			state = NEGOTIATING;
		}
				
		protected function onClose(e:Event):void {
			state = CLOSED;
		}
		
		protected function onError(e:IOErrorEvent):void {
			state = CLOSED;
			Logger.log("AMQP Error - Disconnecting.  Details: ", e.text);
		}
		

		protected function onDataReceived(e:ProgressEvent):void {
						
			while (stream.connected && stream.bytesAvailable > 0) {

				var frame	:Frame = stream.readFrame();
				var payload	:Payload;
				
				switch(frame.type) {
					case AMQP.FRAME_METHOD:
						
						var method:Method = frame.method;
						payload = method;
						
						if(method.hasContent) {
							incoming = new Transmission(method);
						} else {
							dispatchEvent(new MethodEvent(method));
						}
						break;
					case AMQP.FRAME_HEADER:
					
						var header:Header = frame.header;
						payload = header;
						
						if(incoming != null) {
							incoming.header = header;
						} else {
							Logger.log("Unexpected Header Frame");
						}
						
						break;
					case AMQP.FRAME_BODY:
					
						var body:Body = frame.body;
						payload = body;
												
						if(incoming != null) {
							incoming.body = body;
							dispatchEvent(new TransmissionEvent(incoming));
						} else {
							Logger.log("Unexpected Body Frame");
						}
						
						incoming = null;
						
						break;
					case AMQP.FRAME_HEARTBEAT:
						break;
					default:
						Logger.log("Unhandled Frame Type");
						break;
				}
				
				//for debugging output
				if(payload && Logger.debugging) {
					payload.print();
				}
			}
		}
		
		
		/*************
		 * 
		 * Negotiation Methods
		 * AMQP requires a handshaking process
		 * 
		 **************/
		private function onConnectionStart(e:MethodEvent):void {

         	var start	:ConnectionStart 	= e.instance as ConnectionStart;
            var startOk	:ConnectionStartOk 	= new ConnectionStartOk();
			
			startOk.clientProperties.store("product", "AMQP-Flash");
			startOk.clientProperties.store("version", "0.2a");
			
			var credentials:FieldTable = new FieldTable();
			credentials.store("LOGIN", 	"guest");
			credentials.store("PASSWORD", 	"guest");	
				
			startOk.response	= credentials;
			startOk.locale    	= "en_US";
			startOk.mechanism 	= "AMQPLAIN";

			transmitFrame(new Frame(startOk));
			
			Logger.info("Handshaking");
		}
		
		private function onConnectionTune(e:MethodEvent):void {

			var tune	:ConnectionTune = e.instance as ConnectionTune;
            var tuneOk	:ConnectionTuneOk = new ConnectionTuneOk();
           
            
            tuneOk.channelMax 	= tune.channelMax;
            tuneOk.frameMax 	= tune.frameMax;
            tuneOk.heartbeat 	= tune.heartbeat;
            
            transmitFrame(new Frame(tuneOk));
            
            Logger.info("Tuning Connection");
            
			var open:ConnectionOpen = new ConnectionOpen();
            open.virtualHost = authSettings.vhost;
            
            transmitFrame(new Frame(open));
			
			Logger.info("Establishing Connection");	
		}

        private function onConnectionCloseOk(e:MethodEvent):void {
          	stream.close();
        }
	
	    private function onConnectionClose(e:MethodEvent):void {
           var close:ConnectionClose = e.instance as ConnectionClose;
           Logger.log("Connection Error!", close.replyCode, close.replyText);
        }	

		private function onChannelOpen(e:MethodEvent):void {
			state = READY;
		}
		
		private function onConnectionOpenOk(e:MethodEvent):void {
			stream.openChannels(1);
        }
            
        
        private function close():void {
            var close:ConnectionClose = new ConnectionClose();
            close.replyCode = 200;
            close.replyText = "Goodbye";
            transmitFrame(new Frame(close));
        }		 
	}
}