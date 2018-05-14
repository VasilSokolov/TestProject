package com.designpatterns.behavior.mediator;

public class MediatorPatternDemo {
	public static void main(String[] args) {
		User tedi = new User("Tedi");
		User vasil = new User("Vasil");
		
		tedi.sendMessage("Hello, Vasil ;)");
		vasil.sendMessage("Hello, Tedi :)");
	}
}
