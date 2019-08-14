package condition;

public class GearML {

	private Long id;
	private String color;
	private int pin;
	private String email;
	private String fullName;
	private boolean active;
	
	
	
	public GearML() {
		super();
	}

	public GearML(Long id, String color, int pin, String email, String fullName, boolean active) {
		super();
		this.id = id;
		this.color = color;
		this.pin = pin;
		this.email = email;
		this.fullName = fullName;
		this.active = active;
	}
	
	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}
	public String getColor() {
		return color;
	}
	public void setColor(String color) {
		this.color = color;
	}
	public int getPin() {
		return pin;
	}
	public void setPin(int pin) {
		this.pin = pin;
	}
	public String getEmail() {
		return email;
	}
	public void setEmail(String email) {
		this.email = email;
	}
	public String getFullName() {
		return fullName;
	}
	public void setFullName(String fullName) {
		this.fullName = fullName;
	}
	public boolean isActive() {
		return active;
	}
	public void setActive(boolean active) {
		this.active = active;
	}
	
	
	
	
}
