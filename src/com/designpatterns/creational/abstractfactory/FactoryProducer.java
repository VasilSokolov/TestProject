package com.designpatterns.creational.abstractfactory;

public class FactoryProducer {
	public static AbstractFactory getFactory(String choice){
		
		if (choice.equalsIgnoreCase("Shape")) {
			return new ShapeFactory();
		}
		if (choice.equalsIgnoreCase("color")) {
			return new ColorFactory();
		}
		
		return null;		
	}	
}
