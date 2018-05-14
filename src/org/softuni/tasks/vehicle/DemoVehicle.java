package org.softuni.tasks.vehicle;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Arrays;

public class DemoVehicle {

	public static void main(String[] args) throws IOException {
		BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
		VehicleFactory vehicleFactory = new VehicleFactory();
		
		String[] tokens = reader.readLine().split("\\s+");
		
		Vehicle car = vehicleFactory.createVehicle(tokens);
		tokens = reader.readLine().split("\\s+");
		Vehicle truck = vehicleFactory.createVehicle(tokens);
	}
	

}
