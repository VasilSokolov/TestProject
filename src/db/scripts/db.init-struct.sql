--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: add_latest_client_to_loan_application(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION add_latest_client_to_loan_application() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.latest_client := NEW.client_id;
  RETURN NEW;
END
$$;


ALTER FUNCTION public.add_latest_client_to_loan_application() OWNER TO postgres;

--
-- Name: array_median(double precision[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION array_median(double precision[]) RETURNS double precision
    LANGUAGE sql IMMUTABLE
    AS $_$
    SELECT CASE WHEN array_upper($1,1) = 0 THEN null
                ELSE asorted[ceiling(array_upper(asorted,1)/2.0)]::double precision END
       FROM (SELECT ARRAY(SELECT $1[n]
                FROM generate_series(1, array_upper($1, 1)) AS n
               WHERE $1[n] IS NOT NULL
               ORDER BY $1[n]) As asorted) As foo
$_$;


ALTER FUNCTION public.array_median(double precision[]) OWNER TO postgres;

--
-- Name: get_active_loan_claims_payments(date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_active_loan_claims_payments(date) RETURNS TABLE(loan_app_id integer, installment_table_id integer, expected_amount numeric, duedate date, type text, paid_sum numeric, loan_app_status text, loan_app_created date, loan_active_date date, la_closed boolean, income_date date, loan_product_id integer)
    LANGUAGE plpgsql ROWS 10000
    AS $_$
	BEGIN

		RETURN QUERY
		SELECT claims_payments.loan_app_id_res AS loan_app_id_res, claims_payments.installment_table_id_res AS instalment_table_id_res,
		claims_payments.expected_amount_res::numeric AS expected_amount_res, claims_payments.duedate_res::date AS duedate_res,
		claims_payments.type_res AS type_res, claims_payments.paid_sum_res::numeric AS paid_sum_res,
		ls.la_status AS loan_app_status_res, la.created::date AS loan_app_created_res
		, claims_payments.active_date_res::date AS loan_active_date_res, claims_payments.la_closed_res AS la_closed_res, claims_payments.paid_date_res::date AS income_date_res, claims_payments.loan_product_id_res
		FROM
		(
			SELECT
				vla.loan_app_id AS loan_app_id_res, vla.installment_table_id AS installment_table_id_res,
				vla.amount AS expected_amount_res, vla.duedate AS duedate_res, vla.type AS type_res,
				rt.sum AS paid_sum_res, rpt.payment_date::date AS paid_date_res
				, vla.active_date::date AS active_date_res, vla.la_closed AS la_closed_res, rpt.payment_date::date AS income_date_res, vla.loan_product_id AS loan_product_id_res
			FROM
				(SELECT * FROM v_claims_la AS clr WHERE clr.type<> 'delay_interest' AND ( (clr.active_date::date <= $1 AND clr.la_closed=FALSE AND clr.avail_date <= $1) OR (clr.active_date::date <= $1 AND clr.la_closed=true AND clr.la_closed_date::date > $1  AND clr.avail_date <= $1))) vla

			RIGHT JOIN
				repayment_type rt ON rt.ir_id = vla.installment_table_id
			JOIN
				repayments rpt ON rt.repayment_id = rpt.id

			WHERE
				rt.type::text = vla.type AND vla.type<> 'delay_interest' AND ( (vla.active_date::date <= $1 AND vla.la_closed=FALSE AND vla.avail_date <= $1) OR (vla.active_date::date <= $1 AND vla.la_closed=true AND vla.la_closed_date::date > $1  AND vla.avail_date <= $1))

			UNION

			SELECT
				vla2.loan_app_id AS loan_app_id_res, vla2.installment_table_id AS installment_table_id_res,
				vla2.amount AS expected_amount_res, vla2.duedate::date AS duedate_res, vla2.type AS type_res,
				0 AS paid_sum_res, NULL::date AS paid_date_res
				, vla2.active_date::date AS active_date_res, vla2.la_closed AS la_closed_res, NULL::date AS income_date_res, vla2.loan_product_id AS loan_product_id_res
			FROM
				(SELECT * FROM v_claims_la AS clr WHERE clr.type<> 'delay_interest' AND ( (clr.active_date::date <= $1 AND clr.la_closed=FALSE AND clr.avail_date <= $1) OR (clr.active_date::date <= $1 AND clr.la_closed=true AND clr.la_closed_date::date > $1  AND clr.avail_date <= $1))) vla2

			WHERE
				 vla2.type <> 'delay_interest' AND ((vla2.active_date::date <= $1 AND vla2.la_closed=FALSE AND vla2.avail_date <= $1) OR (vla2.active_date::date <= $1 AND vla2.la_closed=true AND vla2.la_closed_date::date > $1 AND vla2.avail_date <= $1))



			UNION

			SELECT
				di.loan_app_id AS loan_app_id_res, di.installment_table_id AS installment_table_id_res,
				di.claim_total AS expected_amount_res, di.claim_date::date AS duedate_res, 'delay_interest' AS type_res,
				di.paid_total AS paid_sum_res, di.last_payment::date AS paid_date_res,
				la.active_date::date AS active_date_res, la.closed AS la_closed_res, NULL::date AS income_date_res, la.loan_product_id AS loan_product_id_res
			FROM
				get_delay_interest('2000-01-01', $1) di
				JOIN loan_application la ON la.id=di.loan_app_id
			WHERE
				(la.active_date::date <= $1 AND la.closed=FALSE) OR (la.active_date::date <= $1 AND la.closed=true AND la.closed_date::date > $1)


			UNION

			SELECT
				di.loan_app_id AS loan_app_id_res, di.installment_table_id AS installment_table_id_res,
				di.claim_total AS expected_amount_res, di.claim_date::date AS duedate_res, 'delay_interest' AS type_res,
				0 AS paid_sum_res, di.last_payment::date AS paid_date_res,
				la.active_date::date AS active_date_res, la.closed AS la_closed_res, NULL::date AS income_date_res, la.loan_product_id AS loan_product_id_res
			FROM
				get_delay_interest('2000-01-01', $1) di
				JOIN loan_application la ON la.id=di.loan_app_id
			WHERE
				(la.active_date::date <= $1 AND la.closed=FALSE) OR (la.active_date::date <= $1 AND la.closed=true AND la.closed_date::date > $1)


		) claims_payments

		JOIN loan_application la ON claims_payments.loan_app_id_res = la.id
		JOIN get_loan_status($1) ls ON claims_payments.loan_app_id_res = ls.loan_app_id;


	END;
$_$;


ALTER FUNCTION public.get_active_loan_claims_payments(date) OWNER TO postgres;

--
-- Name: get_claim_totals(date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_claim_totals(date) RETURNS TABLE(loan_app_id integer, claim numeric, type text)
    LANGUAGE plpgsql
    AS $_$

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
$_$;


ALTER FUNCTION public.get_claim_totals(date) OWNER TO postgres;

--
-- Name: get_claims(date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_claims(date, date) RETURNS TABLE(loan_app_id integer, installment_table_id integer, expected_amount numeric, duedate date, type text, paid_sum numeric, paid_date date, loan_app_status text, loan_app_created date, income_date date, avail_date date, repayment_id integer)
    LANGUAGE plpgsql
    AS $_$

	BEGIN
	RETURN QUERY
	SELECT
		vla2.loan_app_id AS loan_app_id_res,
		vla2.installment_table_id,
		vla2.amount AS expected_amount_res,
		vla2.duedate,
		vla2.type,
		0 AS paid_sum_res,
		NULL::date AS paid_date_res,
		ls.la_status AS loan_app_status_res,
		la.created::date AS loan_app_created_res,
		NULL::date AS income_date_res,
		vla2.avail_date AS avail_date_res,
		0 AS repayment_id_res2
	FROM
		v_claims_la vla2
	LEFT JOIN
		loan_application la ON vla2.loan_app_id = la.id
	LEFT JOIN
		get_loan_status($2) ls ON vla2.loan_app_id = ls.loan_app_id
	WHERE
		vla2.duedate>=$1 AND vla2.duedate<=$2;
	END;
$_$;


ALTER FUNCTION public.get_claims(date, date) OWNER TO postgres;

--
-- Name: get_claims_payments(date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_claims_payments(date) RETURNS TABLE(loan_app_id integer, installment_table_id integer, expected_amount numeric, duedate date, type text, paid_sum numeric, paid_date date, loan_app_status text, loan_app_created date, income_date date, avail_date date, repayment_id integer)
    LANGUAGE plpgsql
    AS $_$
	BEGIN
		RETURN QUERY
		SELECT * FROM get_claims_payments('2008-01-01', $1);
	END;
$_$;


ALTER FUNCTION public.get_claims_payments(date) OWNER TO postgres;

--
-- Name: get_claims_payments(date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_claims_payments(date, date) RETURNS TABLE(loan_app_id integer, installment_table_id integer, expected_amount numeric, duedate date, type text, paid_sum numeric, paid_date date, loan_app_status text, loan_app_created date, income_date date, avail_date date, repayment_id integer)
    LANGUAGE plpgsql
    AS $_$

	BEGIN
	RETURN QUERY


	SELECT claims_payments.loan_app_id_res AS loan_app_id_res, claims_payments.installment_table_id AS installment_table_id_res,
    claims_payments.expected_amount_res::numeric AS expected_amount_res, claims_payments.duedate::date AS duedate_res,
    claims_payments.type::text AS type_res, claims_payments.paid_sum_res::numeric AS paid_sum_res, claims_payments.paid_date_res::date AS paid_date_res,
    ls.la_status AS loan_app_status_res, la.created::date AS loan_app_created_res,
    claims_payments.income_date_res::date AS income_date_res, claims_payments.avail_date_res::date AS avail_date_res, claims_payments.repayment_id_res2 AS repayment_id_res
   FROM (
   		SELECT
	   		payms.loan_app_id AS loan_app_id_res,
	   		payms.installment_table_id,
	   		payms.expected_amount AS expected_amount_res,
	   		payms.duedate,
	   		payms.type AS type,
	   		payms.paid_sum AS paid_sum_res,
	   		payms.paid_date AS paid_date_res,
	   		payms.income_date AS income_date_res,
	   		payms.avail_date AS avail_date_res,
	   		payms.repayment_id AS repayment_id_res2
   		FROM get_payments($1, $2) payms

        UNION
		SELECT
			vla2.loan_app_id AS loan_app_id_res,
			vla2.installment_table_id,
			vla2.amount AS expected_amount_res,
			vla2.duedate,
			vla2.type,
			0 AS paid_sum_res,
			NULL::date AS paid_date_res,
			NULL::date AS income_date_res,
			vla2.avail_date AS avail_date_res,
			0 AS repayment_id_res2
		FROM
			v_claims_la vla2
	) claims_payments
	JOIN loan_application la ON claims_payments.loan_app_id_res = la.id
	JOIN get_loan_status($2) ls ON claims_payments.loan_app_id_res = ls.loan_app_id;
	END;
$_$;


ALTER FUNCTION public.get_claims_payments(date, date) OWNER TO postgres;

--
-- Name: get_component_balance(date, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_component_balance(date, text, integer) RETURNS TABLE(claim numeric, repayment numeric, diff numeric)
    LANGUAGE plpgsql
    AS $_$

	BEGIN

		RETURN QUERY
		SELECT coalesce(paid_out_total.total,0) AS payment_res, coalesce(received_income.total,0) AS repayment_res, (coalesce(paid_out_total.total,0) - coalesce(received_income.total,0)) AS diff_res FROM

		(SELECT SUM(sq.total) AS total FROM
		(
		SELECT MAX(expected_amount) AS total, installment_table_id, 1 AS type
		FROM get_active_loan_claims_payments($1) cp
		WHERE type=$2 AND cp.loan_product_id=$3
		GROUP BY installment_table_id
		) sq) paid_out_total,



		(SELECT SUM(sq.total) AS total FROM
		(
		SELECT SUM(paid_sum) AS total, installment_table_id, 2 as type
		FROM get_active_loan_claims_payments($1) cp
		WHERE type=$2 AND income_date <=$1 AND cp.loan_product_id=$3
		GROUP BY installment_table_id
		)sq) received_income;

	END;
$_$;


ALTER FUNCTION public.get_component_balance(date, text, integer) OWNER TO postgres;

--
-- Name: get_cpi_base(date, date, date, date, date, integer, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_cpi_base(date, date, date, date, date, integer DEFAULT 0, boolean DEFAULT false) RETURNS TABLE(loan_app_id integer, paid double precision, delayed_days integer, created_month integer, created_year integer, cpi_type integer, duedate date)
    LANGUAGE plpgsql
    AS $_$

	DECLARE report_date date;
	DECLARE loan_group_start date;
	DECLARE loan_group_end date;
	DECLARE monitoring_start date;
	DECLARE monitoring_end date;
	DECLARE claim_type int;
	DECLARE until_term BOOLEAN;

	BEGIN

	SELECT $1 INTO report_date;
	SELECT $2 INTO loan_group_start;
	SELECT $3 INTO loan_group_end;
	SELECT $4 INTO monitoring_start;
	SELECT $5 INTO monitoring_end;
	SELECT $6 INTO claim_type;
	SELECT $7 INTO until_term;

	RETURN QUERY
	WITH claims AS (
		SELECT
			la.id AS la_id
			, it.id AS it_id
			, round((it.principal + it.interest + it.admission_fee + it.guarantee_fee + it.admin_fee)::numeric,2) AS claim_r1
			, extract(MONTH FROM it.expected_date)::integer AS due_month
			, extract (YEAR FROM it.expected_date)::integer AS due_year
			, it.expected_date::date AS duedate_r1

		FROM
			installment_table it
		LEFT JOIN
			loan_application la ON it.loan_app_id=la.id
		WHERE
			la.active=true AND la.active_date::date >= loan_group_start AND la.active_date::date<=loan_group_end
			AND it.expected_date::date >= monitoring_start AND it.expected_date::date <= monitoring_end
			AND (CASE WHEN until_term = TRUE AND la.term_date IS NOT NULL THEN it.expected_date::date <= la.term_date::date ELSE it.expected_date IS NOT NULL END)
			AND CASE WHEN claim_type = 1 THEN it.nr > 0 ELSE CASE WHEN claim_type = 2 THEN it.nr = 0 ELSE it.nr >= 0 END END
	)

  , overpayments AS (
      SELECT
        rp.loan_app_id AS overpayment_la_id,
        rpt.sum AS overpayment_la_sum,
        rp.payment_date::date AS overpayment_la_date
      FROM
        claims c
        LEFT JOIN repayments rp ON c.la_id = rp.loan_app_id
        LEFT JOIN repayment_type rpt ON rp.id=rpt.repayment_id
      WHERE rpt.type in ('overpayment', 'defaulted_overpayment') AND rp.payment_date::date <= report_date
  )

  , overpayment_returns AS (
    SELECT
      pm.loan_app_id AS overpayment_return_la_id,
      pm.sum AS overpayment_return_la_sum,
      pm.payment_date::date AS overpayment_return_la_date
    FROM
      claims c
      LEFT JOIN payment pm ON c.la_id = pm.loan_app_id
    WHERE
      pm.type = 'overpayment' and pm.payment_date::date <= report_date
  )
	, payments AS (
		SELECT
			c.la_id AS laid_r1
			, round(rpt.sum::numeric,2) AS paid_r1
			, (rp.payment_date::date - c.duedate_r1::date)::integer AS delayed_days_r1
			, extract(MONTH FROM c.duedate_r1)::integer AS due_month
			, extract (YEAR FROM c.duedate_r1)::integer AS due_year
			, c.duedate_r1::date AS duedate_r1
		FROM claims c
		LEFT JOIN repayment_type rpt ON c.it_id=rpt.ir_id
		LEFT JOIN repayments rp ON rp.id = rpt.repayment_id
	  LEFT JOIN loan_application la ON c.la_id = la.id
		WHERE rpt.type in ('principal', 'commission_fee', 'interest', 'guarantee_fee', 'admin_fee') AND rp.payment_date::date <= report_date
			AND (CASE WHEN until_term = TRUE AND la.term_date IS NOT NULL THEN rp.payment_date::date <= la.term_date::date ELSE rp.payment_date IS NOT NULL END)
			AND (CASE WHEN claim_type = 1 THEN rp.bank != 'dealer' ELSE CASE WHEN claim_type = 2 THEN rp.bank = 'dealer' ELSE rp.id is not null END END)
	)

	SELECT
		cp.laid_r1 AS loan_app_id_res
		, round(cp.paid_r1::numeric,2)::double precision AS paid_res
		, GREATEST(cp.delayed_days_r1, 0) AS delayed_days_res
		, cp.due_month AS created_month_res
		, cp.due_year AS created_year_res
		, 1 AS cpi_type_res
		--, cp.duedate_r1 AS duedate_res
		, LEAST ((date_trunc('MONTH', cp.duedate_r1::date) + INTERVAL '1 MONTH - 1 day')::date, monitoring_end::date)::date AS duedate_res
	FROM
		payments cp


	UNION ALL

	SELECT
		cc.la_id AS loan_app_id_res
		, round(cc.claim_r1::numeric,2)::double precision AS paid_res
		, null AS delayed_days_res
		, cc.due_month AS created_month_res
		, cc.due_year AS created_year_res
		, 2 AS cpi_type_res
		, LEAST ((date_trunc('MONTH', cc.duedate_r1::date) + INTERVAL '1 MONTH - 1 day'), monitoring_end)::date AS duedate_res

	FROM
		claims cc

  UNION

  SELECT
      op.overpayment_la_id AS loan_app_id_res
    , op.overpayment_la_sum AS paid_res
    , NULL AS delayed_days_res
    , NULL AS created_month_res
    , NULL AS created_year_res
    , 3 AS cpi_type_res
    , LEAST ((date_trunc('MONTH', op.overpayment_la_date::date) + INTERVAL '1 MONTH - 1 day'), monitoring_end::date)::date AS duedate_res
  FROM
    overpayments op

  UNION

  SELECT
    opr.overpayment_return_la_id AS loan_app_id_res
    , opr.overpayment_return_la_sum AS paid_res
    , NULL AS delayed_days_res
    , NULL AS created_month_res
    , NULL AS created_year_res
    , 4 AS cpi_type_res
    , LEAST ((date_trunc('MONTH', opr.overpayment_return_la_date::date) + INTERVAL '1 MONTH - 1 day'), monitoring_end::date)::date AS duedate_res
  FROM
    overpayment_returns opr
	;

	END;
$_$;


ALTER FUNCTION public.get_cpi_base(date, date, date, date, date, integer, boolean) OWNER TO postgres;

--
-- Name: get_cpi_basedata(integer, date, date, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_cpi_basedata(integer, date, date, date, date) RETURNS TABLE(loanappid integer, totaldue double precision, totalpaid double precision)
    LANGUAGE plpgsql
    AS $_$
	BEGIN
  	RETURN QUERY
	  	WITH 
		t_claims_due AS (
		SELECT sum(it.principal + it.admission_fee + it.interest) AS total_due, la.id AS loan_app_id FROM installment_table it
		LEFT JOIN loan_application la ON it.loan_app_id = la.id
		WHERE la.active_date::date >=$2 AND la.active_date::date <=$3 AND it.expected_date >=$4 AND it.expected_date::date<=$5
		GROUP BY la.id
		),
		t_payments AS (
		SELECT
		sum(rt.sum) AS paid_total, it.loan_app_id
		FROM repayment_type rt
		LEFT JOIN repayments r ON r.id = rt.repayment_id
		LEFT JOIN installment_table it ON rt.ir_id = it.id
		LEFT JOIN loan_application la ON la.id = it.loan_app_id
		WHERE
		rt.ir_id = it.id
		AND r.payment_date <= (it.expected_date +  ($1 || ' days')::INTERVAL)
		AND (rt.type = 'principal' OR rt.type='commission_fee' OR rt.type='interest')
		AND la.active_date::date >=$2 AND la.active_date::date <=$3
		AND it.expected_date::date >=$4 AND it.expected_date::date<=$5
		GROUP BY it.loan_app_id
		),
		main AS (
		SELECT la.id AS loan_app_id, coalesce(cd.total_due, 0.0)::double precision AS total_due, coalesce(p.paid_total, 0.0)::double precision AS paid
		FROM
		loan_application la
		LEFT JOIN t_claims_due cd ON cd.loan_app_id = la.id
		LEFT JOIN t_payments p ON p.loan_app_id = la.id
		WHERE true AND la.active_date::date >=$2 AND la.active_date::date <=$3
		)

		SELECT * FROM main;


	END;

$_$;


ALTER FUNCTION public.get_cpi_basedata(integer, date, date, date, date) OWNER TO postgres;

--
-- Name: get_cpi_person_base(integer, date, date, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_cpi_person_base(integer, date, date, date, date) RETURNS TABLE(loanappid integer, checkedby character varying, scoredby character varying, totaldue double precision, totalpaid double precision)
    LANGUAGE plpgsql
    AS $_$
	BEGIN
  	RETURN QUERY

	  	WITH t_scoredby AS (
		SELECT at.assignee_ AS username, la.id AS loan_app_id FROM act_hi_taskinst at LEFT JOIN loan_application la ON la.proc_inst_id=at.proc_inst_id_
		WHERE at.task_def_key_ = 'scoreLoanApplication'  AND at.delete_reason_='completed'
		AND la.active_date::date >=$2 AND la.active_date::date <=$3
		),
		t_checkedby AS (
		SELECT at.assignee_ AS username, la.id AS loan_app_id FROM act_hi_taskinst at LEFT JOIN loan_application la ON la.proc_inst_id=at.proc_inst_id_
		WHERE at.task_def_key_ = 'checkLoanApplication'  AND at.delete_reason_='completed'
		AND la.active_date::date >=$2 AND la.active_date::date <=$3
		),
		t_claims_due AS (
		SELECT sum(it.principal + it.admission_fee + it.interest + it.guarantee_fee + it.admin_fee) AS total_due, la.id AS loan_app_id FROM installment_table it
		LEFT JOIN loan_application la ON it.loan_app_id = la.id
		WHERE la.active_date::date >=$2 AND la.active_date::date <=$3 AND it.expected_date >=$4 AND it.expected_date::date<=$5
		GROUP BY la.id
		),
		t_payments AS (
		SELECT
		sum(rt.sum) AS paid_total, it.loan_app_id
		FROM repayment_type rt
		LEFT JOIN repayments r ON r.id = rt.repayment_id
		LEFT JOIN installment_table it ON rt.ir_id = it.id
		LEFT JOIN loan_application la ON la.id = it.loan_app_id
		WHERE
		rt.ir_id = it.id
		AND r.payment_date <= (it.expected_date +  ($1 || ' days')::INTERVAL)
		AND (rt.type = 'principal' OR rt.type='commission_fee' OR rt.type='interest' OR rt.type='guarantee_fee' OR rt.type='admin_fee')
		AND la.active_date::date >=$2 AND la.active_date::date <=$3
		AND it.expected_date::date >=$4 AND it.expected_date::date<=$5
		GROUP BY it.loan_app_id
		),
		main AS (
		SELECT la.id AS loan_app_id, cb.username AS checked_by, sb.username AS scored_by, coalesce(cd.total_due, 0.0)::double precision AS total_due, coalesce(p.paid_total, 0.0)::double precision AS paid
		FROM
		loan_application la
		LEFT JOIN t_scoredby sb ON sb.loan_app_id = la.id
		LEFT JOIN t_checkedby cb ON cb.loan_app_id = la.id
		LEFT JOIN t_claims_due cd ON cd.loan_app_id = la.id
		LEFT JOIN t_payments p ON p.loan_app_id = la.id
		WHERE true
		AND cb.username IS NOT NULL AND sb.username IS NOT NULL
		)

		SELECT * FROM main;


	END;
$_$;


ALTER FUNCTION public.get_cpi_person_base(integer, date, date, date, date) OWNER TO postgres;

--
-- Name: get_defaulted_loanapps(date, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_defaulted_loanapps(date, date, date) RETURNS TABLE(loanappid integer, loanproduct text, loanproductid integer, refnr text, firstname text, lastname text, score text, office text, incassocompany text, incassocompanyid integer, loanamount numeric, loanperiod integer, activedate date, defaulteddate date, collectiondate date, totaldebt numeric, principal numeric, commissionfee numeric, interest numeric, guaranteefee numeric, adminfee numeric, firstrem numeric, secondrem numeric, termalertfee numeric, termfee numeric, suspensionfee numeric, delayinterest numeric, repaymentslater numeric, agreementsignment text, payoutto text)
    LANGUAGE plpgsql
    AS $_$
	BEGIN

		RETURN QUERY
		SELECT * FROM get_defaulted_loanapps_base ($1, $2, $3) dl WHERE dl.defaulteddate>=$1 AND dl.defaulteddate <=$2
		--SELECT * FROM get_indebtcollection_loanapps_base ($1, $2, $3) dl WHERE dl.collectiondate>=$1 AND dl.collectiondate <=$2
		;



	END;
$_$;


ALTER FUNCTION public.get_defaulted_loanapps(date, date, date) OWNER TO postgres;

--
-- Name: get_defaulted_loanapps_base(date, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_defaulted_loanapps_base(date, date, date) RETURNS TABLE(loanappid integer, loanproduct text, loanproductid integer, refnr text, firstname text, lastname text, score text, office text, incassocompany text, incassocompanyid integer, loanamount numeric, loanperiod integer, activedate date, defaulteddate date, internaldate date, collectiondate date, writtenoffdate date, totaldebt numeric, principal numeric, commissionfee numeric, interest numeric, guaranteefee numeric, adminfee numeric, firstrem numeric, secondrem numeric, termalertfee numeric, termfee numeric, suspensionfee numeric, delayinterest numeric, repaymentslater numeric, agreementsignment text, payoutto text)
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.get_defaulted_loanapps_base(date, date, date) OWNER TO postgres;

--
-- Name: get_defaulted_loanapps_bycollectiondate(date, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_defaulted_loanapps_bycollectiondate(date, date, date) RETURNS TABLE(loanappid integer, loanproduct text, loanproductid integer, refnr text, firstname text, lastname text, score text, office text, incassocompany text, incassocompanyid integer, loanamount numeric, loanperiod integer, activedate date, defaulteddate date, collectiondate date, totaldebt numeric, principal numeric, commissionfee numeric, interest numeric, firstrem numeric, secondrem numeric, termalertfee numeric, termfee numeric, suspensionfee numeric, delayinterest numeric, repaymentslater numeric, guaranteefee numeric, adminfee numeric, agreementsignment text, payoutto text)
    LANGUAGE plpgsql
    AS $_$
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
		dl.payoutto AS r30
	FROM get_indebtcollection_loanapps_base($1, $2, $3) dl

	WHERE dl.collectiondate IS NOT NULL AND dl.collectiondate::date >=$1 AND dl.collectiondate::date<=$2
	ORDER BY dl.collectiondate ASC, dl.refnr ASC

	;

	END;
$_$;


ALTER FUNCTION public.get_defaulted_loanapps_bycollectiondate(date, date, date) OWNER TO postgres;

--
-- Name: get_defaulted_loanapps_byinternaldate(date, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_defaulted_loanapps_byinternaldate(date, date, date) RETURNS TABLE(loanappid integer, loanproduct text, loanproductid integer, refnr text, firstname text, lastname text, score text, office text, incassocompany text, incassocompanyid integer, loanamount numeric, loanperiod integer, activedate date, defaulteddate date, collectiondate date, totaldebt numeric, principal numeric, commissionfee numeric, interest numeric, firstrem numeric, secondrem numeric, termalertfee numeric, termfee numeric, suspensionfee numeric, delayinterest numeric, repaymentslater numeric, guaranteefee numeric, adminfee numeric, agreementsignment text, payoutto text)
    LANGUAGE plpgsql
    AS $_$
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
		dl.payoutto AS r30
	FROM get_internal_collection_loanapps_base($1, $2, $3) dl

	WHERE dl.collectiondate IS NOT NULL AND dl.collectiondate::date >=$1 AND dl.collectiondate::date<=$2
	ORDER BY dl.collectiondate ASC, dl.refnr ASC;

	END;
$_$;


ALTER FUNCTION public.get_defaulted_loanapps_byinternaldate(date, date, date) OWNER TO postgres;

--
-- Name: get_defaulted_loanapps_bytermdate(date, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_defaulted_loanapps_bytermdate(date, date, date) RETURNS TABLE(loanappid integer, loanproduct text, loanproductid integer, refnr text, firstname text, lastname text, score text, office text, incassocompany text, incassocompanyid integer, loanamount numeric, loanperiod integer, activedate date, defaulteddate date, collectiondate date, totaldebt numeric, principal numeric, commissionfee numeric, interest numeric, firstrem numeric, secondrem numeric, termalertfee numeric, termfee numeric, suspensionfee numeric, delayinterest numeric, repaymentslater numeric, guaranteefee numeric, adminfee numeric, agreementsignment text, payoutto text)
    LANGUAGE plpgsql
    AS $_$
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
	dl.payoutto AS r30
	FROM get_defaulted_loanapps_base($1, $2, $3) dl

	WHERE dl.defaulteddate::date >=$1 AND dl.defaulteddate::date<=$2
	ORDER BY dl.defaulteddate ASC, dl.refnr ASC
	;

	END;
$_$;


ALTER FUNCTION public.get_defaulted_loanapps_bytermdate(date, date, date) OWNER TO postgres;

--
-- Name: get_defaulted_loanapps_export(date, date, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_defaulted_loanapps_export(date, date, integer) RETURNS TABLE(loanappid integer, firstname text, lastname text, patronymic text, birthdate date, dwellingtype text, companyform text, clientpin text, realaddress text, realtownmunicipality text, realzip text, legaladdress text, legaltownvillage text, legaltownmunicipality text, legalzip text, phonehome text, phonework text, phonegsm text, email text, refnr text, contractprintdate date, incassodate date, terminationdate date, debtamount numeric, referencenumber text, otherdata text, comments text, comments2 text)
    LANGUAGE plpgsql
    AS $_$
	BEGIN

		RETURN QUERY
		SELECT

		dl.loanappid AS loanappid_res,
		cp.first_name ::text AS firstname_res,
		cp.last_name::text AS lastname_res,
		cp.patronymic::text AS patronymic_res,
		cp.birth_date::date AS birthdate_res,
		cp.dwelling_type::text AS dwellingtype_res,
	  	''::text AS companyform_res,
	  	cp.pin::text AS clientpin_res,
	  	(coalesce(cp.home_street,'NA') || ', ' || coalesce(cp.home_house_number,'NA') || ' - ' || coalesce(cp.home_apartment,'NA'))::text::text AS realaddress_res,
	  	cp.home_town::text AS realtownmunicipality_res,
	  	cp.home_zip::text AS realzip_res,
		(coalesce(cp.home_street,'NA') || ', ' || coalesce(cp.home_house_number,'NA') || ' - ' || coalesce(cp.home_apartment,'NA'))::text AS legaladdress_res,
		cp.home_town::text AS legaltownvillage_res,
		cp.home_town::text AS legaltownmunicipality_res,
		cp.home_zip::text AS legalzip_res,
		cp.phone_home::text AS phonehome_res,
		cp.phone_work::text AS phonework_res,
		(coalesce(cp.gsm,'NA'))::text AS phonegsm_res,
		cp.email::text AS email_res,
		la.ref_nr::text AS refnr_res,
		dl.activedate AS contractprintdate_res,
		coalesce(dl.collectiondate,dl.internaldate)::date AS incassodate_res,
		la.term_date::date AS terminationdate_res,
		dl.totaldebt AS debtamount_res,
		la.ref_nr::text AS referencenumber_res,
		coalesce(coalesce(cp.birth_date::date, null)::text,'NA') || ', ' ||
		coalesce(cp.marital_status, 'NA') || ', ' ||
		coalesce(cp.education, 'NA') || ', ' ||
		coalesce(cp.position, 'NA') || ', '||
		coalesce(cp.job_income::text, 'NA') || ', '||
		coalesce(em.name, 'NA') || ', ' ||
		coalesce(em.street, 'NA') || ', ' ||
		coalesce(em.house_number, 'NA') ||', '||
		coalesce(em.town::text, 'NA') AS otherdata_res,
    coalesce(cp.alternative_contact, 'NA') || ', ' ||
    coalesce(cp.alternative_contact_relation, 'NA') || ', ' ||
    coalesce(cp.alternative_contact_phone, 'NA') || ', ' ||
    coalesce(cp.position, 'NA') || ', ' ||
    coalesce(coalesce(cp.work_started::date, null)::text,'NA') || ', ' ||
    coalesce(em.reg_code, 'NA') || ', ' ||
    coalesce(em.name, 'NA') || ', ' ||
    coalesce(em.address, 'NA') || ', ' ||
    coalesce(em.phone, 'NA') AS comments_res,
    coalesce(cp.alternative_contact, 'NA') || ', ' ||
    coalesce(cp.alternative_contact_relation, 'NA') || ', ' ||
    coalesce(cp.alternative_contact_phone, 'NA') || ', ' ||
    coalesce(em.phone, 'NA') AS comments2_res
		FROM get_defaulted_loanapps_base($1, $2, now()::date) dl
		LEFT JOIN loan_application la ON dl.loanappid=la.id
		LEFT JOIN client_profile cp ON cp.id=la.client_id
		LEFT JOIN employer em ON em.id=employer_id
		LEFT JOIN
			collection_scheme cs ON la.collection_scheme_id=cs.id
		LEFT JOIN
			collection_company cc ON cs.collection_company_id=cc.id

		WHERE cc.id=$3 AND coalesce(dl.collectiondate,dl.internaldate)::date >= $1 AND coalesce(dl.collectiondate,dl.internaldate)::date <= $2

		ORDER BY coalesce(dl.collectiondate,dl.internaldate) ASC, la.ref_nr ASC;




	END;
$_$;


ALTER FUNCTION public.get_defaulted_loanapps_export(date, date, integer) OWNER TO postgres;

--
-- Name: get_delay_interest(date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_delay_interest(date, date) RETURNS TABLE(claim_date date, installment_table_id integer, loan_app_id integer, claim_total numeric, paid_total numeric, claim_earlier numeric, paid_earlier numeric, claim_period numeric, received_during_period numeric, unpaid_total numeric, unpaid_period_claim numeric, last_payment date)
    LANGUAGE plpgsql ROWS 10000
    AS $_$
	BEGIN

		RETURN QUERY
		SELECT * FROM get_delay_interest($1, $2, $2);

  END;
$_$;


ALTER FUNCTION public.get_delay_interest(date, date) OWNER TO postgres;

--
-- Name: get_delay_interest(date, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_delay_interest(date, date, date) RETURNS TABLE(claim_date date, installment_table_id integer, loan_app_id integer, claim_total numeric, paid_total numeric, claim_earlier numeric, paid_earlier numeric, claim_period numeric, received_during_period numeric, unpaid_total numeric, unpaid_period_claim numeric, last_payment date)
    LANGUAGE plpgsql
    AS $_$
	BEGIN

		RETURN QUERY

			SELECT
			delay_claim.calculated_date_res2 AS claim_date_res1,
			delay_claim.installment_res2 AS installment_res1,
			delay_claim.loan_app_id_res2 AS loan_app_id_res1,
			coalesce(round(delay_claim.claim_res2::numeric,2),0.00)::numeric AS claim_total_res1,
			coalesce(round(delay_payment.total_paid_res2::numeric,2),0.00)::numeric AS paid_total_res1,
			coalesce(round(claim_earlier_rel.claim_res2::numeric,2),0.00)::numeric AS claim_earlier_res1,
			coalesce(round(paid_earlier_rel.total_paid_res2::numeric,2),0.00)::numeric AS paid_earlier_res1,
			(coalesce(round(delay_claim.claim_res2::numeric,2),0.00) - coalesce(round(claim_earlier_rel.claim_res2::numeric,2),0.00))::numeric AS claim_period_res1,
			(coalesce(round(delay_payment.total_paid_res2::numeric,2),0.00) - coalesce(round(paid_earlier_rel.total_paid_res2::numeric,2),0.00))::numeric AS received_during_period_res1,
			(coalesce(round(delay_claim.claim_res2::numeric,2),0.00) - coalesce(round(delay_payment.total_paid_res2::numeric,2),0.00))::numeric AS unpaid_total_res1,

			round(LEAST (
				coalesce(delay_claim.claim_res2,0.00) -- total claim
				- coalesce(delay_payment.total_paid_res2,0.00) -- total paid
				, (coalesce(delay_claim.claim_res2,0.00) - coalesce(claim_earlier_rel.claim_res2,0.00)) -- claim period
			)::numeric,2)::numeric AS unpaid_period_claim_res1,
			delay_payment.payment_date_res2::date AS delay_payment_res1


			FROM
			(
			SELECT max(dint.calculated_date)::date AS calculated_date_res2, dint.installment_id AS installment_res2, dint.loan_app_id AS loan_app_id_res2, sum(dint.sum) AS claim_res2 FROM
			(
			SELECT * FROM delay_interest di
			WHERE calculated_date::date <= $2 AND calculated_date::date <= $3
			) dint
			GROUP BY dint.installment_id, dint.loan_app_id ) delay_claim

			LEFT JOIN
			(
			SELECT max(dint.calculated_date)::date AS calculated_date_res2, dint.installment_id AS installment_res2, dint.loan_app_id AS loan_app_id_res2, sum(dint.sum) AS claim_res2 FROM
			(
			SELECT * FROM delay_interest di
			WHERE calculated_date::date < $1  AND calculated_date::date <= $3
			) dint
			GROUP BY dint.installment_id, dint.loan_app_id ) AS claim_earlier_rel

			ON delay_claim.installment_res2=claim_earlier_rel.installment_res2

			LEFT JOIN

			(
			SELECT SUM(rpt.sum) AS total_paid_res2, rpt.ir_id AS installment_res2, max(rp.payment_date) AS payment_date_res2 FROM repayment_type AS rpt
			LEFT JOIN repayments AS rp ON rpt.repayment_id = rp.id
			WHERE rpt.type='delay_interest'
			--AND rp.payment_date::date <= $2
			AND rp.payment_date::date <= $3
			GROUP BY rpt.ir_id
			) AS delay_payment

			ON delay_claim.installment_res2=delay_payment.installment_res2


			LEFT JOIN
			(

			SELECT SUM(rpt.sum) AS total_paid_res2, rpt.ir_id AS installment_res2 FROM repayment_type AS rpt
			LEFT JOIN repayments AS rp ON rpt.repayment_id = rp.id
			WHERE rpt.type='delay_interest' AND rp.payment_date::date < $1 AND rp.payment_date::date <= $3
			GROUP BY rpt.ir_id
			) AS paid_earlier_rel
			ON paid_earlier_rel.installment_res2=delay_payment.installment_res2

			;

	END;
$_$;


ALTER FUNCTION public.get_delay_interest(date, date, date) OWNER TO postgres;

--
-- Name: get_delay_interest_consolidated(date, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_delay_interest_consolidated(date, date, date) RETURNS TABLE(claim_date date, installment_table_id integer, loan_app_id integer, claim_period numeric, claim_earlier numeric, paid_total numeric, paid_period numeric, last_payment date)
    LANGUAGE plpgsql
    AS $_$
	BEGIN

		RETURN QUERY

			WITH claims_period AS (
				SELECT max(di.calculated_date) AS claim_date_res2, sum(di.sum) AS delay_sum, di.installment_id AS installment_id, di.loan_app_id AS la_id FROM delay_interest di WHERE di.calculated_date::date >= $1 AND di.calculated_date::date <= $2 AND di.calculated_date::date <= $3 GROUP BY di.installment_id, di.loan_app_id
			),
			claims_before AS (
				SELECT sum(di.sum) AS delay_sum, di.installment_id AS installment_id FROM delay_interest di WHERE di.calculated_date::date < $1 GROUP BY di.installment_id
			),
			payments_total AS (
				SELECT sum(rpt.sum) AS total, rpt.ir_id AS installment_id, MAX(rp.payment_date) AS last_payment_res2
				FROM repayment_type rpt
				LEFT JOIN repayments rp ON rpt.repayment_id = rp.id
				WHERE rp.payment_date::date <=$3 AND rpt.type='delay_interest' GROUP BY rpt.ir_id
			),
			total_output AS (
				SELECT
				cp.claim_date_res2::date AS claim_date_res, cp.installment_id, cp.la_id, cp.delay_sum AS delay_period, coalesce(cb.delay_sum, 0) AS delay_before, coalesce(pt.total, 0) AS payment_total,
				GREATEST (0, LEAST(cp.delay_sum, coalesce(pt.total, 0) -  coalesce(cb.delay_sum, 0))) AS payment_period,
				pt.last_payment_res2::date AS last_payment_res

				FROM
				claims_period cp
				LEFT JOIN claims_before cb ON cp.installment_id = cb.installment_id
				LEFT JOIN payments_total pt ON pt.installment_id=cp.installment_id
			)
			--SELECT sum(paid_period) FROM total_output
			SELECT * FROM total_output;

	END;
$_$;


ALTER FUNCTION public.get_delay_interest_consolidated(date, date, date) OWNER TO postgres;

--
-- Name: get_delay_interest_splitted(date, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_delay_interest_splitted(date, date, date) RETURNS TABLE(claim_date date, installment_table_id integer, loan_app_id integer, claim_total numeric, paid_total numeric, claim_earlier numeric, paid_earlier numeric, claim_period numeric, received_during_period numeric, unpaid_total numeric, unpaid_period_claim numeric, last_payment date)
    LANGUAGE plpgsql
    AS $_$
	BEGIN

		RETURN QUERY

			SELECT
			delay_claim.calculated_date_res2 AS claim_date_res1,
			delay_claim.installment_res2 AS installment_res1,
			delay_claim.loan_app_id_res2 AS loan_app_id_res1,
			coalesce(round(delay_claim.claim_res2::numeric,2),0.00)::numeric AS claim_total_res1,
			coalesce(round(delay_payment.total_paid_res2::numeric,2),0.00)::numeric AS paid_total_res1,
			coalesce(round(claim_earlier_rel.claim_res2::numeric,2),0.00)::numeric AS claim_earlier_res1,
			coalesce(round(paid_earlier_rel.total_paid_res2::numeric,2),0.00)::numeric AS paid_earlier_res1,
			(coalesce(round(delay_claim.claim_res2::numeric,2),0.00) - coalesce(round(claim_earlier_rel.claim_res2::numeric,2),0.00))::numeric AS claim_period_res1,
			(coalesce(round(delay_payment.total_paid_res2::numeric,2),0.00) - coalesce(round(paid_earlier_rel.total_paid_res2::numeric,2),0.00))::numeric AS received_during_period_res1,
			(coalesce(round(delay_claim.claim_res2::numeric,2),0.00) - coalesce(round(delay_payment.total_paid_res2::numeric,2),0.00))::numeric AS unpaid_total_res1,

			round(LEAST (
				coalesce(delay_claim.claim_res2,0.00) -- total claim
				- coalesce(delay_payment.total_paid_res2,0.00) -- total paid
				, (coalesce(delay_claim.claim_res2,0.00) - coalesce(claim_earlier_rel.claim_res2,0.00)) -- claim period
			)::numeric,2)::numeric AS unpaid_period_claim_res1,
			delay_payment.payment_date_res2::date AS delay_payment_res1


			FROM
			(
			SELECT max(dint.calculated_date)::date AS calculated_date_res2, dint.installment_id AS installment_res2, dint.loan_app_id AS loan_app_id_res2, sum(dint.sum) AS claim_res2 FROM
			(
			SELECT * FROM delay_interest di
			WHERE calculated_date::date <= $2 AND calculated_date::date <= $3
			) dint
			GROUP BY dint.installment_id, dint.loan_app_id ) delay_claim

			LEFT JOIN
			(
			SELECT max(dint.calculated_date)::date AS calculated_date_res2, dint.installment_id AS installment_res2, dint.loan_app_id AS loan_app_id_res2, sum(dint.sum) AS claim_res2 FROM
			(
			SELECT * FROM delay_interest di
			WHERE calculated_date::date < $1  AND calculated_date::date <= $3
			) dint
			GROUP BY dint.installment_id, dint.loan_app_id ) AS claim_earlier_rel

			ON delay_claim.installment_res2=claim_earlier_rel.installment_res2

			LEFT JOIN

			(
			SELECT SUM(rpt.sum) AS total_paid_res2, rpt.ir_id AS installment_res2, max(rp.payment_date) AS payment_date_res2 FROM repayment_type AS rpt
			LEFT JOIN repayments AS rp ON rpt.repayment_id = rp.id
			WHERE rpt.type='delay_interest' AND rp.payment_date::date <= $2 AND rp.payment_date::date <= $3
			GROUP BY rpt.ir_id
			) AS delay_payment

			ON delay_claim.installment_res2=delay_payment.installment_res2


			LEFT JOIN
			(

			SELECT SUM(rpt.sum) AS total_paid_res2, rpt.ir_id AS installment_res2 FROM repayment_type AS rpt
			LEFT JOIN repayments AS rp ON rpt.repayment_id = rp.id
			WHERE rpt.type='delay_interest' AND rp.payment_date::date < $1 AND rp.payment_date::date <= $3
			GROUP BY rpt.ir_id
			) AS paid_earlier_rel
			ON paid_earlier_rel.installment_res2=delay_payment.installment_res2

			;

	END;
$_$;


ALTER FUNCTION public.get_delay_interest_splitted(date, date, date) OWNER TO postgres;

--
-- Name: get_delayed_days(date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_delayed_days(date) RETURNS TABLE(loan_app_id integer, delayed_days integer)
    LANGUAGE plpgsql
    AS $_$

	BEGIN
	RETURN QUERY

	WITH payments AS (
		SELECT
			rpt.ir_id AS installment_table_id_res,
			round(sum(rpt.sum::numeric), 2) AS paid_sum_res,
			max(rp.payment_date)::date AS income_date_res
		FROM repayment_type rpt
		LEFT JOIN repayments rp ON  rp.id=rpt.repayment_id
		WHERE rp.payment_date::date <= $1 AND rpt.type = 'principal'
		GROUP BY rpt.ir_id
	)

	SELECT it.loan_app_id AS loan_app_id_r, ($1::date - min(it.expected_date::date)) AS maxdelay_r
	FROM installment_table it
	LEFT JOIN payments p ON it.id = p.installment_table_id_res
	WHERE it.nr > 0 and (it.principal > p.paid_sum_res OR p.paid_sum_res IS NULL)
	GROUP BY it.loan_app_id;

	END;
$_$;


ALTER FUNCTION public.get_delayed_days(date) OWNER TO postgres;

--
-- Name: get_dpi_base_collectgroup(date, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_dpi_base_collectgroup(date, date, date) RETURNS TABLE(loanappid integer, loanproduct text, loanproductid integer, refnr text, firstname text, lastname text, office text, incassocompany text, loanperiod integer, activedate date, defaulteddate date, collectiondate date, termdebt numeric, collectdebt numeric, paymentdate date, paymentsum numeric, sincedefault integer, sincecollection integer, collectioncompanyid integer, availabledefaulted integer, availablecollected integer)
    LANGUAGE plpgsql
    AS $_$
	BEGIN
  	RETURN QUERY
	SELECT
	dl.loanappid AS r_loanappid,
	dl.loanproduct AS r_loanproduct,
	dl.loanproductid AS r_loanproductid,
	dl.refnr AS r_refnr,
	dl.firstname AS r_firstname,
	dl.lastname AS r_lastname,
	dl.office AS r_office,
	dl.incassocompany AS r_incassocompany,
	dl.loanperiod AS r_loanperiod,
	dl.activedate::date AS r_activedate,
	dl.defaulteddate::date AS r_defaulteddate,
	dl.collectiondate::date AS r_collectiondate,
	coalesce(dl.totaldebt,0::numeric) AS r_termdebt,
	coalesce(clb.totaldebt,0::numeric) AS r_collectdebt,
	rp.payment_date::date AS r_paymentdate,
	coalesce(rp.sum, 0::numeric) AS r_paymentsum,

	DATE_PART('day', rp.payment_date - dl.defaulteddate)::integer AS since_default,
	DATE_PART('day', rp.payment_date - dl.collectiondate)::integer AS since_collection,
	cs.collection_company_id AS r_collectioncompanyid,
	coalesce(($3 - dl.defaulteddate), -1)::integer AS available_defaulted,
	coalesce(($3 - dl.collectiondate), -1)::integer AS r_availablecollected

	FROM get_defaulted_loanapps_base('2008-01-01', '2200-01-01', $3) dl
	LEFT JOIN get_indebtcollection_loanapps_base('2008-01-01', '2200-01-01', $3) clb ON clb.loanappid = dl.loanappid
	LEFT JOIN repayments rp ON dl.loanappid=rp.loan_app_id
	LEFT JOIN loan_application la ON la.id=dl.loanappid
	LEFT JOIN collection_scheme cs ON la.collection_scheme_id=cs.id
	WHERE dl.collectiondate::date >=$1 AND dl.collectiondate::date <=$2;
	END;
$_$;


ALTER FUNCTION public.get_dpi_base_collectgroup(date, date, date) OWNER TO postgres;

--
-- Name: get_dpi_base_defaultgroup(date, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_dpi_base_defaultgroup(date, date, date) RETURNS TABLE(loanappid integer, loanproduct text, loanproductid integer, refnr text, firstname text, lastname text, office text, incassocompany text, loanperiod integer, activedate date, defaulteddate date, collectiondate date, termdebt numeric, collectdebt numeric, paymentdate date, paymentsum numeric, sincedefault integer, sincecollection integer, collectioncompanyid integer, availabledefaulted integer, availablecollected integer)
    LANGUAGE plpgsql
    AS $_$
	BEGIN
  	RETURN QUERY
	SELECT
	dl.loanappid AS r_loanappid,
	dl.loanproduct AS r_loanproduct,
	dl.loanproductid AS r_loanproductid,
	dl.refnr AS r_refnr,
	dl.firstname AS r_firstname,
	dl.lastname AS r_lastname,
	dl.office AS r_office,
	dl.incassocompany AS r_incassocompany,
	dl.loanperiod AS r_loanperiod,
	dl.activedate::date AS r_activedate,
	dl.defaulteddate::date AS r_defaulteddate,
	dl.collectiondate::date AS r_collectiondate,
	dl.totaldebt AS r_termdebt,
	clb.totaldebt AS r_collectdebt,
	rp.payment_date::date AS r_paymentdate,

	coalesce(rp.sum, 0::numeric) AS r_paymentsum,
	DATE_PART('day', rp.payment_date - dl.defaulteddate)::integer AS since_default,
	DATE_PART('day', rp.payment_date - dl.collectiondate)::integer AS since_collection,
	cs.collection_company_id AS r_collectioncompanyid,
	coalesce(($3 - dl.defaulteddate), -1)::integer AS available_defaulted,
	coalesce(($3 - dl.collectiondate), -1)::integer AS r_availablecollected

	FROM get_defaulted_loanapps_base('2008-01-01', '2200-01-01', $3) dl
	LEFT JOIN get_indebtcollection_loanapps_base('2008-01-01', '2200-01-01', $3) clb ON clb.loanappid = dl.loanappid
	LEFT JOIN repayments rp ON dl.loanappid=rp.loan_app_id
	LEFT JOIN loan_application la ON la.id=dl.loanappid
	LEFT JOIN collection_scheme cs ON la.collection_scheme_id=cs.id
	WHERE
	--(rp.payment_date >= dl.defaulteddate OR rp.payment_date IS NULL) AND
	dl.defaulteddate >= $1 AND dl.defaulteddate <=$2;
	END;
$_$;


ALTER FUNCTION public.get_dpi_base_defaultgroup(date, date, date) OWNER TO postgres;

--
-- Name: get_dpi_base_internalgroup(date, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_dpi_base_internalgroup(date, date, date) RETURNS TABLE(loanappid integer, loanproduct text, loanproductid integer, refnr text, firstname text, lastname text, office text, incassocompany text, loanperiod integer, activedate date, defaulteddate date, collectiondate date, termdebt numeric, collectdebt numeric, paymentdate date, paymentsum numeric, sincedefault integer, sincecollection integer, collectioncompanyid integer, availabledefaulted integer, availablecollected integer)
    LANGUAGE plpgsql
    AS $_$
	BEGIN
  	RETURN QUERY
	SELECT
	dl.loanappid AS r_loanappid,
	dl.loanproduct AS r_loanproduct,
	dl.loanproductid AS r_loanproductid,
	dl.refnr AS r_refnr,
	dl.firstname AS r_firstname,
	dl.lastname AS r_lastname,
	dl.office AS r_office,
	dl.incassocompany AS r_incassocompany,
	dl.loanperiod AS r_loanperiod,
	dl.activedate::date AS r_activedate,
	dl.defaulteddate::date AS r_defaulteddate,
	dl.collectiondate::date AS r_collectiondate,
	coalesce(dl.totaldebt,0::numeric) AS r_termdebt,
	coalesce(clb.totaldebt,0::numeric) AS r_collectdebt,
	rp.payment_date::date AS r_paymentdate,
	coalesce(rp.sum, 0::numeric) AS r_paymentsum,

	DATE_PART('day', rp.payment_date - dl.defaulteddate)::integer AS since_default,
	DATE_PART('day', rp.payment_date - dl.collectiondate)::integer AS since_collection,
	cs.collection_company_id AS r_collectioncompanyid,
	coalesce(($3 - dl.defaulteddate), -1)::integer AS available_defaulted,
	coalesce(($3 - dl.collectiondate), -1)::integer AS r_availablecollected

	FROM get_defaulted_loanapps_base('2008-01-01', '2200-01-01', $3) dl
	LEFT JOIN get_internal_collection_loanapps_base('2008-01-01', '2200-01-01', $3) clb ON clb.loanappid = dl.loanappid
	LEFT JOIN repayments rp ON dl.loanappid=rp.loan_app_id
	LEFT JOIN loan_application la ON la.id=dl.loanappid
	LEFT JOIN collection_scheme cs ON la.collection_scheme_id=cs.id
	WHERE dl.collectiondate::date >=$1 AND dl.collectiondate::date <=$2;
	END;
$_$;


ALTER FUNCTION public.get_dpi_base_internalgroup(date, date, date) OWNER TO postgres;

--
-- Name: get_dpi_base_loangroup(date, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_dpi_base_loangroup(date, date, date) RETURNS TABLE(loanappid integer, loanproduct text, loanproductid integer, refnr text, firstname text, lastname text, office text, incassocompany text, loanperiod integer, activedate date, defaulteddate date, collectiondate date, termdebt numeric, collectdebt numeric, paymentdate date, paymentsum numeric, sincedefault integer, sincecollection integer, collectioncompanyid integer, availabledefaulted integer, availablecollected integer)
    LANGUAGE plpgsql
    AS $_$
	BEGIN
  	RETURN QUERY
	SELECT
	dl.loanappid AS r_loanappid,
	dl.loanproduct AS r_loanproduct,
	dl.loanproductid AS r_loanproductid,
	dl.refnr AS r_refnr,
	dl.firstname AS r_firstname,
	dl.lastname AS r_lastname,
	dl.office AS r_office,
	dl.incassocompany AS r_incassocompany,
	dl.loanperiod AS r_loanperiod,
	dl.activedate::date AS r_activedate,
	dl.defaulteddate::date AS r_defaulteddate,
	dl.collectiondate::date AS r_collectiondate,
	dl.totaldebt AS r_termdebt,
	clb.totaldebt AS r_collectdebt,
	rp.payment_date::date AS r_paymentdate,
	rp.sum AS r_paymentsum,

	DATE_PART('day', rp.payment_date - dl.defaulteddate)::integer AS since_default,
	DATE_PART('day', rp.payment_date - dl.collectiondate)::integer AS since_collection,
	cs.collection_company_id AS r_collectioncompanyid,
	coalesce(($3 - dl.defaulteddate), -1)::integer AS available_defaulted,
	coalesce(($3 - dl.collectiondate), -1)::integer AS r_availablecollected

	FROM get_defaulted_loanapps_base('2008-01-01', '2200-01-01', $3) dl
	LEFT JOIN get_indebtcollection_loanapps_base('2008-01-01', '2200-01-01', $3) clb ON clb.loanappid = dl.loanappid
	LEFT JOIN repayments rp ON dl.loanappid=rp.loan_app_id
	LEFT JOIN loan_application la ON la.id=dl.loanappid
	LEFT JOIN collection_scheme cs ON la.collection_scheme_id=cs.id
	WHERE la.active_date::date >= $1 AND la.active_date::date <= $2;
	END;
$_$;


ALTER FUNCTION public.get_dpi_base_loangroup(date, date, date) OWNER TO postgres;

--
-- Name: get_dpi_base_writtenoff(date, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_dpi_base_writtenoff(date, date, date) RETURNS TABLE(loanappid integer, loanproduct text, loanproductid integer, refnr text, firstname text, lastname text, office text, incassocompany text, loanperiod integer, activedate date, defaulteddate date, collectiondate date, writtenoffdate date, termdebt numeric, collectdebt numeric, paymentdate date, paymentsum numeric, sincedefault integer, sincecollection integer, sincewrittenoff integer, collectioncompanyid integer, availabledefaulted integer, availablecollected integer)
    LANGUAGE plpgsql
    AS $_$
	BEGIN
  	RETURN QUERY
	SELECT
	dl.loanappid AS r_loanappid,
	dl.loanproduct AS r_loanproduct,
	dl.loanproductid AS r_loanproductid,
	dl.refnr AS r_refnr,
	dl.firstname AS r_firstname,
	dl.lastname AS r_lastname,
	dl.office AS r_office,
	dl.incassocompany AS r_incassocompany,
	dl.loanperiod AS r_loanperiod,
	dl.activedate::date AS r_activedate,
	dl.defaulteddate::date AS r_defaulteddate,
	dl.collectiondate::date AS r_collectiondate,
	dl.writtenoffdate::date AS r_writtenoffdate,
	coalesce(dl.totaldebt,0::numeric) AS r_termdebt,
	coalesce(clb.totaldebt,0::numeric) AS r_collectdebt,
	rp.payment_date::date AS r_paymentdate,
	coalesce(rp.sum, 0::numeric) AS r_paymentsum,

	DATE_PART('day', rp.payment_date - dl.defaulteddate)::integer AS since_default,
	DATE_PART('day', rp.payment_date - dl.collectiondate)::integer AS since_collection,
	DATE_PART('day', rp.payment_date - dl.writtenoffdate)::integer AS since_writtenoff,
	cs.collection_company_id AS r_collectioncompanyid,
	coalesce(($3 - dl.defaulteddate), -1)::integer AS available_defaulted,
	coalesce(($3 - dl.collectiondate), -1)::integer AS r_availablecollected

	FROM get_defaulted_loanapps_base('2008-01-01', '2200-01-01', $3) dl
	LEFT JOIN get_indebtcollection_loanapps_base('2008-01-01', '2200-01-01', $3) clb ON clb.loanappid = dl.loanappid
	LEFT JOIN repayments rp ON dl.loanappid=rp.loan_app_id
	LEFT JOIN loan_application la ON la.id=dl.loanappid
	LEFT JOIN collection_scheme cs ON la.collection_scheme_id=cs.id
	WHERE dl.writtenoffdate::date >=$1 AND dl.writtenoffdate::date <=$2;
	END;
$_$;


ALTER FUNCTION public.get_dpi_base_writtenoff(date, date, date) OWNER TO postgres;

--
-- Name: get_finance_output(date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_finance_output(date) RETURNS TABLE(loan_app_id integer, installment_table_id integer, duedate date, claim double precision, paid double precision, type text, last_payment date)
    LANGUAGE plpgsql
    AS $_$

	BEGIN
	RETURN QUERY 

	
	SELECT vc.loan_app_id AS loan_app_idd_res, vc.installment_table_id AS installment_table_id_res, vc.duedate::date AS duedate_res, 
	    COALESCE(max(vc.expected_amount), 0.0:: numeric)::double precision AS claim_res, 
	    COALESCE(sum(vc.paid_sum), 0.0:: numeric):: double precision AS paid_res, vc.type AS type_res, 
	    max(vc.paid_date)::date AS last_payment_res
	   FROM get_claims_payments($1) vc 
	   WHERE vc.loan_app_created::date <=$1 AND vc.avail_date <= $1 AND vc.type <>'delay_interest'
	  GROUP BY vc.installment_table_id, vc.loan_app_id, vc.duedate, vc.type

	  UNION ALL
	  
	  SELECT vc.loan_app_id AS loan_app_idd_res, vc.installment_table_id AS installment_table_id_res, max(vc.claim_date)::date AS duedate_res, 
	    COALESCE(max(vc.claim_total), 0.0:: numeric)::double precision AS claim_res, 
	    COALESCE(sum(vc.paid_total), 0.0:: numeric):: double precision AS paid_res, 'delay_interest'::text AS type_res, 
	    max(vc.last_payment)::date AS last_payment_res
	   FROM get_delay_interest('2000-01-01', $1) vc
	   LEFT JOIN loan_application la ON vc.loan_app_id=la.id
	   WHERE la.paid_out_date::date <=$1 AND vc.claim_date <= $1
	  GROUP BY vc.installment_table_id, vc.loan_app_id
	  ;
	
	END;
$_$;


ALTER FUNCTION public.get_finance_output(date) OWNER TO postgres;

--
-- Name: get_finance_output(date, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_finance_output(date, date, date) RETURNS TABLE(loan_app_id integer, installment_table_id integer, duedate date, claim numeric, paid numeric, type text, last_payment date, unpaid numeric)
    LANGUAGE plpgsql
    AS $_$

	BEGIN
	RETURN QUERY


	WITH
		payments AS (
		SELECT
			rpt.ir_id AS installment_table_id_res,
			rpt.type AS type_res,
			round(sum(rpt.sum)::numeric,2) AS paid_sum_res,
			max(rp.payment_date)::date AS income_date_res
		FROM
			repayment_type rpt
		LEFT JOIN
			repayments rp ON  rp.id=rpt.repayment_id
		WHERE
			rp.payment_date::date <=$3 AND rpt.type<>'overpayment' AND rpt.type<>'defaulted_overpayment' AND rpt.type<>'delay_interest'
		GROUP BY
			rpt.ir_id, rpt.type
	),
		claims AS (
			SELECT  round(vif.amount::numeric,2) AS amount_res, vif.duedate AS duedate_res, vif.type AS type_res, vif.loan_app_id AS loan_app_id_res, vif.installment_table_id AS installment_table_id_res
			FROM v_installment_flat_paidout vif
			WHERE vif.duedate::date>=$1 AND vif.duedate::date<=$2 AND vif.avail_date::date<=$3
		)

		SELECT
		if.loan_app_id_res AS loan_app_id_r1,
		if.installment_table_id_res AS installment_table_id_r1,
		if.duedate_res AS duedate_r1,
		coalesce(if.amount_res,0.00)::numeric AS total_claim_r1,
		coalesce(p.paid_sum_res,0.0)::numeric AS paid_total_r1,
		if.type_res AS claim_type_r1,
		p.income_date_res AS last_income_date_r1,
		(coalesce(if.amount_res,0.00) - coalesce(p.paid_sum_res,0.0))::numeric AS unpaid_r1
		FROM claims if
		LEFT JOIN payments p ON p.installment_table_id_res=if.installment_table_id_res AND (if.type_res=p.type_res OR p.type_res IS NULL)

		UNION SELECT
		di.loan_app_id AS loan_app_id_r1,
		di.installment_table_id AS installment_table_id_r1,
		di.claim_date AS duedate_r1,
		coalesce(di.claim_period,0.0)::numeric AS total_claim_r1,
		(coalesce(di.paid_period, 0.0))::numeric AS paid_total_r1,
		'delay_interest' AS claim_type_r1,
		di.last_payment AS last_income_date_r1,
		(coalesce(di.claim_period,0.0) - coalesce(di.paid_period, 0.0))::numeric AS unpaid_r1
		FROM get_delay_interest_consolidated($1, $2, $3) di
	  ;

	END;
$_$;


ALTER FUNCTION public.get_finance_output(date, date, date) OWNER TO postgres;

--
-- Name: get_finance_summary(date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_finance_summary(date, date) RETURNS TABLE(claim double precision, paid double precision, income_type text)
    LANGUAGE plpgsql
    AS $_$

	BEGIN
	RETURN QUERY
	SELECT round(coalesce(sum(vc.claim_res),0.0),2) AS claim_res, round(coalesce(sum(vc.paid_res),0.0)::numeric,2) AS paid_res, type AS type_res FROM
	(
		SELECT vc.loan_app_id, vc.installment_table_id, vc.duedate::date AS duedate, COALESCE(max(vc.expected_amount), 0.0::double precision) AS claim_res, COALESCE(sum(vc.paid_sum), 0.0::double precision) AS paid_res, vc.type, max(vc.paid_date) AS last_payment
		FROM get_claims_payments($2) vc WHERE vc.avail_date <= $2
		GROUP BY vc.installment_table_id, vc.loan_app_id, vc.duedate, vc.type
	)
	vc WHERE duedate >=$1 AND duedate <=$2 GROUP BY type;
	END;
$_$;


ALTER FUNCTION public.get_finance_summary(date, date) OWNER TO postgres;

--
-- Name: get_finance_two(date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_finance_two(date, date) RETURNS TABLE(loan_app_id integer, ref_nr text, first_name text, last_name text, workposition text, active_date date, capital numeric, interest numeric, commission_fee numeric, guarantee_fee numeric, admin_fee numeric, total numeric, loan_office text, loan_product_id integer, client_id integer)
    LANGUAGE plpgsql
    AS $_$

	BEGIN
	RETURN QUERY


	WITH financials AS (
		SELECT
			it.loan_app_id AS laid
			, sum(it.principal) AS principal_r1
			, sum(it.interest) AS interest_r1
			, sum(it.admission_fee) AS commission_fee_r1
			, sum(it.guarantee_fee) AS guarantee_fee_r1
			, sum(it.admin_fee) AS admin_fee_r1
		FROM installment_table it
		LEFT JOIN loan_application la ON la.id=it.loan_app_id
		WHERE la.active=true AND la.active_date::date >=$1 AND la.active_date::date <= $2
		GROUP BY it.loan_app_id
	)

	SELECT
		financials.laid AS loan_app_id_r1
		, la.ref_nr::text AS ref_nr_r1
		, cp.first_name::text AS first_name_r1
		, cp.last_name::text AS last_name_r1
		, cp.position::text AS position_r1
		, la.active_date::date AS active_date_r1
		, financials.principal_r1::numeric AS principal_r1
		, financials.interest_r1::numeric AS interest_r1
		, financials.commission_fee_r1::numeric AS commission_fee_r1
		, financials.guarantee_fee_r1::numeric AS guarantee_fee_r1
		, financials.admin_fee_r1::numeric AS admin_fee_r1
		, (financials.principal_r1 + financials.interest_r1 + financials.commission_fee_r1 + financials.guarantee_fee_r1 + financials.admin_fee_r1)::numeric AS total_r1
		, la.loan_office::text AS loan_office_r1
		, la.loan_product_id AS loan_product_id_r1
		, la.client_id AS client_id_r1

	FROM
		financials
	LEFT JOIN
		loan_application la ON la.id = financials.laid
	LEFT JOIN
		client_profile cp ON cp.id = la.client_id
	;

	END;
$_$;


ALTER FUNCTION public.get_finance_two(date, date) OWNER TO postgres;

--
-- Name: get_income_report(date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_income_report(date, date) RETURNS TABLE(loan_app_id integer, repayment_id integer, principal numeric, interest numeric, commission_fee numeric, guarantee_fee numeric, admin_fee numeric, first_reminder_fee numeric, second_reminder_fee numeric, termination_fee numeric, termination_alert_fee numeric, delay_interest numeric, suspension_fee numeric, overpayment numeric, extraordinary_revenue numeric, total numeric, payment_date date, bank character varying, ref_nr integer, firstname character varying, lastname character varying, total_sales numeric)
    LANGUAGE plpgsql
    AS $_$

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
	LEFT JOIN alertfee_claims_payments c_termination_alert_fee ON rpt.id=c_termination_alert_fee.c_repayment_id
	LEFT JOIN delay_claims_payments c_delay_interest ON rpt.id=c_delay_interest.c_repayment_id
	LEFT JOIN suspension_fee_claims_payments c_suspension_fee ON rpt.id=c_suspension_fee.c_repayment_id
	LEFT JOIN overpayment_claims_payments c_overpayment ON rpt.id=c_overpayment.c_repayment_id
	LEFT JOIN extraordinary_revenue_payments c_extraordinary_revenue ON rpt.id=c_extraordinary_revenue.c_repayment_id
	LEFT JOIN loan_application la ON la.id = rpt.c_loan_app_id
	LEFT JOIN client_profile cp ON cp.id = la.client_id
	;
END;
$_$;


ALTER FUNCTION public.get_income_report(date, date) OWNER TO postgres;

--
-- Name: get_indebtcollection_loanapps(date, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_indebtcollection_loanapps(date, date, date) RETURNS TABLE(loanappid integer, loanproduct text, loanproductid integer, refnr text, firstname text, lastname text, defaultinterest double precision, score text, office text, incassocompany text, incassocompanyid integer, loanamount numeric, loanperiod integer, activedate date, defaulteddate date, collectiondate date, totaldebt numeric, principal numeric, commissionfee numeric, guaranteefee numeric, adminfee numeric, interest numeric, firstrem numeric, secondrem numeric, termalertfee numeric, termfee numeric, suspensionfee numeric, delayinterest numeric, repaymentslater numeric, repaymentsbefore numeric, agreementsignment text, comments text, payoutto text)
    LANGUAGE plpgsql
    AS $_$
	BEGIN

	RETURN QUERY
	SELECT * FROM get_indebtcollection_loanapps_base ($1, $2, $3) dl WHERE dl.collectiondate>=$1 AND dl.collectiondate <=$2
	ORDER BY dl.collectiondate ASC, dl.refnr ASC
	;



	END;
$_$;


ALTER FUNCTION public.get_indebtcollection_loanapps(date, date, date) OWNER TO postgres;

--
-- Name: get_indebtcollection_loanapps_base(date, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_indebtcollection_loanapps_base(date, date, date) RETURNS TABLE(loanappid integer, loanproduct text, loanproductid integer, refnr text, firstname text, lastname text, defaultintrest double precision, score text, office text, incassocompany text, incassocompanyid integer, loanamount numeric, loanperiod integer, activedate date, defaulteddate date, collectiondate date, totaldebt numeric, principal numeric, commissionfee numeric, guaranteefee numeric, adminfee numeric, interest numeric, firstrem numeric, secondrem numeric, termalertfee numeric, termfee numeric, suspensionfee numeric, delayinterest numeric, repaymentslater numeric, repaymentsbefore numeric, agreementsignment text, comments text, payoutto text)
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.get_indebtcollection_loanapps_base(date, date, date) OWNER TO postgres;

--
-- Name: get_internal_collection_loanapps_base(date, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_internal_collection_loanapps_base(date, date, date) RETURNS TABLE(loanappid integer, loanproduct text, loanproductid integer, refnr text, firstname text, lastname text, defaultintrest double precision, score text, office text, incassocompany text, incassocompanyid integer, loanamount numeric, loanperiod integer, activedate date, defaulteddate date, collectiondate date, totaldebt numeric, principal numeric, commissionfee numeric, guaranteefee numeric, adminfee numeric, interest numeric, firstrem numeric, secondrem numeric, termalertfee numeric, termfee numeric, suspensionfee numeric, delayinterest numeric, repaymentslater numeric, repaymentsbefore numeric, agreementsignment text, comments text, payoutto text)
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.get_internal_collection_loanapps_base(date, date, date) OWNER TO postgres;

--
-- Name: get_loan_product_balance(date, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_loan_product_balance(date, text, integer) RETURNS TABLE(expected numeric, repayment numeric, diff numeric)
    LANGUAGE plpgsql
    AS $_$

	BEGIN

		RETURN QUERY
		SELECT coalesce(paid_out_total.total,0) AS payment_res, coalesce(received_income.total,0) AS repayment_res, (coalesce(paid_out_total.total,0) - coalesce(received_income.total,0)) AS diff_res FROM

		(SELECT SUM(sq.total) AS total FROM
		(
		SELECT SUM(expected_amount) AS total, installment_table_id, 1 AS type
		FROM get_active_loan_claims_payments($1) cp
		JOIN get_loan_status($1) ls ON cp.loan_app_id = ls.loan_app_id
		WHERE ls.la_status=$2 AND cp.loan_product_id=$3 AND cp.paid_sum=0
		GROUP BY installment_table_id
		) sq) paid_out_total,



		(SELECT SUM(sq.total) AS total FROM
		(
		SELECT SUM(paid_sum) AS total, installment_table_id, 2 as type
		FROM get_active_loan_claims_payments($1) cp
		JOIN get_loan_status($1) ls ON cp.loan_app_id = ls.loan_app_id
		WHERE ls.la_status=$2 AND income_date <=$1 AND cp.loan_product_id=$3
		GROUP BY installment_table_id
		)sq) received_income;

	END;
$_$;


ALTER FUNCTION public.get_loan_product_balance(date, text, integer) OWNER TO postgres;

--
-- Name: get_loan_status(date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_loan_status(date) RETURNS TABLE(loan_app_id integer, la_status text, changed date)
    LANGUAGE plpgsql
    AS $_$

	BEGIN
	RETURN QUERY

	SELECT DISTINCT ON(ls.loan_app_id)  ls.loan_app_id AS id_r1, ls.status::text AS status_r1, ls.generated::date AS generated_r1  FROM loan_status ls
	WHERE (ls.generated::date) <= $1
	ORDER BY ls.loan_app_id, ls.generated DESC, ls.id DESC
	;
	END;
$_$;


ALTER FUNCTION public.get_loan_status(date) OWNER TO postgres;

--
-- Name: get_loanapp_export(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_loanapp_export() RETURNS TABLE(loanappid integer, loanproductname text, status text, refnr text, firstname text, lastname text, submitdate date, printdate date, activedate date, paidoutdate date, loanamount numeric, loanperiod integer, interest numeric, commissionfee numeric, guaranteefee numeric, adminfee numeric, bankname text, office text, birthdate date, clientage integer, education text, workpositionsector text, workpositionkind text, workposition text, workpositionother text, workpositionold text, workpositioncatold text, jobcat text, pin text, income numeric, additionalincome numeric, unofficialincome numeric, previousloans numeric, realestate integer, dwellingtype text, children integer, maritalstatus text, owncar integer, gsm text, hometown text, loanpurpose text, mediasource text, dealername text, dealeragentname text, dealeragentcity text, dealeragentregion text, source text, code text, remainingprincipalamount numeric, remaininginterest numeric, remainingcommissionfee numeric, remainingguaranteefee numeric, remainingadminfee numeric, delayedinterest numeric, delayedreminders numeric, suspensionfee numeric, delayedtermination numeric, overpayment numeric, totaldebtamount numeric, delayeddays integer, rejectiontype character varying, rejectiondate date, rejectionusername character varying, saveasbadreason character varying, withdrawnreason character varying, salesman character varying, submitperson character varying, collectioncompany character varying, salaryratio numeric)
    LANGUAGE plpgsql
    AS $$
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
			cp.car AS owncar_r,
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
$$;


ALTER FUNCTION public.get_loanapp_export() OWNER TO postgres;

--
-- Name: get_loanapp_export_paymentsuntil(date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_loanapp_export_paymentsuntil(date) RETURNS TABLE(loanappid integer, loanproductname text, status text, refnr text, firstname text, lastname text, submitdate date, printdate date, activedate date, loanamount numeric, loanperiod integer, interest numeric, commissionfee numeric, bankname text, office text, birthdate date, clientage integer, education text, workposition text, workpositioncategory text, jobcat text, income numeric, previousloans numeric, realestate integer, dwellingtype text, children integer, maritalstatus text, owncar integer, gsm text, loanpurpose text, mediasource text, dealername text, dealeragentname text, source text, code text, remainingprincipalamount numeric, remaininginterest numeric, remainingcommissionfee numeric, delayedinterest numeric, delayedreminders numeric, suspensionfee numeric, delayedtermination numeric, overpayment numeric, totaldebtamount numeric)
    LANGUAGE plpgsql
    AS $_$
	BEGIN

		RETURN QUERY
		WITH claims AS (
		 SELECT claim, type, loan_app_id FROM get_claim_totals($1)
		 )
		 , payments AS (
		SELECT -rpt.sum AS claim_r, rpt.type AS type_r, rp.loan_app_id AS loan_app_id_r, rp.payment_date AS payment_date FROM repayment_type rpt
		LEFT JOIN repayments rp ON rpt.repayment_id=rp.id
		)
		, totals AS (
		SELECT c.claim AS claim_r, c.type AS type_r, c.loan_app_id AS loan_app_id_r FROM claims c
		UNION ALL
		SELECT p.claim_r, p.type_r, p.loan_app_id_r FROM payments p WHERE p.payment_date::date<=$1
		),
		component_sums AS (
		SELECT sum(claim_r) AS sum, type_r, loan_app_id_r FROM totals GROUP BY type_r, loan_app_id_r
		),

		principal_saldo AS (
			SELECT cs.sum AS saldo, cs.loan_app_id_r AS laid FROM component_sums cs WHERE cs.type_r='principal'
		),
		interest_saldo AS(
			SELECT cs.sum AS saldo, cs.loan_app_id_r AS laid FROM component_sums cs  WHERE cs.type_r='interest'
		),
		commission_saldo AS (
			SELECT cs.sum AS saldo, cs.loan_app_id_r AS laid FROM component_sums cs  WHERE cs.type_r='commission_fee'
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
				la.id AS laid, (u.first_name || ' ' || u.last_name) AS dealer_agent
			FROM
				loan_application la
			LEFT JOIN
				users u ON u.username=la.source
			WHERE
				la.dealer_id IS NOT NULL AND la.source<>'old_crm'
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
			la.amount::numeric AS loanamount_r,
			la.period AS loanperiod_r,
			la.interest_rate::numeric AS interest_r,
			la.admission_fee::numeric AS commissionfee_r,
			la.bank_name::text AS bankname_r,
			la.loan_office::text AS office_r,
			cp.birth_date::date AS birthdate_r,
			date_part('year',age(cp.birth_date))::integer AS age,
			cp.education::text AS education_r,
			cp.position::text AS workposition_r,
			cp.job_category::text AS jobcat_r,
			cp.job_income::numeric AS income_r,
			cp.other_loans_total::numeric AS previousloans_r,
			cp.real_estate AS realestate_r,
			cp.dwelling_type::text AS dwellingtype_r,
			coalesce(cp.underage_children, 0) AS children_r,
			cp.marital_status::text AS maritalstatus_r,
			cp.car AS owncar_r,
			cp.gsm::text AS gsm_r,
			la.purpose::text AS loanpurpose_r,
			la.mediasource::text AS mediasource_r,
			d.company_name::text AS dealername_r,
			da.dealer_agent::text AS dealeragentname_r,
			la.source::text AS source_r,
			la.code::text AS code_r,
			coalesce(ps.saldo,0.0)::numeric AS remainingprincipalamount_r,
			coalesce(i.saldo,0.0)::numeric AS remaininginterest_r,
			coalesce(cs.saldo,0.0)::numeric AS remainingcommissionfee_r,
			coalesce(ds.saldo,0.0)::numeric AS delayedinterest_r,
			(coalesce(fs.saldo,0.0)+coalesce(ss.saldo,0.0)+coalesce(a.saldo,0.0))::numeric AS delayedreminders_r,
			coalesce(sf.saldo,0.0)::numeric AS suspension_fee_r,
			coalesce(ts.saldo,0.0)::numeric AS delayedtermination_r,
			coalesce(os.saldo,0.0)::numeric AS overpayment_r,

			(coalesce(ps.saldo,0.0) +
			coalesce(i.saldo,0.0) +
			coalesce(cs.saldo,0.0) +
			coalesce(ds.saldo,0.0) +
			coalesce(fs.saldo,0.0) +
			coalesce(ss.saldo,0.0) +
			coalesce(a.saldo,0.0) +
			coalesce(sf.saldo,0.0) +
			coalesce(ts.saldo,0.0) +
			coalesce(os.saldo,0.0))::numeric AS totaldebtamount_r
		FROM
			loan_application la
		LEFT JOIN
			client_profile cp ON la.client_id=cp.id
		LEFT JOIN
			loan_products lp ON lp.id=la.loan_product_id
		LEFT JOIN
			dealer d ON d.id=la.dealer_id
		LEFT JOIN
			principal_saldo ps ON ps.laid=la.id
		LEFT JOIN
			interest_saldo i ON i.laid=la.id
		LEFT JOIN
			commission_saldo cs ON cs.laid=la.id
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


		WHERE la.active=true

		;

	END;
$_$;


ALTER FUNCTION public.get_loanapp_export_paymentsuntil(date) OWNER TO postgres;

--
-- Name: get_loanapp_export_view(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_loanapp_export_view() RETURNS TABLE(loanappid integer, loanproductname text, status text, refnr text, firstname text, lastname text, submitdate date, activedate date, loanamount numeric, loanperiod integer, interest numeric, commissionfee numeric, guaranteefee numeric, adminfee numeric, office text, totaldebtamount numeric, rejectiondate date)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.get_loanapp_export_view() OWNER TO postgres;

--
-- Name: get_overview(date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_overview(date) RETURNS TABLE(receivable numeric, income_type text, loan_product integer, loan_status text)
    LANGUAGE plpgsql
    AS $_$

	BEGIN
	RETURN QUERY
	WITH
		claims AS (
		SELECT
			if.type
			, round(sum(if.amount)::numeric,2) AS sum
			, la.loan_product_id
			, ls.la_status
		FROM
			v_installment_flat if
		LEFT JOIN
			loan_application la ON if.loan_app_id=la.id
		LEFT JOIN
			get_loan_status($1) ls ON ls.loan_app_id=la.id
		WHERE
			if.avail_date::date <=$1 AND la.active=true
		GROUP BY
			if.type
			, la.loan_product_id
			, ls.la_status
		)
		, paid AS (
		SELECT
			rpt.type AS type_res
			, round(-SUM(rpt.sum)::numeric,2) AS sum
			, la.loan_product_id
			, ls.la_status

		FROM
			repayment_type rpt
		LEFT JOIN
			repayments rp ON  rp.id=rpt.repayment_id
		LEFT JOIN
			loan_application la ON rp.loan_app_id=la.id
		LEFT JOIN
			get_loan_status($1) ls ON la.id=ls.loan_app_id
		WHERE
			rpt.type<>'overpayment' AND rpt.type<>'defaulted_overpayment' AND rpt.type<>'delay_interest'  AND la.active=true AND rp.payment_date::date <=$1
		GROUP BY
			rpt.type, la.loan_product_id, ls.la_status
		ORDER BY
			la.loan_product_id, rpt.type ASC
		)
		, delay_interest AS (
		SELECT
			'delay_interest'::text AS type
			, round(SUM(di.unpaid_total)::numeric,2) AS sum
			, la.loan_product_id AS loan_product_id
			, ls.la_status AS la_status
		FROM
			get_delay_interest('2008-01-01', $1) di
		LEFT JOIN
			loan_application la ON di.loan_app_id=la.id
		LEFT JOIN
			get_loan_status($1) ls ON ls.loan_app_id=la.id
		GROUP BY
			la.loan_product_id, ls.la_status
		)
		, claims_paid AS (

		SELECT * FROM claims
		UNION
		SELECT * FROM paid
		UNION
		SELECT * FROM delay_interest
		)


	SELECT
		sum(claims_paid.sum)::numeric AS diff
		, claims_paid.type AS type
		, claims_paid.loan_product_id AS loan_product_id
		, claims_paid.la_status AS status
	FROM
		claims_paid
	GROUP BY
		claims_paid.type
		, claims_paid.loan_product_id
		, claims_paid.la_status

	;
END;
$_$;


ALTER FUNCTION public.get_overview(date) OWNER TO postgres;

--
-- Name: get_payments(date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_payments(date, date) RETURNS TABLE(loan_app_id integer, installment_table_id integer, expected_amount numeric, duedate date, type text, paid_sum numeric, paid_date date, loan_app_status text, loan_app_created date, income_date date, avail_date date, repayment_id integer)
    LANGUAGE plpgsql
    AS $_$

	BEGIN
	RETURN QUERY


	SELECT claims_payments.loan_app_id_res AS loan_app_id_res, claims_payments.installment_table_id_res AS installment_table_id_res,
    claims_payments.expected_amount_res::numeric AS expected_amount_res, claims_payments.duedate_res1::date AS duedate_res,
    claims_payments.type_res::text AS type_res, claims_payments.paid_sum_res::numeric AS paid_sum_res, claims_payments.paid_date_res::date AS paid_date_res,
    ls.la_status AS loan_app_status_res, la.created::date AS loan_app_created_res,
    claims_payments.income_date_res::date AS income_date_res, claims_payments.avail_date_res::date AS avail_date_res, claims_payments.repayment_id_res2 AS repayment_id_res
   FROM (


        SELECT
        	rp.loan_app_id AS loan_app_id_res,
   			rpt.ir_id AS installment_table_id_res,
			0 expected_amount_res,
			null AS duedate_res1,
			rpt.type AS type_res,
			rpt.sum AS paid_sum_res,
			rp.payment_date::date AS paid_date_res,
			rp.payment_date::date AS income_date_res,
			null AS avail_date_res,
			rp.id AS repayment_id_res2
        FROM repayment_type rpt
		LEFT JOIN repayments rp ON  rp.id=rpt.repayment_id
		WHERE rp.payment_date::date >=$1 AND rp.payment_date::date <=$2 AND rpt.type<>'delay_interest'


		UNION
        SELECT
        	vc.loan_app_id AS loan_app_id_res,
        	vc.installment_table_id AS installment_table_id_res,
        	vc.claim_total,
        	vc.claim_date AS duedate_res1,
        	'delay_interest' AS type_res,
        	vc.paid_total AS paid_sum_res,
			vc.last_payment::date AS paid_date_res,
			vc.last_payment::date AS income_date_res,
			vc.claim_date AS avail_date_res,
			0 AS repayment_id_res2
		FROM
			get_delay_interest($1, $2) vc
		LEFT JOIN
			loan_application la ON vc.loan_app_id=la.id
		WHERE
			la.active_date::date <=$2 AND vc.claim_date <= $2

	) claims_payments
	JOIN loan_application la ON claims_payments.loan_app_id_res = la.id
	LEFT JOIN get_loan_status($2) ls ON claims_payments.loan_app_id_res = ls.loan_app_id;
	END;
$_$;


ALTER FUNCTION public.get_payments(date, date) OWNER TO postgres;

--
-- Name: get_portfolio_excerpt(date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_portfolio_excerpt(date) RETURNS TABLE(loan_app_id integer, claim double precision, paid double precision, type text, unpaid double precision)
    LANGUAGE plpgsql
    AS $_$

	BEGIN
	RETURN QUERY

	WITH
	loan_app_claims AS (
	SELECT ct.claim AS r_claim, ct.loan_app_id AS la_id, ct.type AS type FROM get_claim_totals($1) ct
	)
	, loan_app_payments AS (
	SELECT sum(rpt.sum) AS paym, rp.loan_app_id AS la_id, rpt.type AS type FROM repayment_type rpt
	LEFT JOIN repayments rp ON rp.id = repayment_id
	WHERE rp.payment_date::date <= $1
	GROUP by rp.loan_app_id, rpt.type
	)

	SELECT
	la.id AS r_loan_app_id,
	round(lac.r_claim::numeric,2)::double precision AS r_claim
	, round(coalesce(lap.paym, 0.00)::numeric,2)::double precision AS r_paym
	, lac.type::text AS r_type,
	(round(lac.r_claim::numeric,2) - round(coalesce(lap.paym, 0.00)::numeric,2))::double precision AS r_claim


	FROM
	loan_application la
	JOIN loan_app_claims lac ON lac.la_id=la.id
	LEFT JOIN loan_app_payments lap ON (lap.la_id=la.id AND lap.type=lac.type)

	WHERE la.active=true AND la.active_date::date<=$1
	;

	END;
$_$;


ALTER FUNCTION public.get_portfolio_excerpt(date) OWNER TO postgres;

--
-- Name: get_provision_base(date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_provision_base(date) RETURNS TABLE(la_id integer, total_expected double precision, total_received double precision, max_delay_days integer)
    LANGUAGE plpgsql
    AS $_$

	BEGIN
	RETURN QUERY


		SELECT pe.loan_app_id_r1 AS loan_app_id, round(pe.claim_r1::numeric,2)::double precision AS claim, round(pe.paid_r1::numeric,2)::double precision AS paid, coalesce(delay.maxdelay_r1,0) AS maxdelay FROM (
			SELECT poex.loan_app_id AS loan_app_id_r1, SUM(poex.claim) AS claim_r1, SUM(poex.paid) AS paid_r1 FROM get_portfolio_excerpt($1) poex GROUP BY poex.loan_app_id
		) pe
		LEFT OUTER JOIN (

			SELECT dq.loan_app_id, MAX(dq.max_delay) AS maxdelay_r1 FROM (
				SELECT itpaid.loan_app_id, itpaid.installment_table_id, ($1::date - itpaid.duedate::date)::integer AS max_delay FROM (
					SELECT
					max(vcp.loan_app_id) AS loan_app_id, vcp.installment_table_id AS installment_table_id, max(vcp.duedate), sum(vcp.paid_sum)::double precision AS paid, type, max(expected_amount)::double precision AS expected, max(duedate) AS duedate
					FROM get_claims_payments($1) vcp
					WHERE duedate <= $1 AND avail_date <=$1 GROUP by installment_table_id, type
				) itpaid WHERE itpaid.paid < itpaid.expected
			) dq GROUP BY dq.loan_app_id

		) delay ON pe.loan_app_id_r1=delay.loan_app_id
		WHERE pe.claim_r1 > pe.paid_r1

		;
	END;
$_$;


ALTER FUNCTION public.get_provision_base(date) OWNER TO postgres;

--
-- Name: get_provision_report(date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_provision_report(date) RETURNS TABLE(loan_app_id integer, ref_nr integer, first_name text, last_name text, pin text, loan_status text, status_date date, maxdelay integer, total_claim double precision, principal_claim double precision, interest_claim double precision, commission_claim double precision, guarantee_claim double precision, adminfee_claim double precision, first_reminder_fee_claim double precision, second_reminder_fee_claim double precision, termination_fee_claim double precision, termination_alert_fee_claim double precision, delay_interest_claim double precision, suspension_fee_claim double precision)
    LANGUAGE plpgsql
    AS $_$

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
LEFT OUTER JOIN sub_delay_interest ON mainquery.loan_app_id_r2=sub_delay_interest.loan_app_id_r4
LEFT OUTER JOIN sub_suspension_fee ON mainquery.loan_app_id_r2=sub_suspension_fee.loan_app_id_r4
LEFT OUTER JOIN loan_application la ON mainquery.loan_app_id_r2 = la.id
LEFT OUTER JOIN client_profile cl ON cl.id = la.client_id
LEFT OUTER JOIN get_loan_status($1) ls ON la.id = ls.loan_app_id;

	END;
$_$;


ALTER FUNCTION public.get_provision_report(date) OWNER TO postgres;

--
-- Name: get_sales_report(date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_sales_report(date, date) RETURNS TABLE(loan_app_id integer, ref_nr text, loan_status text, s_saldo numeric, interest numeric, commission_fee numeric, guarantee_fee numeric, admin_fee numeric, first_reminder_fee numeric, second_reminder_fee numeric, termination_fee numeric, termination_alert_fee numeric, delayinterest numeric, suspension_fee numeric, correction numeric, income numeric, e_saldo numeric)
    LANGUAGE plpgsql ROWS 5000
    AS $_$

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
		, coalesce(sdi.sales,0.00)::numeric AS r_delay_interest
		, coalesce(ssf.sales,0.00)::numeric AS r_suspension_fee
		, coalesce(cor.paid, 0.00)::numeric AS r_correction
		--, (coalesce(si.sales,0.00) + coalesce(sc.sales,0.00) + coalesce(s1r.sales,0.00) + coalesce(s2r.sales,0.00) + coalesce(stf.sales,0.00) + coalesce(sta.sales,0.00) + coalesce(sdi.sales,0.00))::numeric AS r_income
		, coalesce(lapp.paym,0.00)::numeric AS r_income
		, (
		coalesce(lac.claim,0.00) + coalesce(dic.claim,0.00) -- previous sales
		+ coalesce(si.sales,0.00) + coalesce(sc.sales,0.00) + coalesce(sgf.sales,0.00) + coalesce(saf.sales,0.00) + coalesce(s1r.sales,0.00) + coalesce(s2r.sales,0.00) + coalesce(stf.sales,0.00) + coalesce(sta.sales,0.00) + coalesce(sdi.sales,0.00) + coalesce(ssf.sales,0.00) -- period sales
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
	LEFT JOIN sales_delay_interest sdi ON la.id=sdi.la_id
	LEFT JOIN sales_suspension_fee ssf ON la.id=ssf.la_id
	LEFT JOIN loan_app_corrections_period cor ON la.id=cor.la_id
	WHERE la.active=true
	--AND la.active_date::date<=$2
	AND
	(
		((coalesce(si.sales,0.00) + coalesce(sc.sales,0.00) + coalesce(sgf.sales,0.00) + coalesce(saf.sales,0.00) + coalesce(s1r.sales,0.00) + coalesce(s2r.sales,0.00) + coalesce(stf.sales,0.00) + coalesce(sta.sales,0.00) + coalesce(sdi.sales,0.00)  + coalesce(ssf.sales,0.00) ) > 0)
		OR
		( coalesce(lac.claim,0.00) + coalesce(dic.claim,0.00) - coalesce(lap.paym,0.00) <> 0)
		OR
		(
		coalesce(lac.claim,0.00) + coalesce(dic.claim,0.00) -- previous sales
		+ coalesce(si.sales,0.00) + coalesce(sc.sales,0.00) + coalesce(sgf.sales,0.00) + coalesce(saf.sales,0.00) + coalesce(s1r.sales,0.00) + coalesce(s2r.sales,0.00) + coalesce(stf.sales,0.00) + coalesce(sta.sales,0.00) + coalesce(sdi.sales,0.00) + coalesce(ssf.sales,0.00)  -- period sales
		- coalesce(lap.paym,0.00) -- previous payments
		- coalesce(lapp.paym,0.00) -- previous payments
		<> 0
		)
	)
  ;

	END;
$_$;


ALTER FUNCTION public.get_sales_report(date, date) OWNER TO postgres;

--
-- Name: make_last_client_profile_active(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION make_last_client_profile_active() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
  ri                  RECORD;
  oldValue            TEXT;
  newValue            TEXT;
  isColumnSignificant BOOLEAN;
  isValueModified     BOOLEAN;
BEGIN
  -- based on http://crafted-software.blogspot.com.ee/2011/05/hoorah-i-was-able-to-complete-my.html

  IF (TG_OP <> 'INSERT')
  THEN -- If operation is an INSERT, we have no OLD value, so use an empty string.

    FOR ri IN
      -- Fetch a ResultSet listing columns defined for this trigger's table.
    SELECT
      ordinal_position,
      column_name,
      data_type
    FROM information_schema.columns
    WHERE
      table_schema = quote_ident(TG_TABLE_SCHEMA)
      AND table_name = quote_ident(TG_TABLE_NAME)
    ORDER BY ordinal_position
    LOOP
      -- For each column in this trigger's table, copy the OLD & NEW values into respective variables.
      -- NEW value
      EXECUTE 'SELECT ($1).' || ri.column_name || '::text'
      INTO newValue
      USING NEW;

      -- OLD value
      EXECUTE 'SELECT ($1).' || ri.column_name || '::text'
      INTO oldValue
      USING OLD;

      isColumnSignificant := (ri.column_name <> 'id') AND (ri.column_name <> 'active');
      IF isColumnSignificant
      THEN
        isValueModified := oldValue <> newValue OR isValueModified; -- If this nthField in the table was modified, make history.
      END IF;
    END LOOP;
  END IF;

  IF isValueModified AND NEW.created :: DATE <> CURRENT_DATE
  THEN
    RAISE 'Client profiles can be changed only on the creation day by the user who created the profile . Profile id: %', NEW.id;
  END IF;

  IF NEW.active = TRUE
  THEN
    UPDATE client_profile cp
    SET active = FALSE
    WHERE cp.pin = NEW.pin AND cp.id <> NEW.id;
  END IF;

  RETURN NEW;

END
$_$;


ALTER FUNCTION public.make_last_client_profile_active() OWNER TO postgres;

--
-- Name: months_between(timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION months_between(t_start timestamp without time zone, t_end timestamp without time zone) RETURNS integer
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
        SELECT
            (
                12 * extract('years' from a.i) + extract('months' from a.i)
            )::integer
        from (
            values (justify_interval($2 - $1))
        ) as a (i)
    $_$;


ALTER FUNCTION public.months_between(t_start timestamp without time zone, t_end timestamp without time zone) OWNER TO postgres;

--
-- Name: update_latest_client_loan_app(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION update_latest_client_loan_app() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

  IF NEW.active = TRUE
  THEN
    UPDATE loan_application la
    SET latest_client = NEW.id
    WHERE la.client_pin = NEW.pin;
  END IF;

  RETURN NEW;
END
$$;


ALTER FUNCTION public.update_latest_client_loan_app() OWNER TO postgres;

--
-- Name: update_loan_status(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION update_loan_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		IF (OLD.status IS DISTINCT FROM NEW.status) THEN
		INSERT INTO loan_status (loan_app_id, status, generated) VALUES (NEW.id, NEW.status, now());
		END IF;
		RETURN NEW;
	END;
$$;


ALTER FUNCTION public.update_loan_status() OWNER TO postgres;

--
-- Name: median(double precision); Type: AGGREGATE; Schema: public; Owner: postgres
--

CREATE AGGREGATE median(double precision) (
    SFUNC = array_append,
    STYPE = double precision[],
    FINALFUNC = array_median
);


ALTER AGGREGATE public.median(double precision) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: account_balance; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE account_balance (
    id integer NOT NULL,
    balance numeric,
    client_pin character varying(255) NOT NULL
);


ALTER TABLE account_balance OWNER TO postgres;

--
-- Name: account_balance_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE account_balance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE account_balance_id_seq OWNER TO postgres;

--
-- Name: account_balance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE account_balance_id_seq OWNED BY account_balance.id;


--
-- Name: aftersale_efficiency_interval; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE aftersale_efficiency_interval (
    id integer NOT NULL,
    interval_from numeric,
    interval_to numeric,
    type character varying(255) NOT NULL,
    unit character varying(255) NOT NULL,
    value numeric
);


ALTER TABLE aftersale_efficiency_interval OWNER TO postgres;

--
-- Name: aftersale_efficiency_interval_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE aftersale_efficiency_interval_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aftersale_efficiency_interval_id_seq OWNER TO postgres;

--
-- Name: aftersale_efficiency_interval_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE aftersale_efficiency_interval_id_seq OWNED BY aftersale_efficiency_interval.id;


--
-- Name: agent_workday; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE agent_workday (
    id integer NOT NULL,
    day integer NOT NULL,
    end_hour integer,
    end_minute integer,
    open boolean DEFAULT false,
    start_hour integer,
    start_minute integer,
    user_id integer NOT NULL
);


ALTER TABLE agent_workday OWNER TO postgres;

--
-- Name: agent_workday_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE agent_workday_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE agent_workday_id_seq OWNER TO postgres;

--
-- Name: agent_workday_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE agent_workday_id_seq OWNED BY agent_workday.id;


--
-- Name: agent_workday_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE agent_workday_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE agent_workday_user_id_seq OWNER TO postgres;

--
-- Name: agent_workday_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE agent_workday_user_id_seq OWNED BY agent_workday.user_id;


--
-- Name: agreement_recipient; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE agreement_recipient (
    id integer NOT NULL,
    email character varying(255) NOT NULL
);


ALTER TABLE agreement_recipient OWNER TO postgres;

--
-- Name: agreement_recipient_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE agreement_recipient_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE agreement_recipient_id_seq OWNER TO postgres;

--
-- Name: agreement_recipient_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE agreement_recipient_id_seq OWNED BY agreement_recipient.id;


--
-- Name: agricultural_asset; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE agricultural_asset (
    id integer NOT NULL,
    agricultural_type character varying(255) NOT NULL,
    amount double precision,
    name character varying(255),
    value_at_entry numeric(19,2),
    client_id integer
);


ALTER TABLE agricultural_asset OWNER TO postgres;

--
-- Name: agricultural_asset_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE agricultural_asset_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE agricultural_asset_id_seq OWNER TO postgres;

--
-- Name: agricultural_asset_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE agricultural_asset_id_seq OWNED BY agricultural_asset.id;


--
-- Name: agricultural_asset_value_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE agricultural_asset_value_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE agricultural_asset_value_id_seq OWNER TO postgres;

--
-- Name: agricultural_asset_value; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE agricultural_asset_value (
    id integer DEFAULT nextval('agricultural_asset_value_id_seq'::regclass) NOT NULL,
    agricultural_type character varying(255) NOT NULL,
    current_value numeric(19,2),
    name character varying(255)
);


ALTER TABLE agricultural_asset_value OWNER TO postgres;

--
-- Name: alternative_contact; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE alternative_contact (
    id integer NOT NULL,
    name character varying(255),
    phone character varying(255),
    relation character varying(255),
    client_id integer NOT NULL
);


ALTER TABLE alternative_contact OWNER TO postgres;

--
-- Name: alternative_contact_client_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE alternative_contact_client_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE alternative_contact_client_id_seq OWNER TO postgres;

--
-- Name: alternative_contact_client_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE alternative_contact_client_id_seq OWNED BY alternative_contact.client_id;


--
-- Name: alternative_contact_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE alternative_contact_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE alternative_contact_id_seq OWNER TO postgres;

--
-- Name: alternative_contact_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE alternative_contact_id_seq OWNED BY alternative_contact.id;


--
-- Name: audit_trail; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE audit_trail (
    id integer NOT NULL,
    action character varying(255),
    created timestamp without time zone,
    target character varying(255),
    target_id integer,
    user_name character varying(255),
    client_pin character varying(255),
    comment character varying(255),
    string_id character varying(30)
);


ALTER TABLE audit_trail OWNER TO postgres;

--
-- Name: audit_trail_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE audit_trail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE audit_trail_id_seq OWNER TO postgres;

--
-- Name: audit_trail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE audit_trail_id_seq OWNED BY audit_trail.id;


--
-- Name: bonus_settings; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE bonus_settings (
    id integer NOT NULL,
    user_apr_perc numeric
);


ALTER TABLE bonus_settings OWNER TO postgres;

--
-- Name: bonus_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE bonus_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bonus_settings_id_seq OWNER TO postgres;

--
-- Name: bonus_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE bonus_settings_id_seq OWNED BY bonus_settings.id;


--
-- Name: bonus_settings_operation; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE bonus_settings_operation (
    id integer NOT NULL,
    key character varying(255) NOT NULL,
    operation character varying(255) NOT NULL,
    source character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    unit character varying(255) NOT NULL,
    value numeric
);


ALTER TABLE bonus_settings_operation OWNER TO postgres;

--
-- Name: bonus_settings_operation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE bonus_settings_operation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bonus_settings_operation_id_seq OWNER TO postgres;

--
-- Name: bonus_settings_operation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE bonus_settings_operation_id_seq OWNED BY bonus_settings_operation.id;


--
-- Name: bonus_settings_promotion; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE bonus_settings_promotion (
    loan_product_id integer NOT NULL,
    bonus_amount numeric,
    period integer NOT NULL
);


ALTER TABLE bonus_settings_promotion OWNER TO postgres;

--
-- Name: bulk_letter_task_row; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE bulk_letter_task_row (
    id integer NOT NULL,
    created_date date,
    done boolean DEFAULT false NOT NULL,
    ir integer,
    lettertype character varying(255) NOT NULL,
    reminder integer,
    username character varying(255) NOT NULL,
    app integer NOT NULL
);


ALTER TABLE bulk_letter_task_row OWNER TO postgres;

--
-- Name: bulk_letter_task_row_app_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE bulk_letter_task_row_app_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bulk_letter_task_row_app_seq OWNER TO postgres;

--
-- Name: bulk_letter_task_row_app_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE bulk_letter_task_row_app_seq OWNED BY bulk_letter_task_row.app;


--
-- Name: bulk_letter_task_row_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE bulk_letter_task_row_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bulk_letter_task_row_id_seq OWNER TO postgres;

--
-- Name: bulk_letter_task_row_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE bulk_letter_task_row_id_seq OWNED BY bulk_letter_task_row.id;


--
-- Name: call_task; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE call_task (
    id integer NOT NULL,
    call_back_hours integer,
    comment character varying(255) NOT NULL,
    created timestamp without time zone,
    dealer_activity character varying(255),
    later_months integer,
    option character varying(255) NOT NULL,
    task_id character varying(255),
    call_back_at_date timestamp without time zone,
    rating integer,
    task_name character varying(255)
);


ALTER TABLE call_task OWNER TO postgres;

--
-- Name: call_task_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE call_task_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE call_task_id_seq OWNER TO postgres;

--
-- Name: call_task_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE call_task_id_seq OWNED BY call_task.id;


--
-- Name: campaign; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE campaign (
    id integer NOT NULL,
    active boolean DEFAULT false,
    client_category character varying(255),
    connect_loan_days integer,
    created timestamp without time zone,
    created_by character varying(255),
    day_of_month integer DEFAULT (-1),
    day_of_week integer DEFAULT (-1),
    description character varying(255),
    fri boolean DEFAULT true,
    group_month_end integer,
    group_month_start integer,
    group_year_end integer,
    group_year_start integer,
    hour integer DEFAULT 8,
    job_name character varying(255),
    last_execution timestamp without time zone,
    loan_product character varying(255),
    minute integer DEFAULT 0,
    mon boolean DEFAULT true,
    name character varying(255),
    period character varying(255),
    sat boolean DEFAULT true,
    sun boolean DEFAULT true,
    task_duration integer,
    task_type character varying(255),
    thu boolean DEFAULT true,
    tue boolean DEFAULT true,
    type character varying(255),
    wed boolean DEFAULT true,
    day_limit integer,
    template_id integer,
    client_performance character varying(255),
    linked_loan_min_period integer,
    loan_progress character varying(255),
    end_date timestamp without time zone,
    last_notified_due_date timestamp without time zone,
    start_date timestamp without time zone,
    custom_product integer,
    client_employment_type character varying(255),
    task_role character varying(255),
    has_loan boolean DEFAULT true,
    active_debt character varying DEFAULT 'no'::character varying,
    search_type character varying DEFAULT 'last_ending'::character varying
);


ALTER TABLE campaign OWNER TO postgres;

--
-- Name: campaign_client; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE campaign_client (
    id integer NOT NULL,
    client_pin character varying(255),
    completed timestamp without time zone,
    completed_user character varying(255),
    created timestamp without time zone,
    loan_app_id integer,
    step_nr integer,
    updated timestamp without time zone,
    campaign_id integer NOT NULL,
    assignee character varying(255),
    client_id integer,
    client_name character varying(255),
    step_id integer,
    step_name character varying(255),
    execution_id bigint,
    reached_client boolean
);


ALTER TABLE campaign_client OWNER TO postgres;

--
-- Name: campaign_client_cache; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE campaign_client_cache (
    id bigint NOT NULL,
    client_pin character varying(255),
    campaign_id integer
);


ALTER TABLE campaign_client_cache OWNER TO postgres;

--
-- Name: campaign_client_cache_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE campaign_client_cache_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE campaign_client_cache_id_seq OWNER TO postgres;

--
-- Name: campaign_client_cache_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE campaign_client_cache_id_seq OWNED BY campaign_client_cache.id;


--
-- Name: campaign_client_campaign_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE campaign_client_campaign_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE campaign_client_campaign_id_seq OWNER TO postgres;

--
-- Name: campaign_client_campaign_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE campaign_client_campaign_id_seq OWNED BY campaign_client.campaign_id;


--
-- Name: campaign_client_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE campaign_client_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE campaign_client_id_seq OWNER TO postgres;

--
-- Name: campaign_client_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE campaign_client_id_seq OWNED BY campaign_client.id;


--
-- Name: campaign_dealers; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE campaign_dealers (
    campaign_id integer NOT NULL,
    dealer_id integer NOT NULL
);


ALTER TABLE campaign_dealers OWNER TO postgres;

--
-- Name: campaign_dealers_campaign_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE campaign_dealers_campaign_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE campaign_dealers_campaign_id_seq OWNER TO postgres;

--
-- Name: campaign_dealers_campaign_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE campaign_dealers_campaign_id_seq OWNED BY campaign_dealers.campaign_id;


--
-- Name: campaign_dealers_dealer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE campaign_dealers_dealer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE campaign_dealers_dealer_id_seq OWNER TO postgres;

--
-- Name: campaign_dealers_dealer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE campaign_dealers_dealer_id_seq OWNED BY campaign_dealers.dealer_id;


--
-- Name: campaign_filter; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE campaign_filter (
    id integer NOT NULL,
    created timestamp without time zone,
    range boolean DEFAULT false,
    type character varying(255) NOT NULL,
    value_from character varying(255),
    value_to character varying(255),
    campaign_id integer NOT NULL
);


ALTER TABLE campaign_filter OWNER TO postgres;

--
-- Name: campaign_filter_campaign_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE campaign_filter_campaign_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE campaign_filter_campaign_id_seq OWNER TO postgres;

--
-- Name: campaign_filter_campaign_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE campaign_filter_campaign_id_seq OWNED BY campaign_filter.campaign_id;


--
-- Name: campaign_filter_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE campaign_filter_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE campaign_filter_id_seq OWNER TO postgres;

--
-- Name: campaign_filter_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE campaign_filter_id_seq OWNED BY campaign_filter.id;


--
-- Name: campaign_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE campaign_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE campaign_id_seq OWNER TO postgres;

--
-- Name: campaign_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE campaign_id_seq OWNED BY campaign.id;


--
-- Name: campaign_step; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE campaign_step (
    id integer NOT NULL,
    active boolean DEFAULT true,
    created timestamp without time zone,
    day_limit integer,
    description character varying(255),
    duration integer,
    exec_type character varying(255),
    exec_val integer,
    name character varying(255),
    nr integer,
    type character varying(255),
    campaign_id integer NOT NULL,
    template_id integer,
    next_offer boolean DEFAULT false,
    next_loan_period integer,
    day_limit_call integer,
    day_limit_credit integer,
    day_limit_print integer,
    role_call boolean DEFAULT false,
    role_credit boolean DEFAULT false,
    role_print boolean DEFAULT false,
    user_role character varying(255),
    client_product character varying DEFAULT 'cash'::character varying,
    exec_acc character varying DEFAULT 'period'::character varying,
    has_active_comfort character varying DEFAULT 'all'::character varying,
    last_campaign_days integer DEFAULT 0,
    loan_progress character varying DEFAULT 'all'::character varying
);


ALTER TABLE campaign_step OWNER TO postgres;

--
-- Name: campaign_step_campaign_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE campaign_step_campaign_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE campaign_step_campaign_id_seq OWNER TO postgres;

--
-- Name: campaign_step_campaign_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE campaign_step_campaign_id_seq OWNED BY campaign_step.campaign_id;


--
-- Name: campaign_step_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE campaign_step_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE campaign_step_id_seq OWNER TO postgres;

--
-- Name: campaign_step_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE campaign_step_id_seq OWNED BY campaign_step.id;


--
-- Name: car_price; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE car_price (
    id integer NOT NULL,
    created date DEFAULT now() NOT NULL,
    mark character varying(255) NOT NULL,
    model character varying(255),
    value numeric(19,2) NOT NULL,
    year integer
);


ALTER TABLE car_price OWNER TO postgres;

--
-- Name: car_price_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE car_price_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE car_price_id_seq OWNER TO postgres;

--
-- Name: car_price_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE car_price_id_seq OWNED BY car_price.id;


--
-- Name: card_data; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE card_data (
    id integer NOT NULL,
    file_id integer,
    card_prefix character varying(255),
    card_suffix character varying(255),
    client_pin character varying(255),
    created timestamp without time zone,
    digits character varying(255),
    expiration_date timestamp without time zone,
    iban character varying(255),
    office character varying(255),
    used timestamp without time zone,
    client_file_id integer,
    issue_card_proc_id character varying(255),
    issue_user character varying(255),
    issued timestamp without time zone,
    loan_app_file_id integer,
    loan_app_id integer
);


ALTER TABLE card_data OWNER TO postgres;

--
-- Name: card_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE card_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE card_data_id_seq OWNER TO postgres;

--
-- Name: card_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE card_data_id_seq OWNED BY card_data.id;


--
-- Name: card_file; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE card_file (
    id integer NOT NULL,
    created timestamp without time zone,
    file_delivered timestamp without time zone,
    file_name character varying(255),
    file_type character varying(255),
    folder character varying(255),
    response_downloaded timestamp without time zone,
    response_file_name character varying(255),
    response_received timestamp without time zone
);


ALTER TABLE card_file OWNER TO postgres;

--
-- Name: card_file_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE card_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE card_file_id_seq OWNER TO postgres;

--
-- Name: card_file_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE card_file_id_seq OWNED BY card_file.id;


--
-- Name: cash_product_condition; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE cash_product_condition (
    id integer NOT NULL,
    bonus_fix numeric,
    bonus_perc numeric,
    commission_fix numeric,
    commission_perc numeric,
    evening_product boolean DEFAULT false,
    interest_perc numeric,
    period integer,
    principal_max numeric,
    principal_min numeric,
    loan_product_id integer NOT NULL
);


ALTER TABLE cash_product_condition OWNER TO postgres;

--
-- Name: cash_product_condition_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE cash_product_condition_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cash_product_condition_id_seq OWNER TO postgres;

--
-- Name: cash_product_condition_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE cash_product_condition_id_seq OWNED BY cash_product_condition.id;


--
-- Name: cash_product_condition_loan_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE cash_product_condition_loan_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cash_product_condition_loan_product_id_seq OWNER TO postgres;

--
-- Name: cash_product_condition_loan_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE cash_product_condition_loan_product_id_seq OWNED BY cash_product_condition.loan_product_id;


--
-- Name: chat; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE chat (
    id integer NOT NULL,
    answered timestamp without time zone,
    answeredusername character varying(255),
    question character varying(255),
    started timestamp without time zone,
    startedusername character varying(255)
);


ALTER TABLE chat OWNER TO postgres;

--
-- Name: chat_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE chat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE chat_id_seq OWNER TO postgres;

--
-- Name: chat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE chat_id_seq OWNED BY chat.id;


--
-- Name: chat_msg; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE chat_msg (
    id integer NOT NULL,
    created timestamp without time zone,
    info_message boolean DEFAULT true,
    message character varying(255),
    username character varying(255),
    chat_id integer NOT NULL
);


ALTER TABLE chat_msg OWNER TO postgres;

--
-- Name: chat_msg_chat_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE chat_msg_chat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE chat_msg_chat_id_seq OWNER TO postgres;

--
-- Name: chat_msg_chat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE chat_msg_chat_id_seq OWNED BY chat_msg.chat_id;


--
-- Name: chat_msg_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE chat_msg_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE chat_msg_id_seq OWNER TO postgres;

--
-- Name: chat_msg_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE chat_msg_id_seq OWNED BY chat_msg.id;


--
-- Name: classifier; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE classifier (
    id integer NOT NULL,
    bad boolean DEFAULT false,
    key character varying(255) NOT NULL,
    read_only boolean DEFAULT false,
    type character varying(255) NOT NULL,
    value character varying(255) NOT NULL,
    system_only boolean DEFAULT false
);


ALTER TABLE classifier OWNER TO postgres;

--
-- Name: classifier_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE classifier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE classifier_id_seq OWNER TO postgres;

--
-- Name: classifier_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE classifier_id_seq OWNED BY classifier.id;


--
-- Name: clicktodial; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE clicktodial (
    id integer NOT NULL,
    callto character varying(9) NOT NULL,
    created timestamp without time zone,
    ext character varying(3) NOT NULL,
    retries integer,
    state character varying(10)
);


ALTER TABLE clicktodial OWNER TO postgres;

--
-- Name: clicktodial_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE clicktodial_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE clicktodial_id_seq OWNER TO postgres;

--
-- Name: clicktodial_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE clicktodial_id_seq OWNED BY clicktodial.id;


--
-- Name: client_aftersale_data; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE client_aftersale_data (
    id integer NOT NULL,
    category character varying(255),
    client_pin character varying(255) NOT NULL,
    marketing_denial boolean DEFAULT false,
    performance character varying(255),
    updated timestamp without time zone,
    marketing_denial_date timestamp without time zone
);


ALTER TABLE client_aftersale_data OWNER TO postgres;

--
-- Name: client_aftersale_data_hist; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE client_aftersale_data_hist (
    id integer NOT NULL,
    client_pin character varying(255) NOT NULL,
    created timestamp without time zone,
    type character varying(255) NOT NULL,
    value character varying(255) NOT NULL
);


ALTER TABLE client_aftersale_data_hist OWNER TO postgres;

--
-- Name: client_aftersale_data_hist_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE client_aftersale_data_hist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE client_aftersale_data_hist_id_seq OWNER TO postgres;

--
-- Name: client_aftersale_data_hist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE client_aftersale_data_hist_id_seq OWNED BY client_aftersale_data_hist.id;


--
-- Name: client_aftersale_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE client_aftersale_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE client_aftersale_data_id_seq OWNER TO postgres;

--
-- Name: client_aftersale_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE client_aftersale_data_id_seq OWNED BY client_aftersale_data.id;


--
-- Name: client_bonus; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE client_bonus (
    id integer NOT NULL,
    added timestamp without time zone,
    bonus_name character varying(255) NOT NULL,
    bonus_sum double precision NOT NULL,
    bonus_type character varying(255) NOT NULL,
    calc_app_id integer,
    client_pin character varying(255) NOT NULL,
    used boolean DEFAULT false,
    used_app_id integer,
    user_name character varying(255),
    referring_type character varying(255),
    source_pin character varying(255),
    used_date timestamp without time zone
);


ALTER TABLE client_bonus OWNER TO postgres;

--
-- Name: client_bonus_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE client_bonus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE client_bonus_id_seq OWNER TO postgres;

--
-- Name: client_bonus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE client_bonus_id_seq OWNED BY client_bonus.id;


--
-- Name: client_bonus_settings; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE client_bonus_settings (
    id integer NOT NULL,
    bonus_name character varying(255) NOT NULL,
    category character varying(255) NOT NULL,
    loan_cnt integer,
    updated timestamp without time zone,
    value numeric DEFAULT 0 NOT NULL
);


ALTER TABLE client_bonus_settings OWNER TO postgres;

--
-- Name: client_bonus_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE client_bonus_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE client_bonus_settings_id_seq OWNER TO postgres;

--
-- Name: client_bonus_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE client_bonus_settings_id_seq OWNED BY client_bonus_settings.id;


--
-- Name: client_file; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE client_file (
    id integer NOT NULL,
    client_pin character varying(255),
    created timestamp without time zone,
    file_name character varying(255),
    file_type character varying(255),
    folder character varying(255)
);


ALTER TABLE client_file OWNER TO postgres;

--
-- Name: client_file_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE client_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE client_file_id_seq OWNER TO postgres;

--
-- Name: client_file_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE client_file_id_seq OWNED BY client_file.id;


--
-- Name: client_history; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE client_history (
    id integer NOT NULL,
    call_in boolean,
    call_type integer,
    comment text,
    created timestamp without time zone,
    high_priority boolean,
    username character varying(255),
    loan_app_id integer,
    pin character varying(20),
    user_entered boolean,
    type integer DEFAULT 0
);


ALTER TABLE client_history OWNER TO postgres;

--
-- Name: client_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE client_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE client_history_id_seq OWNER TO postgres;

--
-- Name: client_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE client_history_id_seq OWNED BY client_history.id;


--
-- Name: client_next_offer; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE client_next_offer (
    id integer NOT NULL,
    amount double precision,
    cause character varying(255),
    client_pin character varying(255),
    period integer,
    product character varying(255),
    next_product_id integer NOT NULL
);


ALTER TABLE client_next_offer OWNER TO postgres;

--
-- Name: client_next_offer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE client_next_offer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE client_next_offer_id_seq OWNER TO postgres;

--
-- Name: client_next_offer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE client_next_offer_id_seq OWNED BY client_next_offer.id;


--
-- Name: client_next_offer_next_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE client_next_offer_next_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE client_next_offer_next_product_id_seq OWNER TO postgres;

--
-- Name: client_next_offer_next_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE client_next_offer_next_product_id_seq OWNED BY client_next_offer.next_product_id;


--
-- Name: client_other_loan; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE client_other_loan (
    other_loan_id integer NOT NULL,
    amount numeric NOT NULL,
    payback numeric,
    purpose character varying(255),
    client_id integer NOT NULL,
    debt numeric,
    loan_app_id numeric,
    active_loan_count numeric,
    residual_value numeric
);


ALTER TABLE client_other_loan OWNER TO postgres;

--
-- Name: client_other_loan_client_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE client_other_loan_client_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE client_other_loan_client_id_seq OWNER TO postgres;

--
-- Name: client_other_loan_client_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE client_other_loan_client_id_seq OWNED BY client_other_loan.client_id;


--
-- Name: client_other_loan_other_loan_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE client_other_loan_other_loan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE client_other_loan_other_loan_id_seq OWNER TO postgres;

--
-- Name: client_other_loan_other_loan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE client_other_loan_other_loan_id_seq OWNED BY client_other_loan.other_loan_id;


--
-- Name: client_profile; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE client_profile (
    id integer NOT NULL,
    active boolean NOT NULL,
    alternative_contact character varying(255),
    alternative_contact_email character varying(100),
    alternative_contact_phone character varying(100),
    alternative_contact_relation character varying(255),
    birth_date timestamp without time zone,
    car integer,
    car_reg_nr character varying(255),
    comfort_client boolean,
    contact_person character varying(255),
    created timestamp without time zone,
    dwelling_period character varying(30),
    dwelling_type character varying(30),
    education character varying(30),
    email character varying(255),
    first_name character varying(100),
    gender character varying(255),
    gsm character varying(255),
    gsmtype character varying(30),
    home_apartment character varying(255),
    home_house_number character varying DEFAULT ''::character varying,
    home_street character varying(255),
    home_town character varying(255),
    home_zip character varying(255),
    job_category character varying(30),
    language character varying(255),
    last_name character varying(100),
    marital_status character varying(255),
    monthly_payback_total numeric,
    job_income numeric,
    other_loans_total numeric,
    patronymic character varying(255),
    pet character varying(255),
    pets integer,
    phone_home character varying(255),
    phone_work character varying(255),
    pin character varying(50) NOT NULL,
    "position" character varying(255),
    real_estate integer,
    real_estate_address character varying(255),
    underage_children integer,
    work_started timestamp without time zone,
    employer_id integer,
    phone_home_comment character varying(255),
    phone_work_comment character varying(255),
    additional_income numeric,
    has_other_loans integer DEFAULT 0,
    additional_income_comment character varying(255),
    id_card_nr character varying(255),
    position_cat_old character varying(255),
    position_kind character varying(100),
    position_old character varying(255),
    position_other character varying(255),
    position_sector character varying(50),
    alternative_contact_street character varying(255),
    dealer_client_status character varying(255),
    employment_type character varying(50),
    unofficial_income numeric,
    second_alternative_contact character varying(255),
    second_alternative_contact_relation character varying(100),
    old_underage_children integer,
    old_education character varying(30),
    old_marital_status character varying(30),
    old_dwelling_type character varying(30),
    alternative_contact_employer character varying(255),
    id_card_serial character varying(255),
    other_debt_total numeric,
    position_comment character varying(255),
    agricultural_income numeric,
    other_active_loan_count_total numeric,
    other_residual_value_total numeric,
    editing_user character varying(255),
    residence_address character varying(255),
    residence_address_same integer,
    residence_town character varying(255),
    car_mark character varying(255),
    car_model character varying(255),
    car_value numeric(19,2),
    car_value_date timestamp without time zone,
    car_vin_code character varying(255),
    car_year integer,
    work_duration character varying(30),
    car_color character varying(255),
    car_reg_doc_nr character varying(255),
    remittance_country character varying(255)
);


ALTER TABLE client_profile OWNER TO postgres;

--
-- Name: client_profile_employer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE client_profile_employer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE client_profile_employer_id_seq OWNER TO postgres;

--
-- Name: client_profile_employer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE client_profile_employer_id_seq OWNED BY client_profile.employer_id;


--
-- Name: client_profile_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE client_profile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE client_profile_id_seq OWNER TO postgres;

--
-- Name: client_profile_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE client_profile_id_seq OWNED BY client_profile.id;


--
-- Name: collection_company; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE collection_company (
    id integer NOT NULL,
    address character varying(255),
    company_name character varying(255),
    company_type character varying(255),
    contact_person character varying(255),
    created timestamp without time zone,
    email character varying(255),
    fiscal_nr character varying(255),
    phone character varying(255),
    second_email character varying(255),
    send_weekly_raport boolean DEFAULT false,
    collector_id integer
);


ALTER TABLE collection_company OWNER TO postgres;

--
-- Name: collection_company_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE collection_company_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE collection_company_id_seq OWNER TO postgres;

--
-- Name: collection_company_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE collection_company_id_seq OWNED BY collection_company.id;


--
-- Name: collection_conditions; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE collection_conditions (
    id integer NOT NULL,
    overpayment numeric NOT NULL,
    penalties numeric NOT NULL,
    per_end_days integer,
    per_start_days integer NOT NULL,
    pic numeric NOT NULL,
    collection_scheme_id integer NOT NULL
);


ALTER TABLE collection_conditions OWNER TO postgres;

--
-- Name: collection_conditions_collection_scheme_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE collection_conditions_collection_scheme_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE collection_conditions_collection_scheme_id_seq OWNER TO postgres;

--
-- Name: collection_conditions_collection_scheme_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE collection_conditions_collection_scheme_id_seq OWNED BY collection_conditions.collection_scheme_id;


--
-- Name: collection_conditions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE collection_conditions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE collection_conditions_id_seq OWNER TO postgres;

--
-- Name: collection_conditions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE collection_conditions_id_seq OWNED BY collection_conditions.id;


--
-- Name: collection_portfolio; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE collection_portfolio (
    id integer NOT NULL,
    created timestamp without time zone,
    username character varying(255)
);


ALTER TABLE collection_portfolio OWNER TO postgres;

--
-- Name: collection_portfolio_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE collection_portfolio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE collection_portfolio_id_seq OWNER TO postgres;

--
-- Name: collection_portfolio_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE collection_portfolio_id_seq OWNED BY collection_portfolio.id;


--
-- Name: collection_scheme; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE collection_scheme (
    id integer NOT NULL,
    active boolean NOT NULL,
    active_til timestamp without time zone,
    created timestamp without time zone,
    collection_company_id integer NOT NULL
);


ALTER TABLE collection_scheme OWNER TO postgres;

--
-- Name: collection_scheme_collection_company_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE collection_scheme_collection_company_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE collection_scheme_collection_company_id_seq OWNER TO postgres;

--
-- Name: collection_scheme_collection_company_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE collection_scheme_collection_company_id_seq OWNED BY collection_scheme.collection_company_id;


--
-- Name: collection_scheme_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE collection_scheme_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE collection_scheme_id_seq OWNER TO postgres;

--
-- Name: collection_scheme_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE collection_scheme_id_seq OWNED BY collection_scheme.id;


--
-- Name: collector_history; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE collector_history (
    id integer NOT NULL,
    comment text,
    created timestamp without time zone NOT NULL,
    loan_app_id integer,
    username character varying(255)
);


ALTER TABLE collector_history OWNER TO postgres;

--
-- Name: collector_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE collector_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE collector_history_id_seq OWNER TO postgres;

--
-- Name: collector_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE collector_history_id_seq OWNED BY collector_history.id;


--
-- Name: consolidated_payment; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE consolidated_payment (
    id integer NOT NULL,
    bank character varying(255),
    dealer_id integer,
    payment_date timestamp without time zone,
    sum numeric,
    type character varying(255),
    user_name character varying(255)
);


ALTER TABLE consolidated_payment OWNER TO postgres;

--
-- Name: consolidated_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE consolidated_payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE consolidated_payment_id_seq OWNER TO postgres;

--
-- Name: consolidated_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE consolidated_payment_id_seq OWNED BY consolidated_payment.id;


--
-- Name: cpi_bonus_settings; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE cpi_bonus_settings (
    id integer NOT NULL,
    user_cpi_perc_minus numeric,
    user_cpi_perc_plus numeric,
    user_cpi_threshold integer
);


ALTER TABLE cpi_bonus_settings OWNER TO postgres;

--
-- Name: cpi_bonus_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE cpi_bonus_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cpi_bonus_settings_id_seq OWNER TO postgres;

--
-- Name: cpi_bonus_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE cpi_bonus_settings_id_seq OWNED BY cpi_bonus_settings.id;


--
-- Name: cpi_chart; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE cpi_chart (
    id integer NOT NULL,
    chart_set_id bigint DEFAULT 0 NOT NULL,
    created timestamp without time zone NOT NULL,
    loan_office character varying,
    loan_product_id integer
);


ALTER TABLE cpi_chart OWNER TO postgres;

--
-- Name: cpi_chart_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE cpi_chart_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cpi_chart_id_seq OWNER TO postgres;

--
-- Name: cpi_chart_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE cpi_chart_id_seq OWNED BY cpi_chart.id;


--
-- Name: cpi_chart_row; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE cpi_chart_row (
    id integer NOT NULL,
    month integer NOT NULL,
    paid numeric,
    percentage numeric,
    total_claim numeric,
    year integer NOT NULL,
    chart_id integer NOT NULL
);


ALTER TABLE cpi_chart_row OWNER TO postgres;

--
-- Name: cpi_chart_row_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE cpi_chart_row_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cpi_chart_row_id_seq OWNER TO postgres;

--
-- Name: cpi_chart_row_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE cpi_chart_row_id_seq OWNED BY cpi_chart_row.id;


--
-- Name: currency; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE currency (
    id integer NOT NULL,
    insert_username character varying(255),
    inserted timestamp without time zone,
    rate numeric(19,4) NOT NULL,
    rate_date timestamp without time zone NOT NULL
);


ALTER TABLE currency OWNER TO postgres;

--
-- Name: currency_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE currency_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE currency_id_seq OWNER TO postgres;

--
-- Name: currency_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE currency_id_seq OWNED BY currency.id;


--
-- Name: currency_risk; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE currency_risk (
    id integer NOT NULL,
    aer numeric(19,4),
    der numeric(19,4),
    inflation_perc numeric(19,2),
    loan_increased boolean DEFAULT false,
    processed boolean DEFAULT false,
    processed_date timestamp without time zone,
    started_date timestamp without time zone,
    started_debt double precision,
    loan_app_id integer NOT NULL
);


ALTER TABLE currency_risk OWNER TO postgres;

--
-- Name: currency_risk_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE currency_risk_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE currency_risk_id_seq OWNER TO postgres;

--
-- Name: currency_risk_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE currency_risk_id_seq OWNED BY currency_risk.id;


--
-- Name: currency_risk_loan_app_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE currency_risk_loan_app_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE currency_risk_loan_app_id_seq OWNER TO postgres;

--
-- Name: currency_risk_loan_app_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE currency_risk_loan_app_id_seq OWNED BY currency_risk.loan_app_id;


--
-- Name: loan_application; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE loan_application (
    id integer NOT NULL,
    admission_fee numeric,
    amount numeric NOT NULL,
    bank_account character varying(255),
    bank_code character varying(255),
    bank_name character varying(255),
    client_notified boolean,
    closed boolean DEFAULT false,
    closed_date timestamp without time zone,
    code character varying(255),
    created timestamp without time zone,
    early_date timestamp without time zone,
    early_sum numeric,
    first_payment timestamp without time zone,
    interest_rate numeric NOT NULL,
    ip character varying(255),
    loan_office character varying DEFAULT ''::character varying NOT NULL,
    mediasource character varying(255),
    old_crm_id integer,
    owner character varying(255),
    paid numeric,
    active boolean,
    active_date timestamp without time zone,
    period integer NOT NULL,
    proc_inst_id character varying(255),
    purpose character varying(255),
    ref_nr integer,
    refinanced_with integer,
    rejection_reason character varying(255),
    signed timestamp without time zone,
    source character varying(255),
    status character varying(255),
    term_date timestamp without time zone,
    total_sum numeric,
    withdrawn_reason character varying(255),
    client_id integer NOT NULL,
    dealer_id integer,
    loan_product_id integer NOT NULL,
    docs_received boolean DEFAULT false,
    collection integer DEFAULT 0,
    collection_date timestamp without time zone,
    collection_debt numeric,
    collection_scheme_id integer,
    default_proc_inst_id character varying(255),
    paid_out boolean DEFAULT false,
    paid_out_date timestamp without time zone,
    client_pin character varying(255),
    defaulted boolean DEFAULT false,
    performance character varying(255),
    saveasbad_reason character varying(255),
    dealer_loan_count integer,
    data_agreement_nr character varying(255),
    apr numeric,
    admission_fee_client numeric,
    adv_payment numeric,
    purchase_cost numeric,
    salesman character varying(255),
    shop_fee numeric,
    custom_product_id integer,
    submit_person character varying(255),
    agreement_signed boolean DEFAULT false,
    cash_release_allowed boolean DEFAULT false,
    cash_release_allowed_date timestamp without time zone,
    post_office_id integer,
    referral integer,
    evening_loan boolean DEFAULT false,
    has_prev_active_loan boolean DEFAULT false,
    submitted timestamp without time zone,
    signed_office character varying(255),
    signed_person character varying(255),
    short_form boolean DEFAULT false,
    auto_rejected boolean DEFAULT false,
    guarantee_fee numeric,
    guarantee_loan boolean DEFAULT false,
    destroyed_loans_batch_id integer,
    prev_active_loan_id integer,
    prev_active_loan_paid_perc double precision,
    client_infodebit_status character varying,
    posta_mail_id character varying(255),
    aer numeric(19,4),
    last_updated timestamp without time zone,
    last_updated_user character varying(255),
    written_off_date timestamp without time zone,
    early_saved timestamp without time zone,
    collection_debt_date timestamp without time zone,
    admin_fee numeric,
    admin_fee_period_wo integer,
    collection_portfolio_id integer,
    source_gsm character varying(20),
    apr_client numeric,
    submit_post_office character varying(255),
    client_infodebit_debtcnt integer,
    client_infodebit_totaldebt numeric,
    agreement_signment character varying(20),
    pay_out_to character varying(20),
    monthly_payback numeric,
    latest_client integer,
    printed boolean DEFAULT false,
    salesman_phone character varying(255),
    branded_card_id integer,
    branded_card_office character varying(255),
    fresh_card boolean DEFAULT false,
    internal_collection_date timestamp without time zone,
    internal_collection_debt numeric,
    passed_internal_collection boolean DEFAULT false,
    send_to_debt_date timestamp without time zone,
    auto_approved boolean DEFAULT false,
    salary_ratio numeric,
    sign_agreement_attached boolean DEFAULT false,
    car_check_date timestamp without time zone,
    car_checker character varying(255),
    car_pledge_check_date timestamp without time zone,
    car_pledge_checker character varying(255),
    internal_collection_rate character varying(255),
    overdue_settings_id integer,
    car_pledge_registration_date timestamp without time zone
);


ALTER TABLE loan_application OWNER TO postgres;

--
-- Name: custom_cpi_base; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW custom_cpi_base AS
 SELECT base.loanappid,
    cp.id,
    base.totaldue,
    base.totalpaid,
    cp.gender,
    date_part('year'::text, age(la.paid_out_date, cp.birth_date)) AS age,
    cp.gsmtype,
    cp.marital_status,
    cp.real_estate,
    cp.dwelling_type,
    cp.underage_children,
    cp.pets,
    cp.car,
    date_part('year'::text, age(la.paid_out_date, cp.work_started)) AS work_period,
    cp.education,
    cp.job_income,
    cp.birth_date,
    la.ref_nr
   FROM ((get_cpi_basedata(90, '2013-02-01'::date, '2013-05-31'::date, '2013-03-01'::date, '2013-06-30'::date) base(loanappid, totaldue, totalpaid)
     LEFT JOIN loan_application la ON ((la.id = base.loanappid)))
     LEFT JOIN client_profile cp ON ((la.client_id = cp.id)));


ALTER TABLE custom_cpi_base OWNER TO postgres;

--
-- Name: custom_cpi_base_30; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW custom_cpi_base_30 AS
 SELECT base.loanappid,
    cp.id,
    base.totaldue,
    base.totalpaid,
    cp.gender,
    date_part('year'::text, age(la.paid_out_date, cp.birth_date)) AS age,
    cp.gsmtype,
    cp.marital_status,
    cp.real_estate,
    cp.dwelling_type,
    cp.underage_children,
    cp.pets,
    cp.car,
    date_part('year'::text, age(la.paid_out_date, cp.work_started)) AS work_period,
    cp.education,
    cp.job_income,
    cp.birth_date,
    la.ref_nr
   FROM ((get_cpi_person_base(30, '2012-07-01'::date, '2013-07-31'::date, '2012-07-01'::date, '2013-10-14'::date) base(loanappid, checkedby, scoredby, totaldue, totalpaid)
     LEFT JOIN loan_application la ON ((la.id = base.loanappid)))
     LEFT JOIN client_profile cp ON ((la.client_id = cp.id)));


ALTER TABLE custom_cpi_base_30 OWNER TO postgres;

--
-- Name: custom_cpi_base_90; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW custom_cpi_base_90 AS
 SELECT base.loanappid,
    cp.id,
    base.totaldue,
    base.totalpaid,
    cp.gender,
    date_part('year'::text, age(la.paid_out_date, cp.birth_date)) AS age,
    cp.gsmtype,
    cp.marital_status,
    cp.real_estate,
    cp.dwelling_type,
    cp.underage_children,
    cp.pets,
    cp.car,
    date_part('year'::text, age(la.paid_out_date, cp.work_started)) AS work_period,
    cp.education,
    cp.job_income,
    cp.birth_date,
    la.ref_nr
   FROM ((get_cpi_person_base(90, '2012-07-01'::date, '2013-07-31'::date, '2012-07-01'::date, '2013-07-15'::date) base(loanappid, checkedby, scoredby, totaldue, totalpaid)
     LEFT JOIN loan_application la ON ((la.id = base.loanappid)))
     LEFT JOIN client_profile cp ON ((la.client_id = cp.id)));


ALTER TABLE custom_cpi_base_90 OWNER TO postgres;

--
-- Name: custom_product; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE custom_product (
    id integer NOT NULL,
    available character varying(255),
    created timestamp without time zone,
    deleted boolean DEFAULT false,
    description character varying(255),
    max_period integer,
    max_principal numeric,
    min_period integer,
    min_principal numeric,
    name character varying(50) NOT NULL,
    extended_product_id integer NOT NULL,
    end_date timestamp without time zone,
    hidden boolean DEFAULT false,
    last_notified_due_date timestamp without time zone,
    start_date timestamp without time zone,
    description_alt character varying(255),
    name_alt character varying(100),
    enabled boolean DEFAULT true
);


ALTER TABLE custom_product OWNER TO postgres;

--
-- Name: custom_product_condition; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE custom_product_condition (
    id integer NOT NULL,
    adv_payment_fix numeric,
    adv_payment_perc numeric,
    amount_from numeric,
    amount_to numeric,
    bonus_fix numeric,
    bonus_perc numeric,
    client_commission boolean DEFAULT false,
    commission_fix numeric,
    commission_perc numeric,
    interest_perc numeric,
    period integer,
    shop_fee_fix numeric,
    shop_fee_perc numeric,
    custom_product_id integer NOT NULL,
    commission_limit_min numeric,
    mixed_commission boolean DEFAULT false,
    admin_fee_fix numeric,
    admin_fee_perc numeric,
    admin_fee_period_wo numeric
);


ALTER TABLE custom_product_condition OWNER TO postgres;

--
-- Name: custom_product_condition_custom_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE custom_product_condition_custom_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE custom_product_condition_custom_product_id_seq OWNER TO postgres;

--
-- Name: custom_product_condition_custom_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE custom_product_condition_custom_product_id_seq OWNED BY custom_product_condition.custom_product_id;


--
-- Name: custom_product_condition_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE custom_product_condition_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE custom_product_condition_id_seq OWNER TO postgres;

--
-- Name: custom_product_condition_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE custom_product_condition_id_seq OWNED BY custom_product_condition.id;


--
-- Name: custom_product_dealer; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE custom_product_dealer (
    id integer NOT NULL,
    bonus_fix double precision,
    bonus_perc double precision,
    custom_product_id integer NOT NULL,
    dealer_id integer NOT NULL
);


ALTER TABLE custom_product_dealer OWNER TO postgres;

--
-- Name: custom_product_dealer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE custom_product_dealer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE custom_product_dealer_id_seq OWNER TO postgres;

--
-- Name: custom_product_dealer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE custom_product_dealer_id_seq OWNED BY custom_product_dealer.id;


--
-- Name: custom_product_extended_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE custom_product_extended_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE custom_product_extended_product_id_seq OWNER TO postgres;

--
-- Name: custom_product_extended_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE custom_product_extended_product_id_seq OWNED BY custom_product.extended_product_id;


--
-- Name: custom_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE custom_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE custom_product_id_seq OWNER TO postgres;

--
-- Name: custom_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE custom_product_id_seq OWNED BY custom_product.id;


--
-- Name: dealer; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE dealer (
    id integer NOT NULL,
    address character varying(255),
    bank_account character varying(255),
    bank_code character varying(255),
    bank_name character varying(255),
    city character varying(255),
    company_name character varying(255),
    contact_person character varying(255),
    created timestamp without time zone,
    fiscal_nr character varying(255),
    name character varying(255) NOT NULL,
    old_crm_id integer,
    phone character varying(255),
    zip character varying(255),
    accrued_debt numeric,
    contract_date character varying(255),
    contract_nr character varying(255),
    email character varying(255),
    last_task_time timestamp without time zone,
    payment_period integer,
    payment_type character varying DEFAULT 'single'::character varying,
    vip boolean DEFAULT false,
    agreement_signed_btn boolean DEFAULT false,
    allow_unofficially_employed boolean DEFAULT false,
    main_products_visible boolean DEFAULT false,
    bonus_points_applicable boolean DEFAULT false,
    message text,
    repayment_enabled boolean DEFAULT false,
    repayment_group integer DEFAULT 0,
    allow_api boolean DEFAULT false,
    enabled boolean DEFAULT true,
    activity_type character varying(255),
    can_sign_dealer_products boolean DEFAULT true,
    can_sign_regular_products boolean DEFAULT false,
    responsible_person character varying(255),
    can_sign_car_dealer_products boolean DEFAULT false,
    category integer,
    monthly_limit numeric
);


ALTER TABLE dealer OWNER TO postgres;

--
-- Name: dealer_bonus_points; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE dealer_bonus_points (
    id integer NOT NULL,
    cause character varying NOT NULL,
    created timestamp without time zone NOT NULL,
    point_value integer DEFAULT 3 NOT NULL,
    points integer NOT NULL,
    username character varying(255) DEFAULT NULL::character varying,
    agent_id integer NOT NULL,
    loan_app_id integer
);


ALTER TABLE dealer_bonus_points OWNER TO postgres;

--
-- Name: dealer_bonus_points_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE dealer_bonus_points_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dealer_bonus_points_id_seq OWNER TO postgres;

--
-- Name: dealer_bonus_points_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE dealer_bonus_points_id_seq OWNED BY dealer_bonus_points.id;


--
-- Name: dealer_bonus_settings; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE dealer_bonus_settings (
    id integer NOT NULL,
    key character varying NOT NULL,
    value text NOT NULL
);


ALTER TABLE dealer_bonus_settings OWNER TO postgres;

--
-- Name: dealer_bonus_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE dealer_bonus_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dealer_bonus_settings_id_seq OWNER TO postgres;

--
-- Name: dealer_bonus_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE dealer_bonus_settings_id_seq OWNED BY dealer_bonus_settings.id;


--
-- Name: dealer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE dealer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dealer_id_seq OWNER TO postgres;

--
-- Name: dealer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE dealer_id_seq OWNED BY dealer.id;


--
-- Name: dealer_repayments; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE dealer_repayments (
    id integer NOT NULL,
    accepted boolean DEFAULT false,
    created timestamp without time zone,
    firstname character varying(255),
    lastname character varying(255),
    sum numeric,
    user_name character varying(255),
    dealer_id integer NOT NULL,
    loan_app_id integer NOT NULL
);


ALTER TABLE dealer_repayments OWNER TO postgres;

--
-- Name: dealer_repayments_dealer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE dealer_repayments_dealer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dealer_repayments_dealer_id_seq OWNER TO postgres;

--
-- Name: dealer_repayments_dealer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE dealer_repayments_dealer_id_seq OWNED BY dealer_repayments.dealer_id;


--
-- Name: dealer_repayments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE dealer_repayments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dealer_repayments_id_seq OWNER TO postgres;

--
-- Name: dealer_repayments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE dealer_repayments_id_seq OWNED BY dealer_repayments.id;


--
-- Name: dealer_repayments_loan_app_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE dealer_repayments_loan_app_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dealer_repayments_loan_app_id_seq OWNER TO postgres;

--
-- Name: dealer_repayments_loan_app_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE dealer_repayments_loan_app_id_seq OWNED BY dealer_repayments.loan_app_id;


--
-- Name: delay_interest; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE delay_interest (
    id integer NOT NULL,
    calculated_date timestamp without time zone,
    covered_delay_id integer,
    loan_app_id integer,
    sum numeric,
    installment_id integer NOT NULL
);


ALTER TABLE delay_interest OWNER TO postgres;

--
-- Name: delay_interest_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE delay_interest_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE delay_interest_id_seq OWNER TO postgres;

--
-- Name: delay_interest_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE delay_interest_id_seq OWNED BY delay_interest.id;


--
-- Name: delay_interest_installment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE delay_interest_installment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE delay_interest_installment_id_seq OWNER TO postgres;

--
-- Name: delay_interest_installment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE delay_interest_installment_id_seq OWNED BY delay_interest.installment_id;


--
-- Name: destroyed_loans_batch; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE destroyed_loans_batch (
    id integer NOT NULL,
    batch_size integer NOT NULL,
    batch_timestamp timestamp without time zone NOT NULL,
    username character varying(255) NOT NULL
);


ALTER TABLE destroyed_loans_batch OWNER TO postgres;

--
-- Name: destroyed_loans_batch_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE destroyed_loans_batch_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE destroyed_loans_batch_id_seq OWNER TO postgres;

--
-- Name: destroyed_loans_batch_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE destroyed_loans_batch_id_seq OWNED BY destroyed_loans_batch.id;


--
-- Name: doc_template; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE doc_template (
    id integer NOT NULL,
    content text,
    created timestamp without time zone,
    name character varying(255),
    calculator boolean DEFAULT false,
    guarantee boolean DEFAULT false,
    has_signature boolean DEFAULT false,
    has_stamp boolean DEFAULT false,
    lang character varying(255),
    last_updated timestamp without time zone,
    last_updated_user character varying(255),
    signature_bottom_margin integer,
    signature_bottom_margin_last integer,
    signature_every_page boolean DEFAULT false,
    signature_right_margin integer,
    signature_right_margin_last integer,
    stamp_bottom_margin integer,
    stamp_bottom_margin_last integer,
    stamp_every_page boolean DEFAULT false,
    stamp_right_margin integer,
    stamp_right_margin_last integer,
    type character varying(255),
    posta boolean DEFAULT false,
    admin_fee boolean DEFAULT false,
    universal boolean DEFAULT false,
    template_type character varying DEFAULT 'letter'::character varying
);


ALTER TABLE doc_template OWNER TO postgres;

--
-- Name: doc_template_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE doc_template_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE doc_template_id_seq OWNER TO postgres;

--
-- Name: doc_template_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE doc_template_id_seq OWNED BY doc_template.id;


--
-- Name: doc_template_loan_product; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE doc_template_loan_product (
    id integer NOT NULL,
    loan_product_id integer NOT NULL,
    template_id integer NOT NULL
);


ALTER TABLE doc_template_loan_product OWNER TO postgres;

--
-- Name: doc_template_loan_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE doc_template_loan_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE doc_template_loan_product_id_seq OWNER TO postgres;

--
-- Name: doc_template_loan_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE doc_template_loan_product_id_seq OWNED BY doc_template_loan_product.id;


--
-- Name: doc_template_loan_product_loan_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE doc_template_loan_product_loan_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE doc_template_loan_product_loan_product_id_seq OWNER TO postgres;

--
-- Name: doc_template_loan_product_loan_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE doc_template_loan_product_loan_product_id_seq OWNED BY doc_template_loan_product.loan_product_id;


--
-- Name: doc_template_loan_product_template_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE doc_template_loan_product_template_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE doc_template_loan_product_template_id_seq OWNER TO postgres;

--
-- Name: doc_template_loan_product_template_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE doc_template_loan_product_template_id_seq OWNED BY doc_template_loan_product.template_id;


--
-- Name: employer; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE employer (
    id integer NOT NULL,
    accountant character varying(100),
    active boolean DEFAULT false,
    board_member character varying(100),
    business_area character varying(255),
    created timestamp without time zone,
    established timestamp without time zone,
    house_number character varying(255),
    name character varying(255),
    office character varying(100),
    phone character varying(50),
    reg_code character varying(100),
    street character varying(255),
    town character varying(255),
    phone_comment character varying(255),
    income numeric,
    imported timestamp without time zone,
    address character varying(255),
    in_operation boolean,
    public_private character varying(255)
);


ALTER TABLE employer OWNER TO postgres;

--
-- Name: employer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE employer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE employer_id_seq OWNER TO postgres;

--
-- Name: employer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE employer_id_seq OWNED BY employer.id;


--
-- Name: exported_covered_app; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE exported_covered_app (
    id integer NOT NULL,
    covered_sum numeric,
    covered_app_id integer NOT NULL,
    export_payment_id integer NOT NULL
);


ALTER TABLE exported_covered_app OWNER TO postgres;

--
-- Name: exported_covered_app_covered_app_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE exported_covered_app_covered_app_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE exported_covered_app_covered_app_id_seq OWNER TO postgres;

--
-- Name: exported_covered_app_covered_app_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE exported_covered_app_covered_app_id_seq OWNED BY exported_covered_app.covered_app_id;


--
-- Name: exported_covered_app_export_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE exported_covered_app_export_payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE exported_covered_app_export_payment_id_seq OWNER TO postgres;

--
-- Name: exported_covered_app_export_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE exported_covered_app_export_payment_id_seq OWNED BY exported_covered_app.export_payment_id;


--
-- Name: exported_covered_app_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE exported_covered_app_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE exported_covered_app_id_seq OWNER TO postgres;

--
-- Name: exported_covered_app_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE exported_covered_app_id_seq OWNED BY exported_covered_app.id;


--
-- Name: exported_payment; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE exported_payment (
    id integer NOT NULL,
    confirmed boolean NOT NULL,
    exported_bank character varying(255),
    exported_date timestamp without time zone,
    exported_sum numeric,
    type character varying DEFAULT 'regular'::character varying,
    loan_app_id integer NOT NULL
);


ALTER TABLE exported_payment OWNER TO postgres;

--
-- Name: exported_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE exported_payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE exported_payment_id_seq OWNER TO postgres;

--
-- Name: exported_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE exported_payment_id_seq OWNED BY exported_payment.id;


--
-- Name: exported_payment_loan_app_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE exported_payment_loan_app_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE exported_payment_loan_app_id_seq OWNER TO postgres;

--
-- Name: exported_payment_loan_app_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE exported_payment_loan_app_id_seq OWNED BY exported_payment.loan_app_id;


--
-- Name: held_dealer_payment; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE held_dealer_payment (
    id integer NOT NULL,
    bank character varying(255),
    createdtime timestamp without time zone DEFAULT now(),
    deleted boolean DEFAULT false,
    early boolean DEFAULT false,
    processed boolean DEFAULT false,
    payment_date timestamp without time zone,
    sum numeric,
    user_name character varying(255),
    loan_app_id integer NOT NULL
);


ALTER TABLE held_dealer_payment OWNER TO postgres;

--
-- Name: held_dealer_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE held_dealer_payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE held_dealer_payment_id_seq OWNER TO postgres;

--
-- Name: held_dealer_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE held_dealer_payment_id_seq OWNED BY held_dealer_payment.id;


--
-- Name: held_dealer_payment_loan_app_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE held_dealer_payment_loan_app_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE held_dealer_payment_loan_app_id_seq OWNER TO postgres;

--
-- Name: held_dealer_payment_loan_app_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE held_dealer_payment_loan_app_id_seq OWNED BY held_dealer_payment.loan_app_id;


--
-- Name: installment_table; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE installment_table (
    id integer NOT NULL,
    admin_fee numeric,
    admission_fee numeric,
    delay numeric,
    expected_date timestamp without time zone,
    expected_total numeric,
    first_rem numeric,
    first_rem_date timestamp without time zone,
    insurance numeric,
    interest numeric,
    not_paid numeric,
    nr integer,
    other numeric,
    principal numeric,
    reminder_nr integer,
    repayments_total numeric,
    second_rem numeric,
    second_rem_date timestamp without time zone,
    term numeric,
    term_alert numeric,
    term_alert_date timestamp without time zone,
    term_date timestamp without time zone,
    third_rem numeric,
    third_rem_date timestamp without time zone,
    was_delayed boolean DEFAULT false,
    loan_app_id integer NOT NULL,
    suspended_user character varying(255),
    suspended boolean DEFAULT false,
    suspended_date timestamp without time zone,
    suspension_fee numeric DEFAULT 0,
    guarantee_fee numeric DEFAULT 0
);


ALTER TABLE installment_table OWNER TO postgres;

--
-- Name: installment_table_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE installment_table_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE installment_table_id_seq OWNER TO postgres;

--
-- Name: installment_table_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE installment_table_id_seq OWNED BY installment_table.id;


--
-- Name: installment_table_loan_app_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE installment_table_loan_app_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE installment_table_loan_app_id_seq OWNER TO postgres;

--
-- Name: installment_table_loan_app_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE installment_table_loan_app_id_seq OWNED BY installment_table.loan_app_id;


--
-- Name: loan_app_data_check; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE loan_app_data_check (
    id integer NOT NULL,
    field character varying(255) NOT NULL,
    loan_app_id integer NOT NULL,
    status character varying(255),
    username character varying(255)
);


ALTER TABLE loan_app_data_check OWNER TO postgres;

--
-- Name: loan_app_data_check_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE loan_app_data_check_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE loan_app_data_check_id_seq OWNER TO postgres;

--
-- Name: loan_app_data_check_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE loan_app_data_check_id_seq OWNED BY loan_app_data_check.id;


--
-- Name: loan_app_file; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE loan_app_file (
    id integer NOT NULL,
    checked boolean DEFAULT false,
    created timestamp without time zone,
    file_name character varying(255),
    file_type character varying(255),
    loan_app_id integer NOT NULL,
    folder character varying(255)
);


ALTER TABLE loan_app_file OWNER TO postgres;

--
-- Name: loan_app_file_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE loan_app_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE loan_app_file_id_seq OWNER TO postgres;

--
-- Name: loan_app_file_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE loan_app_file_id_seq OWNED BY loan_app_file.id;


--
-- Name: loan_app_file_loan_app_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE loan_app_file_loan_app_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE loan_app_file_loan_app_id_seq OWNER TO postgres;

--
-- Name: loan_app_file_loan_app_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE loan_app_file_loan_app_id_seq OWNED BY loan_app_file.loan_app_id;


--
-- Name: loan_application_client_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE loan_application_client_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE loan_application_client_id_seq OWNER TO postgres;

--
-- Name: loan_application_client_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE loan_application_client_id_seq OWNED BY loan_application.client_id;


--
-- Name: loan_application_custom_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE loan_application_custom_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE loan_application_custom_product_id_seq OWNER TO postgres;

--
-- Name: loan_application_custom_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE loan_application_custom_product_id_seq OWNED BY loan_application.custom_product_id;


--
-- Name: loan_application_dealer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE loan_application_dealer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE loan_application_dealer_id_seq OWNER TO postgres;

--
-- Name: loan_application_dealer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE loan_application_dealer_id_seq OWNED BY loan_application.dealer_id;


--
-- Name: loan_application_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE loan_application_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE loan_application_id_seq OWNER TO postgres;

--
-- Name: loan_application_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE loan_application_id_seq OWNED BY loan_application.id;


--
-- Name: loan_application_loan_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE loan_application_loan_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE loan_application_loan_product_id_seq OWNER TO postgres;

--
-- Name: loan_application_loan_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE loan_application_loan_product_id_seq OWNED BY loan_application.loan_product_id;


--
-- Name: loan_application_post_office_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE loan_application_post_office_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE loan_application_post_office_id_seq OWNER TO postgres;

--
-- Name: loan_application_post_office_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE loan_application_post_office_id_seq OWNED BY loan_application.post_office_id;


--
-- Name: loan_apr; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE loan_apr (
    id integer NOT NULL,
    apr numeric,
    apr_stage character varying(255),
    created timestamp without time zone,
    username character varying(255),
    loan_app_id integer NOT NULL
);


ALTER TABLE loan_apr OWNER TO postgres;

--
-- Name: loan_apr_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE loan_apr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE loan_apr_id_seq OWNER TO postgres;

--
-- Name: loan_apr_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE loan_apr_id_seq OWNED BY loan_apr.id;


--
-- Name: loan_apr_loan_app_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE loan_apr_loan_app_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE loan_apr_loan_app_id_seq OWNER TO postgres;

--
-- Name: loan_apr_loan_app_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE loan_apr_loan_app_id_seq OWNED BY loan_apr.loan_app_id;


--
-- Name: loan_product_car_value_perc; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE loan_product_car_value_perc (
    id integer NOT NULL,
    car_value_from numeric,
    car_value_to numeric,
    max_loan_perc numeric,
    loan_product_id integer NOT NULL
);


ALTER TABLE loan_product_car_value_perc OWNER TO postgres;

--
-- Name: loan_product_car_value_perc_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE loan_product_car_value_perc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE loan_product_car_value_perc_id_seq OWNER TO postgres;

--
-- Name: loan_product_car_value_perc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE loan_product_car_value_perc_id_seq OWNED BY loan_product_car_value_perc.id;


--
-- Name: loan_product_car_value_perc_loan_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE loan_product_car_value_perc_loan_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE loan_product_car_value_perc_loan_product_id_seq OWNER TO postgres;

--
-- Name: loan_product_car_value_perc_loan_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE loan_product_car_value_perc_loan_product_id_seq OWNED BY loan_product_car_value_perc.loan_product_id;


--
-- Name: loan_product_condition; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE loan_product_condition (
    id integer NOT NULL,
    commission_perc numeric,
    commission_perc_cash numeric,
    interest_perc numeric,
    interest_perc_cash numeric,
    loan_amount_from numeric,
    loan_amount_to numeric,
    period integer,
    loan_product_id integer NOT NULL
);


ALTER TABLE loan_product_condition OWNER TO postgres;

--
-- Name: loan_product_condition_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE loan_product_condition_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE loan_product_condition_id_seq OWNER TO postgres;

--
-- Name: loan_product_condition_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE loan_product_condition_id_seq OWNED BY loan_product_condition.id;


--
-- Name: loan_product_condition_loan_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE loan_product_condition_loan_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE loan_product_condition_loan_product_id_seq OWNER TO postgres;

--
-- Name: loan_product_condition_loan_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE loan_product_condition_loan_product_id_seq OWNED BY loan_product_condition.loan_product_id;


--
-- Name: loan_product_settings; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE loan_product_settings (
    id integer NOT NULL,
    check_docs_duration integer,
    checking_duration integer,
    scoring_duration integer,
    notify_client_duration integer,
    pay_out_duration integer,
    upload_agreement_duration integer,
    vip boolean DEFAULT false,
    loan_product_id integer NOT NULL,
    send_precontract_duration integer,
    allow_cash_release_duration integer,
    dealer_id integer,
    type character varying DEFAULT 'general'::character varying,
    check_score_duration integer,
    check_official_duration integer,
    check_official_short_duration integer,
    check_unofficial_altcontact_duration integer,
    check_unofficial_employer_duration integer,
    check_unofficial_person_duration integer,
    check_balance_duration integer,
    deposit_money_duration integer,
    issue_card_duration integer,
    issue_pin_duration integer,
    bonus_task_duration_until_paid_out smallint DEFAULT 30
);


ALTER TABLE loan_product_settings OWNER TO postgres;

--
-- Name: loan_product_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE loan_product_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE loan_product_settings_id_seq OWNER TO postgres;

--
-- Name: loan_product_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE loan_product_settings_id_seq OWNED BY loan_product_settings.id;


--
-- Name: loan_product_settings_loan_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE loan_product_settings_loan_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE loan_product_settings_loan_product_id_seq OWNER TO postgres;

--
-- Name: loan_product_settings_loan_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE loan_product_settings_loan_product_id_seq OWNED BY loan_product_settings.loan_product_id;


--
-- Name: loan_products; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE loan_products (
    id integer NOT NULL,
    admission_fee_perc numeric NOT NULL,
    delay_interest numeric NOT NULL,
    max_interest numeric NOT NULL,
    max_loan_period integer NOT NULL,
    max_principal numeric NOT NULL,
    min_interest numeric NOT NULL,
    min_loan_period integer NOT NULL,
    min_principal numeric NOT NULL,
    name character varying(50) NOT NULL,
    requires_identity_files boolean,
    type character varying DEFAULT 'regular'::character varying NOT NULL,
    min_reminder_debt numeric,
    min_termination_debt numeric,
    suspension_fee numeric,
    apr_threshold numeric,
    req_id_copy boolean DEFAULT false,
    req_salary_cert boolean DEFAULT false,
    min_apr numeric,
    max_apr numeric,
    pm_default boolean DEFAULT false,
    delay_days integer,
    min_delay_debt numeric,
    salary_ratio_regular numeric,
    salary_ratio_second_active numeric,
    salary_ratio_unofficial numeric,
    guarantee_fee_perc numeric,
    guarantee_max_period integer,
    guarantee_product boolean DEFAULT false,
    apr_threshold_guarantee numeric,
    max_delay_days integer,
    paid_inst_records_threshold smallint,
    turnover_threshold numeric,
    official_paid_inst_records_threshold smallint,
    official_turnover_threshold numeric,
    max_suspended_days smallint DEFAULT 17,
    salary_cert_limit numeric,
    official_paid_inst_records_threshold_office smallint,
    official_turnover_threshold_office numeric,
    paid_inst_records_threshold_office smallint,
    turnover_threshold_office numeric,
    enabled boolean DEFAULT true,
    sort_order smallint,
    internal_collection_days numeric DEFAULT 0,
    car_loan boolean DEFAULT false,
    max_car_value_perc numeric DEFAULT 0.0,
    apr_threshold_evening numeric,
    apr_threshold_evening_guarantee numeric,
    closed_loans_archival_threshold_years smallint DEFAULT 3,
    defaulted_loans_archival_threshold_years smallint DEFAULT 5,
    dept_collection_days integer,
    first_call_days integer,
    first_letter_days integer,
    first_letter_fee numeric,
    first_sms_days integer,
    first_sms_text character varying(255),
    fourth_call_days integer,
    invitation_text text,
    payment_sms_days integer,
    preclaim_days integer,
    second_call_days integer,
    second_letter_days integer,
    second_letter_fee numeric,
    second_sms_days integer,
    second_sms_text character varying(255),
    term_alert_letter_days integer,
    term_alert_letter_fee numeric,
    term_letter_days integer,
    term_letter_days_max integer,
    term_letter_fee_perc numeric,
    term_sms_days integer,
    thankyou_notice text,
    third_call_days integer,
    third_letter_days integer,
    third_letter_fee numeric,
    third_sms_days integer,
    guarantee_monthly_max numeric
);


ALTER TABLE loan_products OWNER TO postgres;

--
-- Name: loan_products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE loan_products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE loan_products_id_seq OWNER TO postgres;

--
-- Name: loan_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE loan_products_id_seq OWNED BY loan_products.id;


--
-- Name: loan_qualif_reqs; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE loan_qualif_reqs (
    loan_qualif_req_id integer NOT NULL,
    filter_operand character varying(255) NOT NULL,
    filter_type character varying(255) NOT NULL,
    filter_value character varying(255) NOT NULL,
    loan_product_id integer NOT NULL
);


ALTER TABLE loan_qualif_reqs OWNER TO postgres;

--
-- Name: loan_qualif_reqs_loan_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE loan_qualif_reqs_loan_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE loan_qualif_reqs_loan_product_id_seq OWNER TO postgres;

--
-- Name: loan_qualif_reqs_loan_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE loan_qualif_reqs_loan_product_id_seq OWNED BY loan_qualif_reqs.loan_product_id;


--
-- Name: loan_qualif_reqs_loan_qualif_req_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE loan_qualif_reqs_loan_qualif_req_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE loan_qualif_reqs_loan_qualif_req_id_seq OWNER TO postgres;

--
-- Name: loan_qualif_reqs_loan_qualif_req_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE loan_qualif_reqs_loan_qualif_req_id_seq OWNED BY loan_qualif_reqs.loan_qualif_req_id;


--
-- Name: loan_status; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE loan_status (
    id bigint NOT NULL,
    loan_app_id integer,
    generated timestamp without time zone,
    status character varying
);


ALTER TABLE loan_status OWNER TO postgres;

--
-- Name: loan_status_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE loan_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE loan_status_id_seq OWNER TO postgres;

--
-- Name: loan_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE loan_status_id_seq OWNED BY loan_status.id;


--
-- Name: loan_task; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE loan_task (
    id integer NOT NULL,
    created timestamp without time zone,
    loan_app_id integer,
    proc_inst_id character varying(255),
    task_id character varying(255),
    task_key character varying(255)
);


ALTER TABLE loan_task OWNER TO postgres;

--
-- Name: loan_task_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE loan_task_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE loan_task_id_seq OWNER TO postgres;

--
-- Name: loan_task_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE loan_task_id_seq OWNED BY loan_task.id;


--
-- Name: mintos_loan; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE mintos_loan (
    id integer NOT NULL,
    finished boolean DEFAULT false,
    finished_date timestamp without time zone,
    loan_amount_eur numeric(19,2),
    mintos_loan_id integer,
    rebought_date timestamp without time zone,
    sent_to_mintos timestamp without time zone,
    loan_app_id integer NOT NULL,
    mintos_portfolio_id integer NOT NULL
);


ALTER TABLE mintos_loan OWNER TO postgres;

--
-- Name: mintos_loan_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE mintos_loan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mintos_loan_id_seq OWNER TO postgres;

--
-- Name: mintos_loan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE mintos_loan_id_seq OWNED BY mintos_loan.id;


--
-- Name: mintos_loan_loan_app_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE mintos_loan_loan_app_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mintos_loan_loan_app_id_seq OWNER TO postgres;

--
-- Name: mintos_loan_loan_app_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE mintos_loan_loan_app_id_seq OWNED BY mintos_loan.loan_app_id;


--
-- Name: mintos_loan_mintos_portfolio_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE mintos_loan_mintos_portfolio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mintos_loan_mintos_portfolio_id_seq OWNER TO postgres;

--
-- Name: mintos_loan_mintos_portfolio_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE mintos_loan_mintos_portfolio_id_seq OWNED BY mintos_loan.mintos_portfolio_id;


--
-- Name: mintos_portfolio; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE mintos_portfolio (
    id integer NOT NULL,
    currency_rate numeric(19,2),
    interest_rate numeric(6,3)
);


ALTER TABLE mintos_portfolio OWNER TO postgres;

--
-- Name: mintos_portfolio_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE mintos_portfolio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mintos_portfolio_id_seq OWNER TO postgres;

--
-- Name: mintos_portfolio_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE mintos_portfolio_id_seq OWNED BY mintos_portfolio.id;


--
-- Name: mintos_repayment; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE mintos_repayment (
    id integer NOT NULL,
    interest_amount_eur numeric(19,2),
    remaining_principal_eur numeric(19,2),
    repayment_amount_eur numeric(19,2),
    sent_to_mintos timestamp without time zone,
    loan_app_id integer NOT NULL,
    repayment_id integer NOT NULL,
    repayment_type_id integer NOT NULL,
    penalty_amount_eur numeric(19,2)
);


ALTER TABLE mintos_repayment OWNER TO postgres;

--
-- Name: mintos_repayment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE mintos_repayment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mintos_repayment_id_seq OWNER TO postgres;

--
-- Name: mintos_repayment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE mintos_repayment_id_seq OWNED BY mintos_repayment.id;


--
-- Name: mintos_repayment_loan_app_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE mintos_repayment_loan_app_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mintos_repayment_loan_app_id_seq OWNER TO postgres;

--
-- Name: mintos_repayment_loan_app_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE mintos_repayment_loan_app_id_seq OWNED BY mintos_repayment.loan_app_id;


--
-- Name: mintos_repayment_repayment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE mintos_repayment_repayment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mintos_repayment_repayment_id_seq OWNER TO postgres;

--
-- Name: mintos_repayment_repayment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE mintos_repayment_repayment_id_seq OWNED BY mintos_repayment.repayment_id;


--
-- Name: mintos_repayment_repayment_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE mintos_repayment_repayment_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mintos_repayment_repayment_type_id_seq OWNER TO postgres;

--
-- Name: mintos_repayment_repayment_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE mintos_repayment_repayment_type_id_seq OWNED BY mintos_repayment.repayment_type_id;


--
-- Name: overdue_action; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE overdue_action (
    id integer NOT NULL,
    action_desc character varying(255),
    action_fee numeric(19,2),
    action_fee_unit character varying(255),
    action_name character varying(255),
    action_type character varying(255),
    created timestamp without time zone,
    doc_template_id integer,
    doc_template_secondary_id integer,
    overdue_days integer,
    reminder_type integer,
    skip_for_suspended boolean DEFAULT false,
    soft_process_action boolean DEFAULT false,
    overdue_settings_id integer NOT NULL
);


ALTER TABLE overdue_action OWNER TO postgres;

--
-- Name: overdue_action_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE overdue_action_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE overdue_action_id_seq OWNER TO postgres;

--
-- Name: overdue_action_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE overdue_action_id_seq OWNED BY overdue_action.id;


--
-- Name: overdue_action_installment; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE overdue_action_installment (
    id integer NOT NULL,
    created timestamp without time zone,
    loan_app_id integer,
    installment_id integer NOT NULL,
    overdue_action_id integer NOT NULL
);


ALTER TABLE overdue_action_installment OWNER TO postgres;

--
-- Name: overdue_action_installment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE overdue_action_installment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE overdue_action_installment_id_seq OWNER TO postgres;

--
-- Name: overdue_action_installment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE overdue_action_installment_id_seq OWNED BY overdue_action_installment.id;


--
-- Name: overdue_action_installment_installment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE overdue_action_installment_installment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE overdue_action_installment_installment_id_seq OWNER TO postgres;

--
-- Name: overdue_action_installment_installment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE overdue_action_installment_installment_id_seq OWNED BY overdue_action_installment.installment_id;


--
-- Name: overdue_action_installment_overdue_action_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE overdue_action_installment_overdue_action_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE overdue_action_installment_overdue_action_id_seq OWNER TO postgres;

--
-- Name: overdue_action_installment_overdue_action_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE overdue_action_installment_overdue_action_id_seq OWNED BY overdue_action_installment.overdue_action_id;


--
-- Name: overdue_action_overdue_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE overdue_action_overdue_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE overdue_action_overdue_settings_id_seq OWNER TO postgres;

--
-- Name: overdue_action_overdue_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE overdue_action_overdue_settings_id_seq OWNED BY overdue_action.overdue_settings_id;


--
-- Name: overdue_delay_interest; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE overdue_delay_interest (
    id integer NOT NULL,
    created timestamp without time zone,
    debt_from numeric(19,2),
    debt_to numeric(19,2),
    delay_interest_sum numeric(19,2),
    overdue_settings_id integer NOT NULL
);


ALTER TABLE overdue_delay_interest OWNER TO postgres;

--
-- Name: overdue_delay_interest_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE overdue_delay_interest_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE overdue_delay_interest_id_seq OWNER TO postgres;

--
-- Name: overdue_delay_interest_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE overdue_delay_interest_id_seq OWNED BY overdue_delay_interest.id;


--
-- Name: overdue_delay_interest_overdue_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE overdue_delay_interest_overdue_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE overdue_delay_interest_overdue_settings_id_seq OWNER TO postgres;

--
-- Name: overdue_delay_interest_overdue_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE overdue_delay_interest_overdue_settings_id_seq OWNED BY overdue_delay_interest.overdue_settings_id;


--
-- Name: overdue_process_settings; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE overdue_process_settings (
    id integer NOT NULL,
    created timestamp without time zone,
    last_updated timestamp without time zone,
    last_updated_user character varying(255),
    max_suspended_days smallint DEFAULT 17,
    valid_from timestamp without time zone,
    delay_days integer,
    delay_interest numeric(19,2),
    max_delay_days integer,
    min_delay_debt numeric(19,2),
    min_reminder_debt numeric(19,2),
    min_termination_debt numeric(19,2),
    suspension_fee numeric,
    internal_collection_days numeric DEFAULT 0
);


ALTER TABLE overdue_process_settings OWNER TO postgres;

--
-- Name: overdue_process_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE overdue_process_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE overdue_process_settings_id_seq OWNER TO postgres;

--
-- Name: overdue_process_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE overdue_process_settings_id_seq OWNED BY overdue_process_settings.id;


--
-- Name: payment; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE payment (
    id integer NOT NULL,
    bank character varying(255),
    covered_apps character varying(255),
    for_app_id_old integer,
    payment_date timestamp without time zone,
    refinance boolean DEFAULT false,
    source_crm boolean DEFAULT false,
    sum numeric,
    type character varying(255),
    user_name character varying(255),
    loan_app_id integer NOT NULL,
    actual boolean DEFAULT true,
    consolidated_payment_id integer
);


ALTER TABLE payment OWNER TO postgres;

--
-- Name: payment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE payment_id_seq OWNER TO postgres;

--
-- Name: payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE payment_id_seq OWNED BY payment.id;


--
-- Name: payment_loan_app_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE payment_loan_app_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE payment_loan_app_id_seq OWNER TO postgres;

--
-- Name: payment_loan_app_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE payment_loan_app_id_seq OWNED BY payment.loan_app_id;


--
-- Name: phone_call; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE phone_call (
    id integer NOT NULL,
    action character varying(255),
    ami_identifier character varying(255),
    answer_status character varying(255),
    call_end timestamp without time zone,
    call_start timestamp without time zone,
    call_type character varying(255),
    caller_number character varying(255) NOT NULL,
    channel character varying(255),
    receiver_number character varying(255) NOT NULL,
    status character varying(255) NOT NULL,
    user_id integer
);


ALTER TABLE phone_call OWNER TO postgres;

--
-- Name: phone_call_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE phone_call_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE phone_call_id_seq OWNER TO postgres;

--
-- Name: phone_call_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE phone_call_id_seq OWNED BY phone_call.id;


--
-- Name: post_office; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE post_office (
    id integer NOT NULL,
    active boolean DEFAULT false,
    address character varying(255),
    city character varying(255),
    created timestamp without time zone,
    deleted boolean DEFAULT false,
    deleted_date timestamp without time zone,
    name character varying(255) NOT NULL,
    office_nr character varying(255),
    email character varying(255),
    phone character varying(255)
);


ALTER TABLE post_office OWNER TO postgres;

--
-- Name: post_office_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE post_office_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE post_office_id_seq OWNER TO postgres;

--
-- Name: post_office_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE post_office_id_seq OWNED BY post_office.id;


--
-- Name: post_office_workday; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE post_office_workday (
    id integer NOT NULL,
    day integer NOT NULL,
    end_hour integer,
    end_minute integer,
    open boolean DEFAULT false,
    start_hour integer,
    start_minute integer,
    post_office_id integer NOT NULL
);


ALTER TABLE post_office_workday OWNER TO postgres;

--
-- Name: post_office_workday_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE post_office_workday_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE post_office_workday_id_seq OWNER TO postgres;

--
-- Name: post_office_workday_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE post_office_workday_id_seq OWNED BY post_office_workday.id;


--
-- Name: post_office_workday_post_office_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE post_office_workday_post_office_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE post_office_workday_post_office_id_seq OWNER TO postgres;

--
-- Name: post_office_workday_post_office_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE post_office_workday_post_office_id_seq OWNED BY post_office_workday.post_office_id;


--
-- Name: posta_deposit; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE posta_deposit (
    id integer NOT NULL,
    bank character varying(255),
    payment_date timestamp without time zone,
    source character varying(255),
    sum numeric,
    user_name character varying(255)
);


ALTER TABLE posta_deposit OWNER TO postgres;

--
-- Name: posta_deposit_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE posta_deposit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE posta_deposit_id_seq OWNER TO postgres;

--
-- Name: posta_deposit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE posta_deposit_id_seq OWNED BY posta_deposit.id;


--
-- Name: posta_request_email; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE posta_request_email (
    mailid character varying(255) NOT NULL,
    email character varying(255)
);


ALTER TABLE posta_request_email OWNER TO postgres;

--
-- Name: production_alerts; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE production_alerts (
    id integer NOT NULL,
    created timestamp without time zone DEFAULT now(),
    loan_app_id integer,
    loan_product_id integer,
    operation character varying(255) NOT NULL,
    ref_nr integer,
    task_id character varying(255),
    username character varying(255)
);


ALTER TABLE production_alerts OWNER TO postgres;

--
-- Name: production_alerts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE production_alerts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE production_alerts_id_seq OWNER TO postgres;

--
-- Name: production_alerts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE production_alerts_id_seq OWNED BY production_alerts.id;


--
-- Name: random_table; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE random_table (
    col character(32) NOT NULL,
    stamp bigint NOT NULL
);


ALTER TABLE random_table OWNER TO postgres;

--
-- Name: received_sms; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE received_sms (
    id integer NOT NULL,
    date_received timestamp without time zone DEFAULT now() NOT NULL,
    sender_number character varying(12) NOT NULL,
    text character varying(255) NOT NULL,
    username character varying(50)
);


ALTER TABLE received_sms OWNER TO postgres;

--
-- Name: received_sms_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE received_sms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE received_sms_id_seq OWNER TO postgres;

--
-- Name: received_sms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE received_sms_id_seq OWNED BY received_sms.id;


--
-- Name: reference_employer; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE reference_employer (
    id integer NOT NULL,
    active boolean,
    address character varying(255),
    date_founded timestamp without time zone,
    directors character varying(255),
    import_timestamp bigint DEFAULT 0 NOT NULL,
    modified_date timestamp without time zone,
    modified_user character varying(255),
    name character varying(255),
    org_type character varying(255),
    phone character varying(100),
    phone_comment character varying(255),
    public_private character varying(255),
    reg_code character varying(100)
);


ALTER TABLE reference_employer OWNER TO postgres;

--
-- Name: reference_employer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE reference_employer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE reference_employer_id_seq OWNER TO postgres;

--
-- Name: reference_employer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE reference_employer_id_seq OWNED BY reference_employer.id;


--
-- Name: repayment_type; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE repayment_type (
    id integer NOT NULL,
    ir_id integer,
    ir_nr integer,
    sum numeric,
    type character varying(255),
    repayment_id integer NOT NULL,
    collection_company_sum numeric,
    iute_sum numeric,
    external_id integer,
    created timestamp without time zone
);


ALTER TABLE repayment_type OWNER TO postgres;

--
-- Name: repayment_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE repayment_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE repayment_type_id_seq OWNER TO postgres;

--
-- Name: repayment_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE repayment_type_id_seq OWNED BY repayment_type.id;


--
-- Name: repayment_type_repayment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE repayment_type_repayment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE repayment_type_repayment_id_seq OWNER TO postgres;

--
-- Name: repayment_type_repayment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE repayment_type_repayment_id_seq OWNED BY repayment_type.repayment_id;


--
-- Name: repayments; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE repayments (
    id integer NOT NULL,
    bank character varying(255),
    correction boolean DEFAULT false,
    early boolean DEFAULT false,
    refinance boolean DEFAULT false,
    payment_date timestamp without time zone,
    source_crm boolean DEFAULT false,
    subtr_interest numeric,
    sum numeric,
    user_name character varying(255),
    loan_app_id integer NOT NULL,
    collection_scheme_id integer,
    created timestamp without time zone,
    group_rp_id bigint,
    bonus boolean DEFAULT false,
    writtenoff boolean DEFAULT false,
    refund boolean DEFAULT false
);


ALTER TABLE repayments OWNER TO postgres;

--
-- Name: repayments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE repayments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE repayments_id_seq OWNER TO postgres;

--
-- Name: repayments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE repayments_id_seq OWNED BY repayments.id;


--
-- Name: repayments_loan_app_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE repayments_loan_app_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE repayments_loan_app_id_seq OWNER TO postgres;

--
-- Name: repayments_loan_app_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE repayments_loan_app_id_seq OWNED BY repayments.loan_app_id;


--
-- Name: scheduled_task; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE scheduled_task (
    id integer NOT NULL,
    assignee character varying(255),
    created timestamp without time zone,
    description character varying(255),
    due timestamp without time zone,
    loan_app_id integer,
    name character varying(255),
    start timestamp without time zone,
    task_created timestamp without time zone,
    campaign_client_id integer
);


ALTER TABLE scheduled_task OWNER TO postgres;

--
-- Name: scheduled_task_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE scheduled_task_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE scheduled_task_id_seq OWNER TO postgres;

--
-- Name: scheduled_task_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE scheduled_task_id_seq OWNED BY scheduled_task.id;


--
-- Name: scorecard; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE scorecard (
    loan_app_id integer NOT NULL,
    age integer NOT NULL,
    children integer NOT NULL,
    created timestamp without time zone,
    dwelling integer NOT NULL,
    email integer NOT NULL,
    estate integer NOT NULL,
    income integer NOT NULL,
    language integer NOT NULL,
    manual_score integer,
    manual_score_user character varying(255),
    marital_status integer,
    media integer NOT NULL,
    other_loans integer,
    own_car integer,
    phone integer NOT NULL,
    "position" integer NOT NULL,
    score integer NOT NULL,
    score_group integer,
    study integer NOT NULL
);


ALTER TABLE scorecard OWNER TO postgres;

--
-- Name: settings; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE settings (
    id integer NOT NULL,
    archive_duration integer,
    close_loan_agreement_duration integer,
    contact_new_client_duration integer,
    correction_limit numeric,
    create_file_duration integer,
    overdue_tasks_manager character varying(255),
    overpayment_limit numeric,
    send_dept_collection_duration integer,
    send_termination_duration integer,
    send_dept_collection_user character varying(255),
    archive_defaulted_loan_duration integer,
    close_defaulted_loan_duration integer,
    no_task_minutes integer,
    cons_dealer_payment_duration integer,
    payout_user character varying(255),
    auth_cash_user character varying(255),
    destroy_loan_agreements_duration integer,
    destroy_loan_agreements_user character varying(255),
    posta_balance_limit numeric,
    campaign_manager character varying(255),
    posta_mail_request_duration integer,
    currency_rate_duration integer,
    written_off_deys integer,
    attach_agreement_duration integer,
    collection_fee_method character varying(255),
    currency_call_duration integer,
    currency_letter_duration integer,
    currency_perc_limit numeric,
    currency_period_limit integer,
    currency_risk_enabled boolean DEFAULT false,
    currency_risk_task_duration integer,
    currency_risk_task_user character varying(255),
    currency_sum_limit numeric,
    currency_task_user character varying(255),
    add_sms_balance_task_user character varying(255),
    sms_balance_limit numeric,
    print_loan_agreements_user character varying(255),
    contact_internal_client_duration integer,
    closed_loans_archival_threshold_years smallint DEFAULT 3,
    defaulted_loans_archival_threshold_years smallint DEFAULT 5,
    internal_collection_days numeric DEFAULT 0
);


ALTER TABLE settings OWNER TO postgres;

--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE settings_id_seq OWNER TO postgres;

--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE settings_id_seq OWNED BY settings.id;


--
-- Name: smsmessages; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE smsmessages (
    id integer NOT NULL,
    comment character varying(200),
    created timestamp without time zone DEFAULT now(),
    retries integer,
    sendtonumber character varying(12) NOT NULL,
    status character varying(20),
    text character varying(300) NOT NULL,
    type character varying(32),
    delivered timestamp without time zone,
    messageid character varying(64)
);


ALTER TABLE smsmessages OWNER TO postgres;

--
-- Name: smsmessages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE smsmessages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE smsmessages_id_seq OWNER TO postgres;

--
-- Name: smsmessages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE smsmessages_id_seq OWNED BY smsmessages.id;


--
-- Name: submitted_loan; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE submitted_loan (
    id integer NOT NULL,
    additional_income numeric,
    additional_income_comment character varying(255),
    admission_fee numeric,
    admission_fee_client numeric,
    adv_payment numeric,
    alternative_contact character varying(255),
    alternative_contact_email character varying(100),
    alternative_contact_phone character varying(100),
    alternative_contact_relation character varying(255),
    amount numeric,
    apr numeric,
    bank_account character varying(255),
    bank_code character varying(255),
    bank_name character varying(255),
    birth_date timestamp without time zone,
    car integer,
    car_reg_nr character varying(255),
    client_id integer,
    code character varying(255),
    comfort_client boolean,
    contact_person character varying(255),
    created timestamp without time zone,
    custom_product_id integer,
    dealer_id integer,
    dwelling_period character varying(30),
    dwelling_type character varying(30),
    education character varying(30),
    email character varying(255),
    employer_accountant character varying(100),
    employer_board_member character varying(100),
    employer_house_number character varying(255),
    employer_id integer,
    employer_name character varying(255),
    employer_office character varying(100),
    employer_phone character varying(50),
    employer_phone_comment character varying(255),
    employer_reg_code character varying(100),
    employer_street character varying(255),
    employer_town character varying(255),
    employment_type character varying(50),
    evening_loan boolean DEFAULT false,
    first_name character varying(100),
    first_payment timestamp without time zone,
    gender character varying(255),
    gsm character varying(255),
    gsmtype character varying(30),
    has_other_loans integer DEFAULT 0,
    has_prev_active_loan boolean DEFAULT false,
    home_apartment character varying(255),
    home_house_number character varying DEFAULT ''::character varying,
    home_street character varying(255),
    home_town character varying(255),
    home_zip character varying(255),
    id_card_nr character varying(255),
    interest_rate numeric,
    ip character varying(255),
    job_category character varying(30),
    language character varying(255),
    last_name character varying(100),
    loan_app_id integer,
    loan_office character varying DEFAULT ''::character varying,
    loan_product_id integer,
    marital_status character varying(255),
    mediasource character varying(255),
    monthly_payback_total numeric,
    job_income numeric,
    other_loans_total numeric,
    patronymic character varying(255),
    period integer,
    pet character varying(255),
    pets integer,
    phone_home character varying(255),
    phone_home_comment character varying(255),
    phone_work character varying(255),
    phone_work_comment character varying(255),
    pin character varying(50),
    "position" character varying(255),
    position_cat_old character varying(255),
    position_category character varying(30),
    position_kind character varying(100),
    position_old character varying(255),
    position_other character varying(255),
    position_sector character varying(50),
    postofficeid integer,
    purchase_cost numeric,
    purpose character varying(255),
    real_estate integer,
    real_estate_address character varying(255),
    ref_nr integer,
    referral integer,
    salesman character varying(255),
    shop_fee numeric,
    source character varying(255),
    status character varying(255),
    submit_person character varying(255),
    total_sum numeric,
    underage_children integer,
    work_started timestamp without time zone,
    auto_rejected boolean DEFAULT false,
    guarantee_fee numeric,
    guarantee_loan boolean DEFAULT false,
    prev_active_loan_id integer,
    admin_fee numeric,
    admin_fee_period_without integer,
    agricultural_income numeric,
    residence_address character varying(255),
    residence_address_same integer,
    residence_town character varying(255),
    salary_ratio numeric,
    work_duration character varying(30)
);


ALTER TABLE submitted_loan OWNER TO postgres;

--
-- Name: submitted_loan_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE submitted_loan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE submitted_loan_id_seq OWNER TO postgres;

--
-- Name: submitted_loan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE submitted_loan_id_seq OWNED BY submitted_loan.id;


--
-- Name: system_status; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE system_status (
    id integer NOT NULL,
    bpay_repayments_last_import timestamp without time zone
);


ALTER TABLE system_status OWNER TO postgres;

--
-- Name: system_status_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE system_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE system_status_id_seq OWNER TO postgres;

--
-- Name: system_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE system_status_id_seq OWNED BY system_status.id;


--
-- Name: task_data; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE task_data (
    id integer NOT NULL,
    assignee character varying(255),
    created timestamp without time zone,
    notified boolean,
    notified_overdue boolean,
    task_id character varying(255)
);


ALTER TABLE task_data OWNER TO postgres;

--
-- Name: task_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE task_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE task_data_id_seq OWNER TO postgres;

--
-- Name: task_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE task_data_id_seq OWNED BY task_data.id;


--
-- Name: temp_installment; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE temp_installment (
    id integer NOT NULL,
    admin_fee numeric,
    admin_fee_old numeric,
    commission numeric,
    commission_old numeric,
    delay numeric,
    expected_date timestamp without time zone,
    expected_total numeric,
    first_rem numeric,
    increased boolean DEFAULT false,
    interest numeric,
    interest_old numeric,
    ir_id integer,
    nr integer,
    principal numeric,
    principal_old numeric,
    second_rem numeric,
    suspension_fee numeric DEFAULT 0,
    term numeric,
    term_alert numeric,
    currency_risk_id integer NOT NULL,
    loan_app_id integer NOT NULL
);


ALTER TABLE temp_installment OWNER TO postgres;

--
-- Name: temp_installment_currency_risk_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE temp_installment_currency_risk_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE temp_installment_currency_risk_id_seq OWNER TO postgres;

--
-- Name: temp_installment_currency_risk_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE temp_installment_currency_risk_id_seq OWNED BY temp_installment.currency_risk_id;


--
-- Name: temp_installment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE temp_installment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE temp_installment_id_seq OWNER TO postgres;

--
-- Name: temp_installment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE temp_installment_id_seq OWNED BY temp_installment.id;


--
-- Name: temp_installment_loan_app_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE temp_installment_loan_app_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE temp_installment_loan_app_id_seq OWNER TO postgres;

--
-- Name: temp_installment_loan_app_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE temp_installment_loan_app_id_seq OWNED BY temp_installment.loan_app_id;


--
-- Name: user_role; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE user_role (
    user_id bigint NOT NULL,
    role character varying(255)
);


ALTER TABLE user_role OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    created timestamp without time zone,
    email character varying(255),
    enabled boolean NOT NULL,
    ext integer,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    password character varying(100) NOT NULL,
    primary_location character varying(50),
    username character varying(50) NOT NULL,
    dealer_id integer,
    basic_salary numeric,
    busy boolean DEFAULT false,
    agent_city character varying(255),
    agent_district character varying(255),
    agent_phone character varying(255),
    agent_region character varying(255),
    agent_type character varying(255),
    power_tasks_allowed boolean DEFAULT false
);


ALTER TABLE users OWNER TO postgres;

--
-- Name: users_dealer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE users_dealer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE users_dealer_id_seq OWNER TO postgres;

--
-- Name: users_dealer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE users_dealer_id_seq OWNED BY users.dealer_id;


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: v_installment_flat; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW v_installment_flat AS
 SELECT round(mt.first_rem, 2) AS amount,
    (mt.first_rem_date)::date AS duedate,
    '1st_reminder_fee'::text AS type,
    mt.loan_app_id,
    mt.id AS installment_table_id,
    (mt.first_rem_date)::date AS avail_date
   FROM installment_table mt
  WHERE (mt.first_rem > (0)::numeric)
UNION ALL
 SELECT round(mt.second_rem, 2) AS amount,
    (mt.second_rem_date)::date AS duedate,
    '2nd_reminder_fee'::text AS type,
    mt.loan_app_id,
    mt.id AS installment_table_id,
    (mt.second_rem_date)::date AS avail_date
   FROM installment_table mt
  WHERE (mt.second_rem > (0)::numeric)
UNION ALL
 SELECT round(mt.interest, 2) AS amount,
    (mt.expected_date)::date AS duedate,
    'interest'::text AS type,
    mt.loan_app_id,
    mt.id AS installment_table_id,
    (la.active_date)::date AS avail_date
   FROM (installment_table mt
     LEFT JOIN loan_application la ON ((mt.loan_app_id = la.id)))
  WHERE ((mt.interest > (0)::numeric) AND (la.active = true))
UNION ALL
 SELECT round(mt.admission_fee, 2) AS amount,
    (mt.expected_date)::date AS duedate,
    'commission_fee'::text AS type,
    mt.loan_app_id,
    mt.id AS installment_table_id,
    (la.active_date)::date AS avail_date
   FROM (installment_table mt
     LEFT JOIN loan_application la ON ((mt.loan_app_id = la.id)))
  WHERE ((mt.admission_fee > (0)::numeric) AND (la.active = true))
UNION ALL
 SELECT round(mt.guarantee_fee, 2) AS amount,
    (mt.expected_date)::date AS duedate,
    'guarantee_fee'::text AS type,
    mt.loan_app_id,
    mt.id AS installment_table_id,
    (la.active_date)::date AS avail_date
   FROM (installment_table mt
     LEFT JOIN loan_application la ON ((mt.loan_app_id = la.id)))
  WHERE ((mt.guarantee_fee > (0)::numeric) AND (la.active = true))
UNION ALL
 SELECT round(mt.admin_fee, 2) AS amount,
    (mt.expected_date)::date AS duedate,
    'admin_fee'::text AS type,
    mt.loan_app_id,
    mt.id AS installment_table_id,
    (la.active_date)::date AS avail_date
   FROM (installment_table mt
     LEFT JOIN loan_application la ON ((mt.loan_app_id = la.id)))
  WHERE ((mt.admin_fee > (0)::numeric) AND (la.active = true))
UNION ALL
 SELECT round(mt.principal, 2) AS amount,
    (mt.expected_date)::date AS duedate,
    'principal'::text AS type,
    mt.loan_app_id,
    mt.id AS installment_table_id,
    (la.active_date)::date AS avail_date
   FROM (installment_table mt
     LEFT JOIN loan_application la ON ((mt.loan_app_id = la.id)))
  WHERE ((mt.principal > (0)::numeric) AND (la.active = true))
UNION ALL
 SELECT round(mt.term, 2) AS amount,
    (mt.term_date)::date AS duedate,
    'termination_fee'::text AS type,
    mt.loan_app_id,
    mt.id AS installment_table_id,
    (mt.term_date)::date AS avail_date
   FROM installment_table mt
  WHERE (mt.term > (0)::numeric)
UNION ALL
 SELECT round(mt.term_alert, 2) AS amount,
    (mt.term_alert_date)::date AS duedate,
    'termination_alert_fee'::text AS type,
    mt.loan_app_id,
    mt.id AS installment_table_id,
    (mt.term_alert_date)::date AS avail_date
   FROM installment_table mt
  WHERE (mt.term_alert > (0)::numeric)
UNION ALL
 SELECT round(mt.suspension_fee, 2) AS amount,
    (mt.suspended_date)::date AS duedate,
    'suspension_fee'::text AS type,
    mt.loan_app_id,
    mt.id AS installment_table_id,
    (mt.suspended_date)::date AS avail_date
   FROM installment_table mt
  WHERE (mt.suspended_date IS NOT NULL);


ALTER TABLE v_installment_flat OWNER TO postgres;

--
-- Name: v_claims_la_phys; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW v_claims_la_phys AS
 SELECT mt.amount,
    mt.duedate,
    mt.type,
    mt.loan_app_id,
    mt.installment_table_id,
    COALESCE(mt.avail_date, (la.active_date)::date) AS avail_date,
    la.status AS la_status,
    la.loan_product_id,
    la.active,
    la.closed AS la_closed,
    (la.closed_date)::date AS la_closed_date,
    (la.active_date)::date AS active_date,
    (la.created)::date AS loan_app_created
   FROM (v_installment_flat mt
     JOIN loan_application la ON ((mt.loan_app_id = la.id)))
  WHERE (la.active = true);


ALTER TABLE v_claims_la_phys OWNER TO postgres;

--
-- Name: v_claims_la; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW v_claims_la AS
 SELECT v_claims_la_phys.amount,
    v_claims_la_phys.duedate,
    v_claims_la_phys.type,
    v_claims_la_phys.loan_app_id,
    v_claims_la_phys.installment_table_id,
    v_claims_la_phys.avail_date,
    v_claims_la_phys.la_status,
    v_claims_la_phys.loan_product_id,
    v_claims_la_phys.active,
    v_claims_la_phys.la_closed,
    v_claims_la_phys.la_closed_date,
    v_claims_la_phys.active_date,
    v_claims_la_phys.loan_app_created
   FROM v_claims_la_phys;


ALTER TABLE v_claims_la OWNER TO postgres;

--
-- Name: v_claims_la2_phys; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW v_claims_la2_phys AS
 SELECT mt.first_rem AS amount,
    (mt.first_rem_date)::date AS duedate,
    '1st_reminder_fee'::text AS type,
    mt.loan_app_id,
    mt.id AS installment_table_id,
    (mt.first_rem_date)::date AS avail_date,
    la.status AS la_status,
    la.loan_product_id,
    la.active,
    la.closed AS la_closed,
    (la.closed_date)::date AS la_closed_date,
    (la.active_date)::date AS active_date,
    (la.created)::date AS loan_app_created
   FROM (installment_table mt
     JOIN loan_application la ON ((mt.loan_app_id = la.id)))
  WHERE ((mt.first_rem > (0)::numeric) AND (la.active = true))
UNION ALL
 SELECT mt.second_rem AS amount,
    (mt.second_rem_date)::date AS duedate,
    '2nd_reminder_fee'::text AS type,
    mt.loan_app_id,
    mt.id AS installment_table_id,
    (mt.second_rem_date)::date AS avail_date,
    la.status AS la_status,
    la.loan_product_id,
    la.active,
    la.closed AS la_closed,
    (la.closed_date)::date AS la_closed_date,
    (la.active_date)::date AS active_date,
    (la.created)::date AS loan_app_created
   FROM (installment_table mt
     JOIN loan_application la ON ((mt.loan_app_id = la.id)))
  WHERE ((mt.second_rem > (0)::numeric) AND (la.active = true))
UNION ALL
 SELECT mt.interest AS amount,
    (mt.expected_date)::date AS duedate,
    'interest'::text AS type,
    mt.loan_app_id,
    mt.id AS installment_table_id,
    (la.active_date)::date AS avail_date,
    la.status AS la_status,
    la.loan_product_id,
    la.active,
    la.closed AS la_closed,
    (la.closed_date)::date AS la_closed_date,
    (la.active_date)::date AS active_date,
    (la.created)::date AS loan_app_created
   FROM (installment_table mt
     JOIN loan_application la ON ((mt.loan_app_id = la.id)))
  WHERE ((mt.interest > (0)::numeric) AND (la.active = true))
UNION ALL
 SELECT mt.admission_fee AS amount,
    (mt.expected_date)::date AS duedate,
    'commission_fee'::text AS type,
    mt.loan_app_id,
    mt.id AS installment_table_id,
    (la.active_date)::date AS avail_date,
    la.status AS la_status,
    la.loan_product_id,
    la.active,
    la.closed AS la_closed,
    (la.closed_date)::date AS la_closed_date,
    (la.active_date)::date AS active_date,
    (la.created)::date AS loan_app_created
   FROM (installment_table mt
     JOIN loan_application la ON ((mt.loan_app_id = la.id)))
  WHERE ((mt.admission_fee > (0)::numeric) AND (la.active = true))
UNION ALL
 SELECT mt.principal AS amount,
    (mt.expected_date)::date AS duedate,
    'principal'::text AS type,
    mt.loan_app_id,
    mt.id AS installment_table_id,
    (la.active_date)::date AS avail_date,
    la.status AS la_status,
    la.loan_product_id,
    la.active,
    la.closed AS la_closed,
    (la.closed_date)::date AS la_closed_date,
    (la.active_date)::date AS active_date,
    (la.created)::date AS loan_app_created
   FROM (installment_table mt
     JOIN loan_application la ON ((mt.loan_app_id = la.id)))
  WHERE ((mt.principal > (0)::numeric) AND (la.active = true))
UNION ALL
 SELECT mt.term AS amount,
    (mt.term_date)::date AS duedate,
    'termination_fee'::text AS type,
    mt.loan_app_id,
    mt.id AS installment_table_id,
    (mt.term_date)::date AS avail_date,
    la.status AS la_status,
    la.loan_product_id,
    la.active,
    la.closed AS la_closed,
    (la.closed_date)::date AS la_closed_date,
    (la.active_date)::date AS active_date,
    (la.created)::date AS loan_app_created
   FROM (installment_table mt
     JOIN loan_application la ON ((mt.loan_app_id = la.id)))
  WHERE ((mt.term > (0)::numeric) AND (la.active = true))
UNION ALL
 SELECT mt.term_alert AS amount,
    (mt.term_alert_date)::date AS duedate,
    'termination_alert_fee'::text AS type,
    mt.loan_app_id,
    mt.id AS installment_table_id,
    (mt.term_alert_date)::date AS avail_date,
    la.status AS la_status,
    la.loan_product_id,
    la.active,
    la.closed AS la_closed,
    (la.closed_date)::date AS la_closed_date,
    (la.active_date)::date AS active_date,
    (la.created)::date AS loan_app_created
   FROM (installment_table mt
     JOIN loan_application la ON ((mt.loan_app_id = la.id)))
  WHERE ((mt.term_alert > (0)::numeric) AND (la.active = true))
UNION ALL
 SELECT mt.suspension_fee AS amount,
    (mt.suspended_date)::date AS duedate,
    'suspension_fee'::text AS type,
    mt.loan_app_id,
    mt.id AS installment_table_id,
    (mt.suspended_date)::date AS avail_date,
    la.status AS la_status,
    la.loan_product_id,
    la.active,
    la.closed AS la_closed,
    (la.closed_date)::date AS la_closed_date,
    (la.active_date)::date AS active_date,
    (la.created)::date AS loan_app_created
   FROM (installment_table mt
     JOIN loan_application la ON ((mt.loan_app_id = la.id)))
  WHERE ((mt.suspended_date IS NOT NULL) AND (la.active = true));


ALTER TABLE v_claims_la2_phys OWNER TO postgres;

--
-- Name: v_claims_payments_phys; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW v_claims_payments_phys AS
 SELECT claims_payments.loan_app_id,
    claims_payments.installment_table_id,
    claims_payments.expected_amount,
    claims_payments.duedate,
    claims_payments.type,
    claims_payments.paid_sum,
    claims_payments.paid_date,
    claims_payments.loan_app_created,
    claims_payments.income_date,
    claims_payments.avail_date,
    claims_payments.repayment_id
   FROM ( SELECT vla.loan_app_id,
            vla.installment_table_id,
            vla.amount AS expected_amount,
            vla.duedate,
            vla.type,
            rt.sum AS paid_sum,
            (rpt.payment_date)::date AS paid_date,
            (rpt.payment_date)::date AS income_date,
            vla.loan_app_created,
            vla.avail_date,
            rpt.id AS repayment_id
           FROM ((v_claims_la vla
             RIGHT JOIN repayment_type rt ON ((rt.ir_id = vla.installment_table_id)))
             JOIN repayments rpt ON ((rt.repayment_id = rpt.id)))
          WHERE ((rt.type)::text = vla.type)
        UNION
         SELECT vla2.loan_app_id,
            vla2.installment_table_id,
            vla2.amount AS expected_amount,
            vla2.duedate,
            vla2.type,
            0 AS paid_sum,
            NULL::date AS paid_date,
            NULL::date AS income_date,
            vla2.loan_app_created,
            vla2.avail_date,
            0 AS repayment_id
           FROM v_claims_la vla2) claims_payments
  ORDER BY claims_payments.duedate, claims_payments.type;


ALTER TABLE v_claims_payments_phys OWNER TO postgres;

--
-- Name: v_claims_payments; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW v_claims_payments AS
 SELECT v_claims_payments_phys.loan_app_id,
    v_claims_payments_phys.installment_table_id,
    v_claims_payments_phys.expected_amount,
    v_claims_payments_phys.duedate,
    v_claims_payments_phys.type,
    v_claims_payments_phys.paid_sum,
    v_claims_payments_phys.paid_date,
    v_claims_payments_phys.loan_app_created,
    v_claims_payments_phys.income_date,
    v_claims_payments_phys.avail_date,
    v_claims_payments_phys.repayment_id
   FROM v_claims_payments_phys;


ALTER TABLE v_claims_payments OWNER TO postgres;

--
-- Name: v_client_dealer; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW v_client_dealer AS
 WITH client_dealer AS (
         SELECT la_1.id,
            la_1.client_pin,
            row_number() OVER (PARTITION BY la_1.client_pin ORDER BY la_1.active_date DESC) AS rk
           FROM loan_application la_1
          WHERE (la_1.active_date IS NOT NULL)
        )
 SELECT la.client_pin,
    la.dealer_id
   FROM ((loan_application la
     LEFT JOIN loan_products lp ON ((la.loan_product_id = lp.id)))
     LEFT JOIN client_dealer cd ON ((la.id = cd.id)))
  WHERE ((((lp.type)::text = 'dealer'::text) AND (la.active_date IS NOT NULL)) AND (cd.rk = 1))
  ORDER BY la.client_pin, cd.rk;


ALTER TABLE v_client_dealer OWNER TO postgres;

--
-- Name: v_consolidated_payment; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW v_consolidated_payment AS
 SELECT la.id AS loan_app_id,
    pr.first_name,
    pr.last_name,
    la.ref_nr,
    la.signed AS printdate,
    p.payment_date AS consolidated_payment_date,
    cp.bank,
    la.amount AS total_loan,
    p.sum AS payment_sum,
    cp.sum AS total_consolidated,
    cp.dealer_id,
    d.company_name
   FROM ((((payment p
     LEFT JOIN consolidated_payment cp ON ((p.consolidated_payment_id = cp.id)))
     LEFT JOIN loan_application la ON ((la.id = p.loan_app_id)))
     LEFT JOIN client_profile pr ON ((pr.id = la.client_id)))
     LEFT JOIN dealer d ON ((d.id = cp.dealer_id)))
  WHERE ((p.consolidated_payment_id IS NOT NULL) AND ((cp.type)::text = 'dealer'::text));


ALTER TABLE v_consolidated_payment OWNER TO postgres;

--
-- Name: v_installment_flat_paidout; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW v_installment_flat_paidout AS
 SELECT round(mt.amount, 2) AS amount,
    mt.duedate,
    mt.type,
    mt.loan_app_id,
    mt.installment_table_id,
    COALESCE(mt.avail_date, (la.active_date)::date) AS avail_date,
    la.status AS la_status,
    la.loan_product_id,
    la.active,
    la.closed AS la_closed,
    (la.closed_date)::date AS la_closed_date,
    (la.active_date)::date AS active_date,
    (la.created)::date AS loan_app_created
   FROM (v_installment_flat mt
     JOIN loan_application la ON ((mt.loan_app_id = la.id)))
  WHERE (la.active = true);


ALTER TABLE v_installment_flat_paidout OWNER TO postgres;

--
-- Name: v_paidout; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW v_paidout AS
 WITH loan_payment AS (
         SELECT sum(paym.sum) AS sum,
            paym.payment_date,
            paym.bank,
            (paym.type)::text AS type,
            paym.loan_app_id
           FROM payment paym
          WHERE ((paym.type)::text = 'loan'::text)
          GROUP BY paym.loan_app_id, paym.bank, paym.payment_date, paym.type
        ), cons_payment AS (
         SELECT sum(paym.sum) AS sum,
            paym.consolidated_payment_id,
            paym.payment_date,
            paym.bank,
            (paym.type)::text AS type,
            paym.loan_app_id
           FROM payment paym
          WHERE ((paym.type)::text = 'dealer'::text)
          GROUP BY paym.loan_app_id, paym.bank, paym.payment_date, paym.type, paym.consolidated_payment_id
        ), refinance_payment AS (
         SELECT sum(payment.sum) AS sum,
            payment.payment_date,
            payment.bank,
            'refinance'::text AS type,
            payment.loan_app_id
           FROM payment
          WHERE ((payment.type)::text = 'refinance'::text)
          GROUP BY payment.loan_app_id, payment.bank, payment.payment_date
        ), overpayment AS (
         SELECT payment.id,
            payment.bank,
            payment.covered_apps,
            payment.for_app_id_old,
            payment.payment_date,
            payment.refinance,
            payment.source_crm,
            payment.sum,
            payment.type,
            payment.user_name,
            payment.loan_app_id,
            payment.actual,
            payment.consolidated_payment_id
           FROM payment
          WHERE ((payment.type)::text = 'overpayment'::text)
        )
 SELECT la.id AS loan_app_id,
    la.amount AS la_amount,
    (COALESCE(p1.payment_date, p2.payment_date))::date AS payment_date,
    COALESCE(p1.sum, 0.00) AS bank_sum,
    COALESCE(p2.sum, 0.00) AS crm_sum,
    (COALESCE(p1.sum, 0.00) + COALESCE(p2.sum, 0.00)) AS total,
    COALESCE(p1.bank, 'crm'::character varying) AS bank,
    la.loan_office,
    COALESCE(p1.type, 'loan'::text) AS type
   FROM ((loan_application la
     LEFT JOIN loan_payment p1 ON ((p1.loan_app_id = la.id)))
     LEFT JOIN refinance_payment p2 ON ((p2.loan_app_id = la.id)))
  WHERE ((la.active = true) AND ((p1.sum > (0)::numeric) OR (p2.sum > (0)::numeric)))
UNION ALL
 SELECT la.id AS loan_app_id,
    la.amount AS la_amount,
    (p1.payment_date)::date AS payment_date,
    COALESCE(p1.sum, 0.00) AS bank_sum,
    0.00 AS crm_sum,
    COALESCE(p1.sum, 0.00) AS total,
    COALESCE(p1.bank, 'crm'::character varying) AS bank,
    la.loan_office,
    COALESCE(p1.type, 'loan'::character varying) AS type
   FROM (loan_application la
     LEFT JOIN overpayment p1 ON ((p1.loan_app_id = la.id)))
  WHERE ((la.active = true) AND (p1.sum > (0)::numeric))
UNION ALL
 SELECT la.id AS loan_app_id,
    la.amount AS la_amount,
    (p1.payment_date)::date AS payment_date,
    COALESCE(p1.sum, 0.00) AS bank_sum,
    0.00 AS crm_sum,
    COALESCE(p1.sum, 0.00) AS total,
    COALESCE(p2.bank, 'crm'::character varying) AS bank,
    la.loan_office,
    COALESCE(p1.type, 'dealer'::text) AS type
   FROM ((loan_application la
     LEFT JOIN cons_payment p1 ON ((p1.loan_app_id = la.id)))
     LEFT JOIN consolidated_payment p2 ON ((p1.consolidated_payment_id = p2.id)))
  WHERE ((la.active = true) AND (p1.sum > (0)::numeric));


ALTER TABLE v_paidout OWNER TO postgres;

--
-- Name: v_paidout_out_only; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW v_paidout_out_only AS
 SELECT payment.id,
    payment.bank,
    payment.covered_apps,
    payment.for_app_id_old,
    payment.payment_date,
    payment.refinance,
    payment.source_crm,
    payment.sum,
    payment.type,
    payment.user_name,
    payment.loan_app_id,
    payment.actual,
    payment.consolidated_payment_id
   FROM payment
  WHERE ((payment.type)::text <> 'overpayment'::text);


ALTER TABLE v_paidout_out_only OWNER TO postgres;

--
-- Name: v_repayment_status; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW v_repayment_status AS
 SELECT DISTINCT ON (rp.id) rp.id AS repayment_id,
    ls.status
   FROM (repayments rp
     LEFT JOIN loan_status ls ON ((ls.loan_app_id = rp.loan_app_id)))
  WHERE ((ls.generated)::date <= (rp.payment_date)::date)
  ORDER BY rp.id, rp.payment_date, ls.generated DESC;


ALTER TABLE v_repayment_status OWNER TO postgres;

--
-- Name: v_task_history; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW v_task_history AS
 SELECT act_hi_taskinst.id_,
    act_hi_taskinst.assignee_,
    act_hi_taskinst.description_,
    COALESCE(act_hi_taskinst.proc_inst_id_, ( SELECT lt.proc_inst_id
           FROM loan_task lt
          WHERE ((lt.task_id)::text = (act_hi_taskinst.id_)::text)
         LIMIT 1)) AS proc_inst_id_,
    replace((COALESCE(act_hi_taskinst.task_def_key_, act_hi_taskinst.name_))::text, ' '::text, ''::text) AS task_def_key_,
    act_hi_taskinst.start_time_,
    act_hi_taskinst.end_time_,
    act_hi_taskinst.duration_,
    act_hi_taskinst.delete_reason_,
    act_hi_taskinst.owner_
   FROM act_hi_taskinst
UNION
 SELECT (at.id)::text AS id_,
    (at.user_name)::character(64) AS assignee_,
    at.action AS description_,
    lapp.proc_inst_id AS proc_inst_id_,
    replace((at.action)::text, ' '::text, '_'::text) AS task_def_key_,
    at.created AS start_time_,
    at.created AS end_time_,
    NULL::bigint AS duration_,
    'completed'::character varying AS delete_reason_,
    NULL::character(64) AS owner_
   FROM audit_trail at,
    loan_application lapp
  WHERE ((((at.target)::text = 'loan_application'::text) AND (at.target_id = lapp.id)) AND (((at.action)::text = 'submit new application'::text) OR ((at.action)::text = 'print loan agreement'::text)));


ALTER TABLE v_task_history OWNER TO postgres;

--
-- Name: voipsystemstatus; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE voipsystemstatus (
    id integer NOT NULL,
    lastupdate timestamp without time zone
);


ALTER TABLE voipsystemstatus OWNER TO postgres;

--
-- Name: voipsystemstatus_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE voipsystemstatus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE voipsystemstatus_id_seq OWNER TO postgres;

--
-- Name: voipsystemstatus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE voipsystemstatus_id_seq OWNED BY voipsystemstatus.id;


--
-- Name: workday_general; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE workday_general (
    id integer NOT NULL,
    friday boolean DEFAULT false,
    monday boolean DEFAULT false,
    saturday boolean DEFAULT false,
    sunday boolean DEFAULT false,
    thursday boolean DEFAULT false,
    tuesday boolean DEFAULT false,
    type character varying(255),
    wednesday boolean DEFAULT false,
    end_time time without time zone,
    start_time time without time zone,
    user_id integer
);


ALTER TABLE workday_general OWNER TO postgres;

--
-- Name: workday_general_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE workday_general_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE workday_general_id_seq OWNER TO postgres;

--
-- Name: workday_general_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE workday_general_id_seq OWNED BY workday_general.id;


--
-- Name: workday_general_user; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE workday_general_user (
    id integer NOT NULL,
    friday boolean DEFAULT false,
    friday_end time without time zone,
    friday_start time without time zone,
    monday boolean DEFAULT false,
    monday_end time without time zone,
    monday_start time without time zone,
    saturday boolean DEFAULT false,
    saturday_end time without time zone,
    saturday_start time without time zone,
    sunday boolean DEFAULT false,
    sunday_end time without time zone,
    sunday_start time without time zone,
    thursday boolean DEFAULT false,
    thursday_end time without time zone,
    thursday_start time without time zone,
    tuesday boolean DEFAULT false,
    tuesday_end time without time zone,
    tuesday_start time without time zone,
    wednesday boolean DEFAULT false,
    wednesday_end time without time zone,
    wednesday_start time without time zone,
    user_id integer NOT NULL
);


ALTER TABLE workday_general_user OWNER TO postgres;

--
-- Name: workday_general_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE workday_general_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE workday_general_user_id_seq OWNER TO postgres;

--
-- Name: workday_general_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE workday_general_user_id_seq OWNED BY workday_general_user.id;


--
-- Name: workday_general_user_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE workday_general_user_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE workday_general_user_user_id_seq OWNER TO postgres;

--
-- Name: workday_general_user_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE workday_general_user_user_id_seq OWNED BY workday_general_user.user_id;


--
-- Name: workday_special; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE workday_special (
    id integer NOT NULL,
    opened boolean DEFAULT false,
    type character varying(255),
    work_date date NOT NULL,
    end_time time without time zone,
    start_time time without time zone,
    user_id integer
);


ALTER TABLE workday_special OWNER TO postgres;

--
-- Name: workday_special_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE workday_special_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE workday_special_id_seq OWNER TO postgres;

--
-- Name: workday_special_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE workday_special_id_seq OWNED BY workday_special.id;


--
-- Name: workday_special_user; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE workday_special_user (
    id integer NOT NULL,
    end_time time without time zone,
    start_time time without time zone,
    work_date date NOT NULL,
    working boolean DEFAULT false,
    user_id integer NOT NULL
);


ALTER TABLE workday_special_user OWNER TO postgres;

--
-- Name: workday_special_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE workday_special_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE workday_special_user_id_seq OWNER TO postgres;

--
-- Name: workday_special_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE workday_special_user_id_seq OWNED BY workday_special_user.id;


--
-- Name: workday_special_user_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE workday_special_user_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE workday_special_user_user_id_seq OWNER TO postgres;

--
-- Name: workday_special_user_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE workday_special_user_user_id_seq OWNED BY workday_special_user.user_id;


--
-- Name: wrong_number; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE wrong_number (
    id integer NOT NULL,
    client_pin character varying(255),
    gsm character varying(200)
);


ALTER TABLE wrong_number OWNER TO postgres;

--
-- Name: wrong_number_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE wrong_number_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE wrong_number_id_seq OWNER TO postgres;

--
-- Name: wrong_number_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE wrong_number_id_seq OWNED BY wrong_number.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY account_balance ALTER COLUMN id SET DEFAULT nextval('account_balance_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY aftersale_efficiency_interval ALTER COLUMN id SET DEFAULT nextval('aftersale_efficiency_interval_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY agent_workday ALTER COLUMN id SET DEFAULT nextval('agent_workday_id_seq'::regclass);


--
-- Name: user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY agent_workday ALTER COLUMN user_id SET DEFAULT nextval('agent_workday_user_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY agreement_recipient ALTER COLUMN id SET DEFAULT nextval('agreement_recipient_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY agricultural_asset ALTER COLUMN id SET DEFAULT nextval('agricultural_asset_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY alternative_contact ALTER COLUMN id SET DEFAULT nextval('alternative_contact_id_seq'::regclass);


--
-- Name: client_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY alternative_contact ALTER COLUMN client_id SET DEFAULT nextval('alternative_contact_client_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY audit_trail ALTER COLUMN id SET DEFAULT nextval('audit_trail_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY bonus_settings ALTER COLUMN id SET DEFAULT nextval('bonus_settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY bonus_settings_operation ALTER COLUMN id SET DEFAULT nextval('bonus_settings_operation_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY bulk_letter_task_row ALTER COLUMN id SET DEFAULT nextval('bulk_letter_task_row_id_seq'::regclass);


--
-- Name: app; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY bulk_letter_task_row ALTER COLUMN app SET DEFAULT nextval('bulk_letter_task_row_app_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY call_task ALTER COLUMN id SET DEFAULT nextval('call_task_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY campaign ALTER COLUMN id SET DEFAULT nextval('campaign_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY campaign_client ALTER COLUMN id SET DEFAULT nextval('campaign_client_id_seq'::regclass);


--
-- Name: campaign_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY campaign_client ALTER COLUMN campaign_id SET DEFAULT nextval('campaign_client_campaign_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY campaign_client_cache ALTER COLUMN id SET DEFAULT nextval('campaign_client_cache_id_seq'::regclass);


--
-- Name: campaign_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY campaign_dealers ALTER COLUMN campaign_id SET DEFAULT nextval('campaign_dealers_campaign_id_seq'::regclass);


--
-- Name: dealer_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY campaign_dealers ALTER COLUMN dealer_id SET DEFAULT nextval('campaign_dealers_dealer_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY campaign_filter ALTER COLUMN id SET DEFAULT nextval('campaign_filter_id_seq'::regclass);


--
-- Name: campaign_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY campaign_filter ALTER COLUMN campaign_id SET DEFAULT nextval('campaign_filter_campaign_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY campaign_step ALTER COLUMN id SET DEFAULT nextval('campaign_step_id_seq'::regclass);


--
-- Name: campaign_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY campaign_step ALTER COLUMN campaign_id SET DEFAULT nextval('campaign_step_campaign_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY car_price ALTER COLUMN id SET DEFAULT nextval('car_price_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY card_data ALTER COLUMN id SET DEFAULT nextval('card_data_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY card_file ALTER COLUMN id SET DEFAULT nextval('card_file_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cash_product_condition ALTER COLUMN id SET DEFAULT nextval('cash_product_condition_id_seq'::regclass);


--
-- Name: loan_product_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cash_product_condition ALTER COLUMN loan_product_id SET DEFAULT nextval('cash_product_condition_loan_product_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY chat ALTER COLUMN id SET DEFAULT nextval('chat_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY chat_msg ALTER COLUMN id SET DEFAULT nextval('chat_msg_id_seq'::regclass);


--
-- Name: chat_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY chat_msg ALTER COLUMN chat_id SET DEFAULT nextval('chat_msg_chat_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY classifier ALTER COLUMN id SET DEFAULT nextval('classifier_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY clicktodial ALTER COLUMN id SET DEFAULT nextval('clicktodial_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY client_aftersale_data ALTER COLUMN id SET DEFAULT nextval('client_aftersale_data_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY client_aftersale_data_hist ALTER COLUMN id SET DEFAULT nextval('client_aftersale_data_hist_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY client_bonus ALTER COLUMN id SET DEFAULT nextval('client_bonus_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY client_bonus_settings ALTER COLUMN id SET DEFAULT nextval('client_bonus_settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY client_file ALTER COLUMN id SET DEFAULT nextval('client_file_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY client_history ALTER COLUMN id SET DEFAULT nextval('client_history_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY client_next_offer ALTER COLUMN id SET DEFAULT nextval('client_next_offer_id_seq'::regclass);


--
-- Name: next_product_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY client_next_offer ALTER COLUMN next_product_id SET DEFAULT nextval('client_next_offer_next_product_id_seq'::regclass);


--
-- Name: other_loan_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY client_other_loan ALTER COLUMN other_loan_id SET DEFAULT nextval('client_other_loan_other_loan_id_seq'::regclass);


--
-- Name: client_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY client_other_loan ALTER COLUMN client_id SET DEFAULT nextval('client_other_loan_client_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY client_profile ALTER COLUMN id SET DEFAULT nextval('client_profile_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY collection_company ALTER COLUMN id SET DEFAULT nextval('collection_company_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY collection_conditions ALTER COLUMN id SET DEFAULT nextval('collection_conditions_id_seq'::regclass);


--
-- Name: collection_scheme_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY collection_conditions ALTER COLUMN collection_scheme_id SET DEFAULT nextval('collection_conditions_collection_scheme_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY collection_portfolio ALTER COLUMN id SET DEFAULT nextval('collection_portfolio_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY collection_scheme ALTER COLUMN id SET DEFAULT nextval('collection_scheme_id_seq'::regclass);


--
-- Name: collection_company_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY collection_scheme ALTER COLUMN collection_company_id SET DEFAULT nextval('collection_scheme_collection_company_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY collector_history ALTER COLUMN id SET DEFAULT nextval('collector_history_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY consolidated_payment ALTER COLUMN id SET DEFAULT nextval('consolidated_payment_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cpi_bonus_settings ALTER COLUMN id SET DEFAULT nextval('cpi_bonus_settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cpi_chart ALTER COLUMN id SET DEFAULT nextval('cpi_chart_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cpi_chart_row ALTER COLUMN id SET DEFAULT nextval('cpi_chart_row_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY currency ALTER COLUMN id SET DEFAULT nextval('currency_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY currency_risk ALTER COLUMN id SET DEFAULT nextval('currency_risk_id_seq'::regclass);


--
-- Name: loan_app_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY currency_risk ALTER COLUMN loan_app_id SET DEFAULT nextval('currency_risk_loan_app_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY custom_product ALTER COLUMN id SET DEFAULT nextval('custom_product_id_seq'::regclass);


--
-- Name: extended_product_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY custom_product ALTER COLUMN extended_product_id SET DEFAULT nextval('custom_product_extended_product_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY custom_product_condition ALTER COLUMN id SET DEFAULT nextval('custom_product_condition_id_seq'::regclass);


--
-- Name: custom_product_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY custom_product_condition ALTER COLUMN custom_product_id SET DEFAULT nextval('custom_product_condition_custom_product_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY custom_product_dealer ALTER COLUMN id SET DEFAULT nextval('custom_product_dealer_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dealer ALTER COLUMN id SET DEFAULT nextval('dealer_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dealer_bonus_points ALTER COLUMN id SET DEFAULT nextval('dealer_bonus_points_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dealer_bonus_settings ALTER COLUMN id SET DEFAULT nextval('dealer_bonus_settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dealer_repayments ALTER COLUMN id SET DEFAULT nextval('dealer_repayments_id_seq'::regclass);


--
-- Name: dealer_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dealer_repayments ALTER COLUMN dealer_id SET DEFAULT nextval('dealer_repayments_dealer_id_seq'::regclass);


--
-- Name: loan_app_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dealer_repayments ALTER COLUMN loan_app_id SET DEFAULT nextval('dealer_repayments_loan_app_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY delay_interest ALTER COLUMN id SET DEFAULT nextval('delay_interest_id_seq'::regclass);


--
-- Name: installment_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY delay_interest ALTER COLUMN installment_id SET DEFAULT nextval('delay_interest_installment_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY destroyed_loans_batch ALTER COLUMN id SET DEFAULT nextval('destroyed_loans_batch_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY doc_template ALTER COLUMN id SET DEFAULT nextval('doc_template_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY doc_template_loan_product ALTER COLUMN id SET DEFAULT nextval('doc_template_loan_product_id_seq'::regclass);


--
-- Name: loan_product_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY doc_template_loan_product ALTER COLUMN loan_product_id SET DEFAULT nextval('doc_template_loan_product_loan_product_id_seq'::regclass);


--
-- Name: template_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY doc_template_loan_product ALTER COLUMN template_id SET DEFAULT nextval('doc_template_loan_product_template_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY employer ALTER COLUMN id SET DEFAULT nextval('employer_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY exported_covered_app ALTER COLUMN id SET DEFAULT nextval('exported_covered_app_id_seq'::regclass);


--
-- Name: covered_app_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY exported_covered_app ALTER COLUMN covered_app_id SET DEFAULT nextval('exported_covered_app_covered_app_id_seq'::regclass);


--
-- Name: export_payment_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY exported_covered_app ALTER COLUMN export_payment_id SET DEFAULT nextval('exported_covered_app_export_payment_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY exported_payment ALTER COLUMN id SET DEFAULT nextval('exported_payment_id_seq'::regclass);


--
-- Name: loan_app_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY exported_payment ALTER COLUMN loan_app_id SET DEFAULT nextval('exported_payment_loan_app_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY held_dealer_payment ALTER COLUMN id SET DEFAULT nextval('held_dealer_payment_id_seq'::regclass);


--
-- Name: loan_app_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY held_dealer_payment ALTER COLUMN loan_app_id SET DEFAULT nextval('held_dealer_payment_loan_app_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY installment_table ALTER COLUMN id SET DEFAULT nextval('installment_table_id_seq'::regclass);


--
-- Name: loan_app_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY installment_table ALTER COLUMN loan_app_id SET DEFAULT nextval('installment_table_loan_app_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_app_data_check ALTER COLUMN id SET DEFAULT nextval('loan_app_data_check_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_app_file ALTER COLUMN id SET DEFAULT nextval('loan_app_file_id_seq'::regclass);


--
-- Name: loan_app_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_app_file ALTER COLUMN loan_app_id SET DEFAULT nextval('loan_app_file_loan_app_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_application ALTER COLUMN id SET DEFAULT nextval('loan_application_id_seq'::regclass);


--
-- Name: client_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_application ALTER COLUMN client_id SET DEFAULT nextval('loan_application_client_id_seq'::regclass);


--
-- Name: dealer_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_application ALTER COLUMN dealer_id SET DEFAULT nextval('loan_application_dealer_id_seq'::regclass);


--
-- Name: loan_product_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_application ALTER COLUMN loan_product_id SET DEFAULT nextval('loan_application_loan_product_id_seq'::regclass);


--
-- Name: custom_product_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_application ALTER COLUMN custom_product_id SET DEFAULT nextval('loan_application_custom_product_id_seq'::regclass);


--
-- Name: post_office_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_application ALTER COLUMN post_office_id SET DEFAULT nextval('loan_application_post_office_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_apr ALTER COLUMN id SET DEFAULT nextval('loan_apr_id_seq'::regclass);


--
-- Name: loan_app_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_apr ALTER COLUMN loan_app_id SET DEFAULT nextval('loan_apr_loan_app_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_product_car_value_perc ALTER COLUMN id SET DEFAULT nextval('loan_product_car_value_perc_id_seq'::regclass);


--
-- Name: loan_product_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_product_car_value_perc ALTER COLUMN loan_product_id SET DEFAULT nextval('loan_product_car_value_perc_loan_product_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_product_condition ALTER COLUMN id SET DEFAULT nextval('loan_product_condition_id_seq'::regclass);


--
-- Name: loan_product_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_product_condition ALTER COLUMN loan_product_id SET DEFAULT nextval('loan_product_condition_loan_product_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_product_settings ALTER COLUMN id SET DEFAULT nextval('loan_product_settings_id_seq'::regclass);


--
-- Name: loan_product_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_product_settings ALTER COLUMN loan_product_id SET DEFAULT nextval('loan_product_settings_loan_product_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_products ALTER COLUMN id SET DEFAULT nextval('loan_products_id_seq'::regclass);


--
-- Name: loan_qualif_req_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_qualif_reqs ALTER COLUMN loan_qualif_req_id SET DEFAULT nextval('loan_qualif_reqs_loan_qualif_req_id_seq'::regclass);


--
-- Name: loan_product_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_qualif_reqs ALTER COLUMN loan_product_id SET DEFAULT nextval('loan_qualif_reqs_loan_product_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_status ALTER COLUMN id SET DEFAULT nextval('loan_status_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_task ALTER COLUMN id SET DEFAULT nextval('loan_task_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY mintos_loan ALTER COLUMN id SET DEFAULT nextval('mintos_loan_id_seq'::regclass);


--
-- Name: loan_app_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY mintos_loan ALTER COLUMN loan_app_id SET DEFAULT nextval('mintos_loan_loan_app_id_seq'::regclass);


--
-- Name: mintos_portfolio_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY mintos_loan ALTER COLUMN mintos_portfolio_id SET DEFAULT nextval('mintos_loan_mintos_portfolio_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY mintos_portfolio ALTER COLUMN id SET DEFAULT nextval('mintos_portfolio_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY mintos_repayment ALTER COLUMN id SET DEFAULT nextval('mintos_repayment_id_seq'::regclass);


--
-- Name: loan_app_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY mintos_repayment ALTER COLUMN loan_app_id SET DEFAULT nextval('mintos_repayment_loan_app_id_seq'::regclass);


--
-- Name: repayment_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY mintos_repayment ALTER COLUMN repayment_id SET DEFAULT nextval('mintos_repayment_repayment_id_seq'::regclass);


--
-- Name: repayment_type_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY mintos_repayment ALTER COLUMN repayment_type_id SET DEFAULT nextval('mintos_repayment_repayment_type_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY overdue_action ALTER COLUMN id SET DEFAULT nextval('overdue_action_id_seq'::regclass);


--
-- Name: overdue_settings_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY overdue_action ALTER COLUMN overdue_settings_id SET DEFAULT nextval('overdue_action_overdue_settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY overdue_action_installment ALTER COLUMN id SET DEFAULT nextval('overdue_action_installment_id_seq'::regclass);


--
-- Name: installment_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY overdue_action_installment ALTER COLUMN installment_id SET DEFAULT nextval('overdue_action_installment_installment_id_seq'::regclass);


--
-- Name: overdue_action_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY overdue_action_installment ALTER COLUMN overdue_action_id SET DEFAULT nextval('overdue_action_installment_overdue_action_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY overdue_delay_interest ALTER COLUMN id SET DEFAULT nextval('overdue_delay_interest_id_seq'::regclass);


--
-- Name: overdue_settings_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY overdue_delay_interest ALTER COLUMN overdue_settings_id SET DEFAULT nextval('overdue_delay_interest_overdue_settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY overdue_process_settings ALTER COLUMN id SET DEFAULT nextval('overdue_process_settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY payment ALTER COLUMN id SET DEFAULT nextval('payment_id_seq'::regclass);


--
-- Name: loan_app_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY payment ALTER COLUMN loan_app_id SET DEFAULT nextval('payment_loan_app_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY phone_call ALTER COLUMN id SET DEFAULT nextval('phone_call_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY post_office ALTER COLUMN id SET DEFAULT nextval('post_office_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY post_office_workday ALTER COLUMN id SET DEFAULT nextval('post_office_workday_id_seq'::regclass);


--
-- Name: post_office_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY post_office_workday ALTER COLUMN post_office_id SET DEFAULT nextval('post_office_workday_post_office_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY posta_deposit ALTER COLUMN id SET DEFAULT nextval('posta_deposit_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY production_alerts ALTER COLUMN id SET DEFAULT nextval('production_alerts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY received_sms ALTER COLUMN id SET DEFAULT nextval('received_sms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY reference_employer ALTER COLUMN id SET DEFAULT nextval('reference_employer_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY repayment_type ALTER COLUMN id SET DEFAULT nextval('repayment_type_id_seq'::regclass);


--
-- Name: repayment_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY repayment_type ALTER COLUMN repayment_id SET DEFAULT nextval('repayment_type_repayment_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY repayments ALTER COLUMN id SET DEFAULT nextval('repayments_id_seq'::regclass);


--
-- Name: loan_app_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY repayments ALTER COLUMN loan_app_id SET DEFAULT nextval('repayments_loan_app_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY scheduled_task ALTER COLUMN id SET DEFAULT nextval('scheduled_task_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY settings ALTER COLUMN id SET DEFAULT nextval('settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY smsmessages ALTER COLUMN id SET DEFAULT nextval('smsmessages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY submitted_loan ALTER COLUMN id SET DEFAULT nextval('submitted_loan_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY system_status ALTER COLUMN id SET DEFAULT nextval('system_status_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY task_data ALTER COLUMN id SET DEFAULT nextval('task_data_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY temp_installment ALTER COLUMN id SET DEFAULT nextval('temp_installment_id_seq'::regclass);


--
-- Name: currency_risk_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY temp_installment ALTER COLUMN currency_risk_id SET DEFAULT nextval('temp_installment_currency_risk_id_seq'::regclass);


--
-- Name: loan_app_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY temp_installment ALTER COLUMN loan_app_id SET DEFAULT nextval('temp_installment_loan_app_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: dealer_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY users ALTER COLUMN dealer_id SET DEFAULT nextval('users_dealer_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY voipsystemstatus ALTER COLUMN id SET DEFAULT nextval('voipsystemstatus_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY workday_general ALTER COLUMN id SET DEFAULT nextval('workday_general_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY workday_general_user ALTER COLUMN id SET DEFAULT nextval('workday_general_user_id_seq'::regclass);


--
-- Name: user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY workday_general_user ALTER COLUMN user_id SET DEFAULT nextval('workday_general_user_user_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY workday_special ALTER COLUMN id SET DEFAULT nextval('workday_special_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY workday_special_user ALTER COLUMN id SET DEFAULT nextval('workday_special_user_id_seq'::regclass);


--
-- Name: user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY workday_special_user ALTER COLUMN user_id SET DEFAULT nextval('workday_special_user_user_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY wrong_number ALTER COLUMN id SET DEFAULT nextval('wrong_number_id_seq'::regclass);


--
-- Name: account_balance_client_pin_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY account_balance
    ADD CONSTRAINT account_balance_client_pin_key UNIQUE (client_pin);


--
-- Name: account_balance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY account_balance
    ADD CONSTRAINT account_balance_pkey PRIMARY KEY (id);


--
-- Name: aftersale_efficiency_interval_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aftersale_efficiency_interval
    ADD CONSTRAINT aftersale_efficiency_interval_pkey PRIMARY KEY (id);


--
-- Name: agent_workday_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY agent_workday
    ADD CONSTRAINT agent_workday_pkey PRIMARY KEY (id);


--
-- Name: agreement_recipient_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY agreement_recipient
    ADD CONSTRAINT agreement_recipient_pkey PRIMARY KEY (id);


--
-- Name: agricultural_asset_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY agricultural_asset
    ADD CONSTRAINT agricultural_asset_pkey PRIMARY KEY (id);


--
-- Name: agricultural_asset_value_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY agricultural_asset_value
    ADD CONSTRAINT agricultural_asset_value_pkey PRIMARY KEY (id);


--
-- Name: alternative_contact_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY alternative_contact
    ADD CONSTRAINT alternative_contact_pkey PRIMARY KEY (id);


--
-- Name: audit_trail_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY audit_trail
    ADD CONSTRAINT audit_trail_pkey PRIMARY KEY (id);


--
-- Name: bonus_settings_operation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bonus_settings_operation
    ADD CONSTRAINT bonus_settings_operation_pkey PRIMARY KEY (id);


--
-- Name: bonus_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bonus_settings
    ADD CONSTRAINT bonus_settings_pkey PRIMARY KEY (id);


--
-- Name: bonus_settings_promotion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bonus_settings_promotion
    ADD CONSTRAINT bonus_settings_promotion_pkey PRIMARY KEY (loan_product_id);


--
-- Name: bulk_letter_task_row_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bulk_letter_task_row
    ADD CONSTRAINT bulk_letter_task_row_pkey PRIMARY KEY (id);


--
-- Name: call_task_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY call_task
    ADD CONSTRAINT call_task_pkey PRIMARY KEY (id);


--
-- Name: campaign_client_cache_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY campaign_client_cache
    ADD CONSTRAINT campaign_client_cache_pkey PRIMARY KEY (id);


--
-- Name: campaign_client_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY campaign_client
    ADD CONSTRAINT campaign_client_pkey PRIMARY KEY (id);


--
-- Name: campaign_filter_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY campaign_filter
    ADD CONSTRAINT campaign_filter_pkey PRIMARY KEY (id);


--
-- Name: campaign_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY campaign
    ADD CONSTRAINT campaign_pkey PRIMARY KEY (id);


--
-- Name: campaign_step_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY campaign_step
    ADD CONSTRAINT campaign_step_pkey PRIMARY KEY (id);


--
-- Name: car_price_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY car_price
    ADD CONSTRAINT car_price_pkey PRIMARY KEY (id);


--
-- Name: card_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY card_data
    ADD CONSTRAINT card_data_pkey PRIMARY KEY (id);


--
-- Name: card_file_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY card_file
    ADD CONSTRAINT card_file_pkey PRIMARY KEY (id);


--
-- Name: cash_product_condition_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cash_product_condition
    ADD CONSTRAINT cash_product_condition_pkey PRIMARY KEY (id);


--
-- Name: chat_msg_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY chat_msg
    ADD CONSTRAINT chat_msg_pkey PRIMARY KEY (id);


--
-- Name: chat_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY chat
    ADD CONSTRAINT chat_pkey PRIMARY KEY (id);


--
-- Name: classifier_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY classifier
    ADD CONSTRAINT classifier_pkey PRIMARY KEY (id);


--
-- Name: clicktodial_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY clicktodial
    ADD CONSTRAINT clicktodial_pkey PRIMARY KEY (id);


--
-- Name: client_aftersale_data_client_pin_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY client_aftersale_data
    ADD CONSTRAINT client_aftersale_data_client_pin_key UNIQUE (client_pin);


--
-- Name: client_aftersale_data_hist_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY client_aftersale_data_hist
    ADD CONSTRAINT client_aftersale_data_hist_pkey PRIMARY KEY (id);


--
-- Name: client_aftersale_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY client_aftersale_data
    ADD CONSTRAINT client_aftersale_data_pkey PRIMARY KEY (id);


--
-- Name: client_bonus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY client_bonus
    ADD CONSTRAINT client_bonus_pkey PRIMARY KEY (id);


--
-- Name: client_bonus_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY client_bonus_settings
    ADD CONSTRAINT client_bonus_settings_pkey PRIMARY KEY (id);


--
-- Name: client_file_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY client_file
    ADD CONSTRAINT client_file_pkey PRIMARY KEY (id);


--
-- Name: client_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY client_history
    ADD CONSTRAINT client_history_pkey PRIMARY KEY (id);


--
-- Name: client_next_offer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY client_next_offer
    ADD CONSTRAINT client_next_offer_pkey PRIMARY KEY (id);


--
-- Name: client_other_loan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY client_other_loan
    ADD CONSTRAINT client_other_loan_pkey PRIMARY KEY (other_loan_id);


--
-- Name: client_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY client_profile
    ADD CONSTRAINT client_profile_pkey PRIMARY KEY (id);


--
-- Name: collection_company_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY collection_company
    ADD CONSTRAINT collection_company_pkey PRIMARY KEY (id);


--
-- Name: collection_conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY collection_conditions
    ADD CONSTRAINT collection_conditions_pkey PRIMARY KEY (id);


--
-- Name: collection_portfolio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY collection_portfolio
    ADD CONSTRAINT collection_portfolio_pkey PRIMARY KEY (id);


--
-- Name: collection_scheme_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY collection_scheme
    ADD CONSTRAINT collection_scheme_pkey PRIMARY KEY (id);


--
-- Name: collector_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY collector_history
    ADD CONSTRAINT collector_history_pkey PRIMARY KEY (id);


--
-- Name: consolidated_payment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY consolidated_payment
    ADD CONSTRAINT consolidated_payment_pkey PRIMARY KEY (id);


--
-- Name: cpi_bonus_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cpi_bonus_settings
    ADD CONSTRAINT cpi_bonus_settings_pkey PRIMARY KEY (id);


--
-- Name: cpi_chart_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cpi_chart
    ADD CONSTRAINT cpi_chart_pkey PRIMARY KEY (id);


--
-- Name: cpi_chart_row_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cpi_chart_row
    ADD CONSTRAINT cpi_chart_row_pkey PRIMARY KEY (id);


--
-- Name: currency_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY currency
    ADD CONSTRAINT currency_pkey PRIMARY KEY (id);


--
-- Name: currency_risk_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY currency_risk
    ADD CONSTRAINT currency_risk_pkey PRIMARY KEY (id);


--
-- Name: custom_product_condition_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY custom_product_condition
    ADD CONSTRAINT custom_product_condition_pkey PRIMARY KEY (id);


--
-- Name: custom_product_dealer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY custom_product_dealer
    ADD CONSTRAINT custom_product_dealer_pkey PRIMARY KEY (id);


--
-- Name: custom_product_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY custom_product
    ADD CONSTRAINT custom_product_name_key UNIQUE (name);


--
-- Name: custom_product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY custom_product
    ADD CONSTRAINT custom_product_pkey PRIMARY KEY (id);


--
-- Name: dealer_bonus_points_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY dealer_bonus_points
    ADD CONSTRAINT dealer_bonus_points_pkey PRIMARY KEY (id);


--
-- Name: dealer_bonus_settings_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY dealer_bonus_settings
    ADD CONSTRAINT dealer_bonus_settings_key_key UNIQUE (key);


--
-- Name: dealer_bonus_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY dealer_bonus_settings
    ADD CONSTRAINT dealer_bonus_settings_pkey PRIMARY KEY (id);


--
-- Name: dealer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY dealer
    ADD CONSTRAINT dealer_pkey PRIMARY KEY (id);


--
-- Name: dealer_repayments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY dealer_repayments
    ADD CONSTRAINT dealer_repayments_pkey PRIMARY KEY (id);


--
-- Name: delay_interest_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY delay_interest
    ADD CONSTRAINT delay_interest_pkey PRIMARY KEY (id);


--
-- Name: destroyed_loans_batch_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY destroyed_loans_batch
    ADD CONSTRAINT destroyed_loans_batch_pkey PRIMARY KEY (id);


--
-- Name: doc_template_loan_product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY doc_template_loan_product
    ADD CONSTRAINT doc_template_loan_product_pkey PRIMARY KEY (id);


--
-- Name: doc_template_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY doc_template
    ADD CONSTRAINT doc_template_pkey PRIMARY KEY (id);


--
-- Name: employer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY employer
    ADD CONSTRAINT employer_pkey PRIMARY KEY (id);


--
-- Name: exported_covered_app_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY exported_covered_app
    ADD CONSTRAINT exported_covered_app_pkey PRIMARY KEY (id);


--
-- Name: exported_payment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY exported_payment
    ADD CONSTRAINT exported_payment_pkey PRIMARY KEY (id);


--
-- Name: held_dealer_payment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY held_dealer_payment
    ADD CONSTRAINT held_dealer_payment_pkey PRIMARY KEY (id);


--
-- Name: installment_table_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY installment_table
    ADD CONSTRAINT installment_table_pkey PRIMARY KEY (id);


--
-- Name: loan_app_data_check_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY loan_app_data_check
    ADD CONSTRAINT loan_app_data_check_pkey PRIMARY KEY (id);


--
-- Name: loan_app_file_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY loan_app_file
    ADD CONSTRAINT loan_app_file_pkey PRIMARY KEY (id);


--
-- Name: loan_application_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY loan_application
    ADD CONSTRAINT loan_application_pkey PRIMARY KEY (id);


--
-- Name: loan_application_ref_nr_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY loan_application
    ADD CONSTRAINT loan_application_ref_nr_key UNIQUE (ref_nr);


--
-- Name: loan_apr_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY loan_apr
    ADD CONSTRAINT loan_apr_pkey PRIMARY KEY (id);


--
-- Name: loan_product_car_value_perc_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY loan_product_car_value_perc
    ADD CONSTRAINT loan_product_car_value_perc_pkey PRIMARY KEY (id);


--
-- Name: loan_product_condition_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY loan_product_condition
    ADD CONSTRAINT loan_product_condition_pkey PRIMARY KEY (id);


--
-- Name: loan_product_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY loan_product_settings
    ADD CONSTRAINT loan_product_settings_pkey PRIMARY KEY (id);


--
-- Name: loan_products_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY loan_products
    ADD CONSTRAINT loan_products_name_key UNIQUE (name);


--
-- Name: loan_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY loan_products
    ADD CONSTRAINT loan_products_pkey PRIMARY KEY (id);


--
-- Name: loan_qualif_reqs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY loan_qualif_reqs
    ADD CONSTRAINT loan_qualif_reqs_pkey PRIMARY KEY (loan_qualif_req_id);


--
-- Name: loan_task_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY loan_task
    ADD CONSTRAINT loan_task_pkey PRIMARY KEY (id);


--
-- Name: lps_unique_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY loan_product_settings
    ADD CONSTRAINT lps_unique_key UNIQUE (loan_product_id, type, dealer_id);


--
-- Name: mintos_loan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY mintos_loan
    ADD CONSTRAINT mintos_loan_pkey PRIMARY KEY (id);


--
-- Name: mintos_portfolio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY mintos_portfolio
    ADD CONSTRAINT mintos_portfolio_pkey PRIMARY KEY (id);


--
-- Name: mintos_repayment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY mintos_repayment
    ADD CONSTRAINT mintos_repayment_pkey PRIMARY KEY (id);


--
-- Name: overdue_action_installment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY overdue_action_installment
    ADD CONSTRAINT overdue_action_installment_pkey PRIMARY KEY (id);


--
-- Name: overdue_action_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY overdue_action
    ADD CONSTRAINT overdue_action_pkey PRIMARY KEY (id);


--
-- Name: overdue_delay_interest_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY overdue_delay_interest
    ADD CONSTRAINT overdue_delay_interest_pkey PRIMARY KEY (id);


--
-- Name: overdue_process_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY overdue_process_settings
    ADD CONSTRAINT overdue_process_settings_pkey PRIMARY KEY (id);


--
-- Name: payment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (id);


--
-- Name: phone_call_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY phone_call
    ADD CONSTRAINT phone_call_pkey PRIMARY KEY (id);


--
-- Name: post_office_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY post_office
    ADD CONSTRAINT post_office_email_key UNIQUE (email);


--
-- Name: post_office_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY post_office
    ADD CONSTRAINT post_office_pkey PRIMARY KEY (id);


--
-- Name: post_office_workday_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY post_office_workday
    ADD CONSTRAINT post_office_workday_pkey PRIMARY KEY (id);


--
-- Name: posta_deposit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY posta_deposit
    ADD CONSTRAINT posta_deposit_pkey PRIMARY KEY (id);


--
-- Name: posta_request_email_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY posta_request_email
    ADD CONSTRAINT posta_request_email_pkey PRIMARY KEY (mailid);


--
-- Name: production_alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY production_alerts
    ADD CONSTRAINT production_alerts_pkey PRIMARY KEY (id);


--
-- Name: random_table_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY random_table
    ADD CONSTRAINT random_table_pkey PRIMARY KEY (col);


--
-- Name: received_sms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY received_sms
    ADD CONSTRAINT received_sms_pkey PRIMARY KEY (id);


--
-- Name: reference_employer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY reference_employer
    ADD CONSTRAINT reference_employer_pkey PRIMARY KEY (id);


--
-- Name: repayment_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY repayment_type
    ADD CONSTRAINT repayment_type_pkey PRIMARY KEY (id);


--
-- Name: repayments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY repayments
    ADD CONSTRAINT repayments_pkey PRIMARY KEY (id);


--
-- Name: scheduled_task_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY scheduled_task
    ADD CONSTRAINT scheduled_task_pkey PRIMARY KEY (id);


--
-- Name: scorecard_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY scorecard
    ADD CONSTRAINT scorecard_pkey PRIMARY KEY (loan_app_id);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: smsmessages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY smsmessages
    ADD CONSTRAINT smsmessages_pkey PRIMARY KEY (id);


--
-- Name: submitted_loan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY submitted_loan
    ADD CONSTRAINT submitted_loan_pkey PRIMARY KEY (id);


--
-- Name: system_status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY system_status
    ADD CONSTRAINT system_status_pkey PRIMARY KEY (id);


--
-- Name: task_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY task_data
    ADD CONSTRAINT task_data_pkey PRIMARY KEY (id);


--
-- Name: temp_installment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY temp_installment
    ADD CONSTRAINT temp_installment_pkey PRIMARY KEY (id);


--
-- Name: uk_dqp63u8lh2oilgt0nuyudd2lr; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY client_aftersale_data
    ADD CONSTRAINT uk_dqp63u8lh2oilgt0nuyudd2lr UNIQUE (client_pin);


--
-- Name: uk_nbprnoaft6lruo4gfwaix00yn; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY dealer_bonus_settings
    ADD CONSTRAINT uk_nbprnoaft6lruo4gfwaix00yn UNIQUE (key);


--
-- Name: uk_p3u9tqifxx3chqytocbofarpx; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY classifier
    ADD CONSTRAINT uk_p3u9tqifxx3chqytocbofarpx UNIQUE (type, key);


--
-- Name: uk_r43af9ap4edm43mmtq01oddj6; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT uk_r43af9ap4edm43mmtq01oddj6 UNIQUE (username);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: voipsystemstatus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY voipsystemstatus
    ADD CONSTRAINT voipsystemstatus_pkey PRIMARY KEY (id);


--
-- Name: workday_general_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY workday_general
    ADD CONSTRAINT workday_general_pkey PRIMARY KEY (id);


--
-- Name: workday_general_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY workday_general_user
    ADD CONSTRAINT workday_general_user_pkey PRIMARY KEY (id);


--
-- Name: workday_special_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY workday_special
    ADD CONSTRAINT workday_special_pkey PRIMARY KEY (id);


--
-- Name: workday_special_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY workday_special_user
    ADD CONSTRAINT workday_special_user_pkey PRIMARY KEY (id);


--
-- Name: wrong_number_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY wrong_number
    ADD CONSTRAINT wrong_number_pkey PRIMARY KEY (id);


--
-- Name: agricultural_asset_value_name_index; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX agricultural_asset_value_name_index ON agricultural_asset_value USING btree (name, agricultural_type);


--
-- Name: client_other_loan_client_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX client_other_loan_client_id ON client_other_loan USING btree (client_id);


--
-- Name: delay_interest_calculated_date; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX delay_interest_calculated_date ON delay_interest USING btree (installment_id DESC, calculated_date DESC);


--
-- Name: delay_interest_loan_app_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX delay_interest_loan_app_id ON delay_interest USING btree (loan_app_id);


--
-- Name: idx_assignee; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX idx_assignee ON task_data USING btree (assignee);


--
-- Name: idx_task_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX idx_task_id ON task_data USING btree (task_id);


--
-- Name: index_audit_trail_action; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_audit_trail_action ON audit_trail USING btree (action);


--
-- Name: index_audit_trail_created; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_audit_trail_created ON audit_trail USING btree (created);


--
-- Name: index_audit_trail_user; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_audit_trail_user ON audit_trail USING btree (user_name);


--
-- Name: index_campaign_client_completed_time; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_campaign_client_completed_time ON campaign_client USING btree (completed);


--
-- Name: index_campaign_client_completed_user; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_campaign_client_completed_user ON campaign_client USING btree (completed_user);


--
-- Name: index_campaign_client_pin; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_campaign_client_pin ON campaign_client USING btree (client_pin);


--
-- Name: index_client_history_created; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_client_history_created ON client_history USING btree (created);


--
-- Name: index_client_history_loan_app_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_client_history_loan_app_id ON client_history USING btree (loan_app_id);


--
-- Name: index_client_history_username; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_client_history_username ON client_history USING btree (username);


--
-- Name: index_client_profile_pin; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_client_profile_pin ON client_profile USING btree (pin);


--
-- Name: index_installment_table_commission; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_installment_table_commission ON installment_table USING btree (admission_fee);


--
-- Name: index_installment_table_first_rem; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_installment_table_first_rem ON installment_table USING btree (first_rem);


--
-- Name: index_installment_table_first_rem_date; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_installment_table_first_rem_date ON installment_table USING btree (first_rem_date);


--
-- Name: index_installment_table_interest; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_installment_table_interest ON installment_table USING btree (interest);


--
-- Name: index_installment_table_loan_app_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_installment_table_loan_app_id ON installment_table USING btree (loan_app_id);


--
-- Name: index_installment_table_principal; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_installment_table_principal ON installment_table USING btree (principal);


--
-- Name: index_installment_table_second_rem; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_installment_table_second_rem ON installment_table USING btree (second_rem);


--
-- Name: index_installment_table_second_rem_date; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_installment_table_second_rem_date ON installment_table USING btree (second_rem_date);


--
-- Name: index_installment_table_term; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_installment_table_term ON installment_table USING btree (term);


--
-- Name: index_installment_table_term_alert; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_installment_table_term_alert ON installment_table USING btree (term_alert);


--
-- Name: index_installment_table_term_alert_date; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_installment_table_term_alert_date ON installment_table USING btree (term_alert_date);


--
-- Name: index_installment_table_term_date; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_installment_table_term_date ON installment_table USING btree (term_date);


--
-- Name: index_loan_application_active_date; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_loan_application_active_date ON loan_application USING btree (active_date);


--
-- Name: index_loan_application_client_pin; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_loan_application_client_pin ON loan_application USING btree (client_pin);


--
-- Name: index_loan_application_created; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_loan_application_created ON loan_application USING btree (created);


--
-- Name: index_loan_application_dealer_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_loan_application_dealer_id ON loan_application USING btree (dealer_id);


--
-- Name: index_loan_application_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_loan_application_id ON loan_application USING btree (id);


--
-- Name: index_loan_application_paid_out_date; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_loan_application_paid_out_date ON loan_application USING btree (paid_out_date);


--
-- Name: index_loan_status_loan_app_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_loan_status_loan_app_id ON loan_status USING btree (loan_app_id);


--
-- Name: index_loan_task_created; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_loan_task_created ON loan_task USING btree (created);


--
-- Name: index_loan_task_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_loan_task_id ON loan_task USING btree (task_id);


--
-- Name: index_loan_task_key; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_loan_task_key ON loan_task USING btree (task_key);


--
-- Name: index_loan_task_proc_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_loan_task_proc_id ON loan_task USING btree (proc_inst_id);


--
-- Name: index_payment_bank; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_payment_bank ON payment USING btree (bank);


--
-- Name: index_payment_date; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_payment_date ON payment USING btree (payment_date);


--
-- Name: index_repayments_bank; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_repayments_bank ON repayments USING btree (bank);


--
-- Name: index_repayments_payment_date; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_repayments_payment_date ON repayments USING btree (payment_date);


--
-- Name: index_repayments_user; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_repayments_user ON repayments USING btree (user_name);


--
-- Name: index_submitted_loan_application_loan_app_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX index_submitted_loan_application_loan_app_id ON submitted_loan USING btree (loan_app_id);


--
-- Name: loan_app_file_loan_app_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX loan_app_file_loan_app_id ON loan_app_file USING btree (loan_app_id);


--
-- Name: loan_apr_loan_app_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX loan_apr_loan_app_id ON loan_apr USING btree (loan_app_id);


--
-- Name: loan_status_composite; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX loan_status_composite ON loan_status USING btree (loan_app_id, status);


--
-- Name: loan_status_generated; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX loan_status_generated ON loan_status USING btree (generated);


--
-- Name: loan_status_loan_app_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX loan_status_loan_app_id ON loan_status USING btree (loan_app_id);


--
-- Name: loan_status_status; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX loan_status_status ON loan_status USING btree (status);


--
-- Name: payment_loan_app_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX payment_loan_app_id ON payment USING btree (loan_app_id);


--
-- Name: random_table_stamps_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX random_table_stamps_idx ON random_table USING btree (stamp);


--
-- Name: reference_employer_import_timestamp_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX reference_employer_import_timestamp_idx ON reference_employer USING btree (import_timestamp);


--
-- Name: reference_employer_reg_code_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX reference_employer_reg_code_idx ON reference_employer USING btree (reg_code);


--
-- Name: reference_employer_upper_name_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX reference_employer_upper_name_idx ON reference_employer USING btree (upper((name)::text));


--
-- Name: repayment_type_ir_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX repayment_type_ir_id ON repayment_type USING btree (ir_id);


--
-- Name: repayment_type_repayment_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX repayment_type_repayment_id ON repayment_type USING btree (repayment_id);


--
-- Name: repayment_type_type; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX repayment_type_type ON repayment_type USING btree (type);


--
-- Name: repayments_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX repayments_id ON repayments USING btree (id);


--
-- Name: repayments_loan_app_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX repayments_loan_app_id ON repayments USING btree (loan_app_id);


--
-- Name: scorecard_loan_app_id; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX scorecard_loan_app_id ON scorecard USING btree (loan_app_id);


--
-- Name: ignore_duplicate_randoms; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE ignore_duplicate_randoms AS
    ON INSERT TO random_table
   WHERE (EXISTS ( SELECT 1
           FROM random_table random_table_1
          WHERE (random_table_1.col = new.col))) DO INSTEAD  UPDATE random_table SET stamp = new.stamp
  WHERE (random_table.col = new.col);


--
-- Name: add_client_profile_to_latest_loan_application; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER add_client_profile_to_latest_loan_application BEFORE INSERT ON loan_application FOR EACH ROW EXECUTE PROCEDURE add_latest_client_to_loan_application();


--
-- Name: loan_application_status_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER loan_application_status_update AFTER UPDATE ON loan_application FOR EACH ROW EXECUTE PROCEDURE update_loan_status();


--
-- Name: update_client_profile_active; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_client_profile_active BEFORE INSERT OR UPDATE ON client_profile FOR EACH ROW EXECUTE PROCEDURE make_last_client_profile_active();


--
-- Name: update_latest_client_loan_app; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_latest_client_loan_app AFTER INSERT OR UPDATE ON client_profile FOR EACH ROW EXECUTE PROCEDURE update_latest_client_loan_app();


--
-- Name: agricultural_asset_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY agricultural_asset
    ADD CONSTRAINT agricultural_asset_client_id_fkey FOREIGN KEY (client_id) REFERENCES client_profile(id);


--
-- Name: fk_37o9qtcbs0cuplghlgv1x2ovl; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_application
    ADD CONSTRAINT fk_37o9qtcbs0cuplghlgv1x2ovl FOREIGN KEY (latest_client) REFERENCES client_profile(id);


--
-- Name: fk_9xi0narpo9tp0xdlhvecib13o; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY bulk_letter_task_row
    ADD CONSTRAINT fk_9xi0narpo9tp0xdlhvecib13o FOREIGN KEY (app) REFERENCES loan_application(id);


--
-- Name: fk_agent_workday; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY agent_workday
    ADD CONSTRAINT fk_agent_workday FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: fk_app_overdue_settings; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_application
    ADD CONSTRAINT fk_app_overdue_settings FOREIGN KEY (overdue_settings_id) REFERENCES overdue_process_settings(id);


--
-- Name: fk_bonus_points_agent; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dealer_bonus_points
    ADD CONSTRAINT fk_bonus_points_agent FOREIGN KEY (agent_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: fk_campaign_campaign_client_cache; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY campaign_client_cache
    ADD CONSTRAINT fk_campaign_campaign_client_cache FOREIGN KEY (campaign_id) REFERENCES campaign(id);


--
-- Name: fk_campaign_client; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY campaign_client
    ADD CONSTRAINT fk_campaign_client FOREIGN KEY (campaign_id) REFERENCES campaign(id);


--
-- Name: fk_campaign_client; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY campaign_filter
    ADD CONSTRAINT fk_campaign_client FOREIGN KEY (campaign_id) REFERENCES campaign(id);


--
-- Name: fk_campaign_custom_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY campaign
    ADD CONSTRAINT fk_campaign_custom_product FOREIGN KEY (custom_product) REFERENCES custom_product(id);


--
-- Name: fk_campaign_step; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY campaign_step
    ADD CONSTRAINT fk_campaign_step FOREIGN KEY (campaign_id) REFERENCES campaign(id);


--
-- Name: fk_cash_product_condition; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cash_product_condition
    ADD CONSTRAINT fk_cash_product_condition FOREIGN KEY (loan_product_id) REFERENCES loan_products(id);


--
-- Name: fk_chat_message; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY chat_msg
    ADD CONSTRAINT fk_chat_message FOREIGN KEY (chat_id) REFERENCES chat(id);


--
-- Name: fk_client_loan_application; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_application
    ADD CONSTRAINT fk_client_loan_application FOREIGN KEY (client_id) REFERENCES client_profile(id);


--
-- Name: fk_client_other_loan; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY client_other_loan
    ADD CONSTRAINT fk_client_other_loan FOREIGN KEY (client_id) REFERENCES client_profile(id);


--
-- Name: fk_client_other_loan; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY alternative_contact
    ADD CONSTRAINT fk_client_other_loan FOREIGN KEY (client_id) REFERENCES client_profile(id);


--
-- Name: fk_company_conditions; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY collection_scheme
    ADD CONSTRAINT fk_company_conditions FOREIGN KEY (collection_company_id) REFERENCES collection_company(id);


--
-- Name: fk_cpi_chart; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cpi_chart_row
    ADD CONSTRAINT fk_cpi_chart FOREIGN KEY (chart_id) REFERENCES cpi_chart(id);


--
-- Name: fk_currency_risk_inst_table; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY temp_installment
    ADD CONSTRAINT fk_currency_risk_inst_table FOREIGN KEY (currency_risk_id) REFERENCES currency_risk(id);


--
-- Name: fk_custom_loan_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY custom_product
    ADD CONSTRAINT fk_custom_loan_product FOREIGN KEY (extended_product_id) REFERENCES loan_products(id);


--
-- Name: fk_custom_product_app; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_application
    ADD CONSTRAINT fk_custom_product_app FOREIGN KEY (custom_product_id) REFERENCES custom_product(id);


--
-- Name: fk_custom_product_condition; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY custom_product_condition
    ADD CONSTRAINT fk_custom_product_condition FOREIGN KEY (custom_product_id) REFERENCES custom_product(id);


--
-- Name: fk_dealer_bonus_app; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dealer_bonus_points
    ADD CONSTRAINT fk_dealer_bonus_app FOREIGN KEY (loan_app_id) REFERENCES loan_application(id);


--
-- Name: fk_dealer_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_application
    ADD CONSTRAINT fk_dealer_user FOREIGN KEY (dealer_id) REFERENCES dealer(id);


--
-- Name: fk_dealer_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY users
    ADD CONSTRAINT fk_dealer_user FOREIGN KEY (dealer_id) REFERENCES dealer(id);


--
-- Name: fk_dealer_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dealer_repayments
    ADD CONSTRAINT fk_dealer_user FOREIGN KEY (dealer_id) REFERENCES dealer(id);


--
-- Name: fk_destroyed_loans_batch; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_application
    ADD CONSTRAINT fk_destroyed_loans_batch FOREIGN KEY (destroyed_loans_batch_id) REFERENCES destroyed_loans_batch(id);


--
-- Name: fk_employer_client; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY client_profile
    ADD CONSTRAINT fk_employer_client FOREIGN KEY (employer_id) REFERENCES employer(id);


--
-- Name: fk_export_covered_app; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY exported_covered_app
    ADD CONSTRAINT fk_export_covered_app FOREIGN KEY (covered_app_id) REFERENCES loan_application(id);


--
-- Name: fk_export_payment; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY exported_covered_app
    ADD CONSTRAINT fk_export_payment FOREIGN KEY (export_payment_id) REFERENCES exported_payment(id);


--
-- Name: fk_export_payment_app; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY exported_payment
    ADD CONSTRAINT fk_export_payment_app FOREIGN KEY (loan_app_id) REFERENCES loan_application(id);


--
-- Name: fk_installment; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY overdue_action_installment
    ADD CONSTRAINT fk_installment FOREIGN KEY (installment_id) REFERENCES installment_table(id);


--
-- Name: fk_installment_delay; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY delay_interest
    ADD CONSTRAINT fk_installment_delay FOREIGN KEY (installment_id) REFERENCES installment_table(id);


--
-- Name: fk_loan_app_currency_risk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY currency_risk
    ADD CONSTRAINT fk_loan_app_currency_risk FOREIGN KEY (loan_app_id) REFERENCES loan_application(id);


--
-- Name: fk_loan_app_files; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_app_file
    ADD CONSTRAINT fk_loan_app_files FOREIGN KEY (loan_app_id) REFERENCES loan_application(id);


--
-- Name: fk_loan_app_inst_table; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY temp_installment
    ADD CONSTRAINT fk_loan_app_inst_table FOREIGN KEY (loan_app_id) REFERENCES loan_application(id);


--
-- Name: fk_loan_app_payments; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY payment
    ADD CONSTRAINT fk_loan_app_payments FOREIGN KEY (loan_app_id) REFERENCES loan_application(id);


--
-- Name: fk_loan_app_repayment; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY repayments
    ADD CONSTRAINT fk_loan_app_repayment FOREIGN KEY (loan_app_id) REFERENCES loan_application(id);


--
-- Name: fk_loan_app_repayment; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dealer_repayments
    ADD CONSTRAINT fk_loan_app_repayment FOREIGN KEY (loan_app_id) REFERENCES loan_application(id);


--
-- Name: fk_loan_apr; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_apr
    ADD CONSTRAINT fk_loan_apr FOREIGN KEY (loan_app_id) REFERENCES loan_application(id);


--
-- Name: fk_loan_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY doc_template_loan_product
    ADD CONSTRAINT fk_loan_product FOREIGN KEY (loan_product_id) REFERENCES loan_products(id);


--
-- Name: fk_loan_product_app; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_application
    ADD CONSTRAINT fk_loan_product_app FOREIGN KEY (loan_product_id) REFERENCES loan_products(id);


--
-- Name: fk_loan_product_app; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY production_alerts
    ADD CONSTRAINT fk_loan_product_app FOREIGN KEY (loan_product_id) REFERENCES loan_products(id);


--
-- Name: fk_loan_product_car_value; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_product_car_value_perc
    ADD CONSTRAINT fk_loan_product_car_value FOREIGN KEY (loan_product_id) REFERENCES loan_products(id);


--
-- Name: fk_loan_product_condition; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_product_condition
    ADD CONSTRAINT fk_loan_product_condition FOREIGN KEY (loan_product_id) REFERENCES loan_products(id);


--
-- Name: fk_loan_product_cpi_chart; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cpi_chart
    ADD CONSTRAINT fk_loan_product_cpi_chart FOREIGN KEY (loan_product_id) REFERENCES loan_products(id);


--
-- Name: fk_loan_product_settings; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_product_settings
    ADD CONSTRAINT fk_loan_product_settings FOREIGN KEY (loan_product_id) REFERENCES loan_products(id);


--
-- Name: fk_loanapp_held_payment; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY held_dealer_payment
    ADD CONSTRAINT fk_loanapp_held_payment FOREIGN KEY (loan_app_id) REFERENCES loan_application(id);


--
-- Name: fk_loanapp_inst_table; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY installment_table
    ADD CONSTRAINT fk_loanapp_inst_table FOREIGN KEY (loan_app_id) REFERENCES loan_application(id);


--
-- Name: fk_loanproduct_qualif_req; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_qualif_reqs
    ADD CONSTRAINT fk_loanproduct_qualif_req FOREIGN KEY (loan_product_id) REFERENCES loan_products(id);


--
-- Name: fk_mintos_loan_app; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY mintos_loan
    ADD CONSTRAINT fk_mintos_loan_app FOREIGN KEY (loan_app_id) REFERENCES loan_application(id);


--
-- Name: fk_mintos_portfolio_loan; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY mintos_loan
    ADD CONSTRAINT fk_mintos_portfolio_loan FOREIGN KEY (mintos_portfolio_id) REFERENCES mintos_portfolio(id);


--
-- Name: fk_mintos_repayment; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY mintos_repayment
    ADD CONSTRAINT fk_mintos_repayment FOREIGN KEY (repayment_id) REFERENCES repayments(id);


--
-- Name: fk_mintos_repayment_app; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY mintos_repayment
    ADD CONSTRAINT fk_mintos_repayment_app FOREIGN KEY (loan_app_id) REFERENCES loan_application(id);


--
-- Name: fk_mintos_repayment_type; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY mintos_repayment
    ADD CONSTRAINT fk_mintos_repayment_type FOREIGN KEY (repayment_type_id) REFERENCES repayment_type(id);


--
-- Name: fk_next_loan_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY client_next_offer
    ADD CONSTRAINT fk_next_loan_product FOREIGN KEY (next_product_id) REFERENCES loan_products(id);


--
-- Name: fk_overdue_action; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY overdue_action_installment
    ADD CONSTRAINT fk_overdue_action FOREIGN KEY (overdue_action_id) REFERENCES overdue_action(id);


--
-- Name: fk_overdue_settings; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY overdue_action
    ADD CONSTRAINT fk_overdue_settings FOREIGN KEY (overdue_settings_id) REFERENCES overdue_process_settings(id);


--
-- Name: fk_overdue_settings_delay; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY overdue_delay_interest
    ADD CONSTRAINT fk_overdue_settings_delay FOREIGN KEY (overdue_settings_id) REFERENCES overdue_process_settings(id);


--
-- Name: fk_post_office_loan; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_application
    ADD CONSTRAINT fk_post_office_loan FOREIGN KEY (post_office_id) REFERENCES post_office(id);


--
-- Name: fk_post_office_workday; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY post_office_workday
    ADD CONSTRAINT fk_post_office_workday FOREIGN KEY (post_office_id) REFERENCES post_office(id);


--
-- Name: fk_repayment_type; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY repayment_type
    ADD CONSTRAINT fk_repayment_type FOREIGN KEY (repayment_id) REFERENCES repayments(id);


--
-- Name: fk_role_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_role
    ADD CONSTRAINT fk_role_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: fk_scheme_conditions; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY collection_conditions
    ADD CONSTRAINT fk_scheme_conditions FOREIGN KEY (collection_scheme_id) REFERENCES collection_scheme(id);


--
-- Name: fk_template; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY doc_template_loan_product
    ADD CONSTRAINT fk_template FOREIGN KEY (template_id) REFERENCES doc_template(id);


--
-- Name: fk_user_collector; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY collection_company
    ADD CONSTRAINT fk_user_collector FOREIGN KEY (collector_id) REFERENCES users(id);


--
-- Name: fk_user_workay_general; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY workday_general_user
    ADD CONSTRAINT fk_user_workay_general FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: fk_user_workay_special; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY workday_special_user
    ADD CONSTRAINT fk_user_workay_special FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: fkafc0bd4ba2cdb2a3; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY campaign_dealers
    ADD CONSTRAINT fkafc0bd4ba2cdb2a3 FOREIGN KEY (campaign_id) REFERENCES campaign(id);


--
-- Name: fkafc0bd4bdd3c5043; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY campaign_dealers
    ADD CONSTRAINT fkafc0bd4bdd3c5043 FOREIGN KEY (dealer_id) REFERENCES dealer(id);


--
-- Name: fkd11c32061d5663ba; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY payment
    ADD CONSTRAINT fkd11c32061d5663ba FOREIGN KEY (consolidated_payment_id) REFERENCES consolidated_payment(id);


--
-- Name: loan_application; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY loan_status
    ADD CONSTRAINT loan_application FOREIGN KEY (loan_app_id) REFERENCES loan_application(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: clicktodial; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE clicktodial FROM PUBLIC;
REVOKE ALL ON TABLE clicktodial FROM postgres;
GRANT ALL ON TABLE clicktodial TO postgres;


--
-- Name: voipsystemstatus; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE voipsystemstatus FROM PUBLIC;
REVOKE ALL ON TABLE voipsystemstatus FROM postgres;
GRANT ALL ON TABLE voipsystemstatus TO postgres;


--
-- Name: voipsystemstatus_id_seq; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON SEQUENCE voipsystemstatus_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE voipsystemstatus_id_seq FROM postgres;
GRANT ALL ON SEQUENCE voipsystemstatus_id_seq TO postgres;


--
-- PostgreSQL database dump complete
--

