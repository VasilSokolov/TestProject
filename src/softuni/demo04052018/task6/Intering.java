package softuni.demo04052018.task6;

public class Intering {
	
	public void testing() {

		String a = "abc";
		String b = "abc";
		String c = new String("abc");
		
		System.out.println(a.equals(b));
		System.out.println(a == c);
		System.out.println(b.equals(c));
		testLogic(a);
		System.out.println(a);
		
		String intering =  c.intern();
		System.out.println(a == intering);
	}
	
	public void testLogic(String s) {
		s = s.substring(0, 1);
		System.out.println(s);		
	}
}
