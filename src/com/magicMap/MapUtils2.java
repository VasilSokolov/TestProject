package com.magicMap;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MapUtils2 {

	private static MapUtils2 instance = new MapUtils2();
	private static HashMap map = new HashMap();
	private static HashMap hashMap;
	private static String mapKey = "";
	private static ArrayList list;

	private MapUtils2() {
	}
	
	public static MapUtils2 of() {
		
		if (hashMap != null && !hashMap.isEmpty()) {
			
			hashMap.put("", map);
			return instance;
		}
		hashMap = new HashMap();
		return instance;
	}
	
	public static MapUtils2 set(String key, Object value) {

//		if (!mapKey.isEmpty()) {
//			map.put(mapKey, hashMap);
//			mapKey = "";
//		}
			if (value instanceof Map) { 

				mapKey = key;
				
				hashMap.put(mapKey, value);
				
			} else {
				hashMap.put(key, value);
			}
		
		return instance;
	}
	
	
	public Map get() {
		return hashMap;
	}

	
	
	
	
	
	

//	public static class ofMap {
//
//		public ofMap() {
//			hashMap = new HashMap();
//			if (!mapKey.isEmpty()) {
//				map.put(mapKey, hashMap);
//				mapKey = "";
//			}
//		}
//
//		public ofMap set(String key, Object value) {
//
//			if (value instanceof Map) {
//				mapKey = key;
//				map.put(mapKey, value);
//			} else {
//				map.put(key, value);
//			}
////			 map.put(key, hashMap);
//			return this;
//		}
//
//		public Map get() {
//			return map;
//		}
//
//	}
//
//	public static class ofList {
//		public static Map ofMap() {
//
//			hashMap = new HashMap();
//			if (!mapKey.isEmpty()) {
//				map.put(mapKey, hashMap);
//				mapKey = "";
//			}
//			return map;
//		}
//
//		public static List ofList() {
//			list = new ArrayList();
//			return list;
//		}
//
//		public void set(String key, Object value) {
//
//			if (value instanceof List) {
//
//				hashMap.put(key, list.add(value));
//			} else {
//
//				hashMap.put(key, value);
//			}
//			// map.put(key, hashMap);
//		}
//
//		public Map get() {
//			return map;
//		}
//
//	}
//
//	enum Type {
//		MAP("map"), LIST("list");
//
//		public String value;
//
//		Type(String value) {
//			this.value = value;
//		}
//
//		public String getValue() {
//			return value;
//		}
//	}
}
