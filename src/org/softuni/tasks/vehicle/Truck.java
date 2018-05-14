package org.softuni.tasks.vehicle;

public class Truck extends Vehicle {

	private static final double FUEL_CONSUMPTION_INCREASE_INDEX = 1.6;
	private static final double FUEL_MAX_QUANTITY = 0.95;
	
	public Truck(double fuelQuantity, double fuelConsumption) {
		super(fuelQuantity, fuelConsumption);
	}

	
//	@Override
//	public double getFuelQuantity() {
//		return super.getFuelQuantity() * FUEL_MAX_QUANTITY;
//	}


	@Override
	public void setFuelQuantity(double fuelQuantity) {
		super.setFuelQuantity(fuelQuantity);
	}

	@Override
	public void setFuelConsumption(double fuelConsumption) {
		super.setFuelConsumption(fuelConsumption + FUEL_CONSUMPTION_INCREASE_INDEX);
	}


	@Override
	public void drive(double distance) {
		double fuelNeed = super.getFuelConsumption() * distance;
		if (fuelNeed >= super.getFuelQuantity()) {
			throw new FuelQuantityException("Truck needs of refueling");
		}
		
		double remainingFuel = super.getFuelConsumption() - fuelNeed;
		super.setFuelQuantity(remainingFuel);
	}

	@Override
	public void refuel(double liters) {
		super.setFuelQuantity(super.getFuelQuantity() + liters * FUEL_MAX_QUANTITY);
	}
	
	@Override
	public String toString() {
		return String.format("Truck: %.2f", super.getFuelQuantity());
	}
	
}
