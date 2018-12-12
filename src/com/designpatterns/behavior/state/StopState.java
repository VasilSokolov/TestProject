package com.designpatterns.behavior.state;

public class StopState implements State {

	@Override
	public void doAction(Context context) {
		System.out.println("Player is in stop state");
		System.out.println("this: - " + this);
		context.setState(this);
	}

	@Override
	public String toString() {
		return "Stopt State ";
	}
}
