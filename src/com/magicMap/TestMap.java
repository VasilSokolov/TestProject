package com.magicMap;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TestMap {

	public static void main(String[] args) {
//		Map<String, Map<String, Object>> m = new HashMap();
//		m.put("String", "ssss");
//		m.put("String1", "ssss");
//		m.put("String2", "ssss");
//		m.put("String3", "ssss");
//		m.put("a", "b");
		Map m = new HashMap<String, Object>();
		m.put("city", "Sofia");

		m.put("town", "Chintulovo");

		Map m2 = new HashMap<String, Map<String, Object>>();
		m2.put("adres", m);
		Map map = MapUtils2.of()
				.set("a1","ssssss")
				.set("a2", "b2")
				.set("a3", m2)
//				.set("a3", 
//						 MapUtils2.of()
//						.set("i1", m)
//						.get())
				.get();
		System.out.println(map.toString());
		List list = new ArrayList<>();
		list.add("aaa");
		list.add("bbb");
		DataMap mapp = DataMap.of("str", "5", "pesho", m, "list", list);
		
		System.out.println(mapp);
		DataMap dataMap = new DataMap(map);

		DataMap a3 = dataMap.getData("a3");
		DataMap adres = a3.getData("adres");
		String city = adres.getData("city").toString();
//		String town = adres.getData("town").toString();
		
		
//		Map a3 =   dataMap.get("a3");
//		Map adres =   (Map) a3.get("adres");
//		String city =(String) adres.get("city");
		System.out.println(a3);
		System.out.println(adres);
		System.out.println(city);
//		System.out.println(town);
	}

}
