package com.thread;

public class PrimeRun implements Runnable {

	public long minPrime;
	public PrimeRun(long minPrime) {
		this.minPrime = minPrime;
	}
	
	@Override
	public void run() {
		System.out.println("Another one.");
	}

}
