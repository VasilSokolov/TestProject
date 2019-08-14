package tests.access;

public class Config implements IConfig {
	int count = 0;
	private String descripton;
		
	public String getDescripton() {
		
		return descripton;
	}

	public void setDescripton(String descripton) {
		count++;
		this.descripton = "add data " + count;
	}

	public Config createConfig() {
		return new Config();
	}
}
