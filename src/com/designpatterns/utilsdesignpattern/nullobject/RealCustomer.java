package com.designpatterns.utilsdesignpattern.nullobject;

public class RealCustomer extends AbstractCustomer {
	
	@Override
	public boolean isNil() {
		return true;
	}

	@Override
	public String getName() {
		return this.name + " Not available in Database";
	}

}
