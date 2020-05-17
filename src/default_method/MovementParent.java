package default_method;

public interface MovementParent {

	default void move (String name) {
		System.out.println(name + " moving parent around.");
	}
}
