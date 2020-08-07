package caltulate;

import java.util.Arrays;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;

public class TestDemo {

	public static void main(String[] args) {
		List<Integer> listOfcostId = new LinkedList<Integer>(Arrays.asList(10,11,12,16,17,19,37,40,42,43));
	  
	    int index = Collections.binarySearch(listOfcostId, 10);
	    Integer costId = 0;
	    if(index >= 0) {
	    	costId =  listOfcostId.get(index);
	    }
	    System.out.println(costId);
	}

}
