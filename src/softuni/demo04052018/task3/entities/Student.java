package softuni.demo04052018.task3.entities;

import java.time.LocalDate;

public class Student {
	
	private int id;
	private String name;
	private LocalDate registrationDate;
		
	public Student() {
	}

	public Student(String name, LocalDate registrationDate) {
		this.name = name;
		this.registrationDate = registrationDate;
	}
	
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public LocalDate getRegistrationDate() {
		return registrationDate;
	}
	public void setRegistrationDate(LocalDate registrationDate) {
		this.registrationDate = registrationDate;
	}
	
	@Override
	public String toString() {
		return "Student [id=" + id + ", name=" + name + ", registrationDate=" + registrationDate + "]";
	}
	
	
}
