package com.designpatterns.behavior.chainOfResponsibilityPattern.firstexam;

import java.util.HashMap;
import java.util.Map;

public class ChainOfResponsibilityDemo {
	public static void main(String[] args) {
		Chain chain = new Chain(new FirstCommand(), new SecondCommand());  
		Map<String, Object> context = new HashMap<>();  
		context.put("some parameter", "some value");  
		chain.start(context); 
	}
}
