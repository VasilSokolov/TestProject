package com.thread;

public class TestThreads {

	public static void main(String[] args) {
		PrimeThread pT=new PrimeThread(20);
		pT.start();
		
		PrimeRun p =new PrimeRun(110);
		new Thread(p).start();
	}

}
