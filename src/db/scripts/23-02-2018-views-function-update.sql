DROP FUNCTION IF EXISTS get_claim_totals(date);

create function get_claim_totals(date) returns TABLE(loan_app_id integer, claim numeric, type text)
AS $BODY$
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
	SELECT mt.loan_app_id AS la_id, sum(mt.restructured)::numeric AS amount, 'restructured'::text AS type_res
	FROM installment_table mt
		LEFT JOIN loan_application la ON mt.loan_app_id = la.id
	WHERE mt.principal > 0::numeric AND la.active=true AND la.active_date::date<=$1
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
LANGUAGE plpgsql VOLATILE;


DROP FUNCTION IF EXISTS get_loanapp_export();

CREATE OR REPLACE FUNCTION get_loanapp_export()
	RETURNS TABLE(
		loanappid integer,
		loanproductname text,
		status text,
		refnr text,
		firstname text,
		lastname text,
		submitdate date,
		printdate date,
		activedate date,
		paidoutdate date,
		loanamount numeric,
		restructuredamount numeric,
		loanperiod integer,
		interest numeric,
		commissionfee numeric,
		guaranteefee numeric,
		adminfee numeric,
		bankname text,
		office text,
		birthdate date,
		clientage integer,
		education text,
		workpositionsector text,
		workpositionkind text,
		workposition text,
		workpositionother text,
		workpositionold text,
		workpositioncatold text,
		jobcat text,
		pin text,
		income numeric,
		additionalincome numeric,
		unofficialincome numeric,
		previousloans numeric,
		realestate integer,
		dwellingtype text,
		children integer,
		maritalstatus text,
		gsm text,
		hometown text,
		loanpurpose text,
		mediasource text,
		dealername text,
		dealeragentname text,
		dealeragentcity text,
		dealeragentregion text,
		source text,
		code text,
		remainingprincipalamount numeric,
		remainingrestructuredamount numeric,
		remaininginterest numeric,
		remainingcommissionfee numeric,
		remainingguaranteefee numeric,
		remainingadminfee numeric,
		delayedinterest numeric,
		delayedreminders numeric,
		suspensionfee numeric,
		delayedtermination numeric,
		overpayment numeric,
		totaldebtamount numeric,
		delayeddays integer,

		rejectiontype character varying(255),
		rejectiondate date,
		rejectionusername character varying(255),
		saveasbadreason character varying(255),
		withdrawnreason character varying(255),
		salesman character varying(255),
		submitperson character varying(255),
		collectioncompany character varying,
		salaryratio numeric

	) AS
