package com.designpatterns.utilsdesignpattern.nullobject;

public class RealCustomer extends AbstractCustomer {
	
	private String name;
	
	public RealCustomer(String name) {
		this.name = name;
	}

	@Override
	public boolean isNil() {
		return true;
	}

	@Override
	public String getName() {
		return this.name + " Not available in Database";
	}

}
