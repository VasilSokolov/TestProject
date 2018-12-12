package com.lambdafunc;

public interface B extends O {
	default void print() {
		System.out.println("Print from interface B");
	}
}
