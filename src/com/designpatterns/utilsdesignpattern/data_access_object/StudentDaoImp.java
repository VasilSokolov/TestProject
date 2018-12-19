package com.designpatterns.utilsdesignpattern.data_access_object;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class StudentDaoImp implements StudentDao {

	//list is working as database
	private List<Student> students;
	
	public StudentDaoImp() {
		this.students = new ArrayList<Student>(
				Arrays.asList(
						new Student("Moni", 0),
						new Student("pesho", 1),
						new Student("sashko", 2),
						new Student("sashko", 44)
						)
				);;
	}

	//retrive list with user from database
	@Override
	public List<Student> getAllStudents() {
		return this.students;
	}

	@Override
	public Student getStudent(int rollNo) {
		
		return students.get(rollNo);
	}

	@Override
	public void updateStudent(Student student) {
//		students.get(student.getRollNo()).setName(student.getName());
		Student s = null;
		try {
			s = students.get(student.getRollNo());
		} catch (IndexOutOfBoundsException e) {
			System.out.println("Error id " + student.getRollNo());
			return;
		}
		s.setName(student.getName());
	}

	@Override
	public void deleteStudent(Student student) {
		students.remove(student);
	}

}
