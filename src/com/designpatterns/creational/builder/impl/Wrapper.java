package com.designpatterns.creational.builder.impl;

import com.designpatterns.creational.builder.interfaces.Packing;

public class Wrapper implements Packing {

	@Override
	public String pack() {
		return "Wrapper";
	}
}