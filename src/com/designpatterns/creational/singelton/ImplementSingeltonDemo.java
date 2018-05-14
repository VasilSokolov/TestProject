package com.designpatterns.creational.singelton;

public class ImplementSingeltonDemo {

	public static void main(String[] args) {

		//get the only object available
		SingletonPattern singleton = SingletonPattern.getInstance();
		singleton.showMessage();
	}
}
