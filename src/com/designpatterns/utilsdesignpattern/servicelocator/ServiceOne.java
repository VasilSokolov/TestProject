package com.designpatterns.utilsdesignpattern.servicelocator;

public class ServiceOne implements Service {

	@Override
	public String getName() {
		return "ServiceOne";
	}

	@Override
	public void execute() {
		System.out.println("Executing ServiceOne");
	}
}
