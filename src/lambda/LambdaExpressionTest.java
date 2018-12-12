package lambda;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;
import java.util.Map.Entry;
import java.util.function.Supplier;
//import java.util.Map.Entry;
import java.util.stream.Stream;

public class LambdaExpressionTest {

	public static void main(String[] args) {
		
		// TODO Auto-generated method stub
		LambdaExpressionTest lambda = new LambdaExpressionTest();
//		lambda.streams();
		lambda.streamArray();
	}
	
	public void streams() {
		
		this.testStreamWithLists();
		try {
			this.testOptionalStream();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		
		
		int[] arr = {5,2,1,6,8};
		Set<Integer> listSets = new LinkedHashSet<>(Arrays.asList(new Integer[] {15,20,10,6,80}));
		
		listSets.stream()
			.filter(n -> (10 <= n) && (n <= 20))
			.distinct()
			.limit(3)
			.forEach(n -> System.out.println(n));
		
		Map<String, String> map = new HashMap<>();
		
		Stream<Entry<String, String>> entries = map.entrySet().stream();

//		this.testStreamWithLists();
		this.checkConditions();
	}
	
	public void testOptionalStream() throws IOException {
		BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
		
		List<String> names = Arrays.asList(reader.readLine().split("\\s+"));
		Character ch = reader.readLine().toLowerCase().charAt(0);
		
		Optional<String> first = names
				.stream()
				.filter(name -> ch == name.toLowerCase().charAt(0))
				.sorted()
				.findFirst();
		
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

	public void checkConditions() {
//		List<Integer> list = new ArrayList<>(Arrays.asList(2,5,3,22));
//		Stream<Integer> stream = list.stream();
		
		Supplier<Stream<Integer>> streamSupplier = () -> Stream.of(2,5,3,22);
		
 		// Any element matches
		boolean any = streamSupplier.get().anyMatch(x -> x % 2 == 0);
		
 		// All element matches
		boolean all = streamSupplier.get().allMatch(x -> x % 2 == 0);
		
 		// All element matches
		boolean none = streamSupplier.get().noneMatch(x -> x % 2 == 0);
		
		System.out.println("Any: " + any + " ,All: " + all + " ,None: "+ none);
	}

	public void streamArray() {
		LambdaAnimal animal2 = new LambdaAnimal(1l,"Lion", 15, new BigDecimal(355.54).setScale(2, RoundingMode.CEILING));
		LambdaAnimal[] animal = {
				new LambdaAnimal(1l,"Lion", 15, new BigDecimal(355.54).setScale(3, RoundingMode.CEILING)),
				new LambdaAnimal(2l,"Eagle", 11, new BigDecimal(27.4).setScale(2, RoundingMode.CEILING))
		};
	
		//Arrays.stream
        Stream<LambdaAnimal> stream1 = Arrays.stream(animal);
        stream1.forEach(x -> System.out.println(x));
		
		Arrays.stream(animal).forEach(a ->System.out.println(a));
		
	
	}
}
