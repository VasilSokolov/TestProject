package com.designpatterns.utilsdesignpattern.servicelocator;

public class InitialContext {
	public Object lookup(String ngName) {
		if (ngName.equalsIgnoreCase("SERVICEOne")) {
			System.out.println("Looking up and creating a new Service One object");
			return new ServiceOne();
		} else if (ngName.equalsIgnoreCase("SERVICETwo")) {
			System.out.println("Looking up and creating a new Service Two object");
			return new ServiceTwo();
		}
		return null;
	}
}
