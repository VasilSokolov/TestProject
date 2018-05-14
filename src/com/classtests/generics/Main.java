package com.classtests.generics;

public class Main {

	public static void main(String[] args) {
		Book books = new Book();
		books.setTitle("Underciver");
		getAll(books, books);
	}
	
	static <A, B> Library getAll(A author, B book){
		Library library = new Library();
		library.setAuthor(author);
		library.setBook(book);
		System.out.println(library.toString());
		return library;
	};

}
