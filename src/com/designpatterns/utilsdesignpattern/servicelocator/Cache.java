package com.designpatterns.utilsdesignpattern.servicelocator;

import java.util.ArrayList;
import java.util.List;

public class Cache {

	private List<Service> services;

	public Cache() {
		this.services = new ArrayList<Service>();
	}

	public Service getServices(String serviceName) {
		for (Service service : services) {
			if (service.getName().equalsIgnoreCase(serviceName)) {
				System.out.println("Returning cached " + serviceName + " object");
				return service;
			}
		}
		return null;
	}
	
	public void addService(Service newService) {
		services.add(newService);
	}
}