$BODY$
BEGIN

	RETURN QUERY
	WITH claims AS (
			SELECT claim, type, loan_app_id FROM get_claim_totals('2200-12-31')
	)
		, payments AS (
			SELECT -rpt.sum AS claim_r, rpt.type AS type_r, rp.loan_app_id AS loan_app_id_r FROM repayment_type rpt
				LEFT JOIN repayments rp ON rpt.repayment_id=rp.id
	)
		, totals AS (
		SELECT c.claim AS claim_r, c.type AS type_r, c.loan_app_id AS loan_app_id_r FROM claims c
		UNION ALL
		SELECT p.claim_r, p.type_r, p.loan_app_id_r FROM payments p
	),
			component_sums AS (
				SELECT sum(claim_r) AS sum, type_r, loan_app_id_r FROM totals GROUP BY type_r, loan_app_id_r
		),

			principal_saldo AS (
				SELECT cs.sum AS saldo, cs.loan_app_id_r AS laid FROM component_sums cs WHERE cs.type_r='principal'
		),
			restructured_saldo AS (
				SELECT cs.sum AS saldo, cs.loan_app_id_r AS laid FROM component_sums cs WHERE cs.type_r='restructured'
		),
			interest_saldo AS(
				SELECT cs.sum AS saldo, cs.loan_app_id_r AS laid FROM component_sums cs  WHERE cs.type_r='interest'
		),
			commission_saldo AS (
				SELECT cs.sum AS saldo, cs.loan_app_id_r AS laid FROM component_sums cs  WHERE cs.type_r='commission_fee'
		),
			guarantee_saldo AS (
				SELECT cs.sum AS saldo, cs.loan_app_id_r AS laid FROM component_sums cs  WHERE cs.type_r='guarantee_fee'
		),
			adminfee_saldo AS (
				SELECT cs.sum AS saldo, cs.loan_app_id_r AS laid FROM component_sums cs  WHERE cs.type_r='admin_fee'
		),
			frm_saldo AS (
				SELECT cs.sum AS saldo, cs.loan_app_id_r AS laid FROM component_sums cs  WHERE cs.type_r='1st_reminder_fee'
		),
			srm_saldo AS (
				SELECT cs.sum AS saldo, cs.loan_app_id_r AS laid FROM component_sums cs  WHERE cs.type_r='2nd_reminder_fee'
		),
			termination_saldo AS (
				SELECT cs.sum AS saldo, cs.loan_app_id_r AS laid FROM component_sums cs  WHERE cs.type_r='termination_fee'
		),
			alertfee_saldo AS (
				SELECT cs.sum AS saldo, cs.loan_app_id_r AS laid FROM component_sums cs  WHERE cs.type_r='termination_alert_fee'
		),
			suspension_fee_saldo AS (
				SELECT cs.sum AS saldo, cs.loan_app_id_r AS laid FROM component_sums cs  WHERE cs.type_r='suspension_fee'
		),
			overpayment_saldo AS (
				SELECT cs.sum AS saldo, cs.loan_app_id_r AS laid FROM component_sums cs  WHERE cs.type_r='overpayment' OR cs.type_r='defaulted_overpayment'
		),
			delay_saldo AS (
				SELECT cs.sum AS saldo, cs.loan_app_id_r AS laid FROM component_sums cs  WHERE cs.type_r='delay_interest'
		),
			dealer_agent AS
		(
				SELECT
					la.id AS laid, (u.first_name || ' ' || u.last_name) AS dealer_agent, u.agent_city as agent_city, u.agent_region as agent_region
				FROM
					loan_application la
					LEFT JOIN
					users u ON u.username=la.source
				WHERE
					la.dealer_id IS NOT NULL AND la.source<>'old_crm'
		),
			delayed_days AS (
				SELECT loan_app_id AS laid, date_part('day', now() - min(expected_date))::integer AS delayed_days FROM installment_table WHERE expected_date::date <= now()::date AND not_paid > 0 GROUP by loan_app_id
		),
			rejection AS (
				SELECT
					DISTINCT ON (target_id)
					target_id AS la_id,
					action,
					created::date,
					user_name
				FROM
					audit_trail
				WHERE
					action='application withdrawn by client' OR action='saved as bad application' OR action='reject loan application'
				ORDER BY
					target_id, created ASC
		)
	SELECT
		la.id AS loan_app_id_r,
		lp.name::text AS loanproductname_r,
		la.status::text AS status_r,
		ref_nr::text AS refnr_r,
		cp.first_name::text AS firstname_r,
		cp.last_name::text AS lastname_r,
		la.created::date AS submitdate_r,
		la.signed::date AS printdate_r,
		la.active_date::date AS activedate_r,
		la.paid_out_date::date AS paidoutdate_r,
		la.amount::numeric AS loanamount_r,
		la.restructured_amount::numeric AS restructuredamount_r,
		la.period AS loanperiod_r,
		la.interest_rate::numeric AS interest_r,
		la.admission_fee::numeric AS commissionfee_r,
		la.guarantee_fee::numeric AS guaranteefee_r,
		la.admin_fee::numeric AS adminfee_r,
		la.bank_name::text AS bankname_r,
		la.loan_office::text AS office_r,
		cp.birth_date::date AS birthdate_r,
		coalesce(date_part('year',age(cp.birth_date)), 0)::integer AS age,
		cp.education::text AS education_r,
		cp.position_sector::text AS workpositionsector_r,
		cp.position_kind::text AS workpositionkind_r,
		cp.position::text AS workposition_r,
		cp.position_other::text AS workpositionother_r,
		cp.position_old::text AS workpositionold_r,
		cp.position_cat_old::text AS workpositioncatold_r,
		cp.job_category::text AS jobcat_r,
		cp.pin::text AS pin_r,
		cp.job_income::numeric AS income_r,
		cp.additional_income::numeric AS additionalincome_r,
		cp.unofficial_income::numeric AS unofficialincome_r,
		cp.other_loans_total::numeric AS previousloans_r,
		cp.real_estate AS realestate_r,
		cp.dwelling_type::text AS dwellingtype_r,
		coalesce(cp.underage_children, 0) AS children_r,
		cp.marital_status::text AS maritalstatus_r,
		cp.gsm::text AS gsm_r,
		cp.home_town::text AS hometown_r,
		la.purpose::text AS loanpurpose_r,
		la.mediasource::text AS mediasource_r,
		d.company_name::text AS dealername_r,
		da.dealer_agent::text AS dealeragentname_r,
		da.agent_city::text AS dealeragentcity_r,
		da.agent_region::text AS dealeragentregion_r,
		la.source::text AS source_r,
		la.code::text AS code_r,
		coalesce(ps.saldo,0.0)::numeric AS remainingprincipalamount_r,
		coalesce(rs.saldo,0.0)::numeric AS remainingrestructuredamount_r,
		coalesce(i.saldo,0.0)::numeric AS remaininginterest_r,
		coalesce(cs.saldo,0.0)::numeric AS remainingcommissionfee_r,
		coalesce(gf.saldo,0.0)::numeric AS remainingguaranteefee_r,
		coalesce(af.saldo,0.0)::numeric AS remainingadminfee_r,
		coalesce(ds.saldo,0.0)::numeric AS delayedinterest_r,
		(coalesce(fs.saldo,0.0)+coalesce(ss.saldo,0.0)+coalesce(a.saldo,0.0))::numeric AS delayedreminders_r,
		coalesce(sf.saldo,0.0)::numeric AS suspension_fee_r,
		coalesce(ts.saldo,0.0)::numeric AS delayedtermination_r,
		coalesce(os.saldo,0.0)::numeric AS overpayment_r,

		(coalesce(ps.saldo,0.0) +
		 coalesce(rs.saldo,0.0) +
		 coalesce(i.saldo,0.0) +
		 coalesce(cs.saldo,0.0) +
		 coalesce(gf.saldo,0.0) +
		 coalesce(ds.saldo,0.0) +
		 coalesce(fs.saldo,0.0) +
		 coalesce(ss.saldo,0.0) +
		 coalesce(a.saldo,0.0) +
		 coalesce(sf.saldo,0.0) +
		 coalesce(ts.saldo,0.0) +
		 coalesce(os.saldo,0.0))::numeric AS totaldebtamount_r,
		coalesce(deldays.delayed_days, 0) AS delayed_days_r,

		rej.action AS rej_type,
		rej.created AS rej_date_r,
		rej.user_name AS rej_username_r,
		la.saveasbad_reason AS saveasbad_reason_r,
		la.withdrawn_reason AS withdrawn_reason_r,
		la.salesman AS salesman_r,
		la.submit_person AS submit_person_r,
		ccc.company_name AS collection_company_r,
		la.salary_ratio AS salary_ratio_r


	FROM
		loan_application la
		LEFT JOIN
		client_profile cp ON la.client_id=cp.id
		LEFT JOIN
		loan_products lp ON lp.id=la.loan_product_id
		LEFT JOIN
		dealer d ON d.id=la.dealer_id
		LEFT JOIN
		collection_scheme ccs ON la.collection_scheme_id=ccs.id
		LEFT JOIN
		collection_company ccc ON ccs.collection_company_id=ccc.id
		LEFT JOIN
		principal_saldo ps ON ps.laid=la.id
		LEFT JOIN
		restructured_saldo rs ON rs.laid=la.id
		LEFT JOIN
		interest_saldo i ON i.laid=la.id
		LEFT JOIN
		commission_saldo cs ON cs.laid=la.id
		LEFT JOIN
		guarantee_saldo gf ON gf.laid=la.id
		LEFT JOIN
		adminfee_saldo af ON af.laid=la.id
		LEFT JOIN
		frm_saldo fs ON fs.laid=la.id
		LEFT JOIN
		srm_saldo ss ON ss.laid=la.id
		LEFT JOIN
		termination_saldo ts ON ts.laid=la.id
		LEFT JOIN
		alertfee_saldo a ON a.laid=la.id
		LEFT JOIN
		suspension_fee_saldo sf ON sf.laid=la.id
		LEFT JOIN
		delay_saldo ds ON ds.laid=la.id
		LEFT JOIN
		overpayment_saldo os ON os.laid=la.id
		LEFT JOIN
		dealer_agent da ON da.laid=la.id
		LEFT JOIN
		delayed_days deldays ON deldays.laid = la.id
		LEFT JOIN
		rejection rej ON rej.la_id = la.id

	WHERE la.active=true OR rej.created IS NOT NULL

	;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;



