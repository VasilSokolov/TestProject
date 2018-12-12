package contains;

public class Wolf implements Comparable<Wolf> {
	private String name;
	private String color;
	private int age;
	
	public Wolf() {
	}

	public Wolf(String name, String color, int age) {
		this.name = name;
		this.color = color;
		this.age = age;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((color == null) ? 0 : color.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		return ((Wolf) obj).color == this.color;
	}

	@Override
	public String toString() {
		return "Wolf [name=" + name + ", color=" + color + ", age=" + age + "]";
	}

	@Override
	public int compareTo(Wolf w) {
		return this.age - w.age;
	}
	
}
