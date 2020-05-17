package comparable_vs_comparator.comparator;

import java.util.Comparator;

import comparable_vs_comparator.comparable.Movie;

//Class to compare Movies by name 
public class NameCompare implements Comparator<Movie> 
{ 
 public int compare(Movie m1, Movie m2) 
 { 
     return m1.getName().compareTo(m2.getName()); 
 } 
} 
