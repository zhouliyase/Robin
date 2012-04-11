package com.etm.fsm
{
	import com.etm.fsm.state.IState;

	public class StateMachine
	{
		private var currentState:IState;

		public function changeState(s:IState):void
		{
			if (currentState != null)
			{
				currentState.exit();
			}
			currentState=s;
			s.enter();
		}

		public function update(dt:Number):void
		{
			if (currentState != null)
			{
				currentState.update(dt);
			}
		}
	}
}
