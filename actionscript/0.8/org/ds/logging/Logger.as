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
		private var			_level		:uint 	 = 3;
		
		public function Logger(logLevel:uint=3)
		{
			super();
			
			if(_instance != null) {
				throw new Error("Thy hath declared an instance already");
			}

			_level		= logLevel;
			_instance 	= this;
		}
		
		public function set level(level:uint):void {
			_level = level;
		}
		public function get level():uint {
			return _level;
		}
		
		public static function set level(level:uint):void {
			if(_instance) {
				_instance.level = level;
			}
		}
		
		public static function get level():uint {
			return _instance == null ? 5 : _instance.level;
		}
		
		public static function disable():void {
			level = 5;
		}
		
		public static function enable():void {
			if(_instance == null) {
				new Logger();
			}
			level = 3;
		}
		
		public static function get debugging():Boolean {
			return level == 1;
		}
		
		//critical lvl 3
		public static function log(... args):void {
			filter(3, args);
		}
		
		//non-critical lvl 2
		public static function info(... args):void {
			filter(2, args);
		}
		
		//non-critical lvl 1
		public static function debug(... args):void {
			filter(1, args);
		}
		
		private static function filter(lvl:uint,... args):void {
			if(_instance) {
				_instance.filter(lvl, args);
			}
		}
		
		protected function filter(lvl:uint,... args):void {
			if(_level <= lvl) {
				log(args);
			}
		}
		
		public function log(... args):void {			
			if(level == 1) {
				trace(args);
			}
			for(var i:int = 0;i < args.length;i++) {
				dispatchEvent(new LogEvent(LogEvent.ENTRY, args));
			}
		}
	}
}