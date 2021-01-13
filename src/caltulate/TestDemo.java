package caltulate;

import java.awt.image.RescaleOp;
import java.util.Arrays;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

public class TestDemo {

	public static final String EMPTY_STRING = " ";
//	private String myName;
//	public TestDemo(String name) {
//		myName = name;
//	}
	
	public static void main(String... args) {
//		List<Integer> listOfcostId = new LinkedList<Integer>(Arrays.asList(10,11,12,16,17,19,37,40,42,43));
//	  
//	    int index = Collections.binarySearch(listOfcostId, 10);
//	    Integer costId = 0;
//	    if(index >= 0) {
//	    	costId =  listOfcostId.get(index);
//	    }
//	    System.out.println(costId);
//		Animal dog = new Dog();
//		dog.run("dog");
//		dog.fly("dog");
//		Animal dog1 = new Animal() {
//			
//			@Override
//			public void run(String name) {
//				// TODO Auto-generated method stub
//				
//			}
//		};
//		
//		dog1.fly("animal");
//		reversedString();
//		treeMap();
		
		List<String> list = new LinkedList<String>();
		list.add("AAAA");
		list.add("ssss");
		list.add("sdsdsd");
		list.add("qweqwe");
		list.add(2, "eeeeee00");
		System.out.println(list);
		
	}
	
	
	private static void treeMap() {
		Map person = new TreeMap<Cat, Integer>();
		person.put(new Cat("yellow", 6), 4);
		person.put(new Cat("brown", 11), 6);
		person.put(new Cat("black", 8), 9);
		person.put(new Cat("red", 17), 2);
		
		System.out.println(person.get(1));
	}
	
	public static void ts() {
		TestDemo test = new TestDemo();
		TestDemo test1 = new TestDemo();
		TestDemo test12 = new TestDemo();
		
		String[] name = {"Zlatka", "vasil", "Belgrad", "Sofia"};
		
//		String result = test.zlati(name);
//	    System.out.println(result);	
	    
//		Map m = Map.of("name", "peee");
		String zl = name[2];
		
	    int result2 = TestDemo.calc(5, 8);
	    int result3 = TestDemo.calc(6, 2);
	    int res = TestDemo.calc(result2, result3);
	    System.out.println(res);	
	}
	
	public static void reversedString(){
		String input = "H  ELLO BUNNY  LA    ";
		String result = "";
		String[] args = input.trim().split("");
		for(int i = args.length - 1; i >= 0; i--) {
			if (!args[i].equals(EMPTY_STRING)) {			
				String res = result + args[i];
				result = res;
			}
		}
		
		System.out.println(result);
	}
	
	
//	static {
//		System.out.println("static Zlati");
//	}
	
	{
		System.out.println("Zlati");
	}
	
	
	public String zlati (String[] name) {
		String data = String.format("%s %s", name[1] , "25");
		
		return data;
	}
	
	public static int calc(int x1, int x2) {
		int result = x1+ x2;
		
		return result;
	}
	
	public static String z(String name){
		return name + "static";
		
	}

}
