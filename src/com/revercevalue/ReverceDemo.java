package com.revercevalue;

public class ReverceDemo {

	public static void main(String[] args) {
		int x = 5 ;
		int y = 2 ;

		System.out.println("Before changing x = " + x + " ,y = " + y);
		
//		swap(x, y);
//		swapXor(x, y);
//		name();
	}
	
	private static void name() {
		int a = 60;	/* 60 = 0011 1100 */  
	     int b = 13;	/* 13 = 0000 1101 */
	     int c = 0;
	     System.out.println("a= " + a + " ,b= " + b + " ,c= " + c);
	     //AND
	     c = a & b;       /* 12 = 0000 1100 */ 
	     System.out.println("a & b = " + c );
	 
	 
	     //OR
	     c = a | b;       /* 61 = 0011 1101 */
	     System.out.println("a | b = " + c );
	 
	 
	     //XOR
	     c = a ^ b;       /* 49 = 0011 0001 */
	     System.out.println("a ^ b = " + c );
	 
	 
	     //NEGATION
	     c = ~a;          /*-61 = 1100 0011 */
	     System.out.println("~a = " + c );
	}

	private static void swapXor(int x, int y) {		
		 x ^= y;
		 System.out.println(x);
		 y ^= x;
		 System.out.println(y);
		 x ^= y;

		 System.out.println(x);

//		 System.out.println("After changing x = " + x + " ,y = " + y);
	     
	}
	
	private static void swap(int x, int y) {
		x = x + y;
		y = x - y;
		x = x - y;		
		
		System.out.println("After changing x = " + x + " ,y = " + y);
	}

}
