DROP FUNCTION IF EXISTS get_claim_totals(IN date);
CREATE OR REPLACE FUNCTION public.get_claim_totals(date)
 RETURNS TABLE(loan_app_id integer, claim numeric, type text)
 LANGUAGE plpgsql
AS $function$

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
	WHERE mt.admin_fee > 0::numeric AND la.active=true AND la.active_date::date<=$1
	GROUP BY mt.loan_app_id

	UNION ALL
	
	SELECT mt.loan_app_id AS la_id, sum(mt.guarantee_fee)::numeric AS amount, 'guarantee_fee'::text AS type_res
	FROM installment_table mt
	LEFT JOIN loan_application la ON mt.loan_app_id = la.id
	WHERE mt.guarantee_fee > 0::numeric AND la.active=true AND la.active_date::date<=$1
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
	GROUP BY di.loan_app_id;

	END;
$function$