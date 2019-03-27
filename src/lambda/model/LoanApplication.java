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
	    
	    
}
