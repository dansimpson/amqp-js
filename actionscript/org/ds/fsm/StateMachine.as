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

package org.ds.fsm
{
	import flash.events.EventDispatcher;

	public class StateMachine extends EventDispatcher
	{
		public static var STATE_CHANGE:String = "STATE_CHANGE";
		
		private var _state:String;
		private var _transitions:*;
		
		public function StateMachine(defaultState:String)
		{
			super();
			
			_state 			= defaultState;
			_transitions 	= {};
		}
		
		public function defineTransition(fromState:String, toState:String, method:Function):void {
			_transitions[transitionName(fromState, toState)] = method;
		}
		
		public function set state(state:String):void {

			//execute registered callbacks
			var methods:Array = [
				transitionName(_state,state),
				transitionName(_state, "*"),
				transitionName("*", state)
			];
			
			methods.forEach(executeTransition);
			
			_state = state;
			
			//dispatch event for listeners
			dispatchEvent(new StateEvent(state));
		}
		
		private function executeTransition(name:String, i:int, array:Array):void {
			if(_transitions[name] && _transitions[name] is Function) {
				_transitions[name]();
			}				
		}
		
		public function get state():* {
			return _state;
		}
		
		protected function transitionName(f:String,t:String):String {
			return f.toString() + "." + t.toString();
		}
		
	}
}