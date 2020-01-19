DROP FUNCTION IF EXISTS get_income_report(date, date);
create function get_income_report(date, date) returns TABLE(loan_app_id integer, repayment_id integer, principal numeric, restructure numeric, interest numeric, commission_fee numeric, guarantee_fee numeric, admin_fee numeric, first_reminder_fee numeric, second_reminder_fee numeric, termination_fee numeric, termination_alert_fee numeric, first_reminder_sms_fee numeric, second_reminder_sms_fee numeric, third_reminder_sms_fee numeric, fourth_reminder_sms_fee numeric, fifth_reminder_sms_fee numeric, delay_interest numeric, suspension_fee numeric, overpayment numeric, extraordinary_revenue numeric, total numeric, payment_date date, bank character varying, ref_nr integer, firstname character varying, lastname character varying, total_sales numeric)
AS $$
BEGIN
  RETURN QUERY
  WITH local_claims_payments AS (
      SELECT
        sum(vcp_local.paid_sum) AS c_sum,
        vcp_local.repayment_id AS c_repayment_id,
        vcp_local.type AS c_type
      FROM
            get_payments($1, $2) vcp_local
      WHERE
        vcp_local.paid_sum <> 0 AND vcp_local.income_date::date<=$2 GROUP BY vcp_local.type, vcp_local.repayment_id
  ),
      principal_claims_payments AS (
        SELECT round(vcp.c_sum::numeric,2) AS c_sum, vcp.c_repayment_id AS c_repayment_id, vcp.c_type AS c_type FROM local_claims_payments vcp WHERE vcp.c_type='principal'
    ),
      restructure_claims_payments AS (
        SELECT round(vcp.c_sum::numeric,2) AS c_sum, vcp.c_repayment_id AS c_repayment_id, vcp.c_type AS c_type FROM local_claims_payments vcp WHERE vcp.c_type='restructured'
    ),
      interest_claims_payments AS(
        SELECT round(vcp.c_sum::numeric,2) AS c_sum, vcp.c_repayment_id AS c_repayment_id, vcp.c_type AS c_type FROM local_claims_payments vcp WHERE vcp.c_type='interest'
    ),
      commission_claims_payments AS (
        SELECT round(vcp.c_sum::numeric,2) AS c_sum, vcp.c_repayment_id AS c_repayment_id, vcp.c_type AS c_type FROM local_claims_payments vcp WHERE vcp.c_type='commission_fee'
    ),
      guarantee_claims_payments AS (
        SELECT round(vcp.c_sum::numeric,2) AS c_sum, vcp.c_repayment_id AS c_repayment_id, vcp.c_type AS c_type FROM local_claims_payments vcp WHERE vcp.c_type='guarantee_fee'
    ),
      adminfee_claims_payments AS (
        SELECT round(vcp.c_sum::numeric,2) AS c_sum, vcp.c_repayment_id AS c_repayment_id, vcp.c_type AS c_type FROM local_claims_payments vcp WHERE vcp.c_type='admin_fee'
    ),
      frm_claims_payments AS (
        SELECT round(vcp.c_sum::numeric,2) AS c_sum, vcp.c_repayment_id AS c_repayment_id, vcp.c_type AS c_type FROM local_claims_payments vcp WHERE vcp.c_type='1st_reminder_fee'
    ),
      srm_claims_payments AS (
        SELECT round(vcp.c_sum::numeric,2) AS c_sum, vcp.c_repayment_id AS c_repayment_id, vcp.c_type AS c_type FROM local_claims_payments vcp WHERE vcp.c_type='2nd_reminder_fee'
    ),
      termination_claims_payments AS (
        SELECT round(vcp.c_sum::numeric,2) AS c_sum, vcp.c_repayment_id AS c_repayment_id, vcp.c_type AS c_type FROM local_claims_payments vcp WHERE vcp.c_type='termination_fee'
    ),
      alertfee_claims_payments AS (
        SELECT round(vcp.c_sum::numeric,2) AS c_sum, vcp.c_repayment_id AS c_repayment_id, vcp.c_type AS c_type FROM local_claims_payments vcp WHERE vcp.c_type='termination_alert_fee'
    ),
      frms_claims_payments AS (
        SELECT round(vcp.c_sum::numeric,2) AS c_sum, vcp.c_repayment_id AS c_repayment_id, vcp.c_type AS c_type FROM local_claims_payments vcp WHERE vcp.c_type='1st_reminder_sms_fee'
    ),
      srms_claims_payments AS (
        SELECT round(vcp.c_sum::numeric,2) AS c_sum, vcp.c_repayment_id AS c_repayment_id, vcp.c_type AS c_type FROM local_claims_payments vcp WHERE vcp.c_type='2nd_reminder_sms_fee'
    ),
      trms_claims_payments AS (
        SELECT round(vcp.c_sum::numeric,2) AS c_sum, vcp.c_repayment_id AS c_repayment_id, vcp.c_type AS c_type FROM local_claims_payments vcp WHERE vcp.c_type='3rd_reminder_sms_fee'
    ),
      forms_claims_payments AS (
        SELECT round(vcp.c_sum::numeric,2) AS c_sum, vcp.c_repayment_id AS c_repayment_id, vcp.c_type AS c_type FROM local_claims_payments vcp WHERE vcp.c_type='4th_reminder_sms_fee'
    ),
      firms_claims_payments AS (
        SELECT round(vcp.c_sum::numeric,2) AS c_sum, vcp.c_repayment_id AS c_repayment_id, vcp.c_type AS c_type FROM local_claims_payments vcp WHERE vcp.c_type='5th_reminder_sms_fee'
    ),
      overpayment_claims_payments AS (
        SELECT round(vcp.c_sum::numeric,2) AS c_sum, vcp.c_repayment_id AS c_repayment_id, vcp.c_type AS c_type FROM local_claims_payments vcp WHERE vcp.c_type='overpayment' OR vcp.c_type='defaulted_overpayment'
    ),
      delay_claims_payments AS (
        SELECT round(sum(rpt.sum)::numeric,2) AS c_sum, rpt.repayment_id AS c_repayment_id FROM repayment_type AS rpt INNER JOIN repayments rp ON rpt.repayment_id=rp.id WHERE rpt.type='delay_interest' AND rp.payment_date::date >= $1 AND rp.payment_date::date <=$2 GROUP BY rpt.repayment_id
    ),
      suspension_fee_claims_payments AS (
        SELECT round(vcp.c_sum::numeric,2) AS c_sum, vcp.c_repayment_id AS c_repayment_id, vcp.c_type AS c_type FROM local_claims_payments vcp WHERE vcp.c_type='suspension_fee'
    ),
      repaym AS (
        SELECT rp.id AS id, round(rp.sum::numeric,2) AS c_total, rp.payment_date AS c_payment_date, rp.loan_app_id AS c_loan_app_id, rp.bank AS c_bank FROM repayments rp WHERE rp.payment_date::date>=$1 AND rp.payment_date::date<=$2
    ),
      extraordinary_revenue_payments AS (
        SELECT round(vcp.c_sum::numeric,2) AS c_sum, vcp.c_repayment_id AS c_repayment_id, vcp.c_type AS c_type FROM local_claims_payments vcp WHERE vcp.c_type='extraordinary_revenue'
    )


  SELECT
    rpt.c_loan_app_id AS r_loan_app_id,
    rpt.id AS r_repayment_id,
    coalesce(c_principal.c_sum, 0.00)::numeric AS r_principal,
    coalesce(c_restructure.c_sum, 0.00)::numeric AS r_restructure,
    coalesce(c_interest.c_sum,0.00)::numeric AS r_interest,
    coalesce(c_commission_fee.c_sum,0.00)::numeric AS r_commission_fee,
    coalesce(c_guarantee_fee.c_sum,0.00)::numeric AS r_guarantee_fee,
    coalesce(c_admin_fee.c_sum,0.00)::numeric AS r_admin_fee,
    coalesce(c_1st_reminder_fee.c_sum,0.00)::numeric AS r_1st_reminder_fee,
    coalesce(c_2nd_reminder_fee.c_sum,0.00)::numeric AS r_2nd_reminder_fee,
    coalesce(c_termination_fee.c_sum,0.00)::numeric AS r_termination_fee,
    coalesce(c_termination_alert_fee.c_sum,0.00)::numeric AS r_termination_alert_fee,
    coalesce(c_1st_reminder_sms_fee.c_sum,0.00)::numeric AS r_1st_reminder_sms_fee,
    coalesce(c_2nd_reminder_sms_fee.c_sum,0.00)::numeric AS r_2nd_reminder_sms_fee,
    coalesce(c_3rd_reminder_sms_fee.c_sum,0.00)::numeric AS r_3rd_reminder_sms_fee,
    coalesce(c_4th_reminder_sms_fee.c_sum,0.00)::numeric AS r_4th_reminder_sms_fee,
    coalesce(c_5th_reminder_sms_fee.c_sum,0.00)::numeric AS r_5th_reminder_sms_fee,
    coalesce(c_delay_interest.c_sum,0.00)::numeric AS r_delay_interest,
    coalesce(c_suspension_fee.c_sum,0.00)::numeric AS r_suspension_fee,
    coalesce(c_overpayment.c_sum,0.00)::numeric AS r_overpayment,
    coalesce(c_extraordinary_revenue.c_sum,0.00)::numeric AS r_extraordinary_revenue,
    coalesce(rpt.c_total,0.00)::numeric AS r_total,
    rpt.c_payment_date::date AS r_payment_date,
    rpt.c_bank AS r_bank,
    la.ref_nr AS r_ref_nr,
    cp.first_name AS r_firstname,
    cp.last_name AS r_lastname,

    (coalesce(c_restructure.c_sum,0.00)::numeric +
     coalesce(c_interest.c_sum,0.00)::numeric +
     coalesce(c_commission_fee.c_sum,0.00)::numeric +
     coalesce(c_guarantee_fee.c_sum,0.00)::numeric +
     coalesce(c_admin_fee.c_sum,0.00)::numeric +
     coalesce(c_1st_reminder_fee.c_sum,0.00)::numeric +
     coalesce(c_2nd_reminder_fee.c_sum,0.00)::numeric +
     coalesce(c_termination_fee.c_sum,0.00)::numeric +
     coalesce(c_termination_alert_fee.c_sum,0.00)::numeric +
     coalesce(c_1st_reminder_sms_fee.c_sum,0.00)::numeric +
     coalesce(c_2nd_reminder_sms_fee.c_sum,0.00)::numeric +
     coalesce(c_3rd_reminder_sms_fee.c_sum,0.00)::numeric +
     coalesce(c_4th_reminder_sms_fee.c_sum,0.00)::numeric +
     coalesce(c_5th_reminder_sms_fee.c_sum,0.00)::numeric +
     coalesce(c_delay_interest.c_sum,0.00)::numeric +
     coalesce(c_suspension_fee.c_sum,0.00)::numeric) AS r_income_sales

  FROM
    repaym rpt
    LEFT JOIN principal_claims_payments c_principal ON rpt.id=c_principal.c_repayment_id
    LEFT JOIN restructure_claims_payments c_restructure ON rpt.id=c_restructure.c_repayment_id
    LEFT JOIN interest_claims_payments c_interest ON rpt.id=c_interest.c_repayment_id
    LEFT JOIN commission_claims_payments c_commission_fee ON rpt.id=c_commission_fee.c_repayment_id
    LEFT JOIN guarantee_claims_payments c_guarantee_fee ON rpt.id=c_guarantee_fee.c_repayment_id
    LEFT JOIN adminfee_claims_payments c_admin_fee ON rpt.id=c_admin_fee.c_repayment_id
    LEFT JOIN frm_claims_payments c_1st_reminder_fee ON rpt.id=c_1st_reminder_fee.c_repayment_id
    LEFT JOIN srm_claims_payments c_2nd_reminder_fee ON rpt.id=c_2nd_reminder_fee.c_repayment_id
    LEFT JOIN termination_claims_payments c_termination_fee ON rpt.id=c_termination_fee.c_repayment_id
    LEFT JOIN frms_claims_payments c_1st_reminder_sms_fee ON rpt.id=c_1st_reminder_sms_fee.c_repayment_id
    LEFT JOIN srms_claims_payments c_2nd_reminder_sms_fee ON rpt.id=c_2nd_reminder_sms_fee.c_repayment_id
    LEFT JOIN trms_claims_payments c_3rd_reminder_sms_fee ON rpt.id=c_3rd_reminder_sms_fee.c_repayment_id
    LEFT JOIN forms_claims_payments c_4th_reminder_sms_fee ON rpt.id=c_4th_reminder_sms_fee.c_repayment_id
    LEFT JOIN firms_claims_payments c_5th_reminder_sms_fee ON rpt.id=c_5th_reminder_sms_fee.c_repayment_id
    LEFT JOIN alertfee_claims_payments c_termination_alert_fee ON rpt.id=c_termination_alert_fee.c_repayment_id
    LEFT JOIN delay_claims_payments c_delay_interest ON rpt.id=c_delay_interest.c_repayment_id
    LEFT JOIN suspension_fee_claims_payments c_suspension_fee ON rpt.id=c_suspension_fee.c_repayment_id
    LEFT JOIN overpayment_claims_payments c_overpayment ON rpt.id=c_overpayment.c_repayment_id
    LEFT JOIN extraordinary_revenue_payments c_extraordinary_revenue ON rpt.id=c_extraordinary_revenue.c_repayment_id
    LEFT JOIN loan_application la ON la.id = rpt.c_loan_app_id
    LEFT JOIN client_profile cp ON cp.id = la.client_id
  ;
END;
$$
LANGUAGE plpgsql VOLATILE;
