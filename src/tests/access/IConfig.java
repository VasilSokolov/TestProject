package tests.access;

import java.util.List;

public interface IConfig {
	String getDescripton();
	Config createConfig();

	List<Config> findAllConfig(String group);
	void r();
}
