package com.designpatterns.creational.prototype;

//import java.util.Hashtable;

public class PrototypePatternDemo {

	public static void main(String[] args) {
//		Hashtable<String, Shape> shapes = ShapeCache.loadCache();
		ShapeCache.loadCache();
//		System.out.println("Shapes" + shapes.toString());
		Shape clonedShape = (Shape) ShapeCache.getShape("1");
		System.out.println("Shape : " + clonedShape.getType());

		Shape clonedShape2 = (Shape) ShapeCache.getShape("2");
		System.out.println("Shape : " + clonedShape2.getType());

		Shape clonedShape3 = (Shape) ShapeCache.getShape("3");
		System.out.println("Shape : " + clonedShape3.getType());
	}
}
