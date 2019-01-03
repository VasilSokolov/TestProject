package com.designpatterns.utilsdesignpattern.data_access_object;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.function.Function;
import java.util.function.Predicate;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import com.designpatterns.structural.composite.Employee;
//import java.util.logging.*;

public class DaoPatternDemo {
//	private static Logger logger = Logger.getLogger(DaoPatternDemo.class.getName());
	
	private static final int ID = 4;
	private static StudentDao students = new StudentDaoImp();
	private static Student student;
	
	public static void main(String[] args) {
		int[] input = {7,4,0,3,5,6};
		System.out.println(min(input));
//		studentCrudOperations();
//		streamsManipulations();
//		streamsManipulations();
		
//		streamsTest();
		
		PojoEmployee pojoEmpl = new PojoEmployee();
		List<PojoEmployee> list = new ArrayList<>();
		list.add(new PojoEmployee());
		list.add(new PojoEmployee());
		list.add(new PojoEmployee());
		list.get(1);
		Optional<PojoEmployee> opt1 = Optional.ofNullable(pojoEmpl);
		Optional<PojoEmployee> opt = Optional.ofNullable(null);
		System.out.println(opt1.get().getName());
	}
	
	public static int min(int[] arr) {
		int min = arr[0];
		int min2 = arr[1];
		
		for (int i = 0; i < arr.length; i++) {
			if (arr[i] < min) {
				min2 = min;
				min = arr[i];
			} else if(arr[i] < min2) {
				min2 = arr[i];
			}
		}
		
		return min2;
	}
	
	public static void streamsTest() {
		
//		List<String> streams = new ArrayList<>();
//		String s = "AMAN,AMITABH,LOKESH,RAHUL,SALMAN,SHAHRUKH,SHEKHAR,YANA";
//        String[] arr = s.split(",");
//		for(int i = 0; i < arr.length; i++){
//            streams.add(arr[i]);
//        }
//		System.out.println(arr.length);
//        streams.stream().sorted()
//        .map(String::toLowerCase)
//        .forEach(System.out::println);
        
        HashSet<Integer> set = new HashSet<>();
        set.add(2);
        set.add(1);
        set.add(6);
        set.add(4);
        set.add(3);
        Object[] arr = set.toArray();
        
        Arrays.sort(arr);
        for(int i = 0 ; i < arr.length ; i++) {
        	System.out.println(arr[i]);
        }

    	System.out.println(arr instanceof  Object);

        Stream<Integer> stream = set.stream();
//        stream.forEach(p -> System.out.println(p));
        Integer[] evenNumbersArr = stream.toArray(Integer[]::new);
//        System.out.println(evenNumbersArr);

		for (Integer integer : evenNumbersArr) {
			System.out.println(integer);
		}
//		 IntStream intStream = "12345_abcdefg".chars();
//		 intStream.forEach(p -> System.out.println(p));
//        //OR 
//         System.out.println();
//		 
//        Stream<String> stream = Stream.of("A$B$C".split("\\$"));
//        stream.forEach(p -> System.out.println(p));

//		Stream<Integer> stream = Stream.of(1,2,3,4,5,6,7,8,9);
//        stream.forEach(p -> System.out.println(p));
//        System.out.println();
        
//        Stream<Date> streamDate = Stream.generate(() -> { return new Date(); });
//        streamDate.forEach(p -> System.out.println(p));
	}

