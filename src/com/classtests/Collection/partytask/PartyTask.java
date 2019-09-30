package com.classtests.Collection.partytask;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class PartyTask {

	public static void main(String[] args) {		
		testEnums();
	}

	private static void testEnums() {		
		
		List<SmsProvider> list = new ArrayList<>(
				Arrays.asList(
						new SmsProvider(1l, "Ani", SmsCunstants.SMS_STATUS_BAD_AUTH.toString()),
						new SmsProvider(1l, "Moni", SmsCunstants.SMS_STATUS_DELIVERED.toString()),
						new SmsProvider(1l, "geri", SmsCunstants.SMS_STATUS_FAILED.toString()))
				);
		
		SmsProvider provider = new SmsProvider(1l, "Pepi", SmsCunstants.SMS_STATUS_SEND.toString());
			
		
		System.out.println(provider);
		System.out.println(SmsCunstants.SMS_STATUS_SEND.toString() instanceof String);

		list.stream().forEach(p -> System.out.println(p));
	}
}
