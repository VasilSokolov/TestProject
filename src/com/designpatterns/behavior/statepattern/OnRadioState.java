package com.designpatterns.behavior.statepattern;

public class OnRadioState implements RadioState {  
    public void execute(Radio radio){
        //throws exception if radio is already on
        radio.setOn(true);
    }
}
