package project.test;

public class SomeTest {

	public static void main(String[] args) {
		countItems();	
		listAnimal();
	}

	public static void countItems() {
		String[] items = { "A", "B", "C", "D" };

		int i = 0;
		for (String item : items) {
			System.out.println(++i + " - " + item);
		}
		System.out.println("");

		i = 0;
		for (String item : items) {
			System.out.println(i++ + " - " + item);
		}
	}
	
	public static void listAnimal(){
		Animal lion = new Animal("male", 4, 15);
		Animal eagle = new Animal();
		eagle.setGender("female");
		
		if(lion instanceof Animal){
			System.out.println("Yes is it");
		}else{
			System.out.println("No");
		}
		
		System.out.println("Liaon: "+lion.toString()+ "\nEagle: " + eagle.toString());
	}

}
