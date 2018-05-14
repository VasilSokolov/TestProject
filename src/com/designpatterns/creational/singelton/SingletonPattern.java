package com.designpatterns.creational.singelton;

public class SingletonPattern {
	//create an object of SingletonPattern
	private static SingletonPattern instance = null;
	
	//make the constructor private so that this class cannot be instantiated
	private SingletonPattern(){}
	
	//get the only object available
	public static SingletonPattern getInstance(){
		if(instance == null) {
			instance = new SingletonPattern();
		}
		return instance;
	}
	
	//or threadsafe
	
	public void showMessage(){
		System.out.println("Singelton Pattern Message");
	}
}
