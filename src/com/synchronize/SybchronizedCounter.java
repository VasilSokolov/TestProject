package com.synchronize;

public class SybchronizedCounter {

	public static void main(String[] args) {
		SyncCounter syncCounter = new SyncCounter();
		syncCounter.increment();
		syncCounter.value();
		syncCounter.decrement();
	}
	
	
	

}
