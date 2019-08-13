package com.replace;

public class ReplaceTest {

    public static void main(String[] args) {
        String smsText = "Hello % welcome + Name!";
        
        if (!smsText.isEmpty()) {
            smsText.replace("&", "%26");
            smsText.replace("+", "%2B");
        }
        
        System.out.println(smsText);
    }

}
