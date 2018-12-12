package com.proxytest;

import java.lang.reflect.Proxy;

import com.proxytest.JdkProxyDemo.Handler;
import com.proxytest.JdkProxyDemo.If;
import com.proxytest.JdkProxyDemo.Original;

public class ProxyDemo {

	public static void main(String[] args) {
		Original original = new Original();
        Handler handler = new Handler(original);
        If f = (If) Proxy.newProxyInstance(If.class.getClassLoader(),
                new Class[] { If.class },
                handler);

        f.originalMethod("Hallo");
	}

}
