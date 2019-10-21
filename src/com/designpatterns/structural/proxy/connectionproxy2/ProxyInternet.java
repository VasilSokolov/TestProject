package com.designpatterns.structural.proxy.connectionproxy2;

import java.util.ArrayList;
import java.util.List;


public class ProxyInternet implements Internet {

	private Internet internet = new RealInternet();
	private static List<String> bannedSites;

	static {
		bannedSites = new ArrayList<String>();
		bannedSites.add("abv.bg");
		bannedSites.add("google.bg");
		bannedSites.add("zelka.bg");
		bannedSites.add("abc.bg");
		bannedSites.add("aha.bg");		
	}

	@Override
	public void connectTo(String serverhost) throws Exception {
		chwckBanned(serverhost);
		internet.connectTo(serverhost);
	}

	private void chwckBanned(String serverhost) throws Exception {
		if (bannedSites.contains(serverhost.toLowerCase())) {
			throw new Exception("Access Denied !!!");
		}
	}

}
