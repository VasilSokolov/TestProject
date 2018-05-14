package com.canculateprincipal;

public class MainPrincipal {	

	public static final double MONTHS_OF_YEAR 	= 12;
	public static final double HONDRED_PERCENTAGE = 100;

	public static void main(String[] args) {
		
		double principle = 100;
		double percentage = 10;
		double years = 10;
		double salary = 300;
		
		double convertPercentage = (percentage / HONDRED_PERCENTAGE) / MONTHS_OF_YEAR;
		double months = years * MONTHS_OF_YEAR;
		double resultLeva = resolve(principle, convertPercentage, months);
		double resultEuro = resultLeva / 2;
		System.out.printf(
				"For %.2f years and %.2f percent lihva(interest)\nResult: %.2f lv / %.2f euro",
				years, percentage, resultLeva, resultEuro);
		System.out.println("\n---------------------------------------");
		
		resultLeva = increeseAtMonthWithSelary(principle, convertPercentage, months, salary);
		resultEuro = resultLeva / 2;
		System.out.printf(
				"For %.2f years and %.2f percent lihva(interest)\nResult:  %.2f lv / %.2f euro",
				years, percentage, resultLeva, resultEuro);
	}
	
	public static double resolve(double principle, double convertPercentage, double months){

		double result = 0;
		double interest = 0;
		for (int i = 1; i < months; i++) {
			interest = principle * convertPercentage;
			result = principle + interest;
			principle = result;
		}
		
		return result;
	}

	public static double increeseAtMonthWithSelary(double principle, double convertPercentage, double months, double salary){

		double result = 0;
		double interest = 0;
		for (int i = 1; i < months; i++) {
			interest = principle * convertPercentage;
			result = principle + interest + salary;
			principle = result;
		}
		
		return result;
	}
}
