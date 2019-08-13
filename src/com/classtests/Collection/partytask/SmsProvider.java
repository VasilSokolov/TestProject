package com.classtests.Collection.partytask;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class SmsProvider {

	private Long id;
	private String name;
	private String status;
	public SmsProvider(Long id, String name, String status) {
		this.id = id;
		this.name = name;
		this.status = status;
	}
	
	
}
