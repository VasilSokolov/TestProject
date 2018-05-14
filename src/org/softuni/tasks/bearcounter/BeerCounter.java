package org.softuni.tasks.bearcounter;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Arrays;

public class BeerCounter {

	public static int bearInStock;
	public static int beersDrankCount;
	
	public static void main(String[] args) throws IOException {
		BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));

		String line;
		
		while (!"End".equalsIgnoreCase(line = reader.readLine())) {
			int[] bottles = Arrays.stream(line.split("\\s+")).mapToInt(Integer::parseInt).toArray();
		
			BeerCounter.buyBeer(bottles[0]);
			BeerCounter.drinkBeer(bottles[1]);			
		}
		
		System.out.printf("%d %d", BeerCounter.bearInStock, BeerCounter.beersDrankCount);
	}
	
	public static void buyBeer(int bottlesCount) {
		BeerCounter.bearInStock += bottlesCount;
	}

	public static void drinkBeer(int bottlesCount) {
		BeerCounter.beersDrankCount += bottlesCount;
		BeerCounter.beersDrankCount -= bottlesCount;
	}
}
