package com.thread;

public class PrimeThread extends Thread {
	public long minPrime;
	
	public PrimeThread(long minPrime) {
		this.minPrime = minPrime;
	}
	
	public void run(){
		System.out.println("First");
	}
}
