package org.softuni.tasks.booklibrary;

public class Book {

	private String title; 
	private String author;
	private String publisher;
	private String releaseDate;
	private String ISBN;
	private double price;
		
	public Book() {
	}

	public Book(String title, String author, String publisher, String releaseDate, String iSBN, double price) {
		
		this.title = title;
		this.author = author;
		this.publisher = publisher;
		this.releaseDate = releaseDate;
		ISBN = iSBN;
		this.price = price;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getAuthor() {
		return author;
	}

	public void setAuthor(String author) {
		this.author = author;
	}

	public String getPublisher() {
		return publisher;
	}

	public void setPublisher(String publisher) {
		this.publisher = publisher;
	}

	public String getReleaseDate() {
		return releaseDate;
	}

	public void setReleaseDate(String releaseDate) {
		this.releaseDate = releaseDate;
	}

	public String getISBN() {
		return ISBN;
	}

	public void setISBN(String iSBN) {
		ISBN = iSBN;
	}

	public double getPrice() {
		return price;
	}

	public void setPrice(double price) {
		this.price = price;
	}
	
	
	
	
}
