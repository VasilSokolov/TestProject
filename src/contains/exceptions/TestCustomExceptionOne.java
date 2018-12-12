package contains.exceptions;

import java.io.BufferedReader;
import java.io.FileReader;
import java.lang.reflect.Field;

public class TestCustomExceptionOne {

	public static void main(String[] args) {

		StringBuilder sb = new StringBuilder();
		sb.append("Hello");
		sb.reverse();
		System.out.println(sb.toString());
		String str = sb.toString();
		if(str.compareToIgnoreCase("hello") <= 0)
			System.out.println(true);
		else
			System.out.println(false);
		
	    RegexTestStrings regexTest = new RegexTestStrings();
		regexTest.regexTestStrings();
		System.out.println("-------------Text File Test -----------");
		
//		String file = "C:/textFile.txt";
//		readFromFile(file);
//		checkedAge();
	}
	
	public static void checkedAge() {
		try {
			validate(13);
		} catch (Exception e) {
			String message = e.getClass().getSimpleName();
			
			for (Field string : e.getClass().getDeclaredFields()) {
				System.out.println(string);
			}
//			message = e.getClass().getName();
			System.out.println("Exception occured: " + e.getMessage());
			System.out.println("Exception name: " + message);
		}
		
		System.out.println("rest of the code.. ");
	}
	
	public static void validate(int age) throws InvalidAgeException {
		if (age < 18)
			throw new InvalidAgeException("not valid age");
		else
			System.out.println("welcome to vote");
	}
	
	public static void readFromFile(String file) {
		
	    String line;
	    try(FileReader in = new FileReader(file);
	    	BufferedReader br = new BufferedReader(in);) {			
		    while ((line = br.readLine()) != null) {
		        System.out.println(line);
		        
		        String sLine = line.replace("-", "*");
		        System.out.println(sLine);
		    }
		        
		} catch (Exception e) {
			System.out.println(e.getMessage());
		} finally {
			System.out.println("--------Finally-------");
		}
	}
}

class RegexTestStrings {
	
    public static final String EXAMPLE_TEST = "This is my small example string which I'm going to use for pattern matching.";

    public void regexTestStrings() {
        System.out.println(EXAMPLE_TEST.matches("\\w.*"));
        String[] splitString = (EXAMPLE_TEST.split("\\s+"));
        System.out.println(splitString.length);// should be 14
        for (String string : splitString) {
            System.out.println(string);
        }
        // replace all whitespace with tabs
        System.out.println(EXAMPLE_TEST.replaceAll("\\s+", "****"));
    }
}
