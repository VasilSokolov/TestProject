package com.designpatterns.creational.abstractfactory;

public class ColorFactory extends AbstractFactory{

	@Override
	Shape getShape(String shape) {
		return null;
	}

	@Override
	Color getColor(String color) {
		if (color.equalsIgnoreCase("red")) {
			return new Red();
		}
		if (color.equalsIgnoreCase("blue")) {
			return new Blue();
		}
		if (color.equalsIgnoreCase("green")) {
			return new Green();
		}
		
		return null;
	}

}
