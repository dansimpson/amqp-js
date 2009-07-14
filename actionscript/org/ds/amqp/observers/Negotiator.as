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

package org.ds.amqp.observers
{
	import org.ds.amqp.connection.Connection;
	import org.ds.amqp.datastructures.FieldTable;
	import org.ds.amqp.events.MethodEvent;
	import org.ds.amqp.protocol.connection.Close;
	import org.ds.amqp.protocol.connection.CloseOk;
	import org.ds.amqp.protocol.connection.Open;
	import org.ds.amqp.protocol.connection.Start;
	import org.ds.amqp.protocol.connection.StartOk;
	import org.ds.amqp.protocol.connection.Tune;
	import org.ds.amqp.protocol.connection.TuneOk;
	import org.ds.logging.Logger;
	
	public class Negotiator extends Observer
	{
		public function Negotiator(connection:Connection)
		{
			super(connection);
			
			//connection events
			on(new Start().toString()	, 	onConnectionStart);
			on(new Tune().toString()	, 	onConnectionTune);
			on(new CloseOk().toString()	, 	onConnectionCloseOk);
			on(new Close().toString()	, 	onConnectionClose);
		}
		
		protected function get connection():Connection {
			return target as Connection;
		}
		
		protected function onConnectionStart(e:MethodEvent):void {

         	var start	:Start 		= e.instance as Start;
            var startOk	:StartOk 	= new StartOk();

            startOk.clientProperties = new FieldTable();
			startOk.clientProperties.store("product", "AMQP-Flash");
			startOk.clientProperties.store("version", "0.2a");
			
			var credentials:FieldTable = new FieldTable();
			credentials.store("LOGIN", 	"guest");
			credentials.store("PASSWORD", 	"guest");	
				
			startOk.response	= credentials;
			startOk.locale    	= "en_US";
			startOk.mechanism 	= "AMQPLAIN";

			connection.send(startOk.toFrame());
			
			Logger.log("Starting Connection");
		}
		
		protected function onConnectionTune(e:MethodEvent):void {

			var tune	:Tune 	= e.instance as Tune;
            var tuneOk	:TuneOk = new TuneOk();
           
            
            tuneOk.channelMax 	= tune.channelMax;
            tuneOk.frameMax 	= tune.frameMax;
            tuneOk.heartbeat 	= tune.heartbeat;
            
            //send tune response
            connection.send(tuneOk.toFrame());
            
            Logger.log("Tuning Connection");
            
			openConnection();
		}

        protected function onConnectionCloseOk(e:MethodEvent):void {
           //state = closed;
        }
	
	    protected function onConnectionClose(e:MethodEvent):void {
           var close:Close = e.instance as Close;
           Logger.log(close.replyCode, close.replyText);
        }	

 		protected function openConnection():void {
			
			var open	:Open 	= new Open();
			 
            open.virtualHost 	= "/";
            open.capabilities 	= "";
            open.insist 		= false;
            
            connection.send(open.toFrame());
			
			Logger.log("Opening Connection");			
		}
		
                       
         private function close():void {
            var close:Close = new Close();
            close.replyCode = 200;
            close.replyText = "Goodbye";
			connection.send(close.toFrame());
        }
        
        

	}
}