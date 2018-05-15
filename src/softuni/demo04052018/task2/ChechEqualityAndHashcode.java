package softuni.demo04052018.task2;

import java.util.*;

public class ChechEqualityAndHashcode {


	public static void main(String[] args) {
		Student student1 = new Student(1l, "pesho");
		Student student2 = new Student(1l, "pesho");

		System.out.println("alex1 hashcode = " + student1.hashCode());
		System.out.println("alex2 hashcode = " + student2.hashCode());
		System.out.println("Checking equality between student1 and student2 = " + student1.equals(student2));
		System.out.println("----------------------------------------------");

		Student alex = new Student(1, "Alex");
		List<Student> studentsLst = new ArrayList<Student>();
		studentsLst.add(alex);
		System.out.println("Arraylist size = " + studentsLst.size());
		System.out.println("Arraylist contains Alex = " + studentsLst.contains(new Student(1, "Alex")));
		System.out.println("----------------------------------------------");
		
		Student alex1 = new Student(1, "Alex");
        Student alex2 = new Student(1, "Alex");
        HashSet < Student > students = new HashSet < Student > ();
        students.add(alex1);
        students.add(alex2);
        System.out.println("HashSet size = " + students.size());
        System.out.println("HashSet contains Alex = " + students.contains(new Student(1, "Alex")));
        Hashtable<String, String> m = new Hashtable<>();
        m.put(null, null);
        Map<String, String> map = new LinkedHashMap<String, String>();
        map.put("ss", "aaaaa");
	}
}
