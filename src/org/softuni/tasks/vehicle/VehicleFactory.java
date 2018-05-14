package org.softuni.tasks.vehicle;

import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.util.Arrays;

public class VehicleFactory {

	@SuppressWarnings("unchecked")
	public Vehicle createVehicle(String[] args) {
		try {
			Class vehicle = Class.forName(args[0]);

			Double[] parameters = Arrays
					.stream(args)
					.skip(1L)
					.map(Double::parseDouble)
					.toArray(Double[]::new);
			Constructor constructor = vehicle.getDeclaredConstructor(double.class, double.class);
			return (Vehicle) constructor.newInstance(parameters[1], parameters[0]);
		} catch (ClassNotFoundException | NoSuchMethodException | SecurityException | InstantiationException | IllegalAccessException | IllegalArgumentException | InvocationTargetException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		return null;
	}
}
