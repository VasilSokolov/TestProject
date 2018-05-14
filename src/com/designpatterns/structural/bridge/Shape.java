package com.designpatterns.structural.bridge;

import com.designpatterns.structural.bridge.interfaces.DrawAPI;

public abstract class Shape {
	protected DrawAPI drawAPI;

	protected Shape(DrawAPI drawAPI) {
		this.drawAPI = drawAPI;
	}
	
	public abstract void draw();
}
