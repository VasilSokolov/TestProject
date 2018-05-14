package com.designpatterns.behavior.chainOfResponsibilityPattern.firstexam;

import java.util.Arrays;
import java.util.List;

@SuppressWarnings("rawtypes")
public class Chain {  
	public List<Command> commands;

    public Chain(Command... commands){
        this.commands = Arrays.asList(commands);
    }

    @SuppressWarnings("unchecked")
	public void start(Object context){
        for(Command command : commands){
            boolean shouldStop = command.execute(context);

            if(shouldStop){
                return;
            }
        }
    }
}
