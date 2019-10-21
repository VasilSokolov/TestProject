package com.designpatterns.creational.builder.bankAccountBuilder2;

public class ExampleOfBankAccount {

	public static void main(String[] args) {
		BankAccountBuilder account = new BankAccountBuilder.Builder(1234L)
	            .withOwner("Marge")
	            .atBranch("Springfield")
	            .openingBalance(100)
	            .atRate(2.5)
	            .build();
		
		BankAccountBuilder anotherAccount = new BankAccountBuilder.Builder(4567L)
	            .withOwner("Homer")
	            .atBranch("Springfield")
	            .openingBalance(100)
	            .atRate(2.54)
	            .build();
		
		BankAccountBuilder anotherAccount2 = new BankAccountBuilder.Builder(2345L)
	            .withOwner("Homer3")
	            .atBranch("Springfield33")
	            .openingBalance(100)
	            .atRate(2.52)
	            .builder();
		
		System.out.println(account);
		System.out.println("----------------");
		System.out.println(anotherAccount);
		System.out.println("----------------");
		System.out.println(anotherAccount2);
	}

}
