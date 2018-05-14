package com.designpatterns.structural.bridge;

import com.designpatterns.structural.bridge.impl.GreenCircle;
import com.designpatterns.structural.bridge.impl.RedCircle;

public class BridgePatternDemo {
	public static void main(String[] args) {
		Shape redCircle = new Circle(100, 100, 5, new RedCircle());
		Shape greenCircle = new Circle(100, 70, 16, new GreenCircle());
		
		redCircle.draw();
		greenCircle.draw();
	}
}
