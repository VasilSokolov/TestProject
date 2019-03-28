package superClassTest;

public class C  extends A{
	private String phone;
	public C(String name, int age, int id, String phone) {
		super(id, name, age);
		this.phone = phone;
	}
	public String getPhone() {
		return phone;
	}
	public void setPhone(String phone) {
		this.phone = phone;
	}
	@Override
	public String toString() {
		return "C [id=" + id + ", phone=" + phone + ", name=" + name + ", age=" + age + "]";
	}
	
	
	
}
