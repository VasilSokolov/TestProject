package com.designpatterns.utilsdesignpattern.servicelocator;

import java.lang.reflect.InvocationTargetException;

public class InitialContext {
	public static final String PACKAGE_PATH = "com.designpatterns.utilsdesignpattern.servicelocator.";
		
	public Object lookup(String ngName) {		
		System.out.println("Looking up and creating a new " + ngName + " object");	
//		System.out.println(ServiceOne.class.getName());
		try {
			Class<?> current = Class.forName(PACKAGE_PATH + ngName);			
			try {
				return current.getConstructor().newInstance();
			} catch (InstantiationException | IllegalAccessException | IllegalArgumentException
					| InvocationTargetException | NoSuchMethodException | SecurityException e) {
				e.printStackTrace();
			}
		} catch (ClassNotFoundException e) {
			return null;
		}
		return null;
	}
}
