package com.designpatterns.utilsdesignpattern.servicelocator;

public class ServiceLocator {
	private static Cache cache;
	
	static {
		cache = new Cache();
	}
	
	public static Service getService(String ngName) {
		Service service = cache.getServices(ngName);
		
		if (service != null) {
			return service;
		}
		
		InitialContext context = new InitialContext();
		Service service1 = (Service) context.lookup(ngName);
		cache.addService(service1);
		return service1;
	}
}
