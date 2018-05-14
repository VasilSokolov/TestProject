package lambda;

import java.util.Random;

interface Executable{
	int execute();
}

class Runner{
	public void run(Executable e){
		System.out.println("Execute this code ...");
		int value = e.execute();
		System.err.println("Return value: " + value);
	}
}
public class App {
	public static void main(String[] args) {		
		Runner runner = new Runner();
		runner.run(new Executable() {
			
			@Override
			public int execute() {
				System.out.println("Hello there.");
				return 5;				
			}
		});
		System.out.println("====================");
		
		runner.run(()-> {
			System.out.println("This is code pass...");
			System.out.println("Hello there is");
			return 9;
					
		});
		
		runner.run(()->3);

		System.out.println("====================");
		
		Random random = new Random(10);
		float i;
		for (i = 0; i < 5; i++) {
			System.out.printf("%f.2",random.nextFloat());
			System.out.println();
		}
		
//		var mock = new Mock(IFoo);
//		mock.Setup(foo -> foo.doSomething("ping")).Return(true);
		
	}
}
