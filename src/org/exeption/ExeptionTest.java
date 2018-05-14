package org.exeption;

import java.util.LinkedList;
import java.util.List;

public class ExeptionTest {

	public static void main(String[] args) {
		List<String> users = new LinkedList<>();
		users.add("Ivan");
		users.add("Toshko");
		users.add("Peter");
		users.add("Anna");
		
		List<String> users2 = new LinkedList<>();
		users2.add("Ico");
		users2.add("Stilian");
		users2.add("Gosho");
		users2.add("Anna");
		
//		if (users.contains(users2)) {
//			try {
//				throw new DublicateExampleException("User is dublicated ");
//			} catch (DublicateExampleException e) {
//				System.out.println("Stack trance: "+e.getMessage());
//			}
//		}
	}

}
