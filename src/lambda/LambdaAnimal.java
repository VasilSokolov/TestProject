package lambda;

import java.math.BigDecimal;

public class LambdaAnimal {

	private Long id;
	private String name;
	private Integer age;
	private BigDecimal weighs;
	private String property;
	
	
	public LambdaAnimal() {
	}
	
	public LambdaAnimal(Long id, String name, Integer age, BigDecimal weighs) {
		this.id = id;
		this.name = name;
		this.age = age;
		this.weighs = weighs;
	}
	
	

	public LambdaAnimal(Long id, String name, Integer age, BigDecimal weighs, String property) {
		super();
		this.id = id;
		this.name = name;
		this.age = age;
		this.weighs = weighs;
		this.property = property;
	}

	public String getProperty() {
		return property;
	}

	public void setProperty(String property) {
		this.property = property;
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

	public Integer getAge() {
		return age;
	}

	public void setAge(Integer age) {
		this.age = age;
	}

	public BigDecimal getWeighs() {
		return weighs;
	}

	public void setWeighs(BigDecimal weighs) {
		this.weighs = weighs;
	}

	@Override
	public String toString() {
		return "LambdaAnimal [id=" + id + ", name=" + name + ", age=" + age + ", weighs=" + weighs + "]";
	}
}