DROP FUNCTION IF EXISTS get_loanapp_export_view();

create function get_loanapp_export_view() returns TABLE(loanappid integer, loanproductname text, status text, refnr text, firstname text, lastname text, submitdate date, activedate date, loanamount numeric, restructuredamount numeric, loanperiod integer, interest numeric, commissionfee numeric, guaranteefee numeric, adminfee numeric, office text, totaldebtamount numeric, rejectiondate date)
AS $BODY$
BEGIN

	RETURN QUERY
	WITH rejection AS (
			SELECT
				DISTINCT ON (target_id)
				target_id AS la_id,
				action,
				created::date,
				user_name
			FROM
				audit_trail
			WHERE
				action='application withdrawn by client' OR action='saved as bad application' OR action='reject loan application'
			ORDER BY
				target_id, created ASC
	)

	SELECT
		la.id AS loan_app_id_r,
		lp.name::text AS loanproductname_r,
		la.status::text AS status_r,
		la.ref_nr::text AS refnr_r,
		cp.first_name::text AS firstname_r,
		cp.last_name::text AS lastname_r,
		la.created::date AS submitdate_r,
		la.active_date::date AS activedate_r,
		la.amount::numeric AS loanamount_r,
		la.restructured_amount::numeric AS restructuredamount_r,
		la.period AS loanperiod_r,
		la.interest_rate::numeric AS interest_r,
		la.admission_fee::numeric AS commissionfee_r,
		la.guarantee_fee::numeric AS guaranteefee_r,
		la.admin_fee::numeric AS adminfee_r,
		la.loan_office::text AS office_r,

		(la.total_sum - la.paid) ::numeric AS totaldebtamount_r,
		rej.created AS rej_date_r
	FROM
		loan_application la
		LEFT JOIN
		client_profile cp ON la.client_id=cp.id
		LEFT JOIN
		loan_products lp ON lp.id=la.loan_product_id
		LEFT JOIN
		rejection rej ON rej.la_id = la.id

	WHERE la.active=true OR rej.created IS NOT NULL

	;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;