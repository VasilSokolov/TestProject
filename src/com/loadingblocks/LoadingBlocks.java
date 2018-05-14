package com.loadingblocks;

public class LoadingBlocks {

	static int x = 5;
	
	static {
		System.out.println("intit statick block");
		System.out.println("static result = " + x);
	}
	
	{		
		System.out.println("Init block");
		System.out.println("init result = " + x);
	}
}
