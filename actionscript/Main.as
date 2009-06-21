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
	import org.ds.amqp.diagnostics.Logger;
	import org.ds.amqp.events.ConnectionEvent;
	import org.ds.velveteen.Queue;


	public class Main extends Sprite
	{
		
		private var logger		:Logger 	= new Logger(true);
		private var connection	:Connection	= null;
		
		public function Main()
		{
			initExternalInterface();
			initConnection();
		}
		
		//define all API calls for the javascript API
		private function initExternalInterface():void {
		}
		
		private function initConnection():void {
			connection = new Connection("192.168.0.2");
			connection.addEventListener(ConnectionEvent.READY, runTests);
		}
		
		protected function runTests(e:ConnectionEvent):void {
			Logger.log("Running Tests");
			var q:Queue = new Queue(e.connection, "test_queue");
		}
	}
}
