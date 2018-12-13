package com.designpatterns.utilsdesignpattern.interceptingfilter;

public class Target implements Filter {

	@Override
	public void execute(String request) {
		System.out.println("Executing requesting: " + request);
	}
}
