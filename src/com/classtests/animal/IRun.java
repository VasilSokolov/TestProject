package com.classtests.animal;

public interface IRun {
	default void run() {
		System.out.println("Default run");
	};
	
	void walk();
}
