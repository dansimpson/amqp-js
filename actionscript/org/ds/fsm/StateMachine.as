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