package softuni;

import java.math.BigInteger;
import java.util.Collections;
import java.util.LinkedHashSet;


public class DemoPoli {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		String[] values = {"reporting", "na maika muuu", }; 
//		
		String str = "rac3ecar";
		int length = str.length() - 1 ;
		for(int i = 0, j = length ; i < length; i++, --j) {
			if(str.charAt(i) != str.charAt(j)) {
			  System.out.println("Not polindrome");
			  return;
			}
		}
		System.out.println("Is polindrome");
//		new BigInteger();
//		int[] arr = {3,5,1,4,6,9,8,7,10};
// 		
//		int sum = (((arr.length + 1) * (arr.length + 2 )) / 2);
//		int sum2 = 0 ;
//		
//		for (int i = 0; i < arr.length; i++) {
//			sum2+= arr[i];
//		}
//		
////		String str = "ababaa";
//		
//		String[] arrStr = str.split("");
//		
//		for (int i = 0; i < arrStr.length; i++) {
//			System.out.println(arrStr[i]);
//		}
//		System.out.println(sum + "  " +sum2);
	}

}
