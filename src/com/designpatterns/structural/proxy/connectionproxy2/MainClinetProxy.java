package com.designpatterns.structural.proxy.connectionproxy2;

public class MainClinetProxy {

	public static void main(String[] args) {
		Internet internet = new ProxyInternet();
		try {
			internet.connectTo("geek.bg");
			//TODO get error
			internet.connectTo("abv.bg");
		} catch (Exception e) {
			System.out.println(e.getMessage());
		}
	}

}
