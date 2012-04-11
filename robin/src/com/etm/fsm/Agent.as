package com.etm.fsm
{
	import com.etm.fsm.state.IState;

	public class Agent
	{
		protected var sm:StateMachine;

		public function Agent()
		{
			sm=new StateMachine();
		}

		public function update(dt:Number):void
		{
			sm.update(dt);
		}

		public function changeState(s:IState):void
		{
			sm.changeState(s);
		}
	}
}
