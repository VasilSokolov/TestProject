package testable.code;

public class SpecialNumber {

	public static void main(String[] args) {

		for (int i = 0; i < 2000; i++) {
			double num1 = Math.sqrt(i+1);
			double num2 = Math.sqrt(i/2 +1);
			if(num1 % 1 == 0) {
				System.out.println(num1);
			}
		}
	}

}
