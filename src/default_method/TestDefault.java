package default_method;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;

public class TestDefault {

	public static void main(String[] args) {
		Lion lion = new Lion();
//		lion.run("Lion");
		lion.move("Lion");
		
		List<String> a= new ArrayList<>();
		Collection<String> c = new HashSet<String>();
		long memory = Runtime.getRuntime().freeMemory();
		System.out.println(memory + " bytes = " + memory/1000000 + " MB");
	}

}
