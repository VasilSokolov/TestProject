package com.replace;

public class ReplaceTest {

    public static void main(String[] args) {
        String smsText = null;
        
        if (smsText != null && !smsText.isEmpty()) {
        	smsText = smsText.replace("&", "%26");
        	smsText = smsText.replace("+", "%2B");
        }

        System.out.println("Start");
        System.out.println(smsText);
        System.out.println("End");
    }

}
