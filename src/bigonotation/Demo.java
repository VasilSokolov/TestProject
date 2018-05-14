package bigonotation;

public class Demo {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		devide(5,0);
	}
	
	public static void devide (int a, int b) {
		int c = -1;
		
		try {
			c = a/b;
		} catch (Exception e) {
			System.out.println("here");
		} finally {
			System.out.println("Finally");
		}
	}

}
