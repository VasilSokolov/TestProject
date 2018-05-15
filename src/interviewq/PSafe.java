package interviewq;

import java.util.*;

public class PSafe {

	public static void main(String[] args) {
		PSafe ps = new PSafe();
		int[] arr = {2,1,3,2,6,0,2,3,5,0,5};
		int sum = 5;
		ps.findIndex(arr,  sum);
	}
	
	//find index from 2 near digit,which sum of them is equal of 3-th digit
	public void findIndex(int[] arr, int sum) {
		Map<Integer, Integer> pairs = new HashMap<>();
		final int index;
		for (int i = 0; i < arr.length; i++) {
			if(pairs.containsKey(arr[i])) {
				if(pairs.containsValue(sum)) {
					System.out.println(arr[i] + ", " + pairs.get(arr[i]) + " index= " + i);
				}
				System.out.println(arr[i] + ", " + pairs.get(arr[i]) );
			}else{
				pairs.put(sum - arr[i], arr[i]);
			}
		}
		
//		for (int i = 0; i < arrSize -2; i++) {
//			for (int j = i + 1; j < arrSize -1; j++) {
//				for (int k = j + 1; k < arrSize; k++) {
//					if(arr[i] + arr[j] + arr[k] == sum) {
//						System.out.printf("Triplet is %d, %d, %d", arr[i], arr[j], arr[k]);
//					} else {
//
//						System.out.println("No match");
//					}
//				}
//			}			
//		}		
		
		
	}
}
