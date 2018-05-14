package org.softuni.tasks.vehicle;

import java.text.DecimalFormat;

public abstract class Vehicle {
	
	private double fuelQuantity;
	private double fuelConsumption;
	protected DecimalFormat decimalFormat;
	
	protected Vehicle(double fuelQuantity, double fuelConsumption) {
		this.setFuelQuantity(fuelQuantity);
		this.setFuelConsumption(fuelConsumption);
		this.decimalFormat = new DecimalFormat("#.##########");
	}

	public double getFuelQuantity() {
		return fuelQuantity;
	}


	public void setFuelQuantity(double fuelQuantity) {
		this.fuelQuantity = fuelQuantity;
	}


	public double getFuelConsumption() {
		return fuelConsumption;
	}


	public void setFuelConsumption(double fuelConsumption) {
		this.fuelConsumption = fuelConsumption;
	}

	public abstract void drive(double distance);
	public abstract void refuel(double liters);
	
	
}
