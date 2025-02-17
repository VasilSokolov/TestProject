package comparable_vs_comparator.comparator;

import java.util.Comparator;

import comparable_vs_comparator.comparable.Movie;

//Class to compare Movies by ratings 
public class RatingCompare implements Comparator<Movie> 
{ 
	 public int compare(Movie m1, Movie m2) 
	 {
	     if (m1.getRating() < m2.getRating()) {
			 return -1;
		 } else if (m1.getRating() > m2.getRating()) {
			 return 1;
		 } else {
			 return 0;
		 }
//		 return Double.compare(m1.getRating(), m2.getRating());
	 } 
} 
