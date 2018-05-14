package com.designpatterns.behavior.chainOfResponsibilityPattern.firstexam;

import java.util.Map;

public class FirstCommand implements Command<Map<String, Object>>{  
    public boolean execute(Map<String, Object> context){
        //doing something in here
		return false;
    }
}
