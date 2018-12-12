package contains;

//@SuppressWarnings(value = { "" })
public class Person {
	
	public String p = "Person field"; 
	private String name;
	
	public Person() {
		System.out.println("construct");
	}

	public String getName() {
		return name;
	}
	
	public void setName(String name) {
		this.name = name;
	}

	{
		String init = "init";
		System.out.println(init);
		methods();
	}
	
	static{
		String staticBlock = "static block";
		System.out.println(staticBlock);
		methodStatic();
	}
	
	public void methods() {
		System.out.println("method");
	}
	public static void methodStatic() {
		System.out.println("static method");
	}

	@Override
	public String toString() {
		return "Person [p=" + p + ", name=" + name + "]";
	}
}
