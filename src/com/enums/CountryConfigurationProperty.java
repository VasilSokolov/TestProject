package com.enums;

import java.util.Arrays;

import com.enums.exceptions.InvalidCountryConfigurationPropertyException;

//@RequiredArgsConstructor
//@Getter
public enum CountryConfigurationProperty {
    
    USE_HOME_ADDRESS_IN_DEALER_LOAN("useHomeAddressInDealerLoan"),
    USE_PATRONYMIC("usePatronymic"),
    USE_EMAIL("useEmail"),
    THIRD_AND_FOURHT_REM_CALL_TO_MEN("thirdAndFourthCallToMen"),
    RETURN_MAX_PRINCIPAL_6000_FOR_UNOFFICAL_EMPLOYED_NO_CONFIRM("returnMaxPrincipal6000ForUnofficialEmployedNoConfirm"),
    SET_FIRST_PAYMENT_DATE_OTHERWISE_1_OF_MONTH("setFirstPaymentDateOtherwise1stOfMonth"),
    SET_PURPOSE_CAR_EXPENSES("setPurposeCarExpenses"),
    USE_PAY_OUT_ACCOUNTANT_INSTEAD_OF_USUAL("usePayOutAccountantInsteadOfUsual"),
    SET_PAY_OUT_TO_POSTA_AND_PARTNER_OFFICE_TYPE("setPayOutToPostaAndPartnerOfficeType"),
    SET_ALTERNATIVE_CONTACT_OTHER_RELATIVE("setAlternativeContactOtherRelative"),
    SET_UTF8_ENCODING("setUtf8Encoding"),
    SET_AGREEMENT_SIGNMENT_ONLINE_OTHERWISE_OFFICE("setAgreementSignmentOnlineOtherwiseOffice"),
    SET_AGREEMENT_SIGNMENT_ONLINE_OTHERWISE_SMS("setAgreementSignmentOnlineOtherwiseSms"),
    SET_SIGNING_CODE_EXPIRED_ON_WITHDRAWAL("setSigningCodeExpiredOnWithdrawal"),
    SET_AGREEMENT_SIGNMENT_OFFICE_AND_LOAN_PURPOSE_CAR_EXPENSES("setAgreementSignmentOfficeAndLoanPurposeCarExpenses"),
    SEND_REJECTED_EMAIL("sendRejectedEmail"),
    ALWAYS_SHOW_BANK_STATEMENT("alwaysShowBankStatement"),
    ENABLE_POSTA_EMPLOYEES_CANT_GET_FIDEL_BIGGER_THAN_1000("enablePostaEmployeesCantGetFidelBiggerThan1000"),
    ENABLE_ONLINE_SIGNING("onlineSigningEnabled"),
    ONLINE_SIGNING_CODE_URL("onlineSigningCodeSubmissionURL"),
    AUTO_REFUND_DURING_DAYS("auto_refund_during_days"),
    DEALER_ID_COPY_REQUIRED("dealer_id_copy_required"),
    DEALER_DATA_VERIFICATION_REQUIRED("dealer_data_verification_required"),
    POSTA("posta"),
    WESTERN_UNION("western_union"),
    EASY_PAY("easy_pay"),
    EASY_ABI("abi"),
    EASY_MONETA("moneta"),
    EASY_CAPIRAL_RIA("capiral_ria"),
    RAEFAES("raefaes"),
    PRESENTATION_PHONE_NUMBER("presentationPhoneNumber"),
    CALLFLOW_PRESENTATION_PHONE_NUMBER("callFlowPresentationPhoneNumber"),
    CALLFLOW_API_URL("callFlowApiUrl"),
    CALLFLOW_API_USERNAME("callFlowApiUsername"),
    CALLFLOW_API_PASSWORD("callFlowApiPassword"),
    CALLFLOW_API_CLIENT_ID("callFlowApiClientId"),
    CALLFLOW_API_CODE("callFlowApiCode"),
    CALLFLOW_ENABLED("callFlowEnabled"),
    CEO_NAME("ceoName"),
    ANNUITY_INSTALLMENT_CALCULATION("annuityBased"),
    DAILY_INTEREST_ON_PRINCIPAL_ONLY("dailyInterestOnPrincipalOnly"),

    //MINTOS
    MINTOS_LOAN_LENDER_ID("loan.lender_id"),
    MINTOS_LOAN_COUNTRY("loan.country"),
    MINTOS_LOAN_LENDER_ISSUE_DATE("loan.lender_issue_date"),
    MINTOS_LOAN_MINTOS_ISSUE_DATE("loan.mintos_issue_date"),
    MINTOS_LOAN_FINAL_PAYMENT_DATE("loan.final_payment_date"),
    MINTOS_LOAN_AMOUNT("loan.loan_amount"),
    MINTOS_LOAN_AMOUNT_ASSIGNED_TO_MINTOS("loan.loan_amount_assigned_to_mintos"),
    MINTOS_LOAN_INTEREST_PERCENT("loan.interest_rate_percent"),
    MINTOS_LOAN_BUYBACK("loan.buyback"),
    MINTOS_LOAN_CURRENCY("loan.currency"),
    MINTOS_LOAN_EXCHANGE_RATE("loan.currency_exchange_rate"),


    MINTOS_CLIENT_ID("client.id"),
    MINTOS_CLIENT_PIN("client.personal_identification"),
    MINTOS_CLIENT_NAME("client.name"),
    MINTOS_CLIENT_SURNAME("client.surname"),
    MINTOS_CLIENT_GENDER("client.gender"),
    MINTOS_CLIENT_BIRTH_DATE("client.birth_date"),
    MINTOS_CLIENT_AGE("client.age"),
    MINTOS_CLIENT_PHONE_NUMBER("client.phone_number"),
    MINTOS_CLIENT_ADDRESS_ACTUAL("client.address_street_actual"),
    MINTOS_CLIENT_EMAIL("client.email"),

    MINTOS_PLEDGE_TYPE("pledge.type"),

    MINTOS_APR_NET_ISSUED_AMOUNT("apr_calculation_data.net_issued_amount"),
    MINTOS_APR_FIRST_AGREEMENT_DATE("apr_calculation_data.first_agreement_date"),
    MINTOS_APR_PAYMENT_SCHEDULE("apr_calculation_data.actual_payment_schedule"),

    CLIENT_AGE_MIN_LIMIT("age_min_limit"),
    CLIENT_AGE_MAX_LIMIT("age_max_limit"),
    CLIENT_RISKY_EMPLOYMENT_TYPES("risky_employment_types"),
    CLIENT_SHOW_NATIONALITY("showNatiaonalityField"),

    CIPS_FILE_REQUIRED("cips_file_required"),

    // Moldova sms provider data
    MOLDOVA_SMS_URL("sms.moldova.provider.url"),
    MOLDOVA_SMS_PID("sms.moldova.pid"),
    MOLDOVA_SMS_PASSWORD("sms.moldova.password"),
    MOLDOVA_SMS_ALIAS("sms.moldova.alias");

    private final String code;

    public static CountryConfigurationProperty fromString(String property) {
        return Arrays
                .stream(CountryConfigurationProperty.values())
                .filter(v -> v.code.equals(property))
                .findFirst()
                .orElseThrow(() -> new InvalidCountryConfigurationPropertyException(property));
    }
    
    private CountryConfigurationProperty(String code) {
		this.code = code;
	}
    
	@Override
    public String toString() {
        return code;
    }
    
}