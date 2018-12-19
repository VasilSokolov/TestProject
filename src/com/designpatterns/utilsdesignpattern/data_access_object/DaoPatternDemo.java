package com.designpatterns.utilsdesignpattern.data_access_object;

//import java.util.logging.*;

public class DaoPatternDemo {
//	private static Logger logger = Logger.getLogger(DaoPatternDemo.class.getName());
	
	private static final int ID = 3;
	private static StudentDao students = new StudentDaoImp();
	private static Student student;
	
	public static void main(String[] args) {
		
//		studentCrudOperations();
		streamsManipulations();
	}
	
	public static void streamsManipulations() {
		
	}
	
	public static void studentCrudOperations() {
		printAllStudents();
		if (getStudent(ID)) {
			printUpdateStudent();
			printDeleteStudent();
			printGetStudent();
		}
		System.out.println("Student is not in Database with id " + ID);
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
