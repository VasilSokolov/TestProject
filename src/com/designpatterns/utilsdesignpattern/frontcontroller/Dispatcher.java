package com.designpatterns.utilsdesignpattern.frontcontroller;

public class Dispatcher {
	
	private HomeView homeView;
	private StudentView studentView;
	
	public Dispatcher() {
		this.homeView = new HomeView();
		this.studentView = new StudentView();
	}
	
	public void despetcher(String request) {
		if (request.equals("STUDENT")) {
			studentView.show();
		} else {
			homeView.show();
		}
	}	
}
