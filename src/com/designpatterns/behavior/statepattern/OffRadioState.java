package com.designpatterns.behavior.statepattern;

public class OffRadioState implements RadioState {  
    public void execute(Radio radio){
        //throws exception if radio is already off
        radio.setOn(false);
    }
}
