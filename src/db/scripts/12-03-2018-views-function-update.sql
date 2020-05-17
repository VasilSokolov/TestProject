DROP FUNCTION IF EXISTS get_cpi_base(date, date, date, date, date, integer , boolean);
create function get_cpi_base(date, date, date, date, date, integer DEFAULT 0, boolean DEFAULT false) returns TABLE(loan_app_id integer, paid double precision, delayed_days integer, created_month integer, created_year integer, cpi_type integer, duedate date)
AS $$
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
        , round((it.principal + it.restructured + it.interest + it.admission_fee + it.guarantee_fee + it.admin_fee)::numeric,2) AS claim_r1
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
      WHERE rpt.type in ('principal', 'restructured', 'commission_fee', 'interest', 'guarantee_fee', 'admin_fee') AND rp.payment_date::date <= report_date
            AND (CASE WHEN until_term = TRUE AND la.term_date IS NOT NULL THEN rp.payment_date::date <= la.term_date::date ELSE rp.payment_date IS NOT NULL END)
            AND (CASE WHEN claim_type = 1 THEN rp.bank != 'dealer' ELSE CASE WHEN claim_type = 2 THEN rp.bank = 'dealer' ELSE rp.id is not null END END)
            AND rp.bank != 'crm_restructured'
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
$$
LANGUAGE plpgsql VOLATILE;