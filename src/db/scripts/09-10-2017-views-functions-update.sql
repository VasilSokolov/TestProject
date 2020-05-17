
DROP VIEW IF EXISTS v_installment_flat CASCADE;
CREATE OR REPLACE VIEW v_installment_flat AS

	SELECT
        	round(mt.first_rem::numeric,2) AS amount,
	        mt.first_rem_date::date AS duedate,
	        '1st_reminder_fee'::text AS type,
	        mt.loan_app_id,
	        mt.id AS installment_table_id,
	        mt.first_rem_date::date AS avail_date
		FROM installment_table mt
		WHERE mt.first_rem > 0::numeric

		UNION ALL
		SELECT
		 	round(mt.second_rem::numeric,2) AS amount,
		    mt.second_rem_date::date AS duedate,
		    '2nd_reminder_fee'::text AS type,
	        mt.loan_app_id,
	        mt.id AS installment_table_id,
	        mt.second_rem_date::date AS avail_date
		FROM installment_table mt
		WHERE mt.second_rem > 0::numeric

		UNION ALL
		SELECT
			round(mt.interest::numeric,2) AS amount,
            mt.expected_date::date AS duedate,
            'interest'::text AS type,
            mt.loan_app_id,
            mt.id AS installment_table_id,
            la.active_date::date AS avail_date
		FROM installment_table mt
		LEFT JOIN loan_application la ON mt.loan_app_id = la.id
		WHERE mt.interest > 0::numeric AND la.active=true

		UNION ALL
		SELECT
			round(mt.admission_fee::numeric,2) AS amount,
            mt.expected_date::date AS duedate,
            'commission_fee'::text AS type,
            mt.loan_app_id,
            mt.id AS installment_table_id,
            la.active_date::date AS avail_date
		FROM installment_table mt
		LEFT JOIN loan_application la ON mt.loan_app_id = la.id
		WHERE mt.admission_fee > 0::numeric AND la.active=true

		UNION ALL
		SELECT
			round(mt.guarantee_fee::numeric,2) AS amount,
            mt.expected_date::date AS duedate,
            'guarantee_fee'::text AS type,
            mt.loan_app_id,
            mt.id AS installment_table_id,
            la.active_date::date AS avail_date
		FROM installment_table mt
		LEFT JOIN loan_application la ON mt.loan_app_id = la.id
		WHERE mt.guarantee_fee > 0::numeric AND la.active=true

		UNION ALL
		SELECT
			round(mt.admin_fee::numeric,2) AS amount,
            mt.expected_date::date AS duedate,
            'admin_fee'::text AS type,
            mt.loan_app_id,
            mt.id AS installment_table_id,
            la.active_date::date AS avail_date
		FROM installment_table mt
		LEFT JOIN loan_application la ON mt.loan_app_id = la.id
		WHERE mt.admin_fee > 0::numeric AND la.active=true

		UNION ALL
		SELECT
			round(mt.principal::numeric,2) AS amount,
            mt.expected_date::date AS duedate,
            'principal'::text AS type, mt.loan_app_id,
            mt.id AS installment_table_id,
            la.active_date::date AS avail_date
		FROM installment_table mt
		LEFT JOIN loan_application la ON mt.loan_app_id = la.id
		WHERE mt.principal > 0::numeric AND la.active=true

		UNION ALL
		SELECT
			round(mt.term::numeric,2) AS amount,
            mt.term_date::date AS duedate,
            'termination_fee'::text AS type, mt.loan_app_id,
            mt.id AS installment_table_id,
            mt.term_date::date AS avail_date
		FROM installment_table mt
     	WHERE mt.term > 0::numeric

     	UNION ALL
		SELECT
			round(mt.term_alert::numeric,2) AS amount,
            mt.term_alert_date::date AS duedate,
            'termination_alert_fee'::text AS type, mt.loan_app_id,
            mt.id AS installment_table_id,
            mt.term_alert_date::date AS avail_date
		FROM installment_table mt
     	WHERE mt.term_alert > 0::numeric

		UNION ALL
		SELECT
		 	round(mt.first_rem_sms::numeric,2) AS amount,
		    mt.first_rem_sms_date::date AS duedate,
		    '1st_reminder_sms_fee'::text AS type,
	        mt.loan_app_id,
	        mt.id AS installment_table_id,
	        mt.first_rem_sms_date::date AS avail_date
		FROM installment_table mt
		WHERE mt.first_rem_sms > 0::numeric

		UNION ALL
		SELECT
		 	round(mt.second_rem_sms::numeric,2) AS amount,
		    mt.second_rem_sms_date::date AS duedate,
		    '2nd_reminder_sms_fee'::text AS type,
	        mt.loan_app_id,
	        mt.id AS installment_table_id,
	        mt.second_rem_sms_date::date AS avail_date
		FROM installment_table mt
		WHERE mt.second_rem_sms > 0::numeric

		UNION ALL
		SELECT
		 	round(mt.third_rem_sms::numeric,2) AS amount,
		    mt.third_rem_sms_date::date AS duedate,
		    '3rd_reminder_sms_fee'::text AS type,
	        mt.loan_app_id,
	        mt.id AS installment_table_id,
	        mt.third_rem_sms_date::date AS avail_date
		FROM installment_table mt
		WHERE mt.third_rem_sms > 0::numeric

		UNION ALL
		SELECT
		 	round(mt.fourth_rem_sms::numeric,2) AS amount,
		    mt.fourth_rem_sms_date::date AS duedate,
		    '4th_reminder_sms_fee'::text AS type,
	        mt.loan_app_id,
	        mt.id AS installment_table_id,
	        mt.fourth_rem_sms_date::date AS avail_date
		FROM installment_table mt
		WHERE mt.fourth_rem_sms > 0::numeric

		UNION ALL
		SELECT
		 	round(mt.fifth_rem_sms::numeric,2) AS amount,
		    mt.fifth_rem_sms_date::date AS duedate,
		    '5th_reminder_sms_fee'::text AS type,
	        mt.loan_app_id,
	        mt.id AS installment_table_id,
	        mt.fifth_rem_sms_date::date AS avail_date
		FROM installment_table mt
		WHERE mt.fifth_rem_sms > 0::numeric

     	UNION ALL
		SELECT
			round(mt.suspension_fee::numeric,2) AS amount,
            mt.suspended_date::date AS duedate,
            'suspension_fee'::text AS type, mt.loan_app_id,
            mt.id AS installment_table_id,
            mt.suspended_date::date AS avail_date
		FROM installment_table mt
     	WHERE mt.suspended_date IS NOT NULL

;

DROP VIEW IF EXISTS v_installment_flat_paidout CASCADE;
CREATE OR REPLACE VIEW v_installment_flat_paidout AS
 SELECT round(mt.amount, 2) AS amount,
    mt.duedate,
    mt.type,
    mt.loan_app_id,
    mt.installment_table_id,
    COALESCE(mt.avail_date, la.active_date::date) AS avail_date,
    la.status AS la_status,
    la.loan_product_id,
    la.active,
    la.closed AS la_closed,
    la.closed_date::date AS la_closed_date,
    la.active_date::date AS active_date,
    la.created::date AS loan_app_created
   FROM v_installment_flat mt
     JOIN loan_application la ON mt.loan_app_id = la.id
  WHERE la.active = true;

