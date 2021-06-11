package project.test;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class SomeTest {

	public static void main(String[] args) {
		countItems();	
		listAnimal();
	}

	public static void countItems() {
		String[] items = { "A", "B", "C", "D" };

		int i = 0;
		for (String item : items) {
			System.out.println(++i + " - " + item);
		}
		System.out.println("");

		i = 0;
		for (String item : items) {
			System.out.println(i++ + " - " + item);
		}
	}
	
	public static void listAnimal(){
		Animal lion = new Animal("male", 4, 15);
		Animal eagle = new Animal();
		eagle.setGender("female");
		
		if(lion instanceof Animal){
			System.out.println("Yes is it");
		}else{
			System.out.println("No");
		}
		
		System.out.println("Liaon: "+lion.toString()+ "\nEagle: " + eagle.toString());
	}

	public static Map<String, Object> testMaps() {
		
//		HashMap<String, Object> map = (HashMap<String, Object>) Map.of("mapK1", new Object(), "mapK2", new Object(), "mapK3", new Object(), "mapK4", new Object(), "mapK5", new Object());
//		ArrayList<String> list = List.of("listData1", "listData2");
//		return Map.of("mapK1", new Object(), "mapK2", Map.of("mapK1", new Object(), "mapK2", new Object()), "mapK3", List.of("listData1", "listData2"), "mapK4", new Object(), "mapK5", new Object());
	return null;
	}
}
