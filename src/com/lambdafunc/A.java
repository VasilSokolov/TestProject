package com.lambdafunc;

public interface A extends O {
	default void print() {
		System.out.println("Print from interface A");
	}

}
