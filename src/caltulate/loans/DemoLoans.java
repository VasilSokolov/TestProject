package caltulate.loans;

import java.text.DecimalFormat;

public class DemoLoans {

	public static void main(String[] args) {
		
		double credit = 10000d;

		double investment = 5000d;
		double periodInMonths  = 36d;
		double procentageOfInterest = 1;
		double rateOfInterest = procentageOfInterest/100;
		calculate(investment, periodInMonths, rateOfInterest);
	}
	
	private static double calculate(double investment, double periodInMonths, double rateOfInterest) {
		double sum = 0;
		DecimalFormat dec = new DecimalFormat("#0.00");
		for (int i = 1; i < periodInMonths; i++) {
			investment += investment*rateOfInterest;
//			sum += 
		}
//		sum = 
		System.out.println(dec.format(investment));
		return sum;
		
	}

}
