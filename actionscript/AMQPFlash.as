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

package {
	import flash.display.Sprite;
	
	import org.ds.amqp.connection.Connection;
	import org.ds.fsm.StateEvent;
	import org.ds.logging.Logger;
	import org.ds.velveteen.Exchange;
	import org.ds.velveteen.ExchangeType;
	import org.ds.velveteen.Queue;


	public class AMQPFlash extends Sprite
	{
		
		private var logger		:Logger 	= new Logger(true);
		private var connection	:Connection	= null;
		
		public function AMQPFlash()
		{
			initExternalInterface();
			initConnection();
		}
		
		
		//define all API calls for the javascript API
		private function initExternalInterface():void {
		}
		
		private function initConnection():void {
			connection = new Connection({
				host: "192.168.0.2"
			});
			connection.addEventListener(Connection.READY, runTests);
			
		}
		
		protected function runTests(e:StateEvent):void {
			Logger.log("Running Tests");

						
			var ex:Exchange = new Exchange(connection, "maki", ExchangeType.TOPIC);
			var q:Queue 	= new Queue(connection, "tester");
			
			
			q.subscribe(test);
			
			q.bind(ex, "block", special);
			q.bind(ex, "noblock", noBlock, true);
			
		}
		
		protected function test(message:String):void {
			Logger.log("queue msg", message);
		}
		
		protected function special(message:String):void {
			Logger.log("ex message", message);
		}
		
		protected function noBlock(message:String):void {
			Logger.log("ex message blocked", message);
		}
	}
}
