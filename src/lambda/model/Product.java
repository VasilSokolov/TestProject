package lambda.model;

import java.math.BigDecimal;

public class Product {

	private Long id;
	private String name;
	private BigDecimal salary;
	
	public Product(Long id, String name, BigDecimal salary) {
		this.id = id;
		this.name = name;
		this.salary = salary;
	}
	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public BigDecimal getSalary() {
		return salary;
	}
	public void setSalary(BigDecimal salary) {
		this.salary = salary;
	}
	
	
	
}
