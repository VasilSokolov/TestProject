package com.test.compare;

public class CompareDemo {

	public static void main(String[] args) {
		examTest();

	}
	
	public static void examTest(){
		double r = Math.random();
		double d = Math.round(2.5 + r);
		System.out.println(d + " - " + r);
//		boolean b = null != null;
	}

}
