package interviewq;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;

public class SerdkaOborishte {

	public static void main(String[] args) {
		
		int[] numbers = new int[] {0,2,3,4,5,6,7,8,9,12,3,123,3,124,12,4,4,12,34};
		int target = 9;
		int count = 0 ; 
//		int[] arr1 = findTwoSum_BruteForce(numbers, target);
		System.out.println("-------------------------------");
//		findTwoNumSum_Sorting(numbers, target);
		System.out.println("-------------------------------");
		int[] arr3 = findTwoNumSum(numbers, target);
		System.out.println(arr3);

		System.out.println("-------------------------------");
		printpairs(numbers, target);
	}
	
	// Time complexity: O(n^2)
    private static void findTwoSum_BruteForce(int[] nums, int target) {
//        for (int i = 0; i < nums.length; i++) {
//            for (int j = i + 1; j < nums.length; j++) {
//                if (nums[i] + nums[j] == target) {
//                    return new int[] { i, j };
//                }
//            }
//        }
//        return new int[] {};
		
		for (int i = 0; i < nums.length; i++) {
			for (int j = i + 1; j < nums.length; j++) {
				if (nums[i] + nums[j] == target) {
					System.out.println("1-st digit:" + nums[i] + 
							" on position: " + i + 
							", and 2-nd digit:" + nums[j] +
							" on position: " + j +
							", with SUM: " + target);
//					return new int[] { i, j };
				}
			}
		}
//		return new int[] {};
        
    }
	
	// Time complexity: O(n*log(n))
    private static int[] findTwoNumSum_Sorting(int[] nums, int target) {
        Arrays.sort(nums);
        int left = 0;
        int right = nums.length - 1;
        while(left < right) {
            if(nums[left] + nums[right] == target) {
            	System.out.println("1-st digit:" + nums[left] + 
						" on position: " + left + 
						", and 2-nd digit:" + nums[right] +
						" on position: " + right +
						", with SUM: " + target);
                return new int[] {left, right};
            } else if (nums[left] + nums[right] < target) {
                left++;
            } else {
                right--;
            }
        }
        return new int[] {};
    }
    
 // Time complexity: O(n)
    private static int[] findTwoNumSum(int[] nums, int target) {
        Map<Integer, Integer> numMap = new HashMap<>();
        for (int i = 0; i < nums.length; i++) {
            int complement = target - nums[i];
            if (numMap.containsKey(complement)) {
//            	System.out.println("1-st digit:" + nums[left] + 
//						" on position: " + left + 
//						", and 2-nd digit:" + nums[right] +
//						" on position: " + right +
//						", with SUM: " + target);
                return new int[] { numMap.get(complement), i };
            } else {
                numMap.put(nums[i], i);
            }
        }
        return new int[] {};
    }
    //using HashSet
    static void printpairs(int arr[], int sum) 
    { 
        HashSet<Integer> s = new HashSet<Integer>(); 
        for (int i = 0; i < arr.length; ++i) { 
            int temp = sum - arr[i]; 
  
            // checking for condition 
            if (s.contains(temp)) { 
                System.out.println("Pair with given sum " + sum + " is (" + arr[i] + ", " + temp + ")"); 
            } 
            s.add(arr[i]); 
        } 
    } 
    

}
