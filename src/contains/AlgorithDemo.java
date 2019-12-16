package contains;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;

public class AlgorithDemo{ 
	
	public  static class MyThread implements Runnable {

		@Override
		public void run() {
			System.out.println("Hello world threaa");
			Thread thread = Thread.currentThread();
			thread.getName();
		}
	}

	public static void main(String[] args) {
		// TODO Auto-generated method stub
//		AlgorithmsStrOfData algorithmsStrOfData = new AlgorithmsStrOfData();
//		
//		algorithmsStrOfData.hashMapDemo();
//		algorithmsStrOfData.treeMapDemo();
//		algorithmsStrOfData.linkedHashMapDemo();
//		algorithmsStrOfData.arrayListDemo();
//		algorithmsStrOfData.linkedList();
//		algorithmsStrOfData.setData();
//		algorithmsStrOfData.enumSet();
//		algorithmsStrOfData.linkedHashMapDemo();
		
		compareObjWolf();
//		person.setName("pesho");
//		
//		System.out.println(person.toString());
		testIsItPalindrome();
		
//		getConstr();
		
	}
	
	
	
	public static void compareObjWolf() {

		Wolf w1 = new Wolf("W1","red", 12);
		Wolf w2 = new Wolf("W2","RED", 12);
		
		boolean result = false;
		
		if (w1.equals(w2)) {
			result = true;
		}
		
		System.out.println("Is equal: " + result);
	}
	
	@SuppressWarnings("unused")
	private static void threadDemo() {
		Thread thread = new Thread(new MyThread(), "My thread");
		thread.getName();
		thread.start();
	}

	public static void testIsItPalindrome() {
		String str = "acababa";
		
		String[] strArray = str.split("");
		int length = strArray.length; 
		int end = length - 1;
		String result = "Palindrome";
		boolean isPolindrome = false;
		for (int i = 0; i < length; i++, end--) {
			if(strArray[i].equals(strArray[end])) {
				isPolindrome = true;
			} else {
				isPolindrome = false;
				break;
			}
		}
		
		String res = isPolindrome ? "It's " + result : "It's not " + result;
		System.out.println(res);
		
//		HashSet<Integer> set = new HashSet<Integer>();
//		set.add(3);
//		set.add(3);
//		set.add(3);
//		set.add(null);
		
//		Iterable<String> iterable = Arrays.asList("Testing", "Iterable", "conversion", "to", "Stream");
//		iterable.forEach(System.out::println);
//		
//		List<String> result = StreamSupport.stream(iterable.spliterator(), false)
//			      .map(String::toLowerCase)
//			      .collect(Collectors.toList());
		
//		System.out.println(result);
	}
	
	public static void getConstr() {
		
	try {
	         // returns the Constructor object of the public constructor
		 Class p = Person.class;
		 Class cls[] = new Class[] { p };
		 for (Class clazz : cls) {
			System.out.println(clazz);
			boolean isAnnotated = clazz.isAnnotation();
			if(isAnnotated) {
				System.out.println(clazz + "is annpotated !");
			}
		}
		 Constructor c1 = p.getDeclaredConstructor();
		 System.out.println("constructor - " + c1);
		 
		 Constructor c = p.getConstructor();
		 System.out.println(c);
		 System.out.println("constructor - " + c);
		 System.out.println("-------Begining of fields-------------");
		 Field[] fields = p.getDeclaredFields();
		for (Field field : fields) {
			System.out.println(field);
		}
		 System.out.println("-------Beggining of methods-------------");
	     Method[] methods = p.getMethods();
	     for (Method method2 : methods) {
			System.out.println(method2);
		}
	  } catch(Exception e) {
	     System.out.println(e);
	  } 
	}

}
