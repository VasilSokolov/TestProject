package timestamp;

import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

public class TimestampToString {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		String strDate = "2020-05-10";
		Long time = 1590494866634l;
		Date date = new Date();
				date.setTime(time);
		SimpleDateFormat dateFormat = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
		String string  = dateFormat.format(date);
		System.out.println(string);
		
		SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
		Date date2 = null;;
		try {
			date2 = formatter.parse(strDate);
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	      Timestamp timeStampDate = new Timestamp(date2.getTime());
		System.out.println(timeStampDate.getTime());
	}

}
