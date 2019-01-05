package com.designpatterns.utilsdesignpattern.data_access_object;

public class PojoEmployee {
	private String name;
	private int price;
	
	public PojoEmployee(String name, int price) {
		this.name = name;
		this.price = price;
	}
	
	public PojoEmployee() {
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getPrice() {
		return price;
	}

	public void setPrice(int price) {
		this.price = price;
	}

	@Override
	public String toString() {
		return "PojoEmployee [name=" + name + ", price=" + price + "]";
	}
	
	

}
