package lambda.streams;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import lambda.model.Product;
import lambda.model.Users;

public class StreamsDemo {


	public static void main(String[] args) {
		StreamsDemo demo = new StreamsDemo();
		
		demo.items();
		
	}

	private List<String> items() {
		List<String> items = new ArrayList<>();
		items.add("A");
		items.add("B");
		items.add("C");
		items.add("D");
		items.add("E");

		System.out.println("----------LIST---------");
		//lambda
		//Output : A,B,C,D,E
		items.forEach(item->System.out.print(item));
		System.out.println();
		//Output : C
		items.forEach(item->{
			item = "C".equals(item) ? item :"";
			System.out.print(item);
		});
		items.add("V");
		
		System.out.println(items.add("V"));
		//method reference
		//Output : A,B,C,D,E
		items.forEach(System.out::print);

		System.out.println();
		//Stream and filter
		//Output : B
		items.stream()
			.filter(s->s.contains("B"))
			.forEach(System.out::print);
		System.out.println();
		System.out.println("----------MAP---------");
		Map<String, Integer> mapItems = new HashMap<>();
		mapItems.put("A", 10);
		mapItems.put("B", 20);
		mapItems.put("C", 30);
		mapItems.put("D", 40);
		mapItems.put("E", 50);
		mapItems.put("F", 60);
		
		mapItems.forEach((k,v)->System.out.println("Item : " + k + " Count : " + v));
		
		mapItems.forEach((k,v)->{
			System.out.println("Item : " + k + " Count : " + v);
			if("E".equals(k)){
				System.out.println("Hello E");
			}
		});
		
		
		
		return items;
	}

	
	private void lambda() {

		
		NumericTest isEven = (int n) -> (n % 2) == 0;
		NumericTest isNegative = (int n) -> n < 0;
		

		StringsTest morningGreeting  = (String str) -> "Good Morning " + str + "!";
		
		// Output: false
		System.out.println(isEven.computeTest(5));

		// Output: true
		System.out.println(isNegative.computeTest(-5));
		
		
	}
	
	private List<Users> getData() {
		List<Product> products = new ArrayList<>(Arrays.asList(
		        new Product(1L,"Ajay",new BigDecimal(355.54).setScale(2, RoundingMode.CEILING)),
				new Product(113L,"Ajay",new BigDecimal(3534).setScale(2, RoundingMode.CEILING)),
				new Product(3l,"Ajay",new BigDecimal(3533.2).setScale(2, RoundingMode.CEILING)),
				new Product(4L,"Ajay",new BigDecimal(123.4).setScale(2, RoundingMode.CEILING)),
				new Product(5L,"Ajay",new BigDecimal(55.2).setScale(2, RoundingMode.CEILING))));

        List<Users> userses = new ArrayList<>(Arrays.asList(
	        new Users(123L,"ssay", "Accounting", products),
	        new Users(12L,"Ajay", "Accounting", products),
	        new Users(13L,"Aj2", "Accounting", products),
	        new Users(14L,"A1y", "Accounting", products),
	        new Users(153L,"A2y", "Accounting", products)));
        userses.add(new Users(77L,"A2y", "Accounting", products));
        int count = 0;
         
        
        
        for (Users user : userses) {
        	List<Product> p = user.getProducts();
			System.out.println(user.toString());
			for (Product product : p) {
				System.out.println(product.toString()+ " " + count++);
			}
		}
        new Users();
        

        return userses;
    }
	
	 private List<Users> addData(List<Users> users) {
    	 List<String> lines = new ArrayList<>(Arrays.asList("spring", "node", "mkyong"));
         List<String> result = getFilterOutput(lines, "mkyong");
         for (String temp : result) {
             System.out.println(temp);    //output : spring, node
         }
         
    	 System.out.println(users.toString());
    	 
    	 
    	 List<Users> userss = 
    			 lines
    			 .stream()
    			 .map(element->new Users(1l, element, element,  Arrays.asList(new Product(2l, element, new BigDecimal(355.54).setScale(2, RoundingMode.CEILING)))))
    			 .collect(Collectors.toList());
    	 System.out.println();
    	 System.out.println(userss.toString());
        return userss;
     }

     private static List<String> getFilterOutput(List<String> lines, String filter) {
         List<String> result = new ArrayList<>();
         for (String line : lines) {
             if (!"mkyong".equals(line)) { // we dont like mkyong
                 result.add(line);
             }
         }
         return result;
     }
}