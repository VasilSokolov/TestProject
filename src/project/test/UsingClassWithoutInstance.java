package project.test;

import java.lang.reflect.Method;
import java.util.Scanner;


public class UsingClassWithoutInstance {
	public static void main(String[] args) {
		Method m[] = String.class.getDeclaredMethods();
        for (int i = 0; i < m.length; i++)
        {
//          System.out.println(m[i].toString());
        }
        
        Scanner sc = new Scanner(System.in);
        System.out.println("Press first number: ");
        int first = sc.nextInt();
//        if (first == null) {
//        	first = sc.nextInt();
//		}
        
        String text = TestIfItWork.class.getName();
        System.out.println("Press second number: ");
        String multiple = sc.next();
        int second = sc.nextInt();
        int answer = first * second;
        System.out.println("Multiple first and second number is: " + answer + multiple);
        sc.close();
	}	
	
}