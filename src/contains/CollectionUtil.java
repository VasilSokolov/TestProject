package contains;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.function.Predicate;

public class CollectionUtil {

	public static void main(String[] args) {
		List<Integer> numbers = new ArrayList<>();
		numbers.add(1);
		numbers.add(2);
		numbers.add(3);
		numbers.add(4);
		numbers.add(5);
		List<Integer> numbers2 = find(numbers);
		System.out.println(numbers2.toString());
	}
	 public static List<Integer> find(final List<Integer> collection){
		 Integer serchingNumber = collection.get(4);
		 List<Integer> newList = new ArrayList<>();
         for (Integer item : collection){
             if (!serchingNumber.equals(item)){
            	 newList.add(item);                 
             }
         }
         return newList;
     }
 // and many more methods to deal with collection   

}
