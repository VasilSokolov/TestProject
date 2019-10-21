package com.classtests.animal;

public abstract class AbstractAnimal  {
	private String name;
	
	public void noRun() {
		System.out.println("No run");
	}
	
	public abstract void abstractRun();
}
