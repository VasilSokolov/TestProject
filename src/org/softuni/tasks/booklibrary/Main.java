package org.softuni.tasks.booklibrary;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Arrays;

public class Main {

	public static void main(String[] args) throws NumberFormatException, IOException {
//		
//		BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
//		
//		int inputCount = Integer.parseInt(reader.readLine());
//
//		BookLibrary library = new BookLibrary("name");
//		while (--inputCount >= 0) {
//			String[] inputData = reader.readLine().split("\\s+");
//			
//			Book book = new Book(inputData[0], inputData[0], inputData[0], inputData[0], inputData[0], Double.parseDouble(inputData[0]));
//			library.addBook(book);
//		}
//		System.out.println(library.toString());
		getAvareageDigit();
	}
	
	
	public static void getAvareageDigit() {
		double[] arr = new double[] {2.2, 4.4};
		double result = Arrays.stream(arr).average().orElse(0d);
		System.out.println(result);
	}

}
