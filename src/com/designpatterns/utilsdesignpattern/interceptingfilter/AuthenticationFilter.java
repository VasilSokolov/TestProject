package com.designpatterns.utilsdesignpattern.interceptingfilter;

public class AuthenticationFilter implements Filter {

	@Override
	public void execute(String request) {
		System.out.println("Authentication request: " + request);
	}
}
