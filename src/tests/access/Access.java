package tests.access;

import java.util.List;

import com.enums.CountryConfigurationProperty;

public class Access {

	private String fName;
	private String lName;
	IConfig config = new Config();

	public static void main(String[] args) {
		Access access = new Access();
		access.setData();
		access.init();
		access.past();
	}
	

	private void past() {
	System.out.println(this.fName);
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

	public void setData() {
		this.config = config.createConfig(); 
		List<Config> list = config.findAllConfig(CountryConfigurationProperty.SMS.toString());
System.out.println("Answer: " + list);
		this.fName = config.createConfig().getDescripton();
		this.lName = config.createConfig().getDescripton();
	}
	
	public void init() {	
		System.out.println("First name: " + fName + " Last Name: " +getlName() + " Obj: " + config.toString());
	}

	

	@Override
	public String toString() {
		return "Access [fName=" + fName + ", lName=" + lName + ", config=" + config + "]";
	}

	
}
