package com.anakatech.test;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;


public class DemoClazz {
	public static void main(String[] args) {
		Account accaount = new Account("123");
		accaount.toString();
	}
}


class Account {

	private String numberAccount;

	public Account(String numberAccount) {
		this.numberAccount = numberAccount;
	}

	public String getNumberAccount() {
		return numberAccount;
	}
	
	public ArrayList<DemoClazz> makeTransact() throws Exception {

		try {
			ArrayList<DemoClazz> accaunts = new ArrayList<>();
			List<DemoClazz> listAccounts = new ArrayList<>();
			for (int i = 0; i < accaunts.size(); i++) {

				Transaction transact = makeThisTransact().transact();
			}
			return accaunts;
		} catch (SQLException e) {
			e.getMessage();
			throw new Exception("Can't reach account");
		}
	}
	
	public Transaction makeThisTransact() {		
		return new Transaction();
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((numberAccount == null) ? 0 : numberAccount.hashCode());
		return result;
	}

//	@Override
//	public boolean equals(Account o) {		
//		return o.getNumberAccount() == getNumberAccount();
//	}

	
	
	@Override
	public String toString() {
		return "Account [numberAccount=" + numberAccount + "]";
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Account other = (Account) obj;
		if (numberAccount == null) {
			if (other.numberAccount != null)
				return false;
		} else if (!numberAccount.equals(other.numberAccount))
			return false;
		return true;
	}
}

class Transaction {
	
	public Transaction transact() throws SQLException {
		
		return new Transaction();
	}
}
