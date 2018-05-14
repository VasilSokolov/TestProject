package org.softuni.tasks.dayofweek;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;

public class DayOfWeekTask {
	
	private final static Set<String> HOLIDAYS = new HashSet<>(Arrays.asList(
			"01-01", "03-03"));	

	private final static String yearPattern = "dd-MM-yyyy";
	private final static String monthPattern = "dd-MM";

	private final static DateTimeFormatter Input_Date_Format = DateTimeFormatter.ofPattern(yearPattern);
	private final static DateTimeFormatter Day_Month_Format = DateTimeFormatter.ofPattern(monthPattern);

	public static void main(String[] args) {
		DayOfWeekTask test = new DayOfWeekTask();
		
		try {
			test.countWorkDayVer1();
			test.countWorkingDays();

		} catch (ParseException | IOException e) {
			e.printStackTrace();
		}
		
	}

	
	public void countWorkingDays() throws ParseException, IOException {
		BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
		
		LocalDate startDate = LocalDate.parse(reader.readLine(), Input_Date_Format);
		LocalDate endDate = LocalDate.parse(reader.readLine(), Input_Date_Format);	
		
		int workingDays = 0;
		
		while (!startDate.isAfter(endDate)) {
			if(isWorkDay(startDate)) {
				workingDays++;
			}
			
			startDate = startDate.plusDays(1);
		}

		System.out.println(workingDays);
	}
	
	public boolean isWorkDay (LocalDate date) {
		DayOfWeek dayOfWeek = date.getDayOfWeek();
		
		return dayOfWeek != DayOfWeek.SUNDAY 
				&& dayOfWeek != DayOfWeek.SATURDAY 
				&& !HOLIDAYS.contains(date.format(Day_Month_Format));
	}
	
	public void countWorkDayVer1() throws ParseException, IOException {
		BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
		

		
		SimpleDateFormat format = new SimpleDateFormat(yearPattern);
	
		Date d1 = format.parse(reader.readLine());
		Date d2 = format.parse(reader.readLine());
		
		int workingDays = 0;
		
		Calendar calendar = Calendar.getInstance();	
		while (d1.compareTo(d2) != 1) {
			calendar.setTime(d1);
			
			
			boolean isHoliday = isHoliday(calendar.getTime());
			int dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK);
			if(!isHoliday && dayOfWeek != Calendar.SATURDAY && dayOfWeek != Calendar.SUNDAY) {
				workingDays++;
			}			
			
			calendar.add(Calendar.DAY_OF_MONTH, 1);
			d1 = calendar.getTime();
		}
		
		System.out.println(workingDays);
	}
	
	
	public boolean isHoliday(Date date) {
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(date);

		int daysNumber = getDayOfMonth(calendar);
		switch (calendar.get(Calendar.MONTH)) {
		case Calendar.JANUARY:
			return getDayOfMonth(calendar) == 1;
		case Calendar.MARCH:
			return calendar.get(Calendar.DAY_OF_MONTH) == 3;
		case Calendar.MAY:	
			return daysNumber == 1 || daysNumber == 6 || daysNumber == 24;			
		case Calendar.SEPTEMBER:
			return daysNumber == 6 || daysNumber == 22;
		case Calendar.NOVEMBER:			
			return getDayOfMonth(calendar) == 1;
		case Calendar.DECEMBER:
			return daysNumber == 24 || daysNumber == 25 || daysNumber == 26;
		default:
			break;
		}
		
		
		return false;
	}
	
	public int getDayOfMonth(Calendar calendar) {		
		return calendar.get(Calendar.DAY_OF_MONTH);
	}
}
