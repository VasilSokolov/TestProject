package com.magicMap;

import java.io.IOException;
import java.io.Serializable;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;

/*
 * To use this class its need dependency:
	compile group: 'javax.xml.bind', name: 'jaxb-api', version: '2.3.1'
 */
public final class DataMap implements Serializable {

	private static final long serialVersionUID = 1L;
	
	private static Logger logger = LoggerFactory.getLogger(DataMap.class);
	private static DataMap instance = new DataMap();

	private transient static Map<String, Object> data;

	private String res;

	public DataMap() {
		data = new HashMap<>();
	}

	public DataMap(Object obj) {
		this();
//		String jsonData = "";
		if (obj != null) {
			if (obj instanceof String || obj instanceof Number) {
				data = Collections.singletonMap("str", obj);
			} else {
				try {
//					jsonData = new ObjectMapper().writeValueAsString(obj);
					data = new ObjectMapper().readValue(new ObjectMapper().writeValueAsString(obj), Map.class);
				} catch (IOException ex) {
					System.out.println(ex.getMessage());
				}
			}
		} else {
//          Logger.log("Creating new DataMap with a 'null' JSON data string."
		}
	}

	public DataMap(Map object) {

		ObjectMapper mapper = new ObjectMapper();
		mapper.configure(DeserializationFeature.FAIL_ON_NULL_FOR_PRIMITIVES, false);
		mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
		mapper.configure(DeserializationFeature.FAIL_ON_NUMBERS_FOR_ENUMS, false);
		try {

			String result = mapper.writeValueAsString(object);
			// convert JSON string to Map
			data = mapper.readValue(result, new TypeReference<Map<String, Object>>() {
			});
		} catch (IOException e) {
			System.out.println(e.getMessage());
		}
	}

	public DataMap convertMapToDataMap(Map object) {
		try {
			// convert JSON string to Map
			data = new ObjectMapper().readValue(new ObjectMapper().writeValueAsString(object), Map.class);
		} catch (IOException e) {
			System.out.println(e.getMessage());
		}
		return new DataMap(data);
	}

	public <T> T dtoToObject(Class<T> toValueType) {
		ObjectMapper objMapper = new ObjectMapper();
		T obj = null;
		Object o = null;
		try {
			objMapper.configure(DeserializationFeature.FAIL_ON_NULL_FOR_PRIMITIVES, false);
			objMapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
			objMapper.configure(DeserializationFeature.FAIL_ON_NUMBERS_FOR_ENUMS, false);
			objMapper.configure(DeserializationFeature.ACCEPT_SINGLE_VALUE_AS_ARRAY, true);
			objMapper.configure(DeserializationFeature.ADJUST_DATES_TO_CONTEXT_TIME_ZONE, true);
			objMapper.registerModule(new JavaTimeModule());
			String jsonObject = new ObjectMapper().writeValueAsString(data);
			o = new ObjectMapper().readValue(jsonObject, Object.class);
			obj =  objMapper.convertValue(o,toValueType);
		} catch (IllegalArgumentException | IOException e) {
			System.out.println(e.getMessage());
		}
		return obj;
	}
	
	public static <T> T dataToEntityOrDto(Object object, Class<T> toValueType) {
		ObjectMapper objMapper = new ObjectMapper();
		T obj = null;
		Object o = null;
		try {
			objMapper.configure(DeserializationFeature.FAIL_ON_NULL_FOR_PRIMITIVES, false);
			objMapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
			objMapper.configure(DeserializationFeature.FAIL_ON_NUMBERS_FOR_ENUMS, false);
			objMapper.configure(DeserializationFeature.ACCEPT_SINGLE_VALUE_AS_ARRAY, true);
			objMapper.configure(DeserializationFeature.ADJUST_DATES_TO_CONTEXT_TIME_ZONE, true);
			objMapper.registerModule(new JavaTimeModule());
			String jsonObject = new ObjectMapper().writeValueAsString(object);
			o = new ObjectMapper().readValue(jsonObject, Object.class);
			obj =  objMapper.convertValue(o,toValueType);
		} catch (IllegalArgumentException | IOException e) {
			System.out.println(e.getMessage());
		}
		return obj;
	}

	
	public <D> D put(String key, Object object) {
		return (D) data.put(key, object);
	}

	public <V> V remove(String key) {
		return (V) data.remove(key);
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

	public <T> T get(String key) {
		try {
			if (data.get(key) instanceof String || data.get(key) instanceof Number) {
				return (T) data.get(key);
			} else {
				data = new ObjectMapper().readValue(new ObjectMapper().writeValueAsString(data.get(key)),
						new TypeReference<Map<String, Object>>() {
						});
			}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
//		return (T) data.get(key);
		return (T) data;
	}

	@Override
	public int hashCode() {
		return Objects.hash(res);
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null || getClass() != obj.getClass())
			return false;
		DataMap other = (DataMap) obj;
		return Objects.equals(this.res, other.res);
	}

	@Override
	public String toString() {
		String result;
		try {
			result = new ObjectMapper().writeValueAsString(data);
		} catch (StackOverflowError | JsonProcessingException e) {
			result = String.valueOf(data);
		}
		
		return result;
	}
}
