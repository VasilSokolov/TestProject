package com.designpatterns.creational.builder.bankAccountBuilder2;

public class BankAccountBuilder {
	
    //Fields omitted for brevity.
	private long accountNumber;
    private String owner;
    private String branch;
    private double balance;
    private double interestRate;
    
    private BankAccountBuilder() {
        //Constructor is now private.
    }
       
    
    private BankAccountBuilder(Builder builder) {
		this.accountNumber = builder.accountNumber;
		this.owner = builder.owner;
		this.branch = builder.branch;
		this.balance = builder.balance;
		this.interestRate = builder.interestRate;
	}

	//Getters and setters omitted for brevity.
	public long getAccountNumber() {
		return accountNumber;
	}

	public void setAccountNumber(long accountNumber) {
		this.accountNumber = accountNumber;
	}

	public String getOwner() {
		return owner;
	}

	public void setOwner(String owner) {
		this.owner = owner;
	}

	public String getBranch() {
		return branch;
	}

	public void setBranch(String branch) {
		this.branch = branch;
	}

	public double getBalance() {
		return balance;
	}

	public void setBalance(double balance) {
		this.balance = balance;
	}

	public double getInterestRate() {
		return interestRate;
	}

	public void setInterestRate(double interestRate) {
		this.interestRate = interestRate;
	}
    
	@Override
	public String toString() {
		return "BankAccountBuilder [accountNumber=" + accountNumber + ", owner=" + owner + ", branch=" + branch
				+ ", balance=" + balance + ", interestRate=" + interestRate + "]";
	}
	
public static class Builder {
		
        private long accountNumber; //This is important, so we'll pass it to the constructor.
        private String owner;
        private String branch;
        private double balance;
        private double interestRate;
        
        public Builder(long accountNumber) {
            this.accountNumber = accountNumber;
        }
        public Builder withOwner(String owner){
            this.owner = owner;
            return this;  //By returning the builder each time, we can create a fluent interface.
        }
        public Builder atBranch(String branch){
            this.branch = branch;
            return this;
        }
        public Builder openingBalance(double balance){
            this.balance = balance;
            return this;
        }
        public Builder atRate(double interestRate){
            this.interestRate = interestRate;
            return this;
        }
        
        public BankAccountBuilder build(){
            //Here we create the actual bank account object, which is always in a fully initialised state when it's returned.
        	BankAccountBuilder account = new BankAccountBuilder();  //Since the builder is in the BankAccountBuilder class, we can invoke its private constructor.
            account.accountNumber = this.accountNumber;
            account.owner = this.owner;
            account.branch = this.branch;
            account.balance = this.balance;
            account.interestRate = this.interestRate;
            return account;
        }
        
        public BankAccountBuilder builder(){            
            return new BankAccountBuilder(this);
        }
    }

}
