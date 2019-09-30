package superClassTest;

import java.util.Arrays;

public class TestClass {

	private static final int ID = 70;
	private static final int AGE = 89;
	private static final String PHONE = "+35912312389";
	private static final String NAME = "+Pesho";
	private static final String COLOR = "+RED";
	
	public static void main(String[] args) {
		
		B b1 = new B(ID, NAME, AGE, COLOR);
		A a1 = new A(ID, NAME, AGE);
		C c = new C(NAME, AGE, ID, PHONE);

		A ab1 = new B(ID, NAME, AGE, COLOR);
		System.out.println("Object B : " + b1.toString());
		System.out.println("get " + b1.getAge());
		System.out.println("Object A : " + a1.toString());
		System.out.println("Object A from B : " + ab1.toString());
		System.out.println("Object A from B : " + ab1.getAge());
		System.out.println("Object c : " + c.toString());
		System.out.println();
		summingDigit();
	}
	
	public static void summingDigit() {
		String str = "Item1 10 Item2 5 Item3 5 Item4 15";
		
		Integer sum = Arrays.stream(str.split(" "))
				.filter(x->x.matches("\\d+"))
				.mapToInt(Integer::valueOf)
				.sum();
		System.out.println("Sum: " + sum);
	}
}
