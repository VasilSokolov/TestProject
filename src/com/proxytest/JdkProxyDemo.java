package com.proxytest;

import java.lang.reflect.*;

public class JdkProxyDemo {
	interface If {
        void originalMethod(String s);
    }
	
    static class Original implements If {
        public void originalMethod(String s) {
            System.out.println(s);
        }
    }
    
    static class Handler implements InvocationHandler {
        private final If original;
        public Handler(If original) {
            this.original = original;
        }
        public Object invoke(Object proxy, Method method, Object[] args)
                throws IllegalAccessException, IllegalArgumentException,
                InvocationTargetException {
            System.out.println("BEFORE");
            method.invoke(original, args);
            System.out.println("AFTER");
            
            return null;
        }
    }
}
