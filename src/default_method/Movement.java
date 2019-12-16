package default_method;

public interface Movement {

	default void move (String name) {
		System.out.println(name + " moving around.");
	}
	
	void run (String name);
	
}