DROP VIEW IF EXISTS v_claims_la2_phys CASCADE;
CREATE OR REPLACE VIEW v_claims_la2_phys AS

		SELECT
        	mt.first_rem AS amount,
	        mt.first_rem_date::date AS duedate,
	        '1st_reminder_fee'::text AS type,
	        mt.loan_app_id,
	        mt.id AS installment_table_id,
	        mt.first_rem_date::date AS avail_date,
	        la.status AS la_status,
	        la.loan_product_id,
	        la.active,
	        la.closed AS la_closed,
	        la.closed_date::date AS la_closed_date,
	        la.active_date::date AS active_date, la.created::date AS loan_app_created
		FROM installment_table mt
		INNER JOIN loan_application la ON mt.loan_app_id = la.id
		WHERE mt.first_rem > 0::numeric AND la.active=TRUE

		UNION ALL
		SELECT
		 	mt.second_rem AS amount,
		    mt.second_rem_date::date AS duedate,
		    '2nd_reminder_fee'::text AS type,
	        mt.loan_app_id,
	        mt.id AS installment_table_id,
	        mt.second_rem_date::date AS avail_date,
	        la.status AS la_status,
	        la.loan_product_id,
	        la.active,
	        la.closed AS la_closed,
	        la.closed_date::date AS la_closed_date,
	        la.active_date::date AS active_date, la.created::date AS loan_app_created
		FROM installment_table mt
		INNER JOIN loan_application la ON mt.loan_app_id = la.id
		WHERE mt.second_rem > 0::numeric AND la.active=TRUE

		UNION ALL
		SELECT
			mt.interest AS amount,
            mt.expected_date::date AS duedate,
            'interest'::text AS type,
            mt.loan_app_id,
            mt.id AS installment_table_id,
            la.active_date::date AS avail_date,
            la.status AS la_status,
            la.loan_product_id,
            la.active,
            la.closed AS la_closed,
            la.closed_date::date AS la_closed_date,
            la.active_date::date AS active_date, la.created::date AS loan_app_created
		FROM installment_table mt
		INNER JOIN loan_application la ON mt.loan_app_id = la.id
		WHERE mt.interest > 0::numeric AND la.active=TRUE

		UNION ALL
		SELECT
			mt.admission_fee AS amount,
            mt.expected_date::date AS duedate,
            'commission_fee'::text AS type,
            mt.loan_app_id,
            mt.id AS installment_table_id,
            la.active_date::date AS avail_date,
            la.status AS la_status,
            la.loan_product_id, la.active,
            la.closed AS la_closed,
            la.closed_date::date AS la_closed_date,
            la.active_date::date AS active_date, la.created::date AS loan_app_created
		FROM installment_table mt
		INNER JOIN loan_application la ON mt.loan_app_id = la.id
		WHERE mt.admission_fee > 0::numeric AND la.active=TRUE

		UNION ALL
		SELECT
			mt.principal AS amount,
            mt.expected_date::date AS duedate,
            'principal'::text AS type, mt.loan_app_id,
            mt.id AS installment_table_id,
            la.active_date::date AS avail_date,
            la.status AS la_status, la.loan_product_id,
            la.active, la.closed AS la_closed,
            la.closed_date::date AS la_closed_date,
            la.active_date::date AS active_date, la.created::date AS loan_app_created
		FROM installment_table mt
		INNER JOIN loan_application la ON mt.loan_app_id = la.id
		WHERE mt.principal > 0::numeric AND la.active=TRUE

		UNION ALL
		SELECT
			mt.term AS amount,
            mt.term_date::date AS duedate,
            'termination_fee'::text AS type, mt.loan_app_id,
            mt.id AS installment_table_id,
            mt.term_date::date AS avail_date,
            la.status AS la_status, la.loan_product_id,
            la.active, la.closed AS la_closed,
            la.closed_date::date AS la_closed_date, la.active_date::date AS active_date, la.created::date AS loan_app_created
		FROM installment_table mt
		INNER JOIN loan_application la ON mt.loan_app_id = la.id
     	WHERE mt.term > 0::numeric AND la.active=TRUE

     	UNION ALL
		SELECT
			mt.term_alert AS amount,
            mt.term_alert_date::date AS duedate,
            'termination_alert_fee'::text AS type, mt.loan_app_id,
            mt.id AS installment_table_id,
            mt.term_alert_date::date AS avail_date,
            la.status AS la_status, la.loan_product_id, la.active,
            la.closed AS la_closed, la.closed_date::date AS la_closed_date,
            la.active_date::date AS active_date, la.created::date AS loan_app_created
		FROM installment_table mt
      	INNER JOIN loan_application la ON mt.loan_app_id = la.id
     	WHERE mt.term_alert > 0::numeric AND la.active=TRUE

     			UNION ALL
		SELECT
		 	mt.first_rem_sms AS amount,
		    mt.first_rem_sms_date::date AS duedate,
		    '1st_reminder_sms_fee'::text AS type,
	        mt.loan_app_id,
	        mt.id AS installment_table_id,
	        mt.first_rem_sms_date::date AS avail_date,
	        la.status AS la_status,
	        la.loan_product_id,
	        la.active,
	        la.closed AS la_closed,
	        la.closed_date::date AS la_closed_date,
	        la.active_date::date AS active_date, la.created::date AS loan_app_created
		FROM installment_table mt
		INNER JOIN loan_application la ON mt.loan_app_id = la.id
		WHERE mt.first_rem_sms > 0::numeric AND la.active=TRUE

     			UNION ALL
		SELECT
		 	mt.second_rem_sms AS amount,
		    mt.second_rem_sms_date::date AS duedate,
		    '2nd_reminder_sms_fee'::text AS type,
	        mt.loan_app_id,
	        mt.id AS installment_table_id,
	        mt.second_rem_sms_date::date AS avail_date,
	        la.status AS la_status,
	        la.loan_product_id,
	        la.active,
	        la.closed AS la_closed,
	        la.closed_date::date AS la_closed_date,
	        la.active_date::date AS active_date, la.created::date AS loan_app_created
		FROM installment_table mt
		INNER JOIN loan_application la ON mt.loan_app_id = la.id
		WHERE mt.second_rem_sms > 0::numeric AND la.active=TRUE

     			UNION ALL
		SELECT
		 	mt.third_rem_sms AS amount,
		    mt.third_rem_sms_date::date AS duedate,
		    '3rd_reminder_sms_fee'::text AS type,
	        mt.loan_app_id,
	        mt.id AS installment_table_id,
	        mt.third_rem_sms_date::date AS avail_date,
	        la.status AS la_status,
	        la.loan_product_id,
	        la.active,
	        la.closed AS la_closed,
	        la.closed_date::date AS la_closed_date,
	        la.active_date::date AS active_date, la.created::date AS loan_app_created
		FROM installment_table mt
		INNER JOIN loan_application la ON mt.loan_app_id = la.id
		WHERE mt.third_rem_sms > 0::numeric AND la.active=TRUE

     			UNION ALL
		SELECT
		 	mt.fourth_rem_sms AS amount,
		    mt.fourth_rem_sms_date::date AS duedate,
		    '4th_reminder_sms_fee'::text AS type,
	        mt.loan_app_id,
	        mt.id AS installment_table_id,
	        mt.fourth_rem_sms_date::date AS avail_date,
	        la.status AS la_status,
	        la.loan_product_id,
	        la.active,
	        la.closed AS la_closed,
	        la.closed_date::date AS la_closed_date,
	        la.active_date::date AS active_date, la.created::date AS loan_app_created
		FROM installment_table mt
		INNER JOIN loan_application la ON mt.loan_app_id = la.id
		WHERE mt.fourth_rem_sms > 0::numeric AND la.active=TRUE

     			UNION ALL
		SELECT
		 	mt.fifth_rem_sms AS amount,
		    mt.fifth_rem_sms_date::date AS duedate,
		    '5th_reminder_sms_fee'::text AS type,
	        mt.loan_app_id,
	        mt.id AS installment_table_id,
	        mt.fifth_rem_sms_date::date AS avail_date,
	        la.status AS la_status,
	        la.loan_product_id,
	        la.active,
	        la.closed AS la_closed,
	        la.closed_date::date AS la_closed_date,
	        la.active_date::date AS active_date, la.created::date AS loan_app_created
		FROM installment_table mt
		INNER JOIN loan_application la ON mt.loan_app_id = la.id
		WHERE mt.fifth_rem_sms > 0::numeric AND la.active=TRUE

     	UNION ALL
		SELECT
			mt.suspension_fee AS amount,
            mt.suspended_date::date AS duedate,
            'suspension_fee'::text AS type, mt.loan_app_id,
            mt.id AS installment_table_id,
            mt.suspended_date::date AS avail_date,
            la.status AS la_status, la.loan_product_id, la.active,
            la.closed AS la_closed, la.closed_date::date AS la_closed_date,
            la.active_date::date AS active_date, la.created::date AS loan_app_created
		FROM installment_table mt
      	INNER JOIN loan_application la ON mt.loan_app_id = la.id
     	WHERE mt.suspended_date IS NOT NULL AND la.active=TRUE
;

DROP FUNCTION IF EXISTS  get_provision_report(date);

CREATE OR REPLACE FUNCTION get_provision_report(IN date)
  RETURNS TABLE(loan_app_id integer, ref_nr integer, first_name text, last_name text, pin text, loan_status text, status_date date, maxdelay integer, total_claim double precision, principal_claim double precision, interest_claim double precision, commission_claim double precision, guarantee_claim double precision, adminfee_claim double precision, first_reminder_fee_claim double precision, second_reminder_fee_claim double precision, termination_fee_claim double precision, termination_alert_fee_claim double precision, delay_interest_claim double precision, suspension_fee_claim double precision) AS
$BODY$

	BEGIN
	RETURN QUERY
WITH excerpt AS (
SELECT * FROM get_portfolio_excerpt($1)
),
sub_principal AS (
SELECT poex.loan_app_id AS loan_app_id_r4, round(SUM(poex.claim)::numeric,2) AS claim, round(SUM(poex.paid)::numeric,2) AS paid FROM excerpt poex WHERE poex.type='principal' GROUP BY poex.loan_app_id
)
, sub_interest AS (
SELECT poex.loan_app_id AS loan_app_id_r4, round(SUM(poex.claim)::numeric,2) AS claim, round(SUM(poex.paid)::numeric,2) AS paid FROM excerpt poex WHERE poex.type='interest' GROUP BY poex.loan_app_id
)
, sub_commission AS (
SELECT poex.loan_app_id AS loan_app_id_r4, round(SUM(poex.claim)::numeric,2) AS claim, round(SUM(poex.paid)::numeric,2) AS paid FROM excerpt poex WHERE poex.type='commission_fee' GROUP BY poex.loan_app_id
)
, sub_guarantee AS (
SELECT poex.loan_app_id AS loan_app_id_r4, round(SUM(poex.claim)::numeric,2) AS claim, round(SUM(poex.paid)::numeric,2) AS paid FROM excerpt poex WHERE poex.type='guarantee_fee' GROUP BY poex.loan_app_id
)
, sub_adminfee AS (
SELECT poex.loan_app_id AS loan_app_id_r4, round(SUM(poex.claim)::numeric,2) AS claim, round(SUM(poex.paid)::numeric,2) AS paid FROM excerpt poex WHERE poex.type='admin_fee' GROUP BY poex.loan_app_id
)
, sub_first_reminder_fee AS(
SELECT poex.loan_app_id AS loan_app_id_r4, round(SUM(poex.claim)::numeric,2) AS claim, round(SUM(poex.paid)::numeric,2) AS paid FROM excerpt poex WHERE poex.type='1st_reminder_fee' GROUP BY poex.loan_app_id
)
, sub_second_reminder_fee AS (
SELECT poex.loan_app_id AS loan_app_id_r4, round(SUM(poex.claim)::numeric,2) AS claim, round(SUM(poex.paid)::numeric,2) AS paid FROM excerpt poex WHERE poex.type='2nd_reminder_fee' GROUP BY poex.loan_app_id
)
, sub_termination_fee AS (
SELECT poex.loan_app_id AS loan_app_id_r4, round(SUM(poex.claim)::numeric,2) AS claim, round(SUM(poex.paid)::numeric,2) AS paid FROM excerpt poex WHERE poex.type='termination_fee' GROUP BY poex.loan_app_id
)
, sub_termination_alert_fee AS (
SELECT poex.loan_app_id AS loan_app_id_r4, round(SUM(poex.claim)::numeric,2) AS claim, round(SUM(poex.paid)::numeric,2) AS paid FROM excerpt poex WHERE poex.type='termination_alert_fee' GROUP BY poex.loan_app_id
)
, sub_first_reminder_sms_fee AS(
SELECT poex.loan_app_id AS loan_app_id_r4, round(SUM(poex.claim)::numeric,2) AS claim, round(SUM(poex.paid)::numeric,2) AS paid FROM excerpt poex WHERE poex.type='1st_reminder_sms_fee' GROUP BY poex.loan_app_id
)
, sub_second_reminder_sms_fee AS(
SELECT poex.loan_app_id AS loan_app_id_r4, round(SUM(poex.claim)::numeric,2) AS claim, round(SUM(poex.paid)::numeric,2) AS paid FROM excerpt poex WHERE poex.type='2nd_reminder_sms_fee' GROUP BY poex.loan_app_id
)
, sub_third_reminder_sms_fee AS(
SELECT poex.loan_app_id AS loan_app_id_r4, round(SUM(poex.claim)::numeric,2) AS claim, round(SUM(poex.paid)::numeric,2) AS paid FROM excerpt poex WHERE poex.type='3rd_reminder_sms_fee' GROUP BY poex.loan_app_id
)
, sub_fourth_reminder_sms_fee AS(
SELECT poex.loan_app_id AS loan_app_id_r4, round(SUM(poex.claim)::numeric,2) AS claim, round(SUM(poex.paid)::numeric,2) AS paid FROM excerpt poex WHERE poex.type='4th_reminder_sms_fee' GROUP BY poex.loan_app_id
)
, sub_fifth_reminder_sms_fee AS(
SELECT poex.loan_app_id AS loan_app_id_r4, round(SUM(poex.claim)::numeric,2) AS claim, round(SUM(poex.paid)::numeric,2) AS paid FROM excerpt poex WHERE poex.type='5th_reminder_sms_fee' GROUP BY poex.loan_app_id
)
, sub_delay_interest AS (
SELECT poex.loan_app_id AS loan_app_id_r4, round(SUM(poex.claim)::numeric,2) AS claim, round(SUM(poex.paid)::numeric,2) AS paid FROM excerpt poex WHERE poex.type='delay_interest' GROUP BY poex.loan_app_id
)
, sub_suspension_fee AS (
SELECT poex.loan_app_id AS loan_app_id_r4, round(SUM(poex.claim)::numeric,2) AS claim, round(SUM(poex.paid)::numeric,2) AS paid FROM excerpt poex WHERE poex.type='suspension_fee' GROUP BY poex.loan_app_id
)
,
payments AS (
	SELECT
		rpt.ir_id AS installment_table_id_res,
		round(sum(rpt.sum::numeric),2) AS paid_sum_res,
		max(rp.payment_date)::date AS income_date_res
	FROM
		repayment_type rpt
	LEFT JOIN
		repayments rp ON  rp.id=rpt.repayment_id
	WHERE
		rp.payment_date <=$1 AND rpt.type='principal'
	GROUP BY
		rpt.ir_id
)

, delay AS (
SELECT
it.loan_app_id AS loan_app_id_r3
, ($1::date - min(it.expected_date::date)) AS maxdelay_r1

FROM installment_table it
LEFT JOIN payments p ON it.id = p.installment_table_id_res
WHERE it.nr > 0 and (it.principal > p.paid_sum_res OR p.paid_sum_res IS NULL)
GROUP BY it.loan_app_id
)

, pe AS (
SELECT poex.loan_app_id AS loan_app_id_r1, round(SUM(poex.claim)::numeric,2) AS claim_r1, round(SUM(poex.paid)::numeric,2) AS paid_r1 FROM excerpt poex GROUP BY poex.loan_app_id
)
, mainquery AS (
SELECT pe.loan_app_id_r1 AS loan_app_id_r2, round(pe.claim_r1::numeric,2) AS claim, round(pe.paid_r1::numeric,2) AS paid, GREATEST(coalesce(delay.maxdelay_r1,0), 0) AS maxdelay_r2 FROM pe
	LEFT OUTER JOIN delay ON pe.loan_app_id_r1=delay.loan_app_id_r3
WHERE pe.claim_r1 > pe.paid_r1
)
SELECT
mainquery.loan_app_id_r2::integer AS p_loan_app_id,
la.ref_nr AS p_ref_nr,
cl.first_name::text AS p_first_name,
cl.last_name::text AS p_last_name,
cl.pin::text AS p_pin,
coalesce(ls.la_status::text, la.status) AS p_loan_status,
ls.changed::date AS status_changed,
mainquery.maxdelay_r2::integer AS p_maxdelay,
round((mainquery.claim - mainquery.paid)::numeric,2)::double precision AS p_total_claim,
round(coalesce((sub_principal.claim - sub_principal.paid),0)::numeric,2)::double precision AS p_principal_claim,
round(coalesce((sub_interest.claim - sub_interest.paid),0)::numeric,2)::double precision AS p_interest_claim,
round(coalesce((sub_commission.claim - sub_commission.paid),0)::numeric,2)::double precision AS p_commission_claim,
round(coalesce((sub_guarantee.claim - sub_guarantee.paid),0)::numeric,2)::double precision AS p_guarantee_claim,
round(coalesce((sub_adminfee.claim - sub_adminfee.paid),0)::numeric,2)::double precision AS p_adminfee_claim,
round(coalesce((sub_first_reminder_fee.claim - sub_first_reminder_fee.paid),0)::numeric,2)::double precision AS p_first_reminder_fee_claim,
round(coalesce((sub_second_reminder_fee.claim - sub_second_reminder_fee.paid),0)::numeric,2)::double precision AS p_second_reminder_fee_claim,
round(coalesce((sub_termination_fee.claim - sub_termination_fee.paid),0)::numeric,2)::double precision AS p_termination_fee_claim,
round(coalesce((sub_termination_alert_fee.claim - sub_termination_alert_fee.paid),0)::numeric,2)::double precision AS p_termination_alert_fee_claim,
round(coalesce((sub_first_reminder_sms_fee.claim - sub_first_reminder_sms_fee.paid),0)::numeric,2)::double precision AS p_first_reminder_sms_fee_claim,
round(coalesce((sub_second_reminder_sms_fee.claim - sub_second_reminder_sms_fee.paid),0)::numeric,2)::double precision AS p_second_reminder_sms_fee_claim,
round(coalesce((sub_third_reminder_sms_fee.claim - sub_third_reminder_sms_fee.paid),0)::numeric,2)::double precision AS p_third_reminder_sms_fee_claim,
round(coalesce((sub_fourth_reminder_sms_fee.claim - sub_fourth_reminder_sms_fee.paid),0)::numeric,2)::double precision AS p_fourth_reminder_sms_fee_claim,
round(coalesce((sub_fifth_reminder_sms_fee.claim - sub_fifth_reminder_sms_fee.paid),0)::numeric,2)::double precision AS p_fifth_reminder_sms_fee_claim,
round(coalesce((sub_delay_interest.claim - sub_delay_interest.paid),0)::numeric,2)::double precision AS p_delay_interest_claim,
round(coalesce((sub_suspension_fee.claim - sub_suspension_fee.paid),0)::numeric,2)::double precision AS p_suspension_fee_claim


FROM mainquery
LEFT OUTER JOIN sub_principal ON mainquery.loan_app_id_r2=sub_principal.loan_app_id_r4
LEFT OUTER JOIN sub_interest ON mainquery.loan_app_id_r2=sub_interest.loan_app_id_r4
LEFT OUTER JOIN sub_commission ON mainquery.loan_app_id_r2=sub_commission.loan_app_id_r4
LEFT OUTER JOIN sub_guarantee ON mainquery.loan_app_id_r2=sub_guarantee.loan_app_id_r4
LEFT OUTER JOIN sub_adminfee ON mainquery.loan_app_id_r2=sub_adminfee.loan_app_id_r4
LEFT OUTER JOIN sub_first_reminder_fee ON mainquery.loan_app_id_r2=sub_first_reminder_fee.loan_app_id_r4
LEFT OUTER JOIN sub_second_reminder_fee ON mainquery.loan_app_id_r2=sub_second_reminder_fee.loan_app_id_r4
LEFT OUTER JOIN sub_termination_fee ON mainquery.loan_app_id_r2=sub_termination_fee.loan_app_id_r4
LEFT OUTER JOIN sub_termination_alert_fee ON mainquery.loan_app_id_r2=sub_termination_alert_fee.loan_app_id_r4
LEFT OUTER JOIN sub_first_reminder_sms_fee ON mainquery.loan_app_id_r2=sub_first_reminder_sms_fee.loan_app_id_r4
LEFT OUTER JOIN sub_second_reminder_sms_fee ON mainquery.loan_app_id_r2=sub_second_reminder_sms_fee.loan_app_id_r4
LEFT OUTER JOIN sub_third_reminder_sms_fee ON mainquery.loan_app_id_r2=sub_third_reminder_sms_fee.loan_app_id_r4
LEFT OUTER JOIN sub_fourth_reminder_sms_fee ON mainquery.loan_app_id_r2=sub_fourth_reminder_sms_fee.loan_app_id_r4
LEFT OUTER JOIN sub_fifth_reminder_sms_fee ON mainquery.loan_app_id_r2=sub_fifth_reminder_sms_fee.loan_app_id_r4
LEFT OUTER JOIN sub_delay_interest ON mainquery.loan_app_id_r2=sub_delay_interest.loan_app_id_r4
LEFT OUTER JOIN sub_suspension_fee ON mainquery.loan_app_id_r2=sub_suspension_fee.loan_app_id_r4
LEFT OUTER JOIN loan_application la ON mainquery.loan_app_id_r2 = la.id
LEFT OUTER JOIN client_profile cl ON cl.id = la.client_id
LEFT OUTER JOIN get_loan_status($1) ls ON la.id = ls.loan_app_id;

	END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;

