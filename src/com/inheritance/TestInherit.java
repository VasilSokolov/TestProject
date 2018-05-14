package com.inheritance;

public class TestInherit {

	public static void main(String[] args) {
		A a = new C();
		a.a = "A2";
		
		A a2 = new A();
		a2.a = "A3";

		C c = new C();
		c.a = "C2";
	}

}
