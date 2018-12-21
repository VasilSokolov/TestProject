package com.designpatterns.utilsdesignpattern.data_access_object;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
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
		
//		studentCrudOperations();
//		streamsManipulations();
		streamsManipulations();
	}
	
	public static void streamsManipulations() {
//		List<String> listOfNames = new ArrayList<>();
		String name = students.getAllStudents().stream()
				.filter(s -> ID == s.getRollNo())
				.map(s -> s.getName())
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
}
