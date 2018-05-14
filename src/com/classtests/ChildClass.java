package com.classtests;

public class ChildClass extends AbstractSubClass {

	public ChildClass(String abstractName, int digit) {
		super(abstractName, digit);
		// TODO Auto-generated constructor stub
	}

	@Override
	void foo() {
		System.out.println("Child class foo");		
	}

	@Override
	void goUpHill() {
		System.out.println("Child class up to hill" + this.getAbstractName() + this.getDigit());		
	}
}
