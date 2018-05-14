package com.designpatterns.behavior.statepattern;

public class Radio {  
    private boolean on;
    private RadioState state;

    public Radio(RadioState state){
        this.state = state;
    }

    public void execute(){
        state.execute(this);
    }

    public void setState(RadioState state){
        this.state = state;
    }

    public void setOn(boolean on){
        this.on = on;
    }

    public boolean isOn(){
        return on;
    }

    public boolean isOff(){
        return !on;
    }
}
