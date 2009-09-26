package org.ds.amqp.connection
{
	import flash.events.Event;
	
	import org.ds.amqp.datastructures.FieldTable;
	import org.ds.amqp.protocol.Method;
	import org.ds.amqp.protocol.connection.ConnectionClose;
	import org.ds.amqp.protocol.connection.ConnectionCloseOk;
	import org.ds.amqp.protocol.connection.ConnectionOpen;
	import org.ds.amqp.protocol.connection.ConnectionOpenOk;
	import org.ds.amqp.protocol.connection.ConnectionStart;
	import org.ds.amqp.protocol.connection.ConnectionStartOk;
	import org.ds.amqp.protocol.connection.ConnectionTune;
	import org.ds.amqp.protocol.connection.ConnectionTuneOk;
	import org.ds.logging.Logger;
	
	public class ControlChannel extends Channel
	{
		private var vhost:String = "/";
		
		public function ControlChannel(stream:Stream, virtualHost:String)
		{
			super(0, stream, false);
			
			vhost  = virtualHost;
			state  = "OPEN";
		}
		

		protected override function handleChannelMessages(method:Method):void {

			if(_method is ConnectionTune) {
				onTune(_method as ConnectionTune);
			} else if (_method is ConnectionClose) {
				onClose(_method as ConnectionClose);
			} else if (_method is ConnectionCloseOk) {
				onCloseOk(_method as ConnectionCloseOk);
			} else if (_method is ConnectionStart) {
				onStart(_method as ConnectionStart);
			} else if (_method is ConnectionOpenOk) {
				onOpenOk(_method as ConnectionOpenOk);
			}
			
		}
		
		/*************
		 * 
		 * Negotiation Methods
		 * AMQP requires a handshaking process
		 * 
		 **************/
		private function onStart(start:ConnectionStart):void {

			Logger.info("Handshaking");
			
            var startOk	:ConnectionStartOk 	= new ConnectionStartOk();
			
			startOk.clientProperties.store("product", "AMQP-Flash");
			startOk.clientProperties.store("version", "0.2a");
			
			var credentials:FieldTable = new FieldTable();
			credentials.store("LOGIN", 	"guest");
			credentials.store("PASSWORD", 	"guest");	
				
			startOk.response	= credentials;
			startOk.locale    	= "en_US";
			startOk.mechanism 	= "AMQPLAIN";

			send(startOk);
			
		}
		
		private function onTune(tune:ConnectionTune):void {

			Logger.info("Tuning Connection");
			
            var tuneOk	:ConnectionTuneOk = new ConnectionTuneOk();
           
            tuneOk.channelMax 	= tune.channelMax;
            tuneOk.frameMax 	= tune.frameMax;
            tuneOk.heartbeat 	= tune.heartbeat;
            
            send(tuneOk);

			Logger.info("Establishing Connection");	

			var open:ConnectionOpen = new ConnectionOpen();
            open.virtualHost = vhost;
            
           	send(open);
		}

        private function onClose(close:ConnectionClose):void {
          	_stream.close();
          	Logger.log("Connection Closing unexpectedly!", close.replyCode, close.replyText);
        }
	
	    private function onCloseOk(close:ConnectionCloseOk):void {
           _stream.close();
        }	

		private function onOpenOk(open:ConnectionOpenOk):void {
			dispatchEvent(new Event(Event.COMPLETE));
        }
            
        
       /* private function close():void {
            var close:ConnectionClose = new ConnectionClose();
            close.replyCode = 200;
            close.replyText = "Goodbye";
            send(close);
        }*/
		
	}
}