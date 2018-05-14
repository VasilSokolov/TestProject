package project.test;

public class Animal {
	private String gender; 
	private int legs;
	private int age;
	
	
	public Animal(String gender, int legs, int age) {
		this.gender = gender;
		this.legs = legs;
		this.age = age;
	}	

	public Animal() {
	}

	public String getGender() {
		return gender;
	}


	public void setGender(String gender) {
		this.gender = gender;
	}


	public int getLegs() {
		return legs;
	}


	public void setLegs(int legs) {
		this.legs = legs;
	}


	public int getAge() {
		return age;
	}


	public void setAge(int age) {
		this.age = age;
	}


	@Override
	public String toString() {
		return "The animal gender=" + gender + ", legs=" + legs + ", age=" + age;
	}	
}


