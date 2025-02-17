package com.algorithms.search;

public class LinearSearch {

    public static void main(String[] args) {

        int[] arr1 = {23, 45, 21, 55, 234, 1, 34, 90};
        int searchKey = 0;
        System.out.println("Key " + searchKey + " found at index: " + linerSearch(arr1, searchKey));
        int[] arr2 = {123, 445, 421, 595, 2134, 41, 304, 190};
        searchKey = 421;
        System.out.println("Key " + searchKey + " found at index: " + linerSearch(arr2, searchKey));
    }

    public static int linerSearch(int[] arr, int key) {

        int size = arr.length;
        for (int i = 0; i < size; i++) {
            if (arr[i] == key) {
                return i;
            }
        }

        return -1;
    }
}
