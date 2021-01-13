package com.hashcode_and_equals;

import java.util.HashMap;
import java.util.Map;

public class ExampleOfHashcodeAndEquals {

	public static void main(String[] args) {
		Map<Team,String> leaders = new HashMap<>();
		leaders.put(new Team("New York", "development"), "Anne");
		leaders.put(new Team("Boston", "development"), "Brian");
		leaders.put(new Team("Boston", "marketing"), "Charlie");

		Team myTeam = new Team("New York", "development");
		Team myTeam2 = new Team("New York", "development");
		if (myTeam.equals(myTeam2)) {
			System.out.println("Its equal");
		} else {
			System.out.println("Its not equal");
		}
		if (leaders.containsKey(myTeam2)) {
			System.out.println("Its exist");
		} else {
			System.out.println("Its not exist");
		}	
		String myTeamLeader = leaders.get(myTeam);
		System.out.println(myTeamLeader);
	}

}
