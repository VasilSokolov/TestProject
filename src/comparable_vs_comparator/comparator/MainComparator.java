package comparable_vs_comparator.comparator;

import java.util.*;

import comparable_vs_comparator.comparable.Movie;

public class MainComparator {

    public static void main(String[] args) {
        List<Movie> list = new ArrayList<Movie>();
        list.add(new Movie("Force Awakens", 8.3, 2015));
        list.add(new Movie("Star Wars", 8.7, 1977));
        list.add(new Movie("Empire Strikes Back", 8.8, 1980));
        list.add(new Movie("Return of the Jedi", 8.4, 1983));

        // Sort by rating : (1) Create an object of ratingCompare
        //                  (2) Call Collections.sort
        //                  (3) Print Sorted list
        System.out.println("Sorted by rating");
        RatingCompare ratingCompare = new RatingCompare();
        Collections.sort(list, ratingCompare);
        for (Movie movie : list)
            System.out.println(movie.getRating() + " " +
                    movie.getName() + " " +
                    movie.getYear());

        // Call overloaded sort method with RatingCompare
        // (Same three steps as above)
        System.out.println("\nSorted by name");
        NameCompare nameCompare = new NameCompare();
        Collections.sort(list, nameCompare);
        for (Movie movie : list)
            System.out.println(movie.getName() + " " +
                    movie.getRating() + " " +
                    movie.getYear());

        // Uses Comparable to sort by year
        System.out.println("\nSorted by year");
        Collections.sort(list);
        for (Movie movie : list)
            System.out.println(movie.getYear() + " " +
                    movie.getRating() + " " +
                    movie.getName() + " ");

        //while using anonymous class
        Comparator yearCompare = new Comparator<Movie>() {
            @Override
            public int compare(Movie o1, Movie o2) {
//                return Integer.compare(o1.getYear(), o2.getYear());
                if (o1.getYear() > o2.getYear()) {
                    return 1;
                } else if (o1.getYear() < o2.getYear()) {
                    return -1;
                } else {
                    return 0;
                }
            }
        };



    }
}
