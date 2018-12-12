package com.hcl;

public class CalService {	

	ICalculator calculator;
	
	public ICalculator getCalculator() {
		return calculator;
	}
	public void setCalculator(ICalculator calculator) {
		this.calculator = calculator;
	}
	public int addTwoNumbers(int x, int y) {
		return calculator.add(x, y);
	}
	
	public int multipicatTwoNumbers(int x, int y){
		return calculator.add(x, y);		
	}
}
