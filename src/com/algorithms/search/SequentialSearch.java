package com.algorithms.search;

public class SequentialSearch {

	public static void main(String[] args) {
		int[] arr = {1, 2, 3, 4, 5, 7, 17,  19 };
		int searchKey = 5;
		System.out.println(contains(arr, searchKey));
	}
	
	public static boolean contains(int[] a, int b) {
        if (a.length == 0) {
            return false;
        }
        int low = 0;
        int high = a.length-1;

        while(low <= high ) {
            int middle = (low+high) /2;
            if (b> a[middle] ){
                low = middle +1;
            } else if (b< a[middle]){
                high = middle -1;
            } else { // The element has been found
                return true;
            }
        }
        return false;
    }

}
