package com.designpatterns.behavior.template;

public class TemplatePatternDemo {
	public static void main(String[] args) {
		Game game = new Cricket();
		String gameName= game.getClass().getSimpleName();
		System.out.println("--------------New game " +gameName + "-----------");

		game.play();
		game = new Football();
		gameName = game.getClass().getSimpleName();
		System.out.println("--------------New game " + gameName + "-----------");
		game.play();
	}
}
