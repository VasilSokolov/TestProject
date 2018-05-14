package com.designpatterns.behavior.observer;

public abstract class Observer {
	protected Subject subject;

	public abstract void update();
}
