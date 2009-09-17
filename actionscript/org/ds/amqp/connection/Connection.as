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
	import org.ds.amqp.transport.Frame;
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
		private var stream		:Stream			= null;	
		private var channels	:Array			= [];
		private var control		:ControlChannel	= null;
		
		
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
			
			//define the state transitions, such that each state
			//changes calls a method for us
			defineTransition("*", NEGOTIATING, negotiating);
			defineTransition("*", CLOSED, disconnected);
			defineTransition("*", READY, ready);

			control = new ControlChannel(stream, authSettings.vhost);
			control.addEventListener(Event.COMPLETE, function(e:Event):void {
				state = READY;
			});


			if(autoConnect) {
				connect();
			}
		}

		public function get channel():Channel {
			return channels[channels.length - 1] == null ? createChannel() : channels[channels.length - 1];
		}
		
		
		public function createChannel():Channel {
			channels.push(new Channel(channels.length + 1, stream, true));
			return channel;
		}
		
		
		/*
		* Transitions
		*/
		protected function negotiating():void {
			Logger.info("Socket Connected");
			stream.writeUTFBytes("AMQP");
			stream.writeByte(1);
			stream.writeByte(1);
			stream.writeByte(AMQP.PROTOCOL_MAJOR);
			stream.writeByte(AMQP.PROTOCOL_MINOR);
			stream.flush();
		}
				
		protected function connected():void {
			Logger.info("Connected");
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
		public function get isClosed():Boolean {
			return state == CLOSED;
		}
		
		public function get isConnected():Boolean {
			return stream.connected;
		}

		public function get isReady():Boolean {
			return state == READY;
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
				
			//iterate over the frames we have, and send the frames to
			//each channel respectively		
			while (stream.connected && stream.bytesAvailable > 0) {
				
				var frame:Frame = stream.readFrame();
				
				if(frame.channel == 0) {
					control.receive(frame);
				} else {
					if(channels[frame.channel - 1] is Channel) {
						(channels[frame.channel - 1] as Channel).receive(frame);
					} else {
						Logger.debug("Unexpected Channel on Receive.  Discarding frame.");
						continue;
					}
				}
			}
		}
	}
}