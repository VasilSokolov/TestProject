package softuni.demo04052018.task6;

import static org.hamcrest.CoreMatchers.equalTo;
import static org.junit.Assert.*;

import org.junit.Before;
import org.junit.Test;


public class JUnitIntering {

	private String constantString1 = "abc";
	private String constantString2 = "abc";
	
	@Before
	public void setData() {
	}
	
	@Test
	public void testLogic() {
		assertThat(constantString1,equalTo(constantString2));
//		assertThat(constantString1)
//		  .isSameAs(constantString2);
	}
}
