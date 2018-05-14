package com.classtests;

public class Mini extends AbstractSubClass {

	public Mini(String abstractName, int digit) {
		super(abstractName, digit);
		// TODO Auto-generated constructor stub
	}

	@Override
	void foo() {
		System.out.println("foo");
	}

	@Override
	void goUpHill() {
		System.out.println("go up hill");
	}

}