DROP FUNCTION IF EXISTS get_sales_report(IN date, IN date);

CREATE OR REPLACE FUNCTION get_sales_report(IN date, IN date)
  RETURNS TABLE(loan_app_id integer, ref_nr text, loan_status text, s_saldo numeric, interest numeric, commission_fee numeric, guarantee_fee numeric, admin_fee numeric, first_reminder_fee numeric,
  second_reminder_fee numeric, termination_fee numeric, termination_alert_fee numeric, first_reminder_sms_fee numeric, second_reminder_sms_fee numeric, third_reminder_sms_fee numeric, fourth_reminder_sms_fee numeric, fifth_reminder_sms_fee numeric,
  delayinterest numeric, suspension_fee numeric,correction numeric, income numeric, e_saldo numeric) AS
$BODY$

	BEGIN
	RETURN QUERY

	WITH
	loan_app_claims_before AS (
	SELECT round(SUM(vf.amount)::numeric,2) AS claim, vf.loan_app_id AS la_id FROM v_installment_flat vf
	WHERE duedate::date <$1 AND type<>'principal'
	GROUP BY vf.loan_app_id
	)
	, loan_app_delay_interest_before AS (
	SELECT round(SUM(di.sum)::numeric,2) AS claim, di.loan_app_id AS la_id FROM delay_interest di WHERE calculated_date <$1
	GROUP BY di.loan_app_id
	)
	, loan_app_payments_before AS (
	SELECT round(sum(rpt.sum)::numeric,2) AS paym, rp.loan_app_id AS la_id FROM repayment_type rpt
	LEFT JOIN repayments rp ON rp.id = repayment_id
	WHERE rpt.type<>'principal' AND rpt.type<>'overpayment' AND rpt.type<>'defaulted_overpayment' AND rpt.type <> 'extraordinary_revenue' AND rp.payment_date::date <$1
	GROUP by rp.loan_app_id
	)
	, loan_app_payments_period AS (
	SELECT round(sum(rpt.sum)::numeric,2) AS paym, rp.loan_app_id AS la_id FROM repayment_type rpt
	LEFT JOIN repayments rp ON rp.id = repayment_id
	WHERE rpt.type<>'principal' AND rpt.type<>'overpayment' AND rpt.type<>'defaulted_overpayment' AND rpt.type <> 'extraordinary_revenue' AND rp.payment_date::date >=$1 AND rp.payment_date::date<=$2
	GROUP by rp.loan_app_id
	)

	, loan_app_corrections_period AS (
		SELECT
			round(sum(rp.sum)::numeric,2) AS paid, rp.loan_app_id AS la_id
		FROM
			repayments rp
		WHERE
			rp.correction=true AND rp.payment_date::date>=$1 AND rp.payment_date::date<=$2
		GROUP BY
			rp.loan_app_id
	)
	, period_installment_flat AS (
	SELECT * FROM v_installment_flat WHERE duedate::date>=$1 AND duedate::date<=$2 AND type<>'principal'
	)
	, sales_interest AS (
	SELECT round(SUM(pif.amount)::numeric,2) AS sales, pif.loan_app_id AS la_id FROM period_installment_flat pif WHERE type='interest'
	GROUP BY pif.loan_app_id
	)
	, sales_commission AS (
	SELECT round(SUM(pif.amount)::numeric,2) AS sales, pif.loan_app_id AS la_id FROM period_installment_flat pif WHERE type='commission_fee'
	GROUP BY pif.loan_app_id
	)
	, sales_guarantee AS (
	SELECT round(SUM(pif.amount)::numeric,2) AS sales, pif.loan_app_id AS la_id FROM period_installment_flat pif WHERE type='guarantee_fee'
	GROUP BY pif.loan_app_id
	)
	, sales_adminfee AS (
	SELECT round(SUM(pif.amount)::numeric,2) AS sales, pif.loan_app_id AS la_id FROM period_installment_flat pif WHERE type='admin_fee'
	GROUP BY pif.loan_app_id
	)
	, sales_1st_reminder_fee AS (
	SELECT round(SUM(pif.amount)::numeric,2) AS sales, pif.loan_app_id AS la_id FROM period_installment_flat pif WHERE type='1st_reminder_fee'
	GROUP BY pif.loan_app_id
	)
	, sales_2nd_reminder_fee AS (
	SELECT round(SUM(pif.amount)::numeric,2) AS sales, pif.loan_app_id AS la_id FROM period_installment_flat pif WHERE type='2nd_reminder_fee'
	GROUP BY pif.loan_app_id
	)
	, sales_termination_fee AS (
	SELECT round(SUM(pif.amount)::numeric,2) AS sales, pif.loan_app_id AS la_id FROM period_installment_flat pif WHERE type='termination_fee'
	GROUP BY pif.loan_app_id
	)
	, sales_termination_alert_fee AS (
	SELECT round(SUM(pif.amount)::numeric,2) AS sales, pif.loan_app_id AS la_id FROM period_installment_flat pif WHERE type='termination_alert_fee'
	GROUP BY pif.loan_app_id
	)
	, sales_1st_reminder_sms_fee AS (
	SELECT round(SUM(pif.amount)::numeric,2) AS sales, pif.loan_app_id AS la_id FROM period_installment_flat pif WHERE type='1st_reminder_sms_fee'
	GROUP BY pif.loan_app_id
	)
	, sales_2nd_reminder_sms_fee AS (
	SELECT round(SUM(pif.amount)::numeric,2) AS sales, pif.loan_app_id AS la_id FROM period_installment_flat pif WHERE type='2nd_reminder_sms_fee'
	GROUP BY pif.loan_app_id
	)
	, sales_3rd_reminder_sms_fee AS (
	SELECT round(SUM(pif.amount)::numeric,2) AS sales, pif.loan_app_id AS la_id FROM period_installment_flat pif WHERE type='3rd_reminder_sms_fee'
	GROUP BY pif.loan_app_id
	)
	, sales_4th_reminder_sms_fee AS (
	SELECT round(SUM(pif.amount)::numeric,2) AS sales, pif.loan_app_id AS la_id FROM period_installment_flat pif WHERE type='4th_reminder_sms_fee'
	GROUP BY pif.loan_app_id
	)
	, sales_5th_reminder_sms_fee AS (
	SELECT round(SUM(pif.amount)::numeric,2) AS sales, pif.loan_app_id AS la_id FROM period_installment_flat pif WHERE type='5th_reminder_sms_fee'
	GROUP BY pif.loan_app_id
	)
	, sales_delay_interest AS (
	SELECT round(SUM(di.sum)::numeric,2) AS sales, di.loan_app_id AS la_id FROM delay_interest di WHERE calculated_date::date >=$1 AND calculated_date::date <=$2
	GROUP BY di.loan_app_id
	),
	sales_suspension_fee AS (
	SELECT round(SUM(pif.amount)::numeric,2) AS sales, pif.loan_app_id AS la_id FROM period_installment_flat pif WHERE type='suspension_fee'
	GROUP BY pif.loan_app_id
	)

	SELECT
		la.id AS r_loan_app_id
		, la.ref_nr::text AS r_ref_nr
		, ls.la_status AS r_status
		, (coalesce(lac.claim,0.00) + coalesce(dic.claim,0.00) - coalesce(lap.paym,0.00))::numeric AS r_s_saldo
		, coalesce(si.sales,0.00)::numeric AS r_interest
		, coalesce(sc.sales,0.00)::numeric AS r_commission_fee
		, coalesce(sgf.sales,0.00)::numeric AS r_guarantee_fee
		, coalesce(saf.sales,0.00)::numeric AS r_admin_fee
		, coalesce(s1r.sales,0.00)::numeric AS r_first_reminder_fee
		, coalesce(s2r.sales,0.00)::numeric AS r_second_reminder_fee
		, coalesce(stf.sales,0.00)::numeric AS r_termination_fee
		, coalesce(sta.sales,0.00)::numeric AS r_termination_alert_fee
		, coalesce(s1rs.sales,0.00)::numeric AS r_first_reminder_sms_fee
		, coalesce(s2rs.sales,0.00)::numeric AS r_second_reminder_sms_fee
		, coalesce(s3rs.sales,0.00)::numeric AS r_third_reminder_sms_fee
		, coalesce(s4rs.sales,0.00)::numeric AS r_fourth_reminder_sms_fee
		, coalesce(s5rs.sales,0.00)::numeric AS r_fifth_reminder_sms_fee
		, coalesce(sdi.sales,0.00)::numeric AS r_delay_interest
		, coalesce(ssf.sales,0.00)::numeric AS r_suspension_fee
		, coalesce(cor.paid, 0.00)::numeric AS r_correction
		--, (coalesce(si.sales,0.00) + coalesce(sc.sales,0.00) + coalesce(s1r.sales,0.00) + coalesce(s2r.sales,0.00) + coalesce(stf.sales,0.00) + coalesce(sta.sales,0.00) + coalesce(sdi.sales,0.00))::numeric AS r_income
		, coalesce(lapp.paym,0.00)::numeric AS r_income
		, (
		coalesce(lac.claim,0.00) + coalesce(dic.claim,0.00) -- previous sales
		+ coalesce(si.sales,0.00) + coalesce(sc.sales,0.00) + coalesce(sgf.sales,0.00) + coalesce(saf.sales,0.00) + coalesce(s1r.sales,0.00) + coalesce(s2r.sales,0.00) + coalesce(stf.sales,0.00) + coalesce(sta.sales,0.00) + coalesce(s1rs.sales,0.00) + coalesce(s2rs.sales,0.00) + coalesce(s3rs.sales,0.00) + coalesce(s4rs.sales,0.00) + coalesce(s5rs.sales,0.00) + coalesce(sdi.sales,0.00) + coalesce(ssf.sales,0.00) -- period sales
		- coalesce(lap.paym,0.00) -- previous payments
		- coalesce(lapp.paym,0.00) -- previous payments
		)::numeric AS r_e_saldo

	FROM
		loan_application la
	LEFT JOIN get_loan_status($2) ls ON la.id = ls.loan_app_id
	LEFT JOIN loan_app_claims_before lac ON la.id = lac.la_id
	LEFT JOIN loan_app_payments_before lap ON la.id = lap.la_id
	LEFT JOIN loan_app_delay_interest_before dic ON la.id = dic.la_id
	LEFT JOIN loan_app_payments_period lapp ON la.id = lapp.la_id

	LEFT JOIN sales_interest si ON la.id=si.la_id
	LEFT JOIN sales_commission sc ON la.id=sc.la_id
	LEFT JOIN sales_guarantee sgf ON la.id=sgf.la_id
	LEFT JOIN sales_adminfee saf ON la.id=saf.la_id
	LEFT JOIN sales_1st_reminder_fee s1r ON la.id=s1r.la_id
	LEFT JOIN sales_2nd_reminder_fee s2r ON la.id=s2r.la_id
	LEFT JOIN sales_termination_fee stf ON la.id=stf.la_id
	LEFT JOIN sales_termination_alert_fee sta ON la.id=sta.la_id
	LEFT JOIN sales_1st_reminder_sms_fee s1rs ON la.id=s1rs.la_id
	LEFT JOIN sales_2nd_reminder_sms_fee s2rs ON la.id=s2rs.la_id
	LEFT JOIN sales_3rd_reminder_sms_fee s3rs ON la.id=s3rs.la_id
	LEFT JOIN sales_4th_reminder_sms_fee s4rs ON la.id=s4rs.la_id
	LEFT JOIN sales_5th_reminder_sms_fee s5rs ON la.id=s5rs.la_id
	LEFT JOIN sales_delay_interest sdi ON la.id=sdi.la_id
	LEFT JOIN sales_suspension_fee ssf ON la.id=ssf.la_id
	LEFT JOIN loan_app_corrections_period cor ON la.id=cor.la_id
	WHERE la.active=true
	--AND la.active_date::date<=$2
	AND
	(
		((coalesce(si.sales,0.00) + coalesce(sc.sales,0.00) + coalesce(sgf.sales,0.00) + coalesce(saf.sales,0.00) + coalesce(s1r.sales,0.00) + coalesce(s2r.sales,0.00) + coalesce(stf.sales,0.00) + coalesce(sta.sales,0.00) + coalesce(s1rs.sales,0.00) + coalesce(s2rs.sales,0.00) + coalesce(s3rs.sales,0.00) + coalesce(s4rs.sales,0.00) + coalesce(s5rs.sales,0.00) + coalesce(sdi.sales,0.00)  + coalesce(ssf.sales,0.00) ) > 0)
		OR
		( coalesce(lac.claim,0.00) + coalesce(dic.claim,0.00) - coalesce(lap.paym,0.00) <> 0)
		OR
		(
		coalesce(lac.claim,0.00) + coalesce(dic.claim,0.00) -- previous sales
		+ coalesce(si.sales,0.00) + coalesce(sc.sales,0.00) + coalesce(sgf.sales,0.00) + coalesce(saf.sales,0.00) + coalesce(s1r.sales,0.00) + coalesce(s2r.sales,0.00) + coalesce(stf.sales,0.00) + coalesce(sta.sales,0.00) + coalesce(s1rs.sales,0.00) + coalesce(s2rs.sales,0.00) + coalesce(s3rs.sales,0.00) + coalesce(s4rs.sales,0.00) + coalesce(s5rs.sales,0.00) + coalesce(sdi.sales,0.00) + coalesce(ssf.sales,0.00)  -- period sales
		- coalesce(lap.paym,0.00) -- previous payments
		- coalesce(lapp.paym,0.00) -- previous payments
		<> 0
		)
	)
  ;

	END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 5000;

