package com.classtests.generics;

public class Book {
	private String title;

	public Book(String title) {
		super();
		this.title = title;
	}
	
	

	public Book() {
		super();
	}



	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}



	@Override
	public String toString() {
		return "Book [title=" + title + "]";
	}
	
	
}
