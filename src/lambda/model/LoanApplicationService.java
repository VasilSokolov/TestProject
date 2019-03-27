package lambda.model;

import java.util.Arrays;
import java.util.Date;
import java.util.List;

public class LoanApplicationService {

	public List<LoanApplication> findActiveByClientPin() {
	    
		List<LoanApplication> list = Arrays.asList(
				new LoanApplication(1,"H512355", new Date(), 123123123, true, true),
				new LoanApplication(2, "H22312", new Date(), 123123123, false, true),
				new LoanApplication(3, "H334234", new Date(), 123123123, true, true),
				new LoanApplication(4, "H7231222", new Date(), 123123123, false, false),
				new LoanApplication(5, "H72312345", new Date(), 123123123, false, true),
				new LoanApplication(5, "H72312345", new Date(), 123123123, true, true),
				new LoanApplication(5, "H72312345", new Date(), 123123123, true, true),
				new LoanApplication(5, "H72312345", new Date(), 123123123, true, true),
				new LoanApplication(5, "H72312345", new Date(), 123123123, true, true)
				);
		     
		return list;
	}

}
