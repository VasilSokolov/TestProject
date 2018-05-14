package com.designpatterns.creational.builder.impl;

import com.designpatterns.creational.builder.interfaces.Packing;

public class Bottle implements Packing {

	@Override
	public String pack() {
		return "Bottle";
	}
}
