package com.algorithms;

import java.util.Arrays;
import java.util.Collections;
import java.util.Set;
import java.util.TreeSet;
import java.util.stream.Collectors;

public class MainSearchTest {

    public static void main(String[] args) {
        Integer[] arr = {23, 45, 21, 55, 234, 1, 34, 90};

        searchInSet(arr);
    }

    private static void searchInSet(Integer[] arr){
        Set<Integer> set = new TreeSet<>();
//        Arrays.stream(arr).boxed().collect(Collectors.toSet());
        Collections.addAll(set, arr);
//        set.stream().sorted();
        System.out.println(set);

    }
}
