package com.hcl;

public class CalService {	
	public ICalculator getCalculator() {
		return calculator;
	}
	public void setCalculator(ICalculator calculator) {
		this.calculator = calculator;
	}
	ICalculator calculator;
	public int addTwoNumbers(int x, int y) {
		return calculator.add(x, y);
	}
	
	public int multipicatTwoNumbers(int x, int y){
		return calculator.add(x, y);		
	}
}
