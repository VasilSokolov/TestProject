package com.classtests.Collection;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

public class CollectionTest {	
	
	public static void main(String[] args) {
		// TODO Auto-generated method stub

		int[] array = {5,-13,6, 22,6, 3,7,4};
//		List<Integer> nums = new ArrayList<>(
//				Arrays.asList((Integer)array));
//		nums.add(9);
		List<Integer> nums = Arrays.stream(array).boxed().collect(Collectors.toList());
		nums.add(9);
		System.out.println(nums.get(3));
		nums.set(2, 77);
		System.out.println(nums);
		
		DecimalFormat format = new DecimalFormat("#.0#");
		BigDecimal bigDecimal = new BigDecimal("123");
		System.out.println(format.format(bigDecimal));
		
//		CollectionTest test = null;
//		test.toString();
//		System.out.println(test.toString());
//		toString();
	}
	
//	public String toString() {
//		System.out.println("test method to string");
//		return "";
//	}
	

}
