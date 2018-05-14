package com.designpatterns.structural.decorator.impl;

import com.designpatterns.structural.decorator.interfaces.Shape;

public class Rectangle implements Shape {

	@Override
	public void draw() {
		System.out.println("Shape: Rectangle");
	}

}
