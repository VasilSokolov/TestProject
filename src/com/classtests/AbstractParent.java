package com.classtests;

public abstract class AbstractParent {
	protected String abstractName;
	abstract void goUpHill();	
	
	
	
//	public AbstractParent() {
//		super();
//	}

	public AbstractParent(String abstractName) {
		this.abstractName = abstractName;
	}

	public String getAbstractName() {
		return abstractName;
	}
	public void setAbstractName(String abstractName) {
		this.abstractName = abstractName;
	}
	
	
}
