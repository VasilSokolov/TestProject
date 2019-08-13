package lambda.model;

import java.beans.Transient;
import java.math.BigDecimal;
import java.util.Date;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class LoanApplication {

	    private Integer id;
	    private String clientPin;
	    private Integer newCustomProductId;

	    private String productName;

	    private Date created;

	    private Boolean consentGiven;

	    private Date submitted;

	    private Date signed;

	    private Integer refNr;

	    private Double amount;

	    private Integer period;

	    private String purpose;

	    private String otherPurpose;

	    private Date firstPayment;

	    private String bankAccount;

	    private String bankCode;

	    private String bankName;

	    private String mediasource;

	    private Double interestRate;

	    private Double admissionFee;

	    private Double admissionFeeClient;

	    private String ip;

	    private String source;
	    private String status;


	    private String owner;

	    private boolean clientNotified;

	    private Date approvalDate;

	    private boolean active;

	    private Date activeDate;
	    private boolean paidOut;

	    private Date paidOutDate;

	    @Builder.Default
	    private Double totalSum = 0.0;

	    @Builder.Default
	    private Double monthlyPayback = 0.0;

	    private String loanOffice;

	    @Builder.Default
	    private Double paid = 0.0;

	    private String action;


	    // Used for dealer loan apps only
	    private String code;

	    // Loan app ref, who recommended clientdelay_interest
	    private Integer referral;

	    private String processInstanceId;

	    private String defaultProcessInstanceId;

	    private boolean closed;

	    private Date closedDate;

	    private Integer oldCrmId;

	    private Integer refinancedWith;

	    private Integer restructuredFrom;

	    private BigDecimal restructuredAmount;

	    private Date earlySaved;

	    private Date earlyDate;

	    private Double earlySum;

	    private Date refundRequestSaved;

	    private Date refundRequestDate;

	    private Date termDate;

	    private String saveAsBadReason;

	    private String rejectionReason;

	    private String withdrawnReason;

	    private boolean docsReceived;

	    private int collection;

	    private Date collectionDate;

	    private Date collectionDebtDate;

	    private Date sendToDebt;

	    private Integer collectionSchemeId;

	    private Double collectionDebt;

	    private Integer collectionPortfolioId;

	    private Date internalCollectionDate;

	    private Double internalCollectionDebt;

	    private String performance;

	    private boolean defaulted;


	    private String dataAgreementNr;

	    private Double apr;

	    private Double aprForClient;

	    private Double purchaseCost;

	    private Double shopFee;

	    private boolean useCustomAdvancePayment;

	    private Double advancePayment;

	    private String salesman;

	    private String salesmanPhone;

	    private String submitPerson;

	    private boolean shortForm;

	    private boolean agreementSigned;

	    private String signedPerson;

	    private String signedOffice;

		public LoanApplication(Integer id, String clientPin, Date signed, Integer refNr, boolean agreementSigned, boolean active) {
			super();
			this.id = id;
			this.clientPin = clientPin;
			this.signed = signed;
			this.refNr = refNr;
			this.agreementSigned = agreementSigned;
			this.active = active;
			
		}

		public Integer getId() {
			return id;
		}

		public void setId(Integer id) {
			this.id = id;
		}

		public String getClientPin() {
			return clientPin;
		}

		public void setClientPin(String clientPin) {
			this.clientPin = clientPin;
		}

		public Integer getNewCustomProductId() {
			return newCustomProductId;
		}

		public void setNewCustomProductId(Integer newCustomProductId) {
			this.newCustomProductId = newCustomProductId;
		}

		public String getProductName() {
			return productName;
		}

		public void setProductName(String productName) {
			this.productName = productName;
		}

		public Date getCreated() {
			return created;
		}

		public void setCreated(Date created) {
			this.created = created;
		}

		public Boolean getConsentGiven() {
			return consentGiven;
		}

		public void setConsentGiven(Boolean consentGiven) {
			this.consentGiven = consentGiven;
		}

		public Date getSubmitted() {
			return submitted;
		}

		public void setSubmitted(Date submitted) {
			this.submitted = submitted;
		}

		public Date getSigned() {
			return signed;
		}

		public void setSigned(Date signed) {
			this.signed = signed;
		}

		public Integer getRefNr() {
			return refNr;
		}

		public void setRefNr(Integer refNr) {
			this.refNr = refNr;
		}

		public Double getAmount() {
			return amount;
		}

		public void setAmount(Double amount) {
			this.amount = amount;
		}

		public Integer getPeriod() {
			return period;
		}

		public void setPeriod(Integer period) {
			this.period = period;
		}

		public String getPurpose() {
			return purpose;
		}

		public void setPurpose(String purpose) {
			this.purpose = purpose;
		}

		public String getOtherPurpose() {
			return otherPurpose;
		}

		public void setOtherPurpose(String otherPurpose) {
			this.otherPurpose = otherPurpose;
		}

		public Date getFirstPayment() {
			return firstPayment;
		}

		public void setFirstPayment(Date firstPayment) {
			this.firstPayment = firstPayment;
		}

		public String getBankAccount() {
			return bankAccount;
		}

		public void setBankAccount(String bankAccount) {
			this.bankAccount = bankAccount;
		}

		public String getBankCode() {
			return bankCode;
		}

		public void setBankCode(String bankCode) {
			this.bankCode = bankCode;
		}

		public String getBankName() {
			return bankName;
		}

		public void setBankName(String bankName) {
			this.bankName = bankName;
		}

		public String getMediasource() {
			return mediasource;
		}

		public void setMediasource(String mediasource) {
			this.mediasource = mediasource;
		}

		public Double getInterestRate() {
			return interestRate;
		}

		public void setInterestRate(Double interestRate) {
			this.interestRate = interestRate;
		}

		public Double getAdmissionFee() {
			return admissionFee;
		}

		public void setAdmissionFee(Double admissionFee) {
			this.admissionFee = admissionFee;
		}

		public Double getAdmissionFeeClient() {
			return admissionFeeClient;
		}

		public void setAdmissionFeeClient(Double admissionFeeClient) {
			this.admissionFeeClient = admissionFeeClient;
		}

		public String getIp() {
			return ip;
		}

		public void setIp(String ip) {
			this.ip = ip;
		}

		public String getSource() {
			return source;
		}

		public void setSource(String source) {
			this.source = source;
		}

		public String getStatus() {
			return status;
		}

		public void setStatus(String status) {
			this.status = status;
		}

		public String getOwner() {
			return owner;
		}

		public void setOwner(String owner) {
			this.owner = owner;
		}

		public boolean isClientNotified() {
			return clientNotified;
		}

		public void setClientNotified(boolean clientNotified) {
			this.clientNotified = clientNotified;
		}

		public Date getApprovalDate() {
			return approvalDate;
		}

		public void setApprovalDate(Date approvalDate) {
			this.approvalDate = approvalDate;
		}

		public boolean isActive() {
			return active;
		}

		public void setActive(boolean active) {
			this.active = active;
		}

		public Date getActiveDate() {
			return activeDate;
		}

		public void setActiveDate(Date activeDate) {
			this.activeDate = activeDate;
		}

		public boolean isPaidOut() {
			return paidOut;
		}

		public void setPaidOut(boolean paidOut) {
			this.paidOut = paidOut;
		}

		public Date getPaidOutDate() {
			return paidOutDate;
		}

		public void setPaidOutDate(Date paidOutDate) {
			this.paidOutDate = paidOutDate;
		}

		public Double getTotalSum() {
			return totalSum;
		}

		public void setTotalSum(Double totalSum) {
			this.totalSum = totalSum;
		}

		public Double getMonthlyPayback() {
			return monthlyPayback;
		}

		public void setMonthlyPayback(Double monthlyPayback) {
			this.monthlyPayback = monthlyPayback;
		}

		public String getLoanOffice() {
			return loanOffice;
		}

		public void setLoanOffice(String loanOffice) {
			this.loanOffice = loanOffice;
		}

		public Double getPaid() {
			return paid;
		}

		public void setPaid(Double paid) {
			this.paid = paid;
		}

		public String getAction() {
			return action;
		}

		public void setAction(String action) {
			this.action = action;
		}

		public String getCode() {
			return code;
		}

		public void setCode(String code) {
			this.code = code;
		}

		public Integer getReferral() {
			return referral;
		}

		public void setReferral(Integer referral) {
			this.referral = referral;
		}

		public String getProcessInstanceId() {
			return processInstanceId;
		}

		public void setProcessInstanceId(String processInstanceId) {
			this.processInstanceId = processInstanceId;
		}

		public String getDefaultProcessInstanceId() {
			return defaultProcessInstanceId;
		}

		public void setDefaultProcessInstanceId(String defaultProcessInstanceId) {
			this.defaultProcessInstanceId = defaultProcessInstanceId;
		}

		public boolean isClosed() {
			return closed;
		}

		public void setClosed(boolean closed) {
			this.closed = closed;
		}

		public Date getClosedDate() {
			return closedDate;
		}

		public void setClosedDate(Date closedDate) {
			this.closedDate = closedDate;
		}

		public Integer getOldCrmId() {
			return oldCrmId;
		}

		public void setOldCrmId(Integer oldCrmId) {
			this.oldCrmId = oldCrmId;
		}

		public Integer getRefinancedWith() {
			return refinancedWith;
		}

		public void setRefinancedWith(Integer refinancedWith) {
			this.refinancedWith = refinancedWith;
		}

		public Integer getRestructuredFrom() {
			return restructuredFrom;
		}

		public void setRestructuredFrom(Integer restructuredFrom) {
			this.restructuredFrom = restructuredFrom;
		}

		public BigDecimal getRestructuredAmount() {
			return restructuredAmount;
		}

		public void setRestructuredAmount(BigDecimal restructuredAmount) {
			this.restructuredAmount = restructuredAmount;
		}

		public Date getEarlySaved() {
			return earlySaved;
		}

		public void setEarlySaved(Date earlySaved) {
			this.earlySaved = earlySaved;
		}

		public Date getEarlyDate() {
			return earlyDate;
		}

		public void setEarlyDate(Date earlyDate) {
			this.earlyDate = earlyDate;
		}

		public Double getEarlySum() {
			return earlySum;
		}

		public void setEarlySum(Double earlySum) {
			this.earlySum = earlySum;
		}

		public Date getRefundRequestSaved() {
			return refundRequestSaved;
		}

		public void setRefundRequestSaved(Date refundRequestSaved) {
			this.refundRequestSaved = refundRequestSaved;
		}

		public Date getRefundRequestDate() {
			return refundRequestDate;
		}

		public void setRefundRequestDate(Date refundRequestDate) {
			this.refundRequestDate = refundRequestDate;
		}

		public Date getTermDate() {
			return termDate;
		}

		public void setTermDate(Date termDate) {
			this.termDate = termDate;
		}

		public String getSaveAsBadReason() {
			return saveAsBadReason;
		}

		public void setSaveAsBadReason(String saveAsBadReason) {
			this.saveAsBadReason = saveAsBadReason;
		}

		public String getRejectionReason() {
			return rejectionReason;
		}

		public void setRejectionReason(String rejectionReason) {
			this.rejectionReason = rejectionReason;
		}

		public String getWithdrawnReason() {
			return withdrawnReason;
		}

		public void setWithdrawnReason(String withdrawnReason) {
			this.withdrawnReason = withdrawnReason;
		}

		public boolean isDocsReceived() {
			return docsReceived;
		}

		public void setDocsReceived(boolean docsReceived) {
			this.docsReceived = docsReceived;
		}

		public int getCollection() {
			return collection;
		}

		public void setCollection(int collection) {
			this.collection = collection;
		}

		public Date getCollectionDate() {
			return collectionDate;
		}

		public void setCollectionDate(Date collectionDate) {
			this.collectionDate = collectionDate;
		}

		public Date getCollectionDebtDate() {
			return collectionDebtDate;
		}

		public void setCollectionDebtDate(Date collectionDebtDate) {
			this.collectionDebtDate = collectionDebtDate;
		}

		public Date getSendToDebt() {
			return sendToDebt;
		}

		public void setSendToDebt(Date sendToDebt) {
			this.sendToDebt = sendToDebt;
		}

		public Integer getCollectionSchemeId() {
			return collectionSchemeId;
		}

		public void setCollectionSchemeId(Integer collectionSchemeId) {
			this.collectionSchemeId = collectionSchemeId;
		}

		public Double getCollectionDebt() {
			return collectionDebt;
		}

		public void setCollectionDebt(Double collectionDebt) {
			this.collectionDebt = collectionDebt;
		}

		public Integer getCollectionPortfolioId() {
			return collectionPortfolioId;
		}

		public void setCollectionPortfolioId(Integer collectionPortfolioId) {
			this.collectionPortfolioId = collectionPortfolioId;
		}

		public Date getInternalCollectionDate() {
			return internalCollectionDate;
		}

		public void setInternalCollectionDate(Date internalCollectionDate) {
			this.internalCollectionDate = internalCollectionDate;
		}

		public Double getInternalCollectionDebt() {
			return internalCollectionDebt;
		}

		public void setInternalCollectionDebt(Double internalCollectionDebt) {
			this.internalCollectionDebt = internalCollectionDebt;
		}

		public String getPerformance() {
			return performance;
		}

		public void setPerformance(String performance) {
			this.performance = performance;
		}

		public boolean isDefaulted() {
			return defaulted;
		}

		public void setDefaulted(boolean defaulted) {
			this.defaulted = defaulted;
		}

		public String getDataAgreementNr() {
			return dataAgreementNr;
		}

		public void setDataAgreementNr(String dataAgreementNr) {
			this.dataAgreementNr = dataAgreementNr;
		}

		public Double getApr() {
			return apr;
		}

		public void setApr(Double apr) {
			this.apr = apr;
		}

		public Double getAprForClient() {
			return aprForClient;
		}

		public void setAprForClient(Double aprForClient) {
			this.aprForClient = aprForClient;
		}

		public Double getPurchaseCost() {
			return purchaseCost;
		}

		public void setPurchaseCost(Double purchaseCost) {
			this.purchaseCost = purchaseCost;
		}

		public Double getShopFee() {
			return shopFee;
		}

		public void setShopFee(Double shopFee) {
			this.shopFee = shopFee;
		}

		public boolean isUseCustomAdvancePayment() {
			return useCustomAdvancePayment;
		}

		public void setUseCustomAdvancePayment(boolean useCustomAdvancePayment) {
			this.useCustomAdvancePayment = useCustomAdvancePayment;
		}

		public Double getAdvancePayment() {
			return advancePayment;
		}

		public void setAdvancePayment(Double advancePayment) {
			this.advancePayment = advancePayment;
		}

		public String getSalesman() {
			return salesman;
		}

		public void setSalesman(String salesman) {
			this.salesman = salesman;
		}

		public String getSalesmanPhone() {
			return salesmanPhone;
		}

		public void setSalesmanPhone(String salesmanPhone) {
			this.salesmanPhone = salesmanPhone;
		}

		public String getSubmitPerson() {
			return submitPerson;
		}

		public void setSubmitPerson(String submitPerson) {
			this.submitPerson = submitPerson;
		}

		public boolean isShortForm() {
			return shortForm;
		}

		public void setShortForm(boolean shortForm) {
			this.shortForm = shortForm;
		}

		public boolean isAgreementSigned() {
			return agreementSigned;
		}

		public void setAgreementSigned(boolean agreementSigned) {
			this.agreementSigned = agreementSigned;
		}

		public String getSignedPerson() {
			return signedPerson;
		}

		public void setSignedPerson(String signedPerson) {
			this.signedPerson = signedPerson;
		}

		public String getSignedOffice() {
			return signedOffice;
		}

		public void setSignedOffice(String signedOffice) {
			this.signedOffice = signedOffice;
		}
		
		
	    
	    
}
