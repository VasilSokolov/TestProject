package com.test;

import java.util.Scanner;

public class MainC {

	public static void main(String[] args) {

//		int  value = 4;
//		
//		if(0<value && value <=30) {
//			System.out.println("Result: " + value);
//		} else {
//			System.out.println("Out of range: " + value);
//		}
	
		
		scanner();
	}
	
	private static void scanner() {
		
		String s = "Hello World! 3842334 + 19 + 3.0 = 6.0 true";
		
		
//		Scanner scannerArr = new Scanner(arr.);
		
			
	      // create a new scanner with the specified String Object
	      Scanner scanner = new Scanner(s);

	      // find the next int token and print it
	      // loop for the whole scanner
	      while (scanner.hasNext()) {

	         // if the next is a int, print found and the int
	         if (scanner.hasNextInt()) {
	        	 
	        	 Integer i =  scanner.nextInt();
	            System.out.println("Found :" + i);
	            String str = i+"";
	            String[] arr = str.split("");

	            int r = Integer.parseInt(arr[1]);
	    		 System.out.println(r);
	            
	            
	         } else if (scanner.hasNextBoolean()) {
        	 	System.out.println("Found Boolean :" + scanner.nextBoolean());
	         } else {
	         // if no int is found, print "Not Found:" and the token
	         System.out.println("Not Found :" + scanner.next());
	         
	         }
	      }

	      // close the scanner
	      scanner.close();
	}
	

}
