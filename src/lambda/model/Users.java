package lambda.model;

import java.util.ArrayList;
import java.util.List;

public class Users {

	private Long id;
	private String name;
	private String title;
	private List<Product> products;
		
	public Users() {
	}

	public Users(Long id, String name, String title, List<Product> products) {
		this.id = id;
		this.name = name;
		this.title = title;
		this.products = new ArrayList<>();
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

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public List<Product> getProducts() {
		return products;
	}

	public void setProducts(List<Product> products) {
		this.products = products;
	}

	@Override
	public String toString() {
		return "Users [id=" + id + ", name=" + name + ", title=" + title + ", products=" + products + "]\n";
	}
	
	
}
