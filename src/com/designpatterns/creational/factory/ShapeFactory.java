package com.designpatterns.creational.factory;

public class ShapeFactory {
	public Shape getShape(String shapeType){
		if (shapeType == null) {
			return new Default();
		}
		if (shapeType.equalsIgnoreCase("CIRCLE")) {
			return new Circle();
		}
		if (shapeType.equalsIgnoreCase("SQUARE")) {
			return new Square();
		}
		if (shapeType.equalsIgnoreCase("RECTANGLE")) {
			return new Rectangle();
		}
		
		return new Default();		
	}
}
