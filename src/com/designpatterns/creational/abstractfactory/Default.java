package com.designpatterns.creational.abstractfactory;

public class Default implements Shape{

	@Override
	public void draw() {
		System.out.println("The object with that name is not exist");
	}
	
}
