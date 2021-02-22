package com.classtests.animal;

public class Animal implements IRun {

	@Override
	public void run() {
		System.out.println("Animal run");
	}

	@Override
	public void walk() {
		System.out.println("Animal Walk");
	}
}