DROP FUNCTION IF EXISTS get_income_report(IN date, IN date);

CREATE OR REPLACE FUNCTION get_income_report(IN date, IN date)
  RETURNS TABLE(loan_app_id integer, repayment_id integer, principal numeric, interest numeric, commission_fee numeric, guarantee_fee numeric, admin_fee numeric, first_reminder_fee numeric, second_reminder_fee numeric, termination_fee numeric, termination_alert_fee numeric, first_reminder_sms_fee numeric, second_reminder_sms_fee numeric, third_reminder_sms_fee numeric, fourth_reminder_sms_fee numeric, fifth_reminder_sms_fee numeric, delay_interest numeric, suspension_fee numeric, overpayment numeric, extraordinary_revenue numeric, total numeric, payment_date date, bank character varying, ref_nr integer, firstname character varying, lastname character varying, total_sales numeric) AS
$BODY$

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

	(coalesce(c_interest.c_sum,0.00)::numeric +
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
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;

DROP FUNCTION IF EXISTS get_claim_totals(date);

CREATE OR REPLACE FUNCTION get_claim_totals(IN date)
  RETURNS TABLE(loan_app_id integer, claim numeric, type text) AS
$BODY$

	BEGIN
	RETURN QUERY


	SELECT mt.loan_app_id AS la_id, sum(mt.first_rem)::numeric AS amount, '1st_reminder_fee'::text AS type_res
		FROM installment_table mt
		WHERE mt.first_rem > 0::numeric AND mt.first_rem_date::date<=$1
		GROUP BY mt.loan_app_id

		UNION ALL
		SELECT mt.loan_app_id AS la_id, sum(mt.second_rem)::numeric AS amount, '2nd_reminder_fee'::text AS type_res
		FROM installment_table mt
		WHERE mt.second_rem > 0::numeric AND  mt.second_rem_date::date <=$1
		GROUP BY mt.loan_app_id

		UNION ALL
		SELECT mt.loan_app_id AS la_id, sum(mt.term_alert)::numeric AS amount, 'termination_alert_fee'::text AS type_res
		FROM installment_table mt
		WHERE mt.term_alert > 0::numeric AND mt.term_alert_date::date <=$1
		GROUP BY mt.loan_app_id

		UNION ALL
		SELECT mt.loan_app_id AS la_id, sum(mt.term)::numeric AS amount, 'termination_fee'::text AS type_res
		FROM installment_table mt
		WHERE mt.term > 0::numeric AND mt.term_date::date<=$1
		GROUP BY mt.loan_app_id

		UNION ALL
		SELECT mt.loan_app_id AS la_id, sum(mt.first_rem_sms)::numeric AS amount, '1st_reminder_sms_fee'::text AS type_res
		FROM installment_table mt
		WHERE mt.first_rem_sms > 0::numeric AND  mt.first_rem_sms_date::date <=$1
		GROUP BY mt.loan_app_id

		UNION ALL
		SELECT mt.loan_app_id AS la_id, sum(mt.second_rem_sms)::numeric AS amount, '2nd_reminder_sms_fee'::text AS type_res
		FROM installment_table mt
		WHERE mt.second_rem_sms > 0::numeric AND  mt.second_rem_sms_date::date <=$1
		GROUP BY mt.loan_app_id

		UNION ALL
		SELECT mt.loan_app_id AS la_id, sum(mt.third_rem_sms)::numeric AS amount, '3rd_reminder_sms_fee'::text AS type_res
		FROM installment_table mt
		WHERE mt.third_rem_sms > 0::numeric AND  mt.third_rem_sms_date::date <=$1
		GROUP BY mt.loan_app_id

		UNION ALL
		SELECT mt.loan_app_id AS la_id, sum(mt.fourth_rem_sms)::numeric AS amount, '4th_reminder_sms_fee'::text AS type_res
		FROM installment_table mt
		WHERE mt.fourth_rem_sms > 0::numeric AND  mt.fourth_rem_sms_date::date <=$1
		GROUP BY mt.loan_app_id

		UNION ALL
		SELECT mt.loan_app_id AS la_id, sum(mt.fifth_rem_sms)::numeric AS amount, '5th_reminder_sms_fee'::text AS type_res
		FROM installment_table mt
		WHERE mt.fifth_rem_sms > 0::numeric AND  mt.fifth_rem_sms_date::date <=$1
		GROUP BY mt.loan_app_id

		UNION ALL
		SELECT mt.loan_app_id AS la_id, sum(mt.suspension_fee)::numeric AS amount, 'suspension_fee'::text AS type_res
		FROM installment_table mt
		WHERE mt.suspended_date IS NOT NULL AND mt.suspended_date::date <=$1
		GROUP BY mt.loan_app_id

		UNION ALL
		SELECT mt.loan_app_id AS la_id, sum(mt.admin_fee)::numeric AS amount, 'admin_fee'::text AS type_res
		FROM installment_table mt
		LEFT JOIN loan_application la ON mt.loan_app_id = la.id
		WHERE mt.interest > 0::numeric AND la.active=true AND la.active_date::date<=$1
		GROUP BY mt.loan_app_id

		UNION ALL
		SELECT mt.loan_app_id AS la_id, sum(mt.guarantee_fee)::numeric AS amount, 'guarantee_fee'::text AS type_res
		FROM installment_table mt
		LEFT JOIN loan_application la ON mt.loan_app_id = la.id
		WHERE mt.interest > 0::numeric AND la.active=true AND la.active_date::date<=$1
		GROUP BY mt.loan_app_id

		UNION ALL
		SELECT mt.loan_app_id AS la_id, sum(mt.interest)::numeric AS amount, 'interest'::text AS type_res
		FROM installment_table mt
		LEFT JOIN loan_application la ON mt.loan_app_id = la.id
		WHERE mt.interest > 0::numeric AND la.active=true AND la.active_date::date<=$1
		GROUP BY mt.loan_app_id

		UNION ALL
		SELECT mt.loan_app_id AS la_id, sum(mt.admission_fee)::numeric AS amount, 'commission_fee'::text AS type_res
		FROM installment_table mt
		LEFT JOIN loan_application la ON mt.loan_app_id = la.id
		WHERE mt.admission_fee > 0::numeric AND la.active=true AND la.active_date::date<=$1
		GROUP BY mt.loan_app_id

		UNION ALL
		SELECT mt.loan_app_id AS la_id, sum(mt.principal)::numeric AS amount, 'principal'::text AS type_res
		FROM installment_table mt
		LEFT JOIN loan_application la ON mt.loan_app_id = la.id
		WHERE mt.principal > 0::numeric AND la.active=true AND la.active_date::date<=$1
		GROUP BY mt.loan_app_id

	UNION ALL

	SELECT di.loan_app_id  AS la_id, SUM(di.sum)::numeric AS amount, 'delay_interest'::text AS type_res FROM delay_interest di WHERE calculated_date::date <= $1
	GROUP BY di.loan_app_id



	  ;

	END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;

DROP FUNCTION IF EXISTS get_defaulted_loanapps(date, date, date);

CREATE OR REPLACE FUNCTION get_defaulted_loanapps(IN date, IN date, IN date)
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
	collectiondate date,
	totaldebt numeric,
	principal numeric,
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

	) AS
	$BODY$
	BEGIN

		RETURN QUERY
		SELECT * FROM get_defaulted_loanapps_base ($1, $2, $3) dl WHERE dl.defaulteddate>=$1 AND dl.defaulteddate <=$2
		--SELECT * FROM get_indebtcollection_loanapps_base ($1, $2, $3) dl WHERE dl.collectiondate>=$1 AND dl.collectiondate <=$2
		;



	END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

