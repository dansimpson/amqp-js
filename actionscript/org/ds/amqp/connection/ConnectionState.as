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
	import org.ds.amqp.datastructures.FieldTable;
	import org.ds.amqp.diagnostics.Logger;
	import org.ds.amqp.events.ConnectionEvent;
	import org.ds.amqp.events.MethodEvent;
	import org.ds.amqp.protocol.connection.Close;
	import org.ds.amqp.protocol.connection.CloseOk;
	import org.ds.amqp.protocol.connection.Open;
	import org.ds.amqp.protocol.connection.OpenOk;
	import org.ds.amqp.protocol.connection.Start;
	import org.ds.amqp.protocol.connection.StartOk;
	import org.ds.amqp.protocol.connection.Tune;
	import org.ds.amqp.protocol.connection.TuneOk;
	
	public class ConnectionState
	{
		public static var DISCONNECTED	:String = "DISCONNECTED";
		public static var CONNECTING	:String = "CONNECTING";
		public static var CONNECTED		:String = "CONNECTED";
		
		private var conn	:Connection	= null;
		private var state	:String		= DISCONNECTED;
		
		public function ConnectionState(connection:Connection) {
			conn = connection;
			
			conn.addEventListener(new Start().toString(), 	onStart);
			conn.addEventListener(new Tune().toString(), 	onTune);
			conn.addEventListener(new OpenOk().toString(), 	onOpenOk);
			conn.addEventListener(new CloseOk().toString(), onCloseOk);
		}
		
		public function set connecting(b:Boolean):void {
			state = CONNECTING;
		}
	
		public function get connecting():Boolean {
			return state == CONNECTING;
		}
		
		/*
		* Handle Methods
		*/
		protected function onStart(e:MethodEvent):void {
			
			Logger.log("Start");
			
         	var start	:Start 		= e.instance as Start;
            var startOk	:StartOk 	= new StartOk();

            startOk.clientProperties 	= new FieldTable();
            startOk.response 			= new FieldTable();
            
			startOk.clientProperties.store("product", "AMQP-Flash!");
			startOk.clientProperties.store("version", "0.2a");
			
			startOk.response.store("LOGIN", 	"guest");
			startOk.response.store("PASSWORD", 	"guest");	
				
			startOk.locale    	= "en_US";
			startOk.mechanism 	= "AMQPLAIN";

			conn.send(startOk.toFrame());
			
			Logger.log("Start Ok Sent");
		}
		
		protected function onTune(e:MethodEvent):void {
			
			Logger.log("Tune");
				
			var tune	:Tune 	= e.instance as Tune;
            var tuneOk	:TuneOk = new TuneOk();
            var open	:Open 	= new Open();
            
            tuneOk.channelMax 	= tune.channelMax;
            tuneOk.frameMax 	= tune.frameMax;
            tuneOk.heartbeat 	= tune.heartbeat;
            
            //send tune response
            conn.send(tuneOk.toFrame());
            
            open.virtualHost 	= "/";
            open.capabilities 	= "";
            open.insist 		= false;
            
            conn.send(open.toFrame());
			
			Logger.log("Tune Ok Sent");
		}
		
		
		protected function onOpenOk(e:MethodEvent):void {
			//state = open
			conn.dispatchEvent(new ConnectionEvent(ConnectionEvent.READY, conn));
        }
        
         private function close():void {
            var close:Close = new Close();
            close.replyCode = 200;
            close.replyText = "Goodbye";

			conn.send(close.toFrame());
        }
        
        
        protected function onCloseOk(e:MethodEvent):void {
           // state = closed;
        }
	}
}