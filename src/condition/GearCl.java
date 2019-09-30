package condition;

public class GearCl {

	private int id;
	private String name;
	
	
	public GearCl() {
		super();
	}


	public GearCl(int id, String name) {
		super();
		this.id = id;
		this.name = name;
	}


	public int getId() {
		return id;
	}


	public void setId(int id) {
		this.id = id;
	}


	public String getName() {
		return name;
	}


	public void setName(String name) {
		this.name = name;
	}


	@Override
	public String toString() {
		return "GearCl [id=" + id + ", name=" + name + "]";
	}
	
	
}
