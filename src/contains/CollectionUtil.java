package contains;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.ListIterator;

public class CollectionUtil implements Iterable<String>{

	public static final int SEARCHING_FOR_INDEX = 5;

	public static void main(String[] args) {
		String str = "abababa" ;
		findAllChars(str);
		isPalidtome(str);
		
		List<Integer> numbers = new ArrayList<>();
		
		List<Integer> n2 = new ArrayList<>(Arrays.asList(1,2,3,4));
		numbers.add(1);
		numbers.add(2);
		numbers.add(3);
		numbers.add(4);
		numbers.add(5);
		numbers.add(6);
		List<Integer> numbers2 = find(numbers);
		List<Integer> nn2 = find(n2);
		System.out.println(nn2.toString());
		System.out.println(numbers2.toString());
	}
		
	 public static List<Integer> find(final List<Integer> collection){
		 List<Integer> newList = new ArrayList<>();
		 Integer serchingNumber = null;
		 try {
			 serchingNumber = collection.get(SEARCHING_FOR_INDEX);
			 if (collection.contains(serchingNumber)) {
				 newList.add(serchingNumber);
			}
		} catch (IndexOutOfBoundsException e) {
			System.out.println(e.getMessage());
			System.out.println("The index you have entered is invalid");
		}
		 
		
//         for (Integer item : collection){
//             if (!serchingNumber.equals(item)){
//            	 newList.add(item);                 
//             }
//         }
         return newList;
     }
 // and many more methods to deal with collection   
	 
	 public static void reverseMe(List<String> list) {
		  ListIterator<String> listIterator = list.listIterator(list.size());
		  
		  while (listIterator.hasPrevious()) {
			System.out.printf("%s", listIterator.previous());
			
		}
	 }
	 
	 public static void removeStuff(List<String> list, int from, int to) {
		 list.subList(from, to).clear();
		 
	 }

	@Override
	public Iterator<String> iterator() {
		Iterable<String> strs = Arrays.asList("1","2","3");
		return strs.iterator();
	}
	
	public static void findAllChars(String str) {
		for (int i = 0; i < str.length(); i++) {
			char c = str.charAt(i);
			System.out.print(c);
		}
		System.out.println();
	}	
	
	public static void isPalidtome(String str) {
		String[] s = str.split("");
		for (int j = 0; j < s.length; j++) {
			System.out.print(s[j]);
		}
		System.out.println();
		int length = str.length();
		int i, begin, end, middle;
		
		begin = 0;
		end = length-1;
		middle = (begin + end)/2;
		
		for (i = begin; i <= middle; i++) {
			if(str.charAt(begin) == str.charAt(end)) {
				begin++;
				end--;
			} else {
				break;
			}
		}
		
		if(i == middle + 1) {
			System.out.println("is Palindrome");
		} else {
			System.out.println("Not a palindrome");
		}
		
	}
}
