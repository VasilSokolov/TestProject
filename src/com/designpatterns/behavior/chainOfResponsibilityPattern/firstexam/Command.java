package com.designpatterns.behavior.chainOfResponsibilityPattern.firstexam;

public interface Command<T>{  
    boolean execute(T context);
}
