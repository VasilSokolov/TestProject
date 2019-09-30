package tests.access;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

import com.enums.CountryConfigurationProperty;

public class Config implements IConfig {
	List<Config> list = new ArrayList<Config>();
	
	int count = 1;
	private String descripton;
	private String group;
	
	
		
	public Config() {
		super();
	}

	public Config(String descripton, String group) {
		super();
		this.descripton = descripton;
		this.group = group;
	}

	public String getGroup() {
		return group;
	}

	public void setGroup(String group) {
		this.group = group;
	}

	public String getDescripton() {		
		return descripton;
	}

	public void setDescripton() {
		this.descripton = "add data " + count++;
	}

	public Config createConfig() {
		Config config = new Config();
		config.setDescripton();
		return config;
	}

	@Override
	public void r() {
		System.out.println("Rs");
	}

	@Override
	public String toString() {
		return "Config [count=" + count + ", descripton=" + descripton + "]";
	}

	@Override
	public List<Config> findAllConfig(String group) {
		list.add(new Config("pass", "SMS"));
		list.add(new Config("user", "SMS"));
		list.add(new Config("sbit", "SMS"));
		list.add(new Config("bip", "SMS"));
		list.add(new Config("sss", "general"));
		list.add(new Config("qqq", "general"));
		list.add(new Config("swwwwwss", "general"));
		list.add(new Config("yyyyyyy", "general"));
		list.add(new Config("kkkkkk", "general"));
		list.add(new Config("ddddd", "lm"));
		list.add(new Config("fname", "SMS"));
		list.add(new Config("lname", "SMS"));
		list.add(new Config("auth", "SMS"));
		System.out.println(list  + " Size:" + list.size());
		List<Config> cList = new ArrayList<Config>();
		cList = list.stream().filter(c -> c.group.equalsIgnoreCase(group)).collect(Collectors.toList());
		System.out.println(cList + " Size:" + cList.size());
		return list;
	}
	
	
}
