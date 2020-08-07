package project.test;

import java.util.HashSet;

//public class HashTest {
//    
//    private String str;
//    
//    public HashTest(String str) {
//        this.str = str;
//    }
//    
//    public static void main(String args[]) {
//        HashTest h1 = new HashTest("1");
//        HashTest h2 = new HashTest("1");
//        String s1 = new String("2");
//        String s2 = new String("2");
//        
//        HashSet<Object> hs = new HashSet<Object>();
//        hs.add(h1);
//        hs.add(h2);
//        hs.add(s1);
//        hs.add(s2);
//        
//        System.out.print(hs.size());
//    }
//}

public class Cruiser implements Runnable {
    public static void main(String[] args) throws InterruptedException {
        Thread a = new Thread(new Cruiser());
        a.start();
        
        System.out.println("A");
        a.join();
        System.out.println("B");
    }
    
    public void run() {
        System.out.println("C");
    }
}


