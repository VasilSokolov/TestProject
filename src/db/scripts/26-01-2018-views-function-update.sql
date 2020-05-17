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
            la.paid_out_date::date AS avail_date
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
            la.paid_out_date::date AS avail_date
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
            la.paid_out_date::date AS avail_date
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
            la.paid_out_date::date AS avail_date
		FROM installment_table mt
		LEFT JOIN loan_application la ON mt.loan_app_id = la.id
		WHERE mt.admin_fee > 0::numeric AND la.active=true

		UNION ALL
		SELECT
			round(mt.principal::numeric,2) AS amount,
            mt.expected_date::date AS duedate,
            'principal'::text AS type, mt.loan_app_id,
            mt.id AS installment_table_id,
            la.paid_out_date::date AS avail_date
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
	        la.active_date::date AS active_date,
	        la.created::date AS loan_app_created
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
	        la.active_date::date AS active_date,
	        la.created::date AS loan_app_created
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
            la.paid_out_date::date AS avail_date,
            la.status AS la_status,
            la.loan_product_id,
            la.active,
            la.closed AS la_closed,
            la.closed_date::date AS la_closed_date,
            la.active_date::date AS active_date,
            la.created::date AS loan_app_created
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
            la.paid_out_date::date AS avail_date,
            la.status AS la_status,
            la.loan_product_id, la.active,
            la.closed AS la_closed,
            la.closed_date::date AS la_closed_date,
            la.active_date::date AS active_date,
            la.created::date AS loan_app_created
		FROM installment_table mt
		INNER JOIN loan_application la ON mt.loan_app_id = la.id
		WHERE mt.admission_fee > 0::numeric AND la.active=TRUE

		UNION ALL
		SELECT
			mt.principal AS amount,
            mt.expected_date::date AS duedate,
            'principal'::text AS type, mt.loan_app_id,
            mt.id AS installment_table_id,
            la.paid_out_date::date AS avail_date,
            la.status AS la_status, la.loan_product_id,
            la.active, la.closed AS la_closed,
            la.closed_date::date AS la_closed_date,
            la.active_date::date AS active_date,
            la.created::date AS loan_app_created
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
            la.closed_date::date AS la_closed_date,
            la.active_date::date AS active_date,
            la.created::date AS loan_app_created
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
            la.active_date::date AS active_date,
            la.created::date AS loan_app_created
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
	        la.active_date::date AS active_date,
	        la.created::date AS loan_app_created
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
	        la.active_date::date AS active_date,
	        la.created::date AS loan_app_created
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
	        la.active_date::date AS active_date,
	        la.created::date AS loan_app_created
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
	        la.active_date::date AS active_date,
	        la.created::date AS loan_app_created
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
	        la.active_date::date AS active_date,
	        la.created::date AS loan_app_created
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
            la.active_date::date AS active_date,
            la.created::date AS loan_app_created
		FROM installment_table mt
      	INNER JOIN loan_application la ON mt.loan_app_id = la.id
     	WHERE mt.suspended_date IS NOT NULL AND la.active=TRUE
;