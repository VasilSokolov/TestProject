package contains.annotation;

import contains.annotation.TesterInfo.Priority;

@TesterInfo (
		priority = Priority.HIGH, 
		createdBy = "vasil.com",  
		tags = {"sales","test" }
	)
	public class TestExample {

		@TestAnnotations
		void testA() {
		  if (true)
			throw new RuntimeException("This test always failed");
		}

		@TestAnnotations(enabled = false)
		void testB() {
		  if (false)
			throw new RuntimeException("This test always passed");
		}

		@TestAnnotations(enabled = true)
		void testC() {
		  if (10 > 1) {
				// do nothing, this test always passed.
			  System.out.println("Always passed");
		  }
		}

	}
