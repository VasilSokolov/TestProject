package com.classtests;

public abstract class AbstractSubClass extends AbstractParent {
	abstract void foo();
	private int digit;		
	
//	public AbstractSubClass() {
//		super();
//	}

	public AbstractSubClass(String abstractName, int digit) {
		super(abstractName);
		this.digit = digit;
	}
	
	public int getDigit() {
		return digit;
	}
	public void setDigit(int digit) {
		this.digit = digit;
	}
}
