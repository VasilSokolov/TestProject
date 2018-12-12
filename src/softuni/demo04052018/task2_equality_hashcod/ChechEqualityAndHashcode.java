package softuni.demo04052018.task2_equality_hashcod;

import java.util.*;

public class ChechEqualityAndHashcode {


	public static void main(String[] args) {		

		Student student1 = new Student(1l, "pesho");
		Student student2 = new Student(1l, "pesho");
		
		System.out.println("alex1 hashcode = " + student1.hashCode());
		System.out.println("alex2 hashcode = " + student2.hashCode());
		System.out.println("Checking equality between student1 and student2 = " + student1.equals(student2));
		System.out.println("----------------------------------------------");

		Student alex1 = new Student(1, "Alex");
		Student alex2 = new Student(1, "Alex");
		Student alex = new Student(1, "Alex");
		List<Student> studentsLst = new ArrayList<Student>();
		studentsLst.add(alex1);
		System.out.println("Arraylist size = " + studentsLst.size());
		System.out.println("Arraylist contains Alex = " + studentsLst.contains(alex2));
		System.out.println("----------------------------------------------");
		        
        HashSet < Student > students = new HashSet<Student> ();
        students.add(alex1);
        students.add(alex2);
        System.out.println("alex1 hashcode = " + alex1.hashCode());
		System.out.println("alex2 hashcode = " + alex2.hashCode());
        System.out.println("HashSet size = " + students.size());
        System.out.println("HashSet contains Alex = " + students.contains(alex));
        System.out.println("----------------------------------------------");
                
        String value = "aaaa";
        HashMap <Student, String > studentMap = new HashMap<> ();
        studentMap.put(alex1, value);
        studentMap.put(alex2, value);
        System.out.println("alex1 hashcode = " + alex1.hashCode());
		System.out.println("alex2 hashcode = " + alex2.hashCode());
        System.out.println("HashMap size = " + studentMap.size());
        System.out.println("HashMap contains Alex = key " + studentMap.containsKey(alex) + " value =  " + studentMap.containsValue(value));
        System.out.println("HashMap contains Alex = key " + studentMap.values() + " value =  " + studentMap.get(alex1));
        System.out.println("----------------------------------------------");
//        Hashtable<String, String> m = new Hashtable<>();
//        m.put("pesho", "p");
//        Map<String, String> map = new LinkedHashMap<String, String>();
//        map.put("ss", "aaaaa");
        
//        try {
//			testingObjectClass();
//		} catch (InterruptedException e) {
//			// TODO Auto-generated catch block
//			e.getMessage();
//		}
	}
	
	public static void testingObjectClass() throws InterruptedException {

		Object o = new Object();
		o.wait(5000);
		System.out.println("Class name " + o.equals(o));
		

	}
}
