package org.javatest;

public class Mixed {

	Mixed m1;
	Mixed(){}
	Mixed(Mixed m){
		m1 = m;
	}

	public static void main(String[] args) {
		Mixed m2 = new Mixed();
		Mixed m3 = new Mixed(m2);	 m3.go();
		Mixed m4 = m3.m1;			 m4.go();
		Mixed m5 = m2.m1;			 m5.go();
		
	}
	
	void go(){
		System.out.print("h1 ");
	}
}
