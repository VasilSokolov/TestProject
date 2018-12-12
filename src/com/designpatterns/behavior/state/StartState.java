package com.designpatterns.behavior.state;

public class StartState implements State {
	private String name;
	
	@Override
	public void doAction(Context context) {
		System.out.println("Player is in start state");
		System.out.println("this: - " + this);
		System.out.println();
		context.setState(this);
	}

	@Override
	public String toString() {
		return "Start State ";
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}
	
	
}
