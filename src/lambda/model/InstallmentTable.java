package lambda.model;


public class InstallmentTable {

	public Double notPaid;
	public boolean suspended;
	
	
	public InstallmentTable(Double notPaid, boolean suspended) {
		super();
		this.notPaid = notPaid;
		this.suspended = suspended;
	}


	public Double getNotPaid() {
		return notPaid;
	}


	public void setNotPaid(Double notPaid) {
		this.notPaid = notPaid;
	}


	public boolean isSuspended() {
		return suspended;
	}


	public void setSuspended(boolean suspended) {
		this.suspended = suspended;
	}
	
	
}
