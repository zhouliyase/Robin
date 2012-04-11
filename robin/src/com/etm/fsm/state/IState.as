package com.etm.fsm.state
{
	public interface IState
	{
		function enter():void;
		function exit():void;
		function update(dt:Number):void;
	}
}
