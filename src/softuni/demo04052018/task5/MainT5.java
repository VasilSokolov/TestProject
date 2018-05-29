package softuni.demo04052018.task5;

import java.util.HashMap;
import java.util.Map;

public class MainT5 {

	public static void main(String[] args) {

		Movie m = new Movie();
		m.setActors("Allan");
		m.setName("Thank you");
		m.setReleaseYr(2010);
		
		Movie m1= new Movie();
		m1.setActors("Allan");
		m1.setName("Khaladi");
		m1.setReleaseYr(2010);
		
		Movie m2= new Movie();
		m2.setActors("Allan");
		m2.setName("Taskvir");
		m2.setReleaseYr(2010);

		Movie m3= new Movie();
		m3.setActors("Allan");
		m3.setName("Taskvir");
		m3.setReleaseYr(2010);
		
		Map<Movie, String> map = new HashMap<>();
		map.put(m, "ThankYou");
		map.put(m1, "Khiladi");
		map.put(m2, "Taskvir");
		map.put(m3, "Duplicate Taskvir");
		
		
		//Iterate over HashMap
		for (Movie movie : map.keySet()) {
			System.out.println(map.get(movie).toString());
		}		
		System.out.println(map.size());
		Movie m4= new Movie();
		m4.setActors("Allan");
		m4.setName("Taskvir");
		m4.setReleaseYr(2010);
		
		if (map.get(m4) == null) {
			System.out.println("----------------");
			System.out.println("Object not found");
			System.out.println("----------------");
		} else {
			System.out.println("----------------");
			System.out.println(map.get(m4).toString());
			System.out.println("----------------");
		}
	}
}
