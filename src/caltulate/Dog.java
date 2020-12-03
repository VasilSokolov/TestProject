package caltulate;

public class Dog extends Animal {

	@Override
	public void run(String name) {
		System.out.println("Run " + name);
	}
	
	public void fly(String name) {
		System.out.println("fly" + name);
	}

}