DROP FUNCTION IF EXISTS get_indebtcollection_loanapps(date, date, date);

CREATE OR REPLACE FUNCTION get_indebtcollection_loanapps(IN date, IN date, IN date)
  RETURNS TABLE(
  	loanappid integer,
	loanproduct text,
	loanproductid integer,
	refnr text,
	firstname text,
	lastname text,
	defaultinterest double precision,
	score text,
	office text,
	incassocompany text,
	incassocompanyid integer,
	loanamount numeric,
	loanperiod integer,
	activedate date,
	defaulteddate date,
	collectiondate date,
	totaldebt numeric,
	principal numeric,
	commissionfee numeric,
	guaranteefee numeric,
	adminfee numeric,
	interest numeric,
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
	repaymentsbefore numeric,
	agreementsignment text,
	comments text,
	payoutto text

	) AS
	$BODY$
	BEGIN

	RETURN QUERY
	SELECT * FROM get_indebtcollection_loanapps_base ($1, $2, $3) dl WHERE dl.collectiondate>=$1 AND dl.collectiondate <=$2
	ORDER BY dl.collectiondate ASC, dl.refnr ASC
	;



	END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

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
) AS
$BODY$
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
		la.internal_collection_date::date AS internal_r,
		la.collection_date::date AS collection_r,
		la.written_off_date::date AS writtenoff_r,
		(
			(coalesce(principal_c.claim,0.00) - coalesce(principal_p.payment, 0.0)) +
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
			firstremsms_claim firstrem_c ON firstremsms_c.laid=la.id
		LEFT JOIN
			firstremsms_payments firstrem_p ON firstremsms_p.laid=la.id
		LEFT JOIN
			secondremsms_claim firstrem_c ON secondremsms_c.laid=la.id
		LEFT JOIN
			secondremsms_payments firstrem_p ON secondremsms_p.laid=la.id
		LEFT JOIN
			thirdremsms_claim firstrem_c ON thirdremsms_c.laid=la.id
		LEFT JOIN
			thirdremsms_payments firstrem_p ON thirdremsms_p.laid=la.id
		LEFT JOIN
			fourthremsms_claim firstrem_c ON fourthremsms_c.laid=la.id
		LEFT JOIN
			fourthremsms_payments firstrem_p ON fourthremsms_p.laid=la.id
		LEFT JOIN
			fifthremsms_claim firstrem_c ON fifthremsms_c.laid=la.id
		LEFT JOIN
			fifthremsms_payments firstrem_p ON fifthremsms_p.laid=la.id
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
$BODY$
  LANGUAGE plpgsql VOLATILE;

DROP FUNCTION IF EXISTS get_indebtcollection_loanapps_base(date, date, date);
CREATE OR REPLACE FUNCTION get_indebtcollection_loanapps_base(IN date, IN date, IN date)
  RETURNS TABLE(
  	loanappid integer,
	loanproduct text,
	loanproductid integer,
	refnr text,
	firstname text,
	lastname text,
	defaultintrest double precision,
	score text,
	office text,
	incassocompany text,
	incassocompanyid integer,
	loanamount numeric,
	loanperiod integer,
	activedate date,
	defaulteddate date,
	collectiondate date,
	totaldebt numeric,
	principal numeric,
	commissionfee numeric,
	guaranteefee numeric,
	adminfee numeric,
	interest numeric,
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
	repaymentsbefore numeric,
	agreementsignment text,
	comments text,
	payoutto text

	) AS
	$BODY$
	BEGIN

		RETURN QUERY
		WITH payments_later AS (
			SELECT rp.loan_app_id AS laid, sum(rp.sum) AS payments FROM repayments rp
			LEFT JOIN loan_application la ON rp.loan_app_id=la.id
			WHERE
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2
				AND rp.payment_date::date > la.collection_date::date
				AND rp.payment_date::date <= $3
			GROUP BY rp.loan_app_id
		),
		payments_before AS (
			SELECT rp.loan_app_id AS laid, sum(rp.sum) AS payments FROM repayments rp
      LEFT JOIN loan_application la ON rp.loan_app_id=la.id
      WHERE
        (la.collection_date IS NOT NULL
        AND la.collection_date <$1
        AND rp.payment_date::date < la.collection_date::date)
        OR (rp.payment_date::date < now()::date)
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
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2
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
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2
				AND rp.payment_date::date <= la.collection_date::date
				AND rpt.type='principal'
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
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2
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
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2
				AND rp.payment_date::date <= la.collection_date::date
				AND rpt.type='interest'
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
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2
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
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2
				AND rp.payment_date::date <= la.collection_date::date
				AND rpt.type='commission_fee'
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
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2
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
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2
				AND rp.payment_date::date <= la.collection_date::date
				AND rpt.type='guarantee_fee'
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
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2
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
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2
				AND rp.payment_date::date <= la.collection_date::date
				AND rpt.type='admin_fee'
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
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2
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
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2
				AND rp.payment_date::date <= la.collection_date::date
				AND rpt.type='1st_reminder_fee'
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
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2
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
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2
				AND rp.payment_date::date <= la.collection_date::date
				AND rpt.type='2nd_reminder_fee'
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
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2
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
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2
				AND rp.payment_date::date <= la.collection_date::date
				AND rpt.type='termination_alert_fee'
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
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2
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
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2
				AND rp.payment_date::date <= la.collection_date::date
				AND rpt.type='termination_fee'
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
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2
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
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2
				AND rp.payment_date::date <= la.collection_date::date
				AND rpt.type='1st_reminder_sms_fee'
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
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2
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
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2
				AND rp.payment_date::date <= la.collection_date::date
				AND rpt.type='2nd_reminder_sms_fee'
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
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2
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
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2
				AND rp.payment_date::date <= la.collection_date::date
				AND rpt.type='3rd_reminder_sms_fee'
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
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2
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
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2
				AND rp.payment_date::date <= la.collection_date::date
				AND rpt.type='4th_reminder_sms_fee'
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
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2
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
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2
				AND rp.payment_date::date <= la.collection_date::date
				AND rpt.type='5th_reminder_sms_fee'
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
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2
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
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2
				AND rp.payment_date::date <= la.collection_date::date
				AND rpt.type='suspension_fee'
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
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2 AND di.calculated_date::date<=la.collection_date
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
				la.collection_date IS NOT NULL
				AND la.collection_date >=$1 AND la.collection_date <=$2
				AND rp.payment_date::date <= la.collection_date::date
				AND rpt.type='delay_interest'
			GROUP BY rp.loan_app_id
		)



		SELECT
		la.id AS loanappid_r,
		lp.name::text AS loanproduct_r,
		la.loan_product_id::integer AS loanproductid_r,
		la.ref_nr::text AS refnr_r,
		cp.first_name::text AS firstname_r,
		cp.last_name::text AS lastname_r,
		lp.delay_interest::double precision AS defaultinterest_r,
		sc.score::text AS score_r,
		la.loan_office::text AS office_r,
		cc.company_name::text AS incassocompany_r,
		cc.id::integer AS incassocompany_id,
		la.amount::numeric AS loanamount_r,
		la.period::integer AS loanperiod_r,
		la.active_date::date AS activedate_r,
		la.term_date::date AS defaulteddate_r,
		la.collection_date::date AS collection_r,
		(
			(coalesce(principal_c.claim,0.00) - coalesce(principal_p.payment, 0.0)) +
			(coalesce(commissionfee_c.claim,0.00) - coalesce(commissionfee_p.payment, 0.0)) +
			(coalesce(guaranteefee_c.claim,0.00) - coalesce(guaranteefee_p.payment, 0.0)) +
			(coalesce(adminfee_c.claim,0.00) - coalesce(adminfee_p.payment, 0.0)) +
			(coalesce(interest_c.claim,0.00) - coalesce(interest_p.payment, 0.0)) +
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
		(coalesce(commissionfee_c.claim,0.00) - coalesce(commissionfee_p.payment, 0.0)) ::numeric AS commissionfee_r,
		(coalesce(guaranteefee_c.claim,0.00) - coalesce(guaranteefee_p.payment, 0.0)) ::numeric AS guaranteefee_r,
		(coalesce(adminfee_c.claim,0.00) - coalesce(adminfee_p.payment, 0.0)) ::numeric AS adminfee_r,
		(coalesce(interest_c.claim,0.00) - coalesce(interest_p.payment, 0.0))::numeric AS interest_r,
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
		coalesce (pb.payments, 0.00)::numeric AS repaymentsbefore_r,
		la.agreement_signment::text AS agreementsignment_r,
		coalesce(d.name, 'NA') || ', ' ||
		coalesce(NULLIF(la.purpose,''), 'NA') AS comments_r,
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
			payments_before pb ON la.id=pb.laid
		LEFT JOIN
			principal_claim principal_c ON principal_c.laid=la.id
		LEFT JOIN
			principal_payments principal_p ON principal_p.laid=la.id
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
			firstremsms_claim firstrem_c ON firstremsms_c.laid=la.id
		LEFT JOIN
			firstremsms_payments firstrem_p ON firstremsms_p.laid=la.id
		LEFT JOIN
			secondremsms_claim firstrem_c ON secondremsms_c.laid=la.id
		LEFT JOIN
			secondremsms_payments firstrem_p ON secondremsms_p.laid=la.id
		LEFT JOIN
			thirdremsms_claim firstrem_c ON thirdremsms_c.laid=la.id
		LEFT JOIN
			thirdremsms_payments firstrem_p ON thirdremsms_p.laid=la.id
		LEFT JOIN
			fourthremsms_claim firstrem_c ON fourthremsms_c.laid=la.id
		LEFT JOIN
			fourthremsms_payments firstrem_p ON fourthremsms_p.laid=la.id
		LEFT JOIN
			fifthremsms_claim firstrem_c ON fifthremsms_c.laid=la.id
		LEFT JOIN
			fifthremsms_payments firstrem_p ON fifthremsms_p.laid=la.id
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
    LEFT JOIN
      dealer d ON d.id = la.dealer_id

		WHERE la.active=true AND la.collection_date IS NOT NULL AND la.collection_date::date >=$1 AND la.collection_date <=$2

		;

	END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

DROP FUNCTION IF EXISTS get_defaulted_loanapps_bycollectiondate(date, date, date);

CREATE OR REPLACE FUNCTION get_defaulted_loanapps_bycollectiondate(IN date, IN date, IN date)
  RETURNS TABLE(loanappid integer, loanproduct text, loanproductid integer, refnr text, firstname text, lastname text, score text, office text, incassocompany text, incassocompanyid integer, loanamount numeric, loanperiod integer, activedate date, defaulteddate date, collectiondate date, totaldebt numeric, principal numeric, commissionfee numeric, interest numeric, firstrem numeric, secondrem numeric, termalertfee numeric, termfee numeric, firstremsms numeric, secondremsms numeric, thirdremsms numeric, fourthremsms numeric, fifthremsms numeric, suspensionfee numeric, delayinterest numeric, repaymentslater numeric, guaranteefee numeric, adminfee numeric, agreementsignment text, payoutto text) AS
$BODY$
	BEGIN

		RETURN QUERY
		SELECT dl.loanappid AS r1,
		dl.loanproduct AS r2,
		dl.loanproductid AS r3,
		dl.refnr AS r4,
		dl.firstname AS r5,
		dl.lastname AS r6,
		dl.score AS r7,
		dl.office AS r8,
		dl.incassocompany AS r9,
		dl.incassocompanyid AS r10,
		dl.loanamount AS r11,
		dl.loanperiod AS r12,
		dl.activedate AS r13,
		dl.defaulteddate AS r14,
		dl.collectiondate AS r15,
		dl.totaldebt AS r16,
		dl.principal AS r17,
		dl.commissionfee AS r18,
		dl.interest AS r19,
		dl.firstrem AS r20,
		dl.secondrem AS r21,
		dl.termalertfee AS r22,
		dl.termfee AS r23,
		dl.suspensionfee AS r24,
		dl.delayinterest AS r25,
		dl.repaymentslater AS r26,
		dl.guaranteefee AS r27,
		dl.adminfee AS r28,
		dl.agreementsignment AS r29,
		dl.payoutto AS r30,
		dl.firstremsms AS r31,
		dl.secondremsms AS r32,
		dl.thirdremsms AS r33,
		dl.fourthremsms AS r34,
		dl.fifthremsms AS r35
	FROM get_indebtcollection_loanapps_base($1, $2, $3) dl

	WHERE dl.collectiondate IS NOT NULL AND dl.collectiondate::date >=$1 AND dl.collectiondate::date<=$2
	ORDER BY dl.collectiondate ASC, dl.refnr ASC

	;

	END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

DROP FUNCTION IF EXISTS get_internal_collection_loanapps_base(date, date, date);
CREATE OR REPLACE FUNCTION get_internal_collection_loanapps_base(IN date, IN date, IN date)
  RETURNS TABLE(
  	loanappid integer,
	loanproduct text,
	loanproductid integer,
	refnr text,
	firstname text,
	lastname text,
	defaultintrest double precision,
	score text,
	office text,
	incassocompany text,
	incassocompanyid integer,
	loanamount numeric,
	loanperiod integer,
	activedate date,
	defaulteddate date,
	collectiondate date,
	totaldebt numeric,
	principal numeric,
	commissionfee numeric,
	guaranteefee numeric,
	adminfee numeric,
	interest numeric,
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
	repaymentsbefore numeric,
	agreementsignment text,
	comments text,
	payoutto text

	) AS
	$BODY$
	BEGIN

		RETURN QUERY
		WITH payments_later AS (
			SELECT rp.loan_app_id AS laid, sum(rp.sum) AS payments FROM repayments rp
			LEFT JOIN loan_application la ON rp.loan_app_id=la.id
			WHERE
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2
				AND rp.payment_date::date > la.internal_collection_date::date
				AND rp.payment_date::date <= $3
			GROUP BY rp.loan_app_id
		),
		payments_before AS (
			SELECT rp.loan_app_id AS laid, sum(rp.sum) AS payments FROM repayments rp
      LEFT JOIN loan_application la ON rp.loan_app_id=la.id
      WHERE
        (la.internal_collection_date IS NOT NULL
        AND la.internal_collection_date <$1
        AND rp.payment_date::date < la.internal_collection_date::date)
        OR (rp.payment_date::date < now()::date)
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
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2
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
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2
				AND rp.payment_date::date <= la.internal_collection_date::date
				AND rpt.type='principal'
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
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2
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
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2
				AND rp.payment_date::date <= la.internal_collection_date::date
				AND rpt.type='interest'
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
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2
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
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2
				AND rp.payment_date::date <= la.internal_collection_date::date
				AND rpt.type='commission_fee'
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
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2
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
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2
				AND rp.payment_date::date <= la.internal_collection_date::date
				AND rpt.type='guarantee_fee'
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
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2
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
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2
				AND rp.payment_date::date <= la.internal_collection_date::date
				AND rpt.type='admin_fee'
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
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2
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
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2
				AND rp.payment_date::date <= la.internal_collection_date::date
				AND rpt.type='1st_reminder_fee'
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
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2
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
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2
				AND rp.payment_date::date <= la.internal_collection_date::date
				AND rpt.type='2nd_reminder_fee'
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
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2
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
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2
				AND rp.payment_date::date <= la.internal_collection_date::date
				AND rpt.type='termination_alert_fee'
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
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2
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
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2
				AND rp.payment_date::date <= la.internal_collection_date::date
				AND rpt.type='termination_fee'
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
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2
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
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2
				AND rp.payment_date::date <= la.internal_collection_date::date
				AND rpt.type='1st_reminder_sms_fee'
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
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2
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
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2
				AND rp.payment_date::date <= la.internal_collection_date::date
				AND rpt.type='2nd_reminder_sms_fee'
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
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2
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
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2
				AND rp.payment_date::date <= la.internal_collection_date::date
				AND rpt.type='3rd_reminder_sms_fee'
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
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2
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
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2
				AND rp.payment_date::date <= la.internal_collection_date::date
				AND rpt.type='4th_reminder_sms_fee'
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
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2
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
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2
				AND rp.payment_date::date <= la.internal_collection_date::date
				AND rpt.type='5th_reminder_sms_fee'
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
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2
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
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2
				AND rp.payment_date::date <= la.internal_collection_date::date
				AND rpt.type='suspension_fee'
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
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2 AND di.calculated_date::date<=la.internal_collection_date
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
				la.internal_collection_date IS NOT NULL
				AND la.internal_collection_date >=$1 AND la.internal_collection_date <=$2
				AND rp.payment_date::date <= la.internal_collection_date::date
				AND rpt.type='delay_interest'
			GROUP BY rp.loan_app_id
		)

		SELECT
		la.id AS loanappid_r,
		lp.name::text AS loanproduct_r,
		la.loan_product_id::integer AS loanproductid_r,
		la.ref_nr::text AS refnr_r,
		cp.first_name::text AS firstname_r,
		cp.last_name::text AS lastname_r,
		lp.delay_interest::double precision AS defaultinterest_r,
		sc.score::text AS score_r,
		la.loan_office::text AS office_r,
		cc.company_name::text AS incassocompany_r,
		cc.id::integer AS incassocompany_id,
		la.amount::numeric AS loanamount_r,
		la.period::integer AS loanperiod_r,
		la.active_date::date AS activedate_r,
		la.term_date::date AS defaulteddate_r,
		la.internal_collection_date::date AS collection_r,
		(
			(coalesce(principal_c.claim,0.00) - coalesce(principal_p.payment, 0.0)) +
			(coalesce(commissionfee_c.claim,0.00) - coalesce(commissionfee_p.payment, 0.0)) +
			(coalesce(guaranteefee_c.claim,0.00) - coalesce(guaranteefee_p.payment, 0.0)) +
			(coalesce(adminfee_c.claim,0.00) - coalesce(adminfee_p.payment, 0.0)) +
			(coalesce(interest_c.claim,0.00) - coalesce(interest_p.payment, 0.0)) +
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
		(coalesce(commissionfee_c.claim,0.00) - coalesce(commissionfee_p.payment, 0.0)) ::numeric AS commissionfee_r,
		(coalesce(guaranteefee_c.claim,0.00) - coalesce(guaranteefee_p.payment, 0.0)) ::numeric AS guaranteefee_r,
		(coalesce(adminfee_c.claim,0.00) - coalesce(adminfee_p.payment, 0.0)) ::numeric AS adminfee_r,
		(coalesce(interest_c.claim,0.00) - coalesce(interest_p.payment, 0.0))::numeric AS interest_r,
		(coalesce(firstremsms_c.claim,0.00) - coalesce(firstremsms_p.payment, 0.0))::numeric AS firstremsms_r,
		(coalesce(secondremsms_c.claim,0.00) - coalesce(secondremsms_p.payment, 0.0))::numeric AS secondremsms_r,
		(coalesce(thirdremsms_c.claim,0.00) - coalesce(thirdremsms_p.payment, 0.0))::numeric AS thirdremsms_r,
		(coalesce(fourthremsms_c.claim,0.00) - coalesce(fourthremsms_p.payment, 0.0))::numeric AS fourthremsms_r,
		(coalesce(fifthremsms_c.claim,0.00) - coalesce(fifthremsms_p.payment, 0.0))::numeric AS fifthremsms_r,
		(coalesce(firstrem_c.claim,0.00) - coalesce(firstrem_p.payment, 0.0))::numeric AS firstrem_r,
		(coalesce(secondrem_c.claim,0.00) - coalesce(secondrem_p.payment, 0.0))::numeric AS secondrem_r,
		(coalesce(termalertfee_c.claim,0.00) - coalesce(termalertfee_p.payment, 0.0))::numeric AS termalertfee_r,
		(coalesce(termfee_c.claim,0.00) - coalesce(termfee_p.payment, 0.0))::numeric AS termfee_r,
		(coalesce(suspension_fee_c.claim,0.00) - coalesce(suspension_fee_p.payment, 0.0))::numeric AS suspension_fee_r,
		(coalesce(delay_c.claim,0.00) - coalesce(delay_p.payment, 0.0))::numeric AS delayinterest_r,
		coalesce (pl.payments, 0.00)::numeric AS repaymentslater_r,
		coalesce (pb.payments, 0.00)::numeric AS repaymentsbefore_r,
		la.agreement_signment::text AS agreementsignment_r,
		coalesce(d.name, 'NA') || ', ' ||
		coalesce(NULLIF(la.purpose,''), 'NA') AS comments_r,
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
			payments_before pb ON la.id=pb.laid
		LEFT JOIN
			principal_claim principal_c ON principal_c.laid=la.id
		LEFT JOIN
			principal_payments principal_p ON principal_p.laid=la.id
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
			firstremsms_claim firstrem_c ON firstremsms_c.laid=la.id
		LEFT JOIN
			firstremsms_payments firstrem_p ON firstremsms_p.laid=la.id
		LEFT JOIN
			secondremsms_claim firstrem_c ON secondremsms_c.laid=la.id
		LEFT JOIN
			secondremsms_payments firstrem_p ON secondremsms_p.laid=la.id
		LEFT JOIN
			thirdremsms_claim firstrem_c ON thirdremsms_c.laid=la.id
		LEFT JOIN
			thirdremsms_payments firstrem_p ON thirdremsms_p.laid=la.id
		LEFT JOIN
			fourthremsms_claim firstrem_c ON fourthremsms_c.laid=la.id
		LEFT JOIN
			fourthremsms_payments firstrem_p ON fourthremsms_p.laid=la.id
		LEFT JOIN
			fifthremsms_claim firstrem_c ON fifthremsms_c.laid=la.id
		LEFT JOIN
			fifthremsms_payments firstrem_p ON fifthremsms_p.laid=la.id
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
		LEFT JOIN
			dealer d ON d.id = la.dealer_id

		WHERE la.active=true AND la.internal_collection_date IS NOT NULL AND la.internal_collection_date::date >=$1 AND la.internal_collection_date <=$2
		;

	END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

DROP FUNCTION IF EXISTS get_defaulted_loanapps_byinternaldate(date, date, date);
CREATE OR REPLACE FUNCTION get_defaulted_loanapps_byinternaldate(IN date, IN date, IN date)
  RETURNS TABLE(loanappid integer, loanproduct text, loanproductid integer, refnr text, firstname text, lastname text, score text, office text, incassocompany text, incassocompanyid integer, loanamount numeric, loanperiod integer, activedate date, defaulteddate date, collectiondate date, totaldebt numeric, principal numeric, commissionfee numeric, interest numeric, firstremsms numeric, secondremsms numeric, thirdremsms numeric, fourthremsms numeric, fifthremsms numeric, firstrem numeric, secondrem numeric, termalertfee numeric, termfee numeric, suspensionfee numeric, delayinterest numeric, repaymentslater numeric, guaranteefee numeric, adminfee numeric, agreementsignment text, payoutto text) AS
$BODY$
	BEGIN

		RETURN QUERY
		SELECT dl.loanappid AS r1,
		dl.loanproduct AS r2,
		dl.loanproductid AS r3,
		dl.refnr AS r4,
		dl.firstname AS r5,
		dl.lastname AS r6,
		dl.score AS r7,
		dl.office AS r8,
		dl.incassocompany AS r9,
		dl.incassocompanyid AS r10,
		dl.loanamount AS r11,
		dl.loanperiod AS r12,
		dl.activedate AS r13,
		dl.defaulteddate AS r14,
		dl.collectiondate AS r15,
		dl.totaldebt AS r16,
		dl.principal AS r17,
		dl.commissionfee AS r18,
		dl.interest AS r19,
		dl.firstrem AS r20,
		dl.secondrem AS r21,
		dl.termalertfee AS r22,
		dl.termfee AS r23,
		dl.suspensionfee AS r24,
		dl.delayinterest AS r25,
		dl.repaymentslater AS r26,
		dl.guaranteefee AS r27,
		dl.adminfee AS r28,
		dl.agreementsignment AS r29,
		dl.payoutto AS r30,
		dl.firstremsms AS r31,
		dl.secondremsms AS r32,
		dl.thirdremsms AS r33,
		dl.fourthremsms AS r34,
		dl.fifthremsms AS r35
	FROM get_internal_collection_loanapps_base($1, $2, $3) dl

	WHERE dl.collectiondate IS NOT NULL AND dl.collectiondate::date >=$1 AND dl.collectiondate::date<=$2
	ORDER BY dl.collectiondate ASC, dl.refnr ASC;

	END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

DROP FUNCTION IF EXISTS get_defaulted_loanapps_bytermdate(date, date, date);

CREATE OR REPLACE FUNCTION get_defaulted_loanapps_bytermdate(IN date, IN date, IN date)
  RETURNS TABLE(loanappid integer, loanproduct text, loanproductid integer, refnr text, firstname text, lastname text, score text, office text, incassocompany text, incassocompanyid integer, loanamount numeric, loanperiod integer, activedate date, defaulteddate date, collectiondate date, totaldebt numeric, principal numeric, commissionfee numeric, interest numeric, firstremsms numeric, secondremsms numeric, thirdremsms numeric, fourthremsms numeric, fifthremsms numeric, firstrem numeric, secondrem numeric, termalertfee numeric, termfee numeric, suspensionfee numeric, delayinterest numeric, repaymentslater numeric, guaranteefee numeric, adminfee numeric, agreementsignment text, payoutto text) AS
$BODY$
	BEGIN

		RETURN QUERY
		SELECT dl.loanappid AS r1,
	dl.loanproduct AS r2,
	dl.loanproductid AS r3,
	dl.refnr AS r4,
	dl.firstname AS r5,
	dl.lastname AS r6,
	dl.score AS r7,
	dl.office AS r8,
	dl.incassocompany AS r9,
	dl.incassocompanyid AS r10,
	dl.loanamount AS r11,
	dl.loanperiod AS r12,
	dl.activedate AS r13,
	dl.defaulteddate AS r14,
	dl.collectiondate AS r15,
	dl.totaldebt AS r16,
	dl.principal AS r17,
	dl.commissionfee AS r18,
	dl.interest AS r19,
	dl.firstrem AS r20,
	dl.secondrem AS r21,
	dl.termalertfee AS r22,
	dl.termfee AS r23,
	dl.suspensionfee AS r24,
	dl.delayinterest AS r25,
	dl.repaymentslater AS r26,
	dl.guaranteefee AS r27,
	dl.adminfee AS r28,
	dl.agreementsignment AS r29,
	dl.payoutto AS r30,
	dl.firstremsms AS r31,
	dl.secondremsms AS r32,
	dl.thirdremsms AS r33,
	dl.fourthremsms AS r34,
	dl.fifthremsms AS r35
	FROM get_defaulted_loanapps_base($1, $2, $3) dl

	WHERE dl.defaulteddate::date >=$1 AND dl.defaulteddate::date<=$2
	ORDER BY dl.defaulteddate ASC, dl.refnr ASC
	;

	END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

