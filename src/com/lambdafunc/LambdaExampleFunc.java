package com.lambdafunc;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.function.Function;
import java.util.function.Predicate;

public class LambdaExampleFunc {

	public static void main(String[] args) {

		MyFunc func = (param) -> {System.out.println("System " + param);};

		String param = "ssssssa";
		
		func.apply(param);
		methodReference();
		
		Predicate<Integer> predicate = i -> i > 0;
		predicate.and(predicate);
		
	}
	
	public static void methodReference() {
		Function<String, Double> doubleConvertor=Double::parseDouble;
		Function<String, Double> doubleConvertorLambda=(String s) -> Double.parseDouble(s);
		System.out.println("double value using method reference - "+ doubleConvertor.apply("0.254"));
		System.out.println("double value using Lambda - "+ doubleConvertorLambda.apply("0.254"));
		
		List<String> list = new ArrayList<>();
		list = Arrays.asList("aaaaa", "sasdas", "sssssss");
		list.parallelStream().forEach(s->System.out.println(s));
	}	
}
