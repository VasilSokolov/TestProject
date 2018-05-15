package com.classtests;

public class VisibiliteOFClass {

	public static void main(String[] args) {
//		Lion roo = new Lion();
//		roo.testCloo();
//		
//		String name = roo.name;
//		System.out.println(name);
//		
//		roo.secondTest();
//		
//		Animal cloo = new Animal();
//		String name2 = cloo.name;
//		System.out.println("name 2 "+name2);
//		
////		AbstractSubClass as = new AbstractSubClass();
//		System.out.println("-------------------------------------");
//		Mini mini = new Mini();
//		mini.goUpHill();
//		
		System.out.println("-------------------------------------");
		Animal lion = new Lion();
		lion.doSomething();
		
		IRunnable animal = new Animal();
		animal.run();
		
		IRunnable dog = new Dog();
		dog.run();
		
		AbstractParent abstractperant = new ChildClass("Pesho be", 12);
//		abper.abstractName = "cew";
		System.out.println(abstractperant.getAbstractName());
		abstractperant.goUpHill();
		
		AbstractSubClass abstractSubClass = new ChildClass("Pepi", 13);
		abstractSubClass.foo();
		abstractSubClass.goUpHill();
		
	}
}
