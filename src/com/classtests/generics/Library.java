package com.classtests.generics;


public class Library {
	private Object author;
	private Object book;
	
	public Library(Author author, Book book) {
		this.author = author;
		this.book = book;
	}
	
	
	
	public Library() {
		super();
	}



	public Object getAuthor() {
		return author;
	}
	public void setAuthor(Object author) {
		this.author = author;
	}
	public Object getBook() {
		return book;
	}
	public void setBook(Object book) {
		this.book = book;
	}

	@Override
	public String toString() {
		return "Library [author=" + author + ", book=" + book + "]";
	}
}
