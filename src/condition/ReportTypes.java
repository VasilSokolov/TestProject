package condition;

import java.util.ArrayList;
import java.util.Arrays;

public enum ReportTypes {

    DAILY("daily"),
    DAILY_PRODUCT_SUMMARY("daily-product-summary"),
    DAILY_ROUTE_PASS("daily-route-pass"),
    DAILY_COMPENSATORY_FEE("daily-compensatory-fee"),
    DAILY_ROUTE_PASS_PARTNER_SUMMARY("daily-route-pass-partner-summary"),
    DAILY_COMPENSATORY_FEE_PARTNER_SUMMARY("daily-compensatory-fee-partner-summary"),
    TWICE_MONTHLY_ROUTE_PASS("twice-monthly-route-pass"),
    TWICE_MONTHLY_COMPENSATORY_FEE("twice-monthly-compensatory-fee"),
    DAILY_PARTNER_SUMMARY("daily-partner-summary"),
    TWICE_MONTHLY_PARTNER_SUMMARY("twice-monthly-partner-summary"),
    MONTHLY_PARTNER_SUMMARY("monthly-partner-summary"),
    MONTHLY_SUMMARY("monthly-summary"),
    WEEKLY_SUMMARY("weekly-summary"),
    WEEKLY_SUMMARY_ROUTE_PASS("weekly-summary-route-pass"),
    WEEKLY_SUMMARY_COMPENSATORY_FEE("weekly-summary-compensatory-fee"),
    TWICE_MONTHLY_SUMMARY("twice-monthly-summary"),
    MONTHLY_SUMMARY_ROUTE_PASS("monthly-summary-route-pass"),
    MONTHLY_SUMMARY_COMPENSATORY_FEE("monthly-summary-compensatory-fee"),
    FIVE_DAY_SUMMARY_ROUTE_PASS("five-day-summary-route-pass"),
    FIVE_DAY_SUMMARY_COMPENSATORY_FEE("five-day-summary-compensatory-fee"),
    FIVE_DAY_SUMMARY("five-day-summary"),
    DAILY_TOLLING_COMMISSIONER("daily-tolling-commissioner"),
    TWICE_MONTHLY_TOLLING_COMMISSIONER("twice-monthly-tolling-commissioner"),
    MONTHLY_TOLLING_COMMISSIONER("monthly-tolling-commissioner"),
    DAILY_COMMISSIONER("daily-commissioner"),
    TWICE_MONTHLY_COMMISSIONER("twice-monthly-commissioner"),
    MONTHLY_COMMISSIONER("monthly-commissioner"),
    ALL_COMMISSIONS("all-commissions");

    public String getTypeCode() {
        return typeCode;
    }

    public void setTypeCode(String typeCode) {
        this.typeCode = typeCode;
    }

    private String typeCode;
    private static ArrayList<ReportTypes> types;
    private static ArrayList<ReportTypes> reportTypes = new ArrayList<>();

    ReportTypes(String typeCode) {
        this.typeCode = typeCode;
    }

    public static ArrayList<ReportTypes> getTypes() {
        types.addAll(Arrays.asList(ReportTypes.values()));
        return types;
    }

    public static ArrayList<ReportTypes> getDefaultReportTypes() {
        reportTypes.add(ReportTypes.DAILY);
        reportTypes.add(ReportTypes.DAILY_PRODUCT_SUMMARY);
        reportTypes.add(ReportTypes.DAILY_PARTNER_SUMMARY);
        reportTypes.add(ReportTypes.MONTHLY_SUMMARY);
        reportTypes.add(ReportTypes.TWICE_MONTHLY_SUMMARY);
        return reportTypes;
    }
}
