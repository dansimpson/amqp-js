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

package org.ds.logging
{
	import flash.events.EventDispatcher;

	public class Logger extends EventDispatcher
	{
		
		private static var 	_instance	:Logger  = null;
		private var 		_trace		:Boolean = true;
		
		public function Logger(traceEntries:Boolean=true)
		{
			super();
			
			if(_instance != null) {
				throw new Error("Thy hath declared an instance already");
			}

			_trace 		= traceEntries;
			_instance 	= this;
			
		}
		
		public static function log(... args):void {
			if(_instance) {
				_instance.log(args);
			}
		}
		
		public function log(... args):void {
			if(_trace) {
				trace(args);
			}
			
			for(var i:int = 0;i < args.length;i++) {
				dispatchEvent(new LogEvent(LogEvent.ENTRY, args[i]));
			}
		}
	}
}