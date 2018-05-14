package com.designpatterns.structural.proxy;

public class ProxyPatternDemo {
	
	public static void main(String[] args) {
		
		Image img = new ProxyImage("test_10mb.jpg");
		
		//img will be loaded
		img.display();  
		System.out.println("");
		
		//img will not be loaded from disk
		img.display();		
	}
}
