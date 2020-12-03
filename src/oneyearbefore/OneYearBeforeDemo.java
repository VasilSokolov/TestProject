package oneyearbefore;

import java.time.LocalDate;
import java.time.Month;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

//import com.sun.xml.internal.ws.util.StringUtils;

public class OneYearBeforeDemo {

	public static void main(String[] args) {
		OneYearBeforeDemo o = new OneYearBeforeDemo();
		Map<String, Object> map = o.fromCurrentDateOneYearAgoReport();

		System.out.println(map.toString());
	}
	
	
	private Map<String, Object> fromCurrentDateOneYearAgoReport() {
//		String fromYear = serviceParams.get("fromYear").toString();
//	    String toYear = serviceParams.get("toYear").toString();
//	    String fromMonth = serviceParams.get("fromMonth").toString();
//	    String toMonth = serviceParams.get("toMonth").toString();
		LocalDate date = LocalDate.now();
	    String fromYear = String.valueOf(date.getYear());
	    String toYear = String.valueOf(date.getYear() - 1);
	    String fromMonth = String.valueOf(date.getMonth().getValue());
	    String toMonth = String.valueOf(date.getMonth().getValue() + 1);
		
	    Map<String, Object> dataObject= new HashMap<String, Object>();
	    dataObject.put("fromYear", fromYear);
	    dataObject.put("toYear", toYear);
	    dataObject.put("fromMonth", fromMonth);
	    dataObject.put("toMonth", toMonth);	 

	    return dataObject;
	  }
}
