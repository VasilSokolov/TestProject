package com.classtests.animal;

public class Main {

	public static void main(String[] args) {
		
		IRun animal = new Animal();
		animal.run();
		IRun cat = new Cat();
		cat.run();
		
		AbstractAnimal abstractAnimal = new Dog();
		abstractAnimal.abstractRun();
	}
}
