package softuni.demo04052018.task2_equality_hashcod;
import static java.lang.Math.toIntExact;

public class Student {

	private long id;
	private String name;
	
	public Student() {
	}
		
	public Student(long id, String name) {
		this.id = id;
		this.name = name;
	}

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

//	@Override
//	public int hashCode() {
//		return hashcodeMethod();
//	}

//	@Override
//	public boolean equals(Object obj) {
//		return equalsMethod(obj);
//	}
	
	@Override
	public int hashCode() {
		return toIntExact(id);
	}
//
	
	@Override
	public String toString() {
		return "Student [id=" + id + ", name=" + name + "]";
	}
	
	public int hashcodeMethod() {
		final int prime = 31;
		int result = 1;
		result = prime * result + (int) (id ^ (id >>> 32));
		result = prime * result + ((name == null) ? 0 : name.hashCode());
		return result;
	}
	
	public boolean equalsMethod(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Student other = (Student) obj;
		if (id != other.id)
			return false;
		if (name == null) {
			if (other.name != null)
				return false;
		} else if (!name.equals(other.name))
			return false;
		return true;
	}
	
}
