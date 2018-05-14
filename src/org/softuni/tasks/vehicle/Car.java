package org.softuni.tasks.vehicle;

public class Car extends Vehicle {

	private static final double FUEL_CONSUMPTION_INCREASE_INDEX = 0.9 ;
	
	public Car(double fuelQuantity, double fuelConsumption) {
		super(fuelQuantity, fuelConsumption);
	}

//	@Override
//	public void setFuelQuantity(double fuelQuantity) {
//		super.setFuelQuantity(fuelQuantity);
//	}

	@Override
	public void setFuelConsumption(double fuelConsumption) {
		super.setFuelConsumption(fuelConsumption + FUEL_CONSUMPTION_INCREASE_INDEX);
	}

	@Override
	public void drive(double distance) {
		double fuelNeed = super.getFuelConsumption() * distance;
		if (fuelNeed >= super.getFuelQuantity()) {
			throw new FuelQuantityException("Car needs of refueling");
		}
		
		double remainingFuel = super.getFuelConsumption() - fuelNeed;
		super.setFuelQuantity(remainingFuel);
		
		System.out.printf("Car traveled %s km", this.decimalFormat.format(distance));
	}

	@Override
	public void refuel(double liters) {
		super.setFuelQuantity(super.getFuelQuantity() + liters);
	}

	@Override
	public String toString() {
		return String.format("Car: %.2f", super.getFuelQuantity());
	}
}
