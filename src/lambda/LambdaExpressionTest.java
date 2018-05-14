package lambda;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.*;
import java.util.Map.Entry;
import java.util.stream.Stream;

public class LambdaExpressionTest {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		LambdaExpressionTest name = new LambdaExpressionTest();
		name.streams();
	}
	
	public void streams() {
		
//		this.testStreamWithLists();
		try {
			this.testOptionalStream();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		
//		int[] arr = {5,2,1,6,8};
		Set<Integer> listSets = new LinkedHashSet<>(Arrays.asList(new Integer[] {15,20,10,6,80}));
		
		listSets.stream()
			.filter(n -> (10 <= n) && (n <= 20))
			.distinct()
			.limit(3)
			.forEach(n -> System.out.println(n));
		
//		Map<String, String> map = new HashMap<>();
		
//		Stream<Entry<String, String>> entries = map.entrySet().stream();
		
	}
	
	public void testOptionalStream() throws IOException {
		BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
		
		List<String> names = Arrays.asList(reader.readLine().split("\\s+"));
		Character ch = reader.readLine().toLowerCase().charAt(0);
		
		Optional<String> first = names.stream().filter(name -> ch == name.toLowerCase().charAt(0)).sorted().findFirst();
		
		if(first.isPresent()){
			System.out.println(first.get());
		} else {
			System.out.println("No matches");
		}
	}
	
	public void testStreamWithLists() {

		List<String> names = new ArrayList<>(Arrays.asList("pesho", "tosho", "tedi"));
		Stream<String> stream = names.stream();
		stream.map(m -> m.toUpperCase())
			.peek(s -> System.out.println(s + " "))
			.map(m -> m.toLowerCase())
			.forEach(s -> System.out.println(s));
	}

}
