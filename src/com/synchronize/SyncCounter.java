package com.synchronize;

public class SyncCounter {

	private int count = 0;
	
	public synchronized void increment(){
		count++;
		System.out.println(count);
	}
	
	public synchronized void decrement(){
		count--;
		System.out.println(count);
	}
	
	public synchronized int value(){
		System.out.println(count);
		return count;
	}
}
