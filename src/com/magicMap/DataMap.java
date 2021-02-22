package com.magicMap;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.reflect.TypeToken;

import org.jetbrains.annotations.Contract;
import org.jetbrains.annotations.NotNull;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.Serializable;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/*
 * To use this class its need 5 dependencies:
compile group: 'com.google.code.gson', name: 'gson', version: '2.8.6'
//compile group: 'org.jetbrains', name: 'annotations', version: '16.0.1'
compile group: 'com.fasterxml.jackson.core', name: 'jackson-databind', version: '2.10.1'
compile group: 'com.fasterxml.jackson.core', name: 'jackson-annotations', version: '2.10.1'
compile group: 'com.fasterxml.jackson.core', name: 'jackson-core', version: '2.10.1'
 */
public final class DataMap implements Serializable {

	private static final long serialVersionUID = 1L;

	private static DataMap instance = new DataMap();

	private transient static Map<String, Object> data;
	
	private String res;

	public DataMap() {
		data = new HashMap<>();
	}

	public DataMap(Object object) {
		this(new Gson().toJson(object));
	}

	public DataMap(String jsonData) {
		this();
		if (jsonData != null) {
			Type collectionType = new TypeToken<Map<String, Object>>() {
			}.getType();
			if (validJson(jsonData)) {

				res = jsonData;
			} else {
				data = new Gson().fromJson(jsonData, collectionType);
				
			}
			
		} else {
//          Logger.log("Creating new DataMap with a 'null' JSON data string."
		}
	}

	public boolean validJson(String jsonData) {
		Object s = new Gson().fromJson(jsonData, Object.class).getClass();
		if (s.equals(String.class)) {
			return true;
		}
		return false;
	}

	public static DataMap of(Object... keyValuePairs) {
		if (keyValuePairs == null || (keyValuePairs.length & 1) != 0) {
			throw new RuntimeException(new RuntimeException("INVALID_NUMBER_OF_PARAMETERS"));
		}

		for (int idx = 0; idx < keyValuePairs.length; idx += 2) {
			data.put(String.valueOf(keyValuePairs[idx]), keyValuePairs[idx + 1]);
		}

		return instance;
	}

	@Override
	public String toString() {
		String result;

		try {
			
				result = new Gson().toJson(data);
			
		} catch (StackOverflowError e) {
			result = String.valueOf(data);
		}
		return result;
	}

	public DataMap getData(String key) {

		ObjectMapper mapper = new ObjectMapper();
		try {
			String result = mapper.writeValueAsString(data.get(key));
			if (validJson(result)) {
				return new DataMap(result);
			}
			return new DataMap(result);
		} catch (JsonProcessingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return new DataMap();
	}
	
	public Map get(String key) {
		return (Map) data.get(key);
	}


	public DataMap(Map object) {

//		String result = new Gson().toJson(object);
		ObjectMapper mapper = new ObjectMapper();
		mapper.configure(DeserializationFeature.FAIL_ON_NULL_FOR_PRIMITIVES, false);
		mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
		mapper.configure(DeserializationFeature.FAIL_ON_NUMBERS_FOR_ENUMS, false);
		try {

			String result = mapper.writeValueAsString(object);
			// convert JSON string to Map
			data = mapper.readValue(result, new TypeReference<Map<String, Object>>() {});
		} catch (IOException e) {
			System.out.println(e.getMessage());
		}
	}

	public DataMap convertMapToDataMap(Map object) {
		
		String result = new Gson().toJson(object);
		ObjectMapper mapper = new ObjectMapper();
		try {
			// convert JSON string to Map
			data = mapper.readValue(result, Map.class);
		} catch (IOException e) {
			System.out.println(e.getMessage());
		}
		return new DataMap(data);
	}

	public <V> V remove(String key) {
		return (V) data.remove(key);
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((res == null) ? 0 : res.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		DataMap other = (DataMap) obj;
		if (res == null) {
			if (other.res != null)
				return false;
		} else if (!res.equals(other.res))
			return false;
		return true;
	}
	
	
}
