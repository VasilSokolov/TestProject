package com.algorithms.sort;

public class BubbleSort {
	  static int intArray[] = { 1000, 1, 100, 101, 15 };
	  public static void doSort() {
	    for (int outer = 0; outer < intArray.length; outer++) {
	      for (int inner = 0; inner < intArray.length - outer- 1; inner++) {
	        if (intArray[inner] > intArray[inner + 1]) {
	          int temp = intArray[inner];
	          intArray[inner] = intArray[inner + 1];
	          intArray[inner + 1] = temp;
	        }//if condition ends
	      }//inner loop ends
	    }//outer loop ends
	  }
	  
	  public static void printArray() {
	    for (int i = 0; i < intArray.length; i++) {
	      System.out.print(" " + intArray[i]);
	    }
	  }
	  public static void main(String[] args) {
	    System.out.print("Array Before Sorting->");
	    printArray();
	    doSort();
	    System.out.print("\nArray After Sorting ->");
	    printArray();
	  }
	}
