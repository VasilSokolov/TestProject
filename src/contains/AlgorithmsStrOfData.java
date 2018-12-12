package contains;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.EnumSet;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Queue;
import java.util.Set;
import java.util.TreeMap;
import java.util.stream.Collectors;

enum Gfg  
{ 
    CODE, LEARN, CONTRIBUTE, QUIZ, MCQ 
};

public class AlgorithmsStrOfData {	
	
	private Map<Wolf, Integer> map;
	private List<String> list;
	private Set<String> set;
	private Queue<String> queue;
	private Collection<String> data = Arrays.asList("pesho","tosho","gosho","mimi","anna", "gosho");
	
	public static final int FIND_NUMBER = 9;

	public	Wolf w1 = new Wolf("W1","red", 12);
	public	Wolf w2 = new Wolf("W2","green", 78);
	public	Wolf w3 = new Wolf("W3","white", 17);
	public	Wolf w4 = new Wolf("W4","white", 17);
	public	Wolf w5 = new Wolf("W5","selver", 34);
		
	public void hashMapDemo() {
		
			map =  new HashMap<>();
			map.put(null, null);
			map.put(w1, 4);
			map.put(w1, null);
			map.put(w2, 7);
			map.put(w3, 11);
			map.put(w4, 16);
			map.put(w5, 9);
			
			System.out.println("Elements of the hashMap:");
			
		    for (Entry<Wolf, Integer> entry : map.entrySet()) {
		    	System.out.println(entry.getKey() + " - " + entry.getValue());
	    	}
	}
	
	public void treeMapDemo() {
		map = new TreeMap<>();
		
		map.put(w1, 4);
		map.put(w2, 7);
		map.put(w3, 11);
		map.put(w4, 16);
		map.put(w5, 9);
		
		System.out.println("Elements of the TreeMap:");
	    
	    for (Entry<Wolf, Integer> entry : map.entrySet()) {
	    	System.out.println(entry.getKey() + " - " + entry.getValue());
    	}
	}
	
	public void linkedHashMapDemo() {
		// it's a subclass of HashMap
		map = new LinkedHashMap<>();
		
		map.put(w1, 4);
		map.put(w2, 7);
		map.put(w3, 11);
		map.put(w4, 16);
		map.put(w5, 9);
		
		System.out.println("Elements of the LinkedHashMap:");
	    for (Entry<Wolf, Integer> entry : map.entrySet()) {
	    	System.out.println(entry.getKey() + " - " + entry.getValue());
//	    	Integer value = Integer.valueOf(FIND_NUMBER);
	    	 if (entry.getValue().compareTo(FIND_NUMBER) == 0) {
	 			System.out.println("value " + entry.getValue() + " , is faund in map");
	 		} else {
	 			System.out.println("not found value: " + entry.getValue());
	 		}
	    	 System.out.println("Is equal " + (entry.getValue().compareTo(FIND_NUMBER) == 0));
    	}
	}
	
	public void hashtableDemo() {
		// the same us HashMap but is synchronized and permit nulls
	}
	
	public void arrayListDemo() {
		list = new ArrayList<String>(data);
		list.add(3, "ra`o");
		list.add(null);
		list.add(null);
		boolean b = true;
		System.out.println(b);
		String arrayList = list.stream().collect(Collectors.joining(","));
		System.out.println(arrayList);
	}
	
	public void linkedList() {
		list = new LinkedList<>(data);
		list.add("charly");

		String linkedList = list.stream().collect(Collectors.joining(", "));
		System.out.println(linkedList);
	}
	
	public void queue() {
		queue = new LinkedList<>(data);
		queue.add("eli");
		String theQueue = queue.stream().collect(Collectors.joining(", "));
		System.out.println(theQueue);
		
	}
	
	public void setData() {
		set = new HashSet<>(data);
		set.add("kris");
		
		String theSet = set.stream().collect(Collectors.joining(", "));
		System.out.println(theSet);		
	}	
	
	public void enumSet() {
		EnumSet <Gfg> set1, set2, set3, set4;
		
		set1 = EnumSet.of(Gfg.QUIZ, Gfg.CONTRIBUTE, Gfg.LEARN, Gfg.CODE);
		
		set2 = EnumSet.complementOf(set1);
		set3 = EnumSet.allOf(Gfg.class);
		set4 = EnumSet.range(Gfg.CODE, Gfg.CONTRIBUTE);
		
		System.out.println("Set 1: " + set1); 
        System.out.println("Set 2: " + set2); 
        System.out.println("Set 3: " + set3); 
        System.out.println("Set 4: " + set4); 
	}
}
