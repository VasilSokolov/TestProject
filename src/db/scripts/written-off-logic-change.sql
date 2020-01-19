
DROP FUNCTION IF EXISTS get_sales_report(IN date, IN date);
DROP FUNCTION IF EXISTS get_sales_report(IN date, IN date, IN BOOLEAN);

CREATE OR REPLACE FUNCTION get_sales_report(IN date, IN date, IN BOOLEAN DEFAULT FALSE)
  RETURNS TABLE(loan_app_id integer, ref_nr text, loan_status text, s_saldo numeric, interest numeric, commission_fee numeric, guarantee_fee numeric, admin_fee numeric, first_reminder_fee numeric,
                second_reminder_fee numeric, termination_fee numeric, termination_alert_fee numeric,
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
        - coalesce(lapp.paym,0.00) -- period payments
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
        AND (CASE WHEN $3 = TRUE THEN ls.la_status=ls.la_status ELSE ls.la_status<>'written_off' END)
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
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100
ROWS 5000;

------------------------------------------

DROP FUNCTION IF EXISTS get_overview(IN date);

CREATE OR REPLACE FUNCTION get_overview(IN date)
  RETURNS TABLE(
    receivable numeric
  , income_type text
  , loan_product integer
  , loan_status text
  ) AS
$BODY$

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
          INNER JOIN
          loan_application la ON if.loan_app_id=la.id
          LEFT JOIN
              get_loan_status($1) ls ON ls.loan_app_id=la.id
        WHERE
          if.avail_date::date <=$1 AND la.active=true
          AND (la.status <> 'written_off' OR la.written_off_date::DATE > $1)
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
        INNER JOIN
        loan_application la ON rp.loan_app_id=la.id
        LEFT JOIN
            get_loan_status($1) ls ON la.id=ls.loan_app_id
      WHERE
        rpt.type<>'overpayment' AND rpt.type<>'defaulted_overpayment' AND rpt.type<>'delay_interest'  AND la.active=true AND rp.payment_date::date <=$1
        AND (la.status <> 'written_off' OR la.written_off_date::DATE > $1)
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
        INNER JOIN
        loan_application la ON di.loan_app_id=la.id
        LEFT JOIN
            get_loan_status($1) ls ON ls.loan_app_id=la.id
      WHERE la.active=true AND (la.status <> 'written_off' OR la.written_off_date::DATE > $1)
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
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100
ROWS 1000;
