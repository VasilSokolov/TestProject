package com.classtests;

public class Animal implements IRunnable {
//	private String name;
	
	public String doSomething(){
		return "Do something";
	}
	
	protected String name;

	@Override
	public void run() {
		System.out.println("Run fast");		
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}
}
