package com.designpatterns.behavior.statepattern;

public class RadioDemo {

	public static void main(String[] args) {
		Radio radio = new Radio(new OffRadioState()); //initial status  
		radio.setState(new OnRadioState());  
		radio.execute(); //radio on  
		radio.setState(new OffRadioState());  
		radio.execute(); //radio off 
	}

}
