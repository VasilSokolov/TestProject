package com.designpatterns.creational.abstractfactory;

public class ShapeFactory extends AbstractFactory{

	@Override
	Shape getShape(String shape) {
		if (shape.equalsIgnoreCase("rectangle")) {
			return new Rectangle();
		}
		if (shape.equalsIgnoreCase("CIRCLE")) {
			return new Circle();
		}
		if (shape.equalsIgnoreCase("square")) {
			return new Square();
		}
		return new Default();
	}

	@Override
	Color getColor(String color) {
		return null;
	}

}
