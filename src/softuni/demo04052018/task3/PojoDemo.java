package softuni.demo04052018.task3;

import java.time.LocalDate;
import java.util.*;

//import javax.security.auth.login.Configuration;

import softuni.demo04052018.task3.entities.Student;

public class PojoDemo {

	public static void main(String[] args) {

		List<Student> studentList = new ArrayList<>();
//		Configuration cfg = Configuration().getConfiguration();
		Student pesho = new Student("Pesho", LocalDate.parse("2018-03-05"));
		studentList.add(pesho);
		Student joko = new Student("Joko", LocalDate.parse("2017-11-05"));
		studentList.add(joko);
		Student misho = new Student("Misho", LocalDate.parse("2016-02-05"));
		studentList.add(misho);
		Student titi = new Student("Titi", LocalDate.parse("2015-12-08"));
		studentList.add(titi);
		Student ra = new Student("Ra", LocalDate.parse("2018-11-05"));
		studentList.add(ra);
		
//		Iterator<Student> students = studentList.iterator();
		for (Student student : studentList) {
			System.out.println(student);
		}
		
	}

}
