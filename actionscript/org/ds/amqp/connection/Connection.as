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
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	
	import org.ds.amqp.AMQP;
	import org.ds.amqp.diagnostics.Logger;
	import org.ds.amqp.events.ConnectionEvent;
	import org.ds.amqp.events.MethodEvent;
	import org.ds.amqp.transport.Frame;
	
	public class Connection extends EventDispatcher
	{
		
		//host related properties
		private var host		:String				= null;		
		private var port		:int				= AMQP.PORT;	
		private var user		:String				= null;		
		private var pass		:String				= null;		
		
		private var state		:ConnectionState 	= null;
		private var socket		:Socket				= null;		
		private var queue		:Array				= new Array();
		private var observers	:Array				= new Array();
		private var transmitting:Boolean			= false;
		
		//for round robin channel goodness... maybe not
		//private var sessions	:Dictionary = new Dictionary();
		
		public function Connection(hostName:String, hostPort:int=5672, 
			userName:String="guest", password:String="guest", 
			autoConnect:Boolean=true)
		{
			super();
			
			host = hostName;
			port = hostPort;
			user = userName;
			pass = password;
			
			socket = new Socket();
            socket.addEventListener(Event.CONNECT, 				onConnect);
            socket.addEventListener(Event.CLOSE, 				onClose);
            socket.addEventListener(IOErrorEvent.IO_ERROR, 		onError);
            socket.addEventListener(ProgressEvent.SOCKET_DATA,	onDataReceived);
			
			
			state = new ConnectionState(this);
			
			if(autoConnect) {
				connect();
			}
		}

		public function connect():Boolean {
			
			if(disconnected && !connecting) {
				dispatchEvent(new ConnectionEvent(ConnectionEvent.CONNECTING, this));
				socket.connect(host,port);
			}
			
			return true;
		}

		public function get connecting():Boolean {
			return "NO" == ConnectionEvent.CONNECTING;
		}
		
		public function get disconnected():Boolean {
			return !socket.connected;
		}

		//TODO: Possibly simplify, as AS3 is single threaded
		//and probably doesnt need anything fancy
		public function send(frame:Frame):void {
			
			enqueue(frame);
			
			if(!transmitting) {
				if(!disconnected) {
					transmit();
				} else {
					connect();
				}
			}
		}
		
		public function enqueue(frame:Frame):void {
			queue.push(frame);
		}
	
		public function dequeue():Frame {
			return queue.shift();
		}
		
		private function transmit():void {
			transmitting = true;
			var f:Frame = null;
			while((f = dequeue()) != null) {
				f.encode(socket);
				socket.flush();
			}
			transmitting = false;			
		}
			
		
		protected function onReady(e:ConnectionEvent):void {
			if(queue.length > 0) {
				send(dequeue());
			}
		}
				
		/*
		* Socket Events
		*/
		protected function onConnect(e:Event):void {
			//send the initial message to the AMQP server
			socket.writeUTFBytes("AMQP");
			socket.writeByte(1);
			socket.writeByte(1);
			socket.writeByte(AMQP.PROTOCOL_MAJOR);
			socket.writeByte(AMQP.PROTOCOL_MINOR);
			
			dispatchEvent(new ConnectionEvent(ConnectionEvent.CONNECTED, this));	
		}
				
		protected function onClose(e:Event):void {
			dispatchEvent(new ConnectionEvent(ConnectionEvent.DISCONNECTED, this));
		}
		
		protected function onError(e:IOErrorEvent):void {
			dispatchEvent(new ConnectionEvent(ConnectionEvent.FATAL, this));
		}
		
		//TODO:  Make sure that we are getting all the data before
		//reading it into a frame
		protected function onDataReceived(e:ProgressEvent):void {
						
			
			var frame:Frame = Frame.decode(socket);
			
			Logger.log("Frame Received ", frame.type);
			
			if(frame.valid) {
	
				switch(frame.type) {
					case AMQP.FRAME_METHOD:
						dispatchEvent(new MethodEvent(frame.method));
						break;
					case AMQP.FRAME_HEADER:
						break;
					case AMQP.FRAME_BODY:
						break;
					case AMQP.FRAME_HEARTBEAT:
						Logger.log("Heart Beat");
						break;
					default:
						Logger.log("Unhandled Frame Type");
						break;
				}
				
			}
		}
		
		

	}
}