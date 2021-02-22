package com.classtests.animal;

public class Cat extends Animal {

	private Long id;
	private String name;
	private int age;
	private String bread;
	private boolean isAlive;
	
	public void zlati() {
		System.out.println(name);
	}
	@Override
	public void run() {
		System.out.println("Cat run");
	}


	public Long getId() {
		return id;
	}


	public void setId(Long id) {
		this.id = id;
	}


	public String getName() {
		return name;
	}


	public void setName(String name) {
		this.name = name;
	}

	public int getAge() {
		return age;
	}

	public void setAge(int age) {
		this.age = age;
	}

	public String getBread() {
		return bread;
	}


	public void setBread(String bread) {
		this.bread = bread;
	}


	public boolean isAlive() {
		return isAlive;
	}


	public void setAlive(boolean isAlive) {
		this.isAlive = isAlive;
	}
	
	@Override
	public String toString() {
		return "Cat {id=" + id + ", name=" + name + ", age=" + age + ", bread=" + bread + ", isAlive=" + isAlive + "}";
	}

	
}
