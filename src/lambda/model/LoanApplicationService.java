package lambda.model;

import java.util.Arrays;
import java.util.Date;
import java.util.List;

public class LoanApplicationService {

	public List<LoanApplication> getAllClients() {
	    
		List<LoanApplication> list = Arrays.asList(
				new LoanApplication(1,"H1", new Date(), 1231231231, true, true),
				new LoanApplication(2, "H2", new Date(), 1231231232, false, true),
				new LoanApplication(3, "H3", new Date(), 1231231233, true, true),
				new LoanApplication(4, "H4", new Date(), 1231231234, false, false),
				new LoanApplication(5, "H5", new Date(), 1231231234, false, true),
				new LoanApplication(6, "H6", new Date(), 1231231235, true, true),
				new LoanApplication(7, "H7", new Date(), 1231231236, true, true),
				new LoanApplication(8, "H8", new Date(), 1231231237, true, false),
				new LoanApplication(9, "H9", new Date(), 1231231238, true, false)
				);
		     
		return list;
	}

public List<LoanApplication> getIncEmails() {
	    
		List<LoanApplication> list = Arrays.asList(
				new LoanApplication(Arrays.asList("m11@gmail.com", "m12@gmail.com")),
				new LoanApplication(Arrays.asList("m21@gmail.com", "m22@gmail.com")),
				new LoanApplication(Arrays.asList("m31@gmail.com", "m32@gmail.com")),
				new LoanApplication(Arrays.asList("m41@gmail.com", "m42@gmail.com"))
				);
		     
		return list;
	}
	
}
