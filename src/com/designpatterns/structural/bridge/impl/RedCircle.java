package com.designpatterns.structural.bridge.impl;

import com.designpatterns.structural.bridge.interfaces.DrawAPI;

public class RedCircle implements DrawAPI {

	@Override
	public void drawCircle(int radius, int x, int y) {
		System.out.println("Drawing Circle[ color: red, radius: " + radius + ", x: " + x + ", " + y + "]");
	}
	
}
