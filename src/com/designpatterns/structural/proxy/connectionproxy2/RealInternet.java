package com.designpatterns.structural.proxy.connectionproxy2;

public class RealInternet implements Internet {

	@Override
	public void connectTo(String serverhost) throws Exception {
		System.out.println("Access Granted !!!");
		System.out.println("Connecting to - " + serverhost);
	}
	
}
