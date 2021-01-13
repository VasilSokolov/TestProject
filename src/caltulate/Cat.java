package caltulate;

public class Cat implements Comparable<Cat> {

	private String color;
	private int age;
	
	
	
	public Cat() {
		super();
	}



	public Cat(String color, int age) {
		super();
		this.color = color;
		this.age = age;
	}



	public String getColor() {
		return color;
	}



	public void setColor(String color) {
		this.color = color;
	}



	public int getAge() {
		return age;
	}



	public void setAge(int age) {
		this.age = age;
	}



	
	public void run(String name) {
		System.out.println("Run " + name);
	}


	

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + age;
		result = prime * result + ((color == null) ? 0 : color.hashCode());
		return result;
	}



	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Cat other = (Cat) obj;
		if (age != other.age)
			return false;
		if (color == null) {
			if (other.color != null)
				return false;
		} else if (!color.equals(other.color))
			return false;
		return true;
	}



	@Override
	public int compareTo(Cat o) {
		
		return this.age - o.age;
	}

}
