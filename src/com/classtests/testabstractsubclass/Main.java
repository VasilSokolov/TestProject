package com.classtests.testabstractsubclass;

public class Main {

	public static void main(String[] args) {

//		float[] f = new float[];
		//is an bad practice
		RunTimeSomething r = new RunTimeSomething() {
			
			@Override
			public void go() {
				System.out.println("Da beeeeee");
				
			}
		};
		
		r.go();
		
		Lions l = new Lions() {
			
			@Override
			void go() {
				System.out.println("Lion the lions");
				
			}
		};
		l.go();
	}

}

abstract class Lions extends Monkey {
	String name = "Pesho";
	abstract void go ();
	
	void run(){
		System.out.println("Run");
	}
}

class Monkey {
	String name = "RRRR";
	void gotoSomewere(){
		System.out.println("GOTO");
	}
}

abstract class Subclass extends Lions{
	abstract void go();	
}

class RunTimeImpl implements RunTimeSomething{

	@Override
	public void go() {
		System.out.println("Something to do.");		
	}
	
}
