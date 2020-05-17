package default_method;

public abstract class Animal implements Movement, MovementParent {

	@Override
	public void move(String name) {
		System.out.println("Moving");
		Movement.super.move(name);
		MovementParent.super.move(name);
	}

	@Override
	public void run(String name) {
		System.out.println(name + " is running.");
	}
	
	
}
