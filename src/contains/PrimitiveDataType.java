package contains;

import java.io.File;
import java.lang.reflect.Method;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLClassLoader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Stream;

public class PrimitiveDataType {
	private static final String CANNOT_CONVERT_PARAMETER_FORMAT = "Cannot convert \"%s\" into %s type.";
	
	private Class<?> currentType; 
	
	private String currentData;
	
	@FunctionalInterface
	private interface TryParse {
        Object parse();
    }
	
	@FunctionalInterface
	private interface Square 
	{ 
	    int calculate(int x); 
	} 
	
	@FunctionalInterface
	private interface ITrade {
		public boolean check(Trade t);
	}

	public static void main(String[] args) {
		Short shorting = new Short("123");
		// TODO Auto-generated method stub
		PrimitiveDataType primitiveDataType = new PrimitiveDataType();
		Object s1 = primitiveDataType.resolve(Short.class, "123");
		Object s2 = primitiveDataType.resolve(shorting.getClass(), "123");
		System.out.println("S1 " + s1 + "\n" + "S2 " + s2);
		
		int digit = 5;

		Square s  = (int x) -> x*x;
		int result = primitiveDataType.getCalc(s, digit); 
		System.out.println("Result " + result);
		Trade tr = new Trade();
		tr.setStatus("new");
		ITrade trade = ((t) -> t.getStatus().equalsIgnoreCase(tr.getStatus()));
		System.out.println("Trade: " + trade.check(tr));
		
		primitiveDataType.lambdaMap();
		primitiveDataType.replaseSalary();
	}

	private int getCalc(Square funcSquare, int value) {
		return funcSquare.calculate(value);
	}
	
	public Object resolve(Class<?> primitiveType, String data) {
		this.currentType = primitiveType;
		this.currentData = data;
		
		if(primitiveType == short.class || primitiveType == Short.class) {
			return this.tryParse(() -> Short.parseShort(data));
		}
		
		return null;
	}
	
	private Object tryParse(TryParse function) {
        try {
            return function.parse();
        } catch (Exception ex) {
            throw new IllegalArgumentException(String.format(CANNOT_CONVERT_PARAMETER_FORMAT, this.currentData,  this.currentType.getName()));
        }
    }
	
	private void lambdaMap() {
		Map<String, Integer> nameMap = new HashMap<>();
		Integer value = nameMap.computeIfAbsent("John", s -> s.length());
		System.out.println(value);
	}
	
	private void replaseSalary() {
		Map<String, Integer> salaries = new HashMap<>();

		Map<Object, String> tests = new HashMap<>();
		
		salaries.put("John", 40000);
		salaries.put("Freddy", 30000);
		salaries.put("Samuel", 50000);

		tests.put(new Object(), "ops");
		tests.put(new Object(), "ops");
		
		tests.replaceAll((k, v) -> k.equals("") ? v : v + "name");
		System.out.println(tests.toString());
		
		salaries.replaceAll((name, oldValue) -> 
		name.equals("Freddy") ? oldValue : oldValue + 10000);
		System.out.println(salaries);
		
		List<Integer> values = Arrays.asList(3, 5, 8, 9, 12);
		 
		int sum = values.stream()
		  .reduce(0, (i1, i2) -> i1 + i2);
		System.out.println(sum);
		
		List<String> list = new ArrayList<String>();
		list.add("java");
		list.add("php");
		list.add("python");
		list.add("perl");
		list.add("c");
		list.add("li");
		list.add("c#");
		Stream<String> wordStream = list.stream();
		
		Stream<Integer> lengthStream = wordStream.map(s -> s.length());
		Optional<Integer> sumRed = lengthStream.reduce((x, y) -> x + y);
		
		sumRed.ifPresent(System.out::println);
	}
	
	 private void addJarFileToClassPath(String canonicalPath) {
	        try {
	            this.addUrlToClassPath(new URL("jar:file:" + canonicalPath + "!/"));
	        } catch (MalformedURLException ignored) {
	        }
	    }
	
	 private void addUrlToClassPath(URL url) {
	        try {
	            URLClassLoader sysClassLoaderInstance = (URLClassLoader) ClassLoader.getSystemClassLoader();
	            Class<URLClassLoader> sysClassLoaderType = URLClassLoader.class;
	             Method method = sysClassLoaderType.getDeclaredMethod("addURL", URL.class);
	            method.setAccessible(true);
	            method.invoke(sysClassLoaderInstance, url);
	        } catch (Throwable t) {
	            t.printStackTrace();
	        }
	    }
	     /**
	     * Checks if a file's name ends with .jar
	     */
	    private boolean isJarFile(File file) {
	        return file.isFile() && file.getName().endsWith(".jar");
	    }
	
}