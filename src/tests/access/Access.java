package tests.access;

public class Access {

	private String fName;
	private String lName;
	IConfig config;

	public static void main(String[] args) {
		Access access = new Access();
		access.init();
	}
	

//	public Access() {
//		Config configur = config.createConfig(); 
//		this.fName = config.createConfig().getDescripton();
//		this.lName = config.createConfig().getDescripton();
//	}



	public String getfName() {
		return fName;
	}

	public void setfName(String fName) {
		this.fName = config.createConfig().getDescripton();
	}

	public String getlName() {
		return lName;
	}

	public void setlName(String lName) {
		this.lName = config.createConfig().getDescripton();
	}

	
	public void init() {

		Config configur = config.createConfig(); 
		System.out.println("First name: " + getfName() + " Last Name: " +getlName());
	}

}
