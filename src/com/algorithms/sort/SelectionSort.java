package com.algorithms.sort;

public class SelectionSort{
	
  static int intArray[] = { 10, 5, 100, 1, 10000, 5, 25, 2 };
  
  public static void doSort() {
    for (int outer = 0; outer < intArray.length; outer++) {
      int minPosition=outer;
      for(int inner=outer;inner < intArray.length;inner++){
        if(intArray[inner] < intArray[minPosition]){
          minPosition=inner;
        }
      }
      int temp=intArray[minPosition];
      intArray[minPosition]=intArray[outer];
      intArray[outer]=temp;
    }
  }
  
  public static void printArray() {
    for (int i = 0; i < intArray.length; i++) {
      System.out.print(" " + intArray[i]);
    }
  }
  
  public static void main(String args[]) {
    System.out.print("Array Before Sorting ->");
    printArray();
    doSort();
    System.out.print("\nArray After Sorting ->");
    printArray();
  }
}
