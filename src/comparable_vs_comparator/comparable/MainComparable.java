package comparable_vs_comparator.comparable;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class MainComparable {

 public static void main(String[] args) 
	 {
		 List<String> listString = new ArrayList<>();
		 listString.add("Pesho");
		 listString.add("Ina");
		 listString.add("Mario");
		 listString.sort(String::compareTo);
		 System.out.println(listString);

		 List<Movie> list = new ArrayList<>();
	     list.add(new Movie("Force Awakens", 8.3, 2015)); 
	     list.add(new Movie("Star Wars", 8.7, 1977)); 
	     list.add(new Movie("Empire Strikes Back", 8.8, 1980)); 
	     list.add(new Movie("Return of the Jedi", 8.4, 1983));
	     Collections.sort(list);
	
	     System.out.println("Movies after sorting : "); 
	     for (Movie movie: list) 
	     { 
	         System.out.println(movie.getName() + " " + 
	                            movie.getRating() + " " + 
	                            movie.getYear()); 
	     } 
	 } 
} 
