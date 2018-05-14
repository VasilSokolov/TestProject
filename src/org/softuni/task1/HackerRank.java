package org.softuni.task1;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Scanner;

public class HackerRank {

	public static void main(String[] args) throws IOException {
		HackerRank hr = new HackerRank();
//		hr.usedBufferReader();
		hr.usedScanner();
	}

	public void usedBufferReader() throws IOException {
		BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
		
		try {
			String input;
				while (!("end".equalsIgnoreCase(input = reader.readLine()))) {
					
					String[] data = input.split(" ");
					String myString = data[0];
					String digit = data[1];
					System.out.println("myString is: " + myString);
					System.out.println("myInt is: " + digit);
				}
		    } finally {
			reader.close();
		}
	}
	
	public void usedScanner() {
		Scanner scanner  = new Scanner(System.in);
//		String myString = scanner.next();
        int digit = scanner.nextInt();
        
        weird(digit);
//        
//		System.out.println("myString is: " + myString);
//		System.out.println("myInt is: " + digit);
	}
	
	public void weird(int N) {
		String answer = "";
        
        if(N%2==1 || ( (N%2==0) && (N>=6 && N <= 20 ) ) ){
          answer = "Weird";
        }
        else{
            answer = "Not Weird";
           //Complete the code

        }
        System.out.println(answer);
		
//		if(N%2==1) {
//            if(N >= 6 && N <= 20){                    
//                System.out.println("Not Weird");
//            } else {
//                System.out.println("Weird");
//            }
//        } else if(N%2==0){
//            if(N <= 5 && N >= 2) {                    
//                System.out.println("Weird");
//            } else {                    
//                System.out.println("Not Weird");
//            }
//        } else {                
//            System.out.println("Not Weird");
//        }
		

	}
}
