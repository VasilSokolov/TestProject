DROP FUNCTION IF EXISTS get_defaulted_loanapps_base(date, date, date);
CREATE OR REPLACE FUNCTION get_defaulted_loanapps_base(IN date, IN date, IN date)
  RETURNS TABLE(
    loanappid integer,
    loanproduct text,
    loanproductid integer,
    refnr text,
    firstname text,
    lastname text,
    score text,
    office text,
    incassocompany text,
    incassocompanyid integer,
    loanamount numeric,
    loanperiod integer,
    activedate date,
    defaulteddate date,
    internaldate date,
    collectiondate date,
    writtenoffdate date,
    totaldebt numeric,
    principal numeric,
    restructured numeric,
    commissionfee numeric,
    interest numeric,
    guaranteefee numeric,
    adminfee numeric,
    firstrem numeric,
    secondrem numeric,
    termalertfee numeric,
    termfee numeric,
    firstremsms numeric,
    secondremsms numeric,
    thirdremsms numeric,
    fourthremsms numeric,
    fifthremsms numeric,
    suspensionfee numeric,
    delayinterest numeric,
    repaymentslater numeric,
    agreementsignment text,
    payoutto text
  )
LANGUAGE plpgsql
AS $$
BEGIN

  RETURN QUERY
  WITH payments_later AS (
      SELECT rp.loan_app_id AS laid, sum(rp.sum) AS payments FROM repayments rp
        LEFT JOIN loan_application la ON rp.loan_app_id=la.id
      WHERE
        la.term_date IS NOT NULL
        AND (la.term_date::date >=$1 OR la.collection_date >=$1)
        AND rp.payment_date::date >= la.term_date::date
        AND rp.payment_date::date <= $3
        AND rp.writtenoff = false
      GROUP BY rp.loan_app_id
  ),
      principal_claim AS (
        SELECT
          it.loan_app_id AS laid, SUM(it.principal) AS claim
        FROM
          installment_table it
          LEFT JOIN
          loan_application la ON la.id=it.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
        GROUP BY it.loan_app_id
    ),
      principal_payments AS (
        SELECT
          rp.loan_app_id AS laid,
          SUM(rpt.sum) AS payment
        FROM
          repayment_type rpt
          LEFT JOIN
          repayments rp ON rp.id=rpt.repayment_id
          LEFT JOIN
          loan_application la ON la.id=rp.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
          AND rp.payment_date::date <= la.term_date::date
          AND rpt.type='principal'
          AND rp.writtenoff = false
        GROUP BY rp.loan_app_id
    ),
      restructured_claim AS (
        SELECT
          it.loan_app_id AS laid, SUM(it.restructured) AS claim
        FROM
          installment_table it
          LEFT JOIN
          loan_application la ON la.id=it.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
        GROUP BY it.loan_app_id
    ),
      restructured_payments AS (
        SELECT
          rp.loan_app_id AS laid,
          SUM(rpt.sum) AS payment
        FROM
          repayment_type rpt
          LEFT JOIN
          repayments rp ON rp.id=rpt.repayment_id
          LEFT JOIN
          loan_application la ON la.id=rp.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
          AND rp.payment_date::date <= la.term_date::date
          AND rpt.type='restructured'
          AND rp.writtenoff = false
        GROUP BY rp.loan_app_id
    ),
      interest_claim AS (
        SELECT
          it.loan_app_id AS laid, SUM(it.interest) AS claim
        FROM
          installment_table it
          LEFT JOIN
          loan_application la ON la.id=it.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
        GROUP BY it.loan_app_id
    ),
      interest_payments AS (
        SELECT
          rp.loan_app_id AS laid,
          SUM(rpt.sum) AS payment
        FROM
          repayment_type rpt
          LEFT JOIN
          repayments rp ON rp.id=rpt.repayment_id
          LEFT JOIN
          loan_application la ON la.id=rp.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
          AND rp.payment_date::date <= la.term_date::date
          AND rpt.type='interest'
          AND rp.writtenoff = false
        GROUP BY rp.loan_app_id
    ),
      commissionfee_claim AS (
        SELECT
          it.loan_app_id AS laid, SUM(it.admission_fee) AS claim
        FROM
          installment_table it
          LEFT JOIN
          loan_application la ON la.id=it.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
        GROUP BY it.loan_app_id
    ),
      commissionfee_payments AS (
        SELECT
          rp.loan_app_id AS laid,
          SUM(rpt.sum) AS payment
        FROM
          repayment_type rpt
          LEFT JOIN
          repayments rp ON rp.id=rpt.repayment_id
          LEFT JOIN
          loan_application la ON la.id=rp.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
          AND rp.payment_date::date <= la.term_date::date
          AND rpt.type='commission_fee'
          AND rp.writtenoff = false
        GROUP BY rp.loan_app_id
    ),
      guaranteefee_claim AS (
        SELECT
          it.loan_app_id AS laid, SUM(it.guarantee_fee) AS claim
        FROM
          installment_table it
          LEFT JOIN
          loan_application la ON la.id=it.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
        GROUP BY it.loan_app_id
    ),
      guaranteefee_payments AS (
        SELECT
          rp.loan_app_id AS laid,
          SUM(rpt.sum) AS payment
        FROM
          repayment_type rpt
          LEFT JOIN
          repayments rp ON rp.id=rpt.repayment_id
          LEFT JOIN
          loan_application la ON la.id=rp.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
          AND rp.payment_date::date <= la.term_date::date
          AND rpt.type='guarantee_fee'
          AND rp.writtenoff = false
        GROUP BY rp.loan_app_id
    ),
      adminfee_claim AS (
        SELECT
          it.loan_app_id AS laid, SUM(it.admin_fee) AS claim
        FROM
          installment_table it
          LEFT JOIN
          loan_application la ON la.id=it.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
        GROUP BY it.loan_app_id
    ),
      adminfee_payments AS (
        SELECT
          rp.loan_app_id AS laid,
          SUM(rpt.sum) AS payment
        FROM
          repayment_type rpt
          LEFT JOIN
          repayments rp ON rp.id=rpt.repayment_id
          LEFT JOIN
          loan_application la ON la.id=rp.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
          AND rp.payment_date::date <= la.term_date::date
          AND rpt.type='admin_fee'
          AND rp.writtenoff = false
        GROUP BY rp.loan_app_id
    ),
      firstrem_claim AS (
        SELECT
          it.loan_app_id AS laid, SUM(it.first_rem) AS claim
        FROM
          installment_table it
          LEFT JOIN
          loan_application la ON la.id=it.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
        GROUP BY it.loan_app_id
    ),
      firstrem_payments AS (
        SELECT
          rp.loan_app_id AS laid,
          SUM(rpt.sum) AS payment
        FROM
          repayment_type rpt
          LEFT JOIN
          repayments rp ON rp.id=rpt.repayment_id
          LEFT JOIN
          loan_application la ON la.id=rp.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
          AND rp.payment_date::date <= la.term_date::date
          AND rpt.type='1st_reminder_fee'
          AND rp.writtenoff = false
        GROUP BY rp.loan_app_id
    ),
      secondrem_claim AS (
        SELECT
          it.loan_app_id AS laid, SUM(it.second_rem) AS claim
        FROM
          installment_table it
          LEFT JOIN
          loan_application la ON la.id=it.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
        GROUP BY it.loan_app_id
    ),
      secondrem_payments AS (
        SELECT
          rp.loan_app_id AS laid,
          SUM(rpt.sum) AS payment
        FROM
          repayment_type rpt
          LEFT JOIN
          repayments rp ON rp.id=rpt.repayment_id
          LEFT JOIN
          loan_application la ON la.id=rp.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
          AND rp.payment_date::date <= la.term_date::date
          AND rpt.type='2nd_reminder_fee'
          AND rp.writtenoff = false
        GROUP BY rp.loan_app_id
    ),
      termalertfee_claim AS (
        SELECT
          it.loan_app_id AS laid, SUM(it.term_alert) AS claim
        FROM
          installment_table it
          LEFT JOIN
          loan_application la ON la.id=it.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
        GROUP BY it.loan_app_id
    ),
      termalertfee_payments AS (
        SELECT
          rp.loan_app_id AS laid,
          SUM(rpt.sum) AS payment
        FROM
          repayment_type rpt
          LEFT JOIN
          repayments rp ON rp.id=rpt.repayment_id
          LEFT JOIN
          loan_application la ON la.id=rp.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
          AND rp.payment_date::date <= la.term_date::date
          AND rpt.type='termination_alert_fee'
          AND rp.writtenoff = false
        GROUP BY rp.loan_app_id
    )
    ,
      termfee_claim AS (
        SELECT
          it.loan_app_id AS laid, SUM(it.term) AS claim
        FROM
          installment_table it
          LEFT JOIN
          loan_application la ON la.id=it.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
        GROUP BY it.loan_app_id
    ),
      termfee_payments AS (
        SELECT
          rp.loan_app_id AS laid,
          SUM(rpt.sum) AS payment
        FROM
          repayment_type rpt
          LEFT JOIN
          repayments rp ON rp.id=rpt.repayment_id
          LEFT JOIN
          loan_application la ON la.id=rp.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
          AND rp.payment_date::date <= la.term_date::date
          AND rpt.type='termination_fee'
          AND rp.writtenoff = false
        GROUP BY rp.loan_app_id
    ),
      firstremsms_claim AS (
        SELECT
          it.loan_app_id AS laid, SUM(it.first_rem_sms) AS claim
        FROM
          installment_table it
          LEFT JOIN
          loan_application la ON la.id=it.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
        GROUP BY it.loan_app_id
    ),
      firstremsms_payments AS (
        SELECT
          rp.loan_app_id AS laid,
          SUM(rpt.sum) AS payment
        FROM
          repayment_type rpt
          LEFT JOIN
          repayments rp ON rp.id=rpt.repayment_id
          LEFT JOIN
          loan_application la ON la.id=rp.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
          AND rp.payment_date::date <= la.term_date::date
          AND rpt.type='1st_reminder_sms_fee'
          AND rp.writtenoff = false
        GROUP BY rp.loan_app_id
    ),
      secondremsms_claim AS (
        SELECT
          it.loan_app_id AS laid, SUM(it.second_rem_sms) AS claim
        FROM
          installment_table it
          LEFT JOIN
          loan_application la ON la.id=it.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
        GROUP BY it.loan_app_id
    ),
      secondremsms_payments AS (
        SELECT
          rp.loan_app_id AS laid,
          SUM(rpt.sum) AS payment
        FROM
          repayment_type rpt
          LEFT JOIN
          repayments rp ON rp.id=rpt.repayment_id
          LEFT JOIN
          loan_application la ON la.id=rp.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
          AND rp.payment_date::date <= la.term_date::date
          AND rpt.type='2nd_reminder_sms_fee'
          AND rp.writtenoff = false
        GROUP BY rp.loan_app_id
    ),
      thirdremsms_claim AS (
        SELECT
          it.loan_app_id AS laid, SUM(it.third_rem_sms) AS claim
        FROM
          installment_table it
          LEFT JOIN
          loan_application la ON la.id=it.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
        GROUP BY it.loan_app_id
    ),
      thirdremsms_payments AS (
        SELECT
          rp.loan_app_id AS laid,
          SUM(rpt.sum) AS payment
        FROM
          repayment_type rpt
          LEFT JOIN
          repayments rp ON rp.id=rpt.repayment_id
          LEFT JOIN
          loan_application la ON la.id=rp.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
          AND rp.payment_date::date <= la.term_date::date
          AND rpt.type='3rd_reminder_sms_fee'
          AND rp.writtenoff = false
        GROUP BY rp.loan_app_id
    ),
      fourthremsms_claim AS (
        SELECT
          it.loan_app_id AS laid, SUM(it.fourth_rem_sms) AS claim
        FROM
          installment_table it
          LEFT JOIN
          loan_application la ON la.id=it.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
        GROUP BY it.loan_app_id
    ),
      fourthremsms_payments AS (
        SELECT
          rp.loan_app_id AS laid,
          SUM(rpt.sum) AS payment
        FROM
          repayment_type rpt
          LEFT JOIN
          repayments rp ON rp.id=rpt.repayment_id
          LEFT JOIN
          loan_application la ON la.id=rp.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
          AND rp.payment_date::date <= la.term_date::date
          AND rpt.type='4th_reminder_sms_fee'
          AND rp.writtenoff = false
        GROUP BY rp.loan_app_id
    ),
      fifthremsms_claim AS (
        SELECT
          it.loan_app_id AS laid, SUM(it.fifth_rem_sms) AS claim
        FROM
          installment_table it
          LEFT JOIN
          loan_application la ON la.id=it.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
        GROUP BY it.loan_app_id
    ),
      fifthremsms_payments AS (
        SELECT
          rp.loan_app_id AS laid,
          SUM(rpt.sum) AS payment
        FROM
          repayment_type rpt
          LEFT JOIN
          repayments rp ON rp.id=rpt.repayment_id
          LEFT JOIN
          loan_application la ON la.id=rp.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
          AND rp.payment_date::date <= la.term_date::date
          AND rpt.type='5th_reminder_sms_fee'
          AND rp.writtenoff = false
        GROUP BY rp.loan_app_id
    ),
      suspension_fee_claim AS (
        SELECT
          it.loan_app_id AS laid, SUM(it.suspension_fee) AS claim
        FROM
          installment_table it
          LEFT JOIN
          loan_application la ON la.id=it.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
        GROUP BY it.loan_app_id
    ),
      suspension_fee_payments AS (
        SELECT
          rp.loan_app_id AS laid,
          SUM(rpt.sum) AS payment
        FROM
          repayment_type rpt
          LEFT JOIN
          repayments rp ON rp.id=rpt.repayment_id
          LEFT JOIN
          loan_application la ON la.id=rp.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
          AND rp.payment_date::date <= la.term_date::date
          AND rpt.type='suspension_fee'
          AND rp.writtenoff = false
        GROUP BY rp.loan_app_id
    ),
      delay_claim AS (
        SELECT
          di.loan_app_id AS laid, SUM(di.sum) AS claim
        FROM
          delay_interest di
          LEFT JOIN
          loan_application la ON la.id=di.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND la.term_date >=$1 AND la.term_date <=$2 AND di.calculated_date::date<=la.term_date
        GROUP BY di.loan_app_id
    ),
      delay_payments AS (
        SELECT
          rp.loan_app_id AS laid,
          SUM(rpt.sum) AS payment
        FROM
          repayment_type rpt
          LEFT JOIN
          repayments rp ON rp.id=rpt.repayment_id
          LEFT JOIN
          loan_application la ON la.id=rp.loan_app_id
        WHERE
          la.term_date IS NOT NULL
          AND (la.term_date::date >=$1 OR la.collection_date >=$1)
          AND rp.payment_date::date <= la.term_date::date
          AND rpt.type='delay_interest'
          AND rp.writtenoff = false
        GROUP BY rp.loan_app_id
    )

  SELECT
    la.id AS loanappid_r,
    lp.name::text AS loanproduct_r,
    la.loan_product_id::integer AS loanproductid_r,
    la.ref_nr::text AS refnr_r,
    cp.first_name::text AS firstname_r,
    cp.last_name::text AS lastname_r,
    sc.score::text AS score_r,
    la.loan_office::text AS office_r,
    cc.company_name::text AS incassocompany_r,
    cc.id::integer AS incassocompany_id,
    la.amount::numeric AS loanamount_r,
    la.period::integer AS loanperiod_r,
    la.active_date::date AS activedate_r,
    la.term_date::date AS defaulteddate_r,
    la.internal_collection_date::date AS internaldate_r,
    la.collection_date::date AS collectiondate_r,
    la.written_off_date::date AS writtenoffdate_r,
    (
      (coalesce(principal_c.claim,0.00) - coalesce(principal_p.payment, 0.0)) +
      (coalesce(restructured_c.claim,0.00) - coalesce(restructured_p.payment, 0.0)) +
      (coalesce(commissionfee_c.claim,0.00) - coalesce(commissionfee_p.payment, 0.0)) +
      (coalesce(interest_c.claim,0.00) - coalesce(interest_p.payment, 0.0)) +
      (coalesce(guaranteefee_c.claim,0.00) - coalesce(guaranteefee_p.payment, 0.0)) +
      (coalesce(adminfee_c.claim,0.00) - coalesce(adminfee_p.payment, 0.0)) +
      (coalesce(firstrem_c.claim,0.00) - coalesce(firstrem_p.payment, 0.0)) +
      (coalesce(secondrem_c.claim,0.00) - coalesce(secondrem_p.payment, 0.0)) +
      (coalesce(termalertfee_c.claim,0.00) - coalesce(termalertfee_p.payment, 0.0)) +
      (coalesce(termfee_c.claim,0.00) - coalesce(termfee_p.payment, 0.0)) +
      (coalesce(firstremsms_c.claim,0.00) - coalesce(firstremsms_p.payment, 0.0)) +
      (coalesce(secondremsms_c.claim,0.00) - coalesce(secondremsms_p.payment, 0.0)) +
      (coalesce(thirdremsms_c.claim,0.00) - coalesce(thirdremsms_p.payment, 0.0)) +
      (coalesce(fourthremsms_c.claim,0.00) - coalesce(fourthremsms_p.payment, 0.0)) +
      (coalesce(fifthremsms_c.claim,0.00) - coalesce(fifthremsms_p.payment, 0.0)) +
      (coalesce(suspension_fee_c.claim,0.00) - coalesce(suspension_fee_p.payment, 0.0)) +
      (coalesce(delay_c.claim,0.00) - coalesce(delay_p.payment, 0.0))
    )::numeric AS totaldebt_r,
    (coalesce(principal_c.claim,0.00) - coalesce(principal_p.payment, 0.0)) ::numeric AS principal_r,
    (coalesce(restructured_c.claim,0.00) - coalesce(restructured_p.payment, 0.0)) ::numeric AS restructured_r,
    (coalesce(commissionfee_c.claim,0.00) - coalesce(commissionfee_p.payment, 0.0)) ::numeric AS commissionfee_r,
    (coalesce(interest_c.claim,0.00) - coalesce(interest_p.payment, 0.0))::numeric AS interest_r,
    (coalesce(guaranteefee_c.claim,0.00) - coalesce(guaranteefee_p.payment, 0.0))::numeric AS guaranteefee_r,
    (coalesce(adminfee_c.claim,0.00) - coalesce(adminfee_p.payment, 0.0))::numeric AS adminfee_r,
    (coalesce(firstrem_c.claim,0.00) - coalesce(firstrem_p.payment, 0.0))::numeric AS firstrem_r,
    (coalesce(secondrem_c.claim,0.00) - coalesce(secondrem_p.payment, 0.0))::numeric AS secondrem_r,
    (coalesce(termalertfee_c.claim,0.00) - coalesce(termalertfee_p.payment, 0.0))::numeric AS termalertfee_r,
    (coalesce(termfee_c.claim,0.00) - coalesce(termfee_p.payment, 0.0))::numeric AS termfee_r,
    (coalesce(firstremsms_c.claim,0.00) - coalesce(firstremsms_p.payment, 0.0))::numeric AS firstremsms_r,
    (coalesce(secondremsms_c.claim,0.00) - coalesce(secondremsms_p.payment, 0.0))::numeric AS secondremsms_r,
    (coalesce(thirdremsms_c.claim,0.00) - coalesce(thirdremsms_p.payment, 0.0))::numeric AS thirdremsms_r,
    (coalesce(fourthremsms_c.claim,0.00) - coalesce(fourthremsms_p.payment, 0.0))::numeric AS fourthremsms_r,
    (coalesce(fifthremsms_c.claim,0.00) - coalesce(fifthremsms_p.payment, 0.0))::numeric AS fifthremsms_r,

    (coalesce(suspension_fee_c.claim,0.00) - coalesce(suspension_fee_p.payment, 0.0))::numeric AS suspension_fee_r,
    (coalesce(delay_c.claim,0.00) - coalesce(delay_p.payment, 0.0))::numeric AS delayinterest_r,
    coalesce (pl.payments, 0.00)::numeric AS repaymentslater_r,
    la.agreement_signment::text AS agreementsignment_r,
    la.pay_out_to::text AS payoutto_r
  FROM
    loan_application la
    LEFT JOIN
    client_profile cp ON la.client_id=cp.id
    LEFT JOIN
    loan_products lp ON la.loan_product_id=lp.id
    LEFT JOIN
    scorecard sc ON la.id=sc.loan_app_id
    LEFT JOIN
    payments_later pl ON la.id=pl.laid
    LEFT JOIN
    principal_claim principal_c ON principal_c.laid=la.id
    LEFT JOIN
    principal_payments principal_p ON principal_p.laid=la.id
    LEFT JOIN
    restructured_claim restructured_c ON restructured_c.laid=la.id
    LEFT JOIN
    restructured_payments restructured_p ON restructured_p.laid=la.id
    LEFT JOIN
    interest_claim interest_c ON interest_c.laid=la.id
    LEFT JOIN
    interest_payments interest_p ON interest_p.laid=la.id
    LEFT JOIN
    commissionfee_claim commissionfee_c ON commissionfee_c.laid=la.id
    LEFT JOIN
    commissionfee_payments commissionfee_p ON commissionfee_p.laid=la.id
    LEFT JOIN
    guaranteefee_claim guaranteefee_c ON guaranteefee_c.laid=la.id
    LEFT JOIN
    guaranteefee_payments guaranteefee_p ON guaranteefee_p.laid=la.id
    LEFT JOIN
    adminfee_claim adminfee_c ON adminfee_c.laid=la.id
    LEFT JOIN
    adminfee_payments adminfee_p ON adminfee_p.laid=la.id
    LEFT JOIN
    firstrem_claim firstrem_c ON firstrem_c.laid=la.id
    LEFT JOIN
    firstrem_payments firstrem_p ON firstrem_p.laid=la.id
    LEFT JOIN
    secondrem_claim secondrem_c ON secondrem_c.laid=la.id
    LEFT JOIN
    secondrem_payments secondrem_p ON secondrem_p.laid=la.id
    LEFT JOIN
    termalertfee_claim termalertfee_c ON termalertfee_c.laid=la.id
    LEFT JOIN
    termalertfee_payments termalertfee_p ON termalertfee_p.laid=la.id
    LEFT JOIN
    termfee_claim termfee_c ON termfee_c.laid=la.id
    LEFT JOIN
    termfee_payments termfee_p ON termfee_p.laid=la.id
    LEFT JOIN
    firstremsms_claim firstremsms_c ON firstremsms_c.laid=la.id
    LEFT JOIN
    firstremsms_payments firstremsms_p ON firstremsms_p.laid=la.id
    LEFT JOIN
    secondremsms_claim secondremsms_c ON secondremsms_c.laid=la.id
    LEFT JOIN
    secondremsms_payments secondremsms_p ON secondremsms_p.laid=la.id
    LEFT JOIN
    thirdremsms_claim thirdremsms_c ON thirdremsms_c.laid=la.id
    LEFT JOIN
    thirdremsms_payments thirdremsms_p ON thirdremsms_p.laid=la.id
    LEFT JOIN
    fourthremsms_claim fourthremsms_c ON fourthremsms_c.laid=la.id
    LEFT JOIN
    fourthremsms_payments fourthremsms_p ON fourthremsms_p.laid=la.id
    LEFT JOIN
    fifthremsms_claim fifthremsms_c ON fifthremsms_c.laid=la.id
    LEFT JOIN
    fifthremsms_payments fifthremsms_p ON fifthremsms_p.laid=la.id
    LEFT JOIN
    delay_claim delay_c ON delay_c.laid=la.id
    LEFT JOIN
    delay_payments delay_p ON delay_p.laid=la.id
    LEFT JOIN
    suspension_fee_claim suspension_fee_c ON suspension_fee_c.laid=la.id
    LEFT JOIN
    suspension_fee_payments suspension_fee_p ON suspension_fee_p.laid=la.id
    LEFT JOIN
    collection_scheme cs ON la.collection_scheme_id=cs.id
    LEFT JOIN
    collection_company cc ON cs.collection_company_id=cc.id

  WHERE la.active=true AND la.term_date IS NOT NULL
        AND (la.term_date::date >=$1 OR la.collection_date >=$1 or (la.internal_collection_date is not null and la.internal_collection_date >=$1) or (la.written_off_date is not null and la.written_off_date >=$1))

  ;

END;
$$;

