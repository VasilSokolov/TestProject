package com.designpatterns.structural.decorator.impl;

import com.designpatterns.structural.decorator.interfaces.Shape;

public abstract class ShapeDecorator implements Shape {
	protected Shape decoratorShape;

	public ShapeDecorator(Shape decoratorShape) {
		this.decoratorShape = decoratorShape;
	}

	@Override
	public void draw() {
		decoratorShape.draw();
	}
}