	public static void streamsManipulations() {
//		List<String> listOfNames = new ArrayList<>();
		String name = students.getAllStudents().stream()
				.filter(s -> ID == s.getRollNo())
				.map(s ->s.getName())
				.findFirst()
				.orElse(null);
		System.out.println(name);
		
		List<Employee> employees = students.getAllStudents().stream()
				.map(e-> new Employee(e.getName()))
				.collect(Collectors.toList());
				System.out.println(employees);
				
//		List<String> listOfNames = students.getAllStudents().stream()
//				.map(n -> n.getName())
//				.collect(Collectors.toList());
//		System.out.println(listOfNames.toString());
		List<String> myList =
			    Arrays.asList("a1", "a2", "b1", "c2", "c1");

		myList
			.stream()
		    .filter(s -> s.startsWith("c") || s.startsWith("a"))
		    .map(String::toUpperCase)
		    .sorted()
		    .forEach(p-> System.out.println(p));
		
		 Stream<String> names4 = Stream.of("Pesho","Anita","Dido", "Lisana", "Doncho");
		 Optional<String> firstNameWithD = names4.filter(i -> i.startsWith("z")).findFirst();
		 
		 if(firstNameWithD.isPresent()){
		 	System.out.println("First Name starting with D="+firstNameWithD.get()); //Dido
		 }
		 System.out.println();
		 Arrays.asList("a1a2a3"+"a4"+"a5")
		    .stream()
		    .findAny()
		    .ifPresent(p-> {System.out.println(p);});
		 
		 System.out.println();
	}
	
	public static <T> Predicate<T> distinctByKeys(Function<? super T, Object> keyExtractor) {
		Map<Object, Boolean> seen =  new ConcurrentHashMap<Object, Boolean>();
		
		return t ->seen.putIfAbsent(keyExtractor.apply(t), Boolean.TRUE) == null;
	}
	
	public static List<Employee> getlist() {
		return Arrays.asList(
				new Employee("Roni", "LM", 2000),
				new Employee("Pedro", "SNN", 1500)
				);
	}
	
	public static void parallelStream() {
		List<Integer> ss = Arrays.asList(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15);
		List<Integer> result = new ArrayList<Integer>();
		 
		Stream<Integer> stream = ss.parallelStream();
		 
		stream.map(s -> {
		        synchronized (result) {
		          if (result.size() < 10) {
		            result.add(s);
		          }
		        }
				return s;
		    }).forEach(e -> {});
		 System.out.println(result);
	}
	
	public static void studentCrudOperations() {
		printAllStudents();
		if (getStudent(ID)) {
			printUpdateStudent();
			printDeleteStudent();
			printGetStudent();
		}
		System.out.println("Student is not in Database with id=" + ID);
	}
	
	public static boolean getStudent(int id) {
		try {
			student = students.getAllStudents().stream()
					.filter(s-> id == s.getRollNo())
					.findAny()
					.orElse(null);
			return student != null ? true : false;
	    } catch (IndexOutOfBoundsException error) {
	        // Output expected IndexOutOfBoundsExceptions.
			System.out.println("Student is not in Database with id " + id);
	    	System.out.println(error);
	    	return false;
//	    	logger.log(error);
	    } catch (Exception | Error exception) {
	        // Output unexpected Exceptions/Errors.
//	        logger.log(Level.WARNING, exception, false);
	    	System.out.println(exception);
	    	return false;
	    }
	}
	
	public static void printAllStudents() {
		for (Student student : students.getAllStudents()) {
			System.out.println(student.toString());
		}
		System.out.println();
	}
	
	public static void printUpdateStudent() {
		student.setName("Anna");		
		students.updateStudent(student);

		printAllStudents();
	}
	
	public static void printDeleteStudent() {
		students.deleteStudent(student);
		
		printAllStudents();
	}

	public static void printGetStudent() {
		Student findStudent = new Student();
		if (student != null) {
			try {
				findStudent = students.getStudent(student.getRollNo());
			} catch (Exception e) {
				return;
			}
		}		

		System.out.println(findStudent);
	}
	
	
	
	 private static class NameAndPricePojoKey {
		    final String name;
		    final int price;

		    public NameAndPricePojoKey(final PojoEmployee pojoEmployee) {
		      this.name = pojoEmployee.getName();
		      this.price = pojoEmployee.getPrice();
		    }

		    @Override
		    public boolean equals(final Object o) {
		      if (this == o) return true;
		      if (o == null || getClass() != o.getClass()) return false;

		      final NameAndPricePojoKey that = (NameAndPricePojoKey) o;

		      if (price != that.price) return false;
		      return name != null ? name.equals(that.name) : that.name == null;

		    }

		    @Override
		    public int hashCode() {
		      int result = name != null ? name.hashCode() : 0;
		      result = 31 * result + price;
		      return result;
		    }
		  }
}


