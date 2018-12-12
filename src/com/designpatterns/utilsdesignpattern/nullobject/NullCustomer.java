package com.designpatterns.utilsdesignpattern.nullobject;

public class NullCustomer extends AbstractCustomer {
	
	@Override
	public boolean isNil() {
		return false;
	}

	@Override
	public String getName() {
		return this.name;
	}

}
