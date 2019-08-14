package com.classtests.Collection.partytask;

public enum SmsCunstants {
	
	 SMS_STATUS_SENT("sent"),            //sent to SMS gateway
     SMS_STATUS_SEND ("send"),               //albanian sms service response status
     SMS_STATUS_RETRY ("retry"),             //need to retry to send to SMS gateway
     SMS_STATUS_DELIVERED ("delivered"),     //delivered success
     SMS_STATUS_NOT_DEDELIVERED ("failed"),      //failed to deliver, need to retry later
     SMS_STATUS_FAILED ("failed"),   //failed to send to SMS gateway, will not try again, need manually update records when problem is solved
     SMS_STATUS_BAD_AUTH ("bad_auth"), // HTTP status code 403
     SMS_STATUS_PROHIBITED ("prohibited"), // HTTP status code 430
     SMS_STATUS_WRONG_MSISDN ("wrong_msisdn"), // HTTP status code 431
     SMS_STATUS_WRONG_SENDER ("wrong_sender"); // HTTP status code 406

	
	
     private String smsStatus;
     
     private SmsCunstants(String smsStatus) {
		this.smsStatus = smsStatus;
	}

	@Override
     public String toString() {
         return smsStatus;
     }
     
     public String getName() {
    	 return smsStatus;
     }
}
