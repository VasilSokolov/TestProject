package superClassTest;

public class B extends A {
	private static int x;
	private String color;
	
	public B() {
	}

	B(int id, String name, int age, String color) {
		super(id, name, age);
		this.color = color;
	}
	
	B(int y){
		super(y);
	}

	public static int getX() {
		return x;
	}

	public static void setX(int x) {
		B.x = x;
	}

	public String getColor() {
		return color;
	}

	public void setColor(String color) {
		this.color = color;
	}

	@Override
	public String toString() {
		return "B [name=" + name + ", age=" + age + ", color=" + color + "]";
	}

	
}
