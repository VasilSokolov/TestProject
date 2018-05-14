package com.wealth;

public class WealthEffect {

	public static void main(String[] args) {
		double amount =100;
		double[] years ={10};
		double procent = 0.08;
		double total = WealthCalc(procent,amount,years);
		System.out.println("Total sum: " + total + " ыт.");
	}
	
	public static double WealthCalc(double procent, double amount, double[] years){
		double sum = 0;
		double count;
		for (int i = 0; i < years.length; i++) {
			count = amount*12*years[i]*procent;
			sum+=count;
		}
//		sum = amount*12*years*procent ;
	return sum;
	}
}
