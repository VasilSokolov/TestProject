package softuni.demo04052018.task7;

import java.util.HashMap;
import java.util.Map;

public class DemoCount {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		counting();
	}

	private static void counting() {
		Map<String, Integer> countMap = new HashMap<>();
		String[] a = {"a", "b", "b", "b", "b"};
		for (int i = 0; i < a.length; i++) {
			if (countMap.keySet().contains(a[i])) {
				countMap.put(a[i], countMap.get(a[i]) + 1);
			} else {
				countMap.put(a[i], 1);
			}
		}		
		System.out.println(countMap.toString());
	}
}
