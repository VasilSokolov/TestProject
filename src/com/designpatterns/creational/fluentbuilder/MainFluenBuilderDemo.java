package com.designpatterns.creational.fluentbuilder;

public class MainFluenBuilderDemo {

	public static void main(String[] args) {
		Product product = Product.newProduct()  
                .id(1l)
                .description("TV 46'")
                .value(2000.00)
                .name("TV 46'")
            .build();
		System.out.println(product.toString());
	}

}
