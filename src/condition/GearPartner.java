package condition;

import java.util.ArrayList;
import java.util.List;

public class GearPartner {

	private List<ReportTypes> reportTypes = new ArrayList<>();

	public List<ReportTypes> getReportTypes() {
		return reportTypes;
	}

	public void setReportTypes(List<ReportTypes> reportTypes) {
		this.reportTypes = reportTypes;
	}

	@Override
	public String toString() {
		return "GearPartner [reportTypes=" + reportTypes + "]";
	}
	
	
}
