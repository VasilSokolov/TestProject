package org.softuni.tasks.booklibrary;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

public class BookLibrary {
	private String name;
	private List<Book> books;
	private Map<String, Double> moneyByAuthor;
	
	public BookLibrary(String name) {
		this.name = name;
		this.books = new ArrayList<>();
		this.moneyByAuthor = new TreeMap<>();
	}

	public String getName() {
		return name;
	}

	public Iterable<Book> getBooks() {
		return this.books;
	}
	
	public void addBook(Book book) {
		this.books.add(book);
		this.moneyByAuthor.putIfAbsent(book.getAuthor(), 0d);
		
		Double price = this.moneyByAuthor.get(book.getAuthor()) + book.getPrice();
		this.moneyByAuthor.put(book.getAuthor(), price);
	}

	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder();
//		this.moneyByAuthor.entrySet().stream().sorted((a1, a2) -> (int)(a2.getValue() - a1.getValue()));
		this.moneyByAuthor
		.entrySet()
		.stream()
		.sorted((a1, a2) -> Double.compare(a2.getValue(), a1.getValue()))
		.forEach(e -> {
			String input = String.format("%s -> %.2f", e.getKey(), e.getValue());
			sb.append(input).append(System.lineSeparator());
			
		});
		
		return sb.toString().trim();
}
	
	
	
	
}
