DROP VIEW IF EXISTS v_installment_flat CASCADE;
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
           CASE
           WHEN (la.dealer_id IS NOT NULL) THEN la.active_date
           ELSE la.paid_out_date
           END AS avail_date
    FROM (installment_table mt
      LEFT JOIN loan_application la ON ((mt.loan_app_id = la.id)))
    WHERE ((mt.interest > (0)::numeric) AND (la.active = true))
    UNION ALL
    SELECT round(mt.admission_fee, 2) AS amount,
           (mt.expected_date)::date AS duedate,
           'commission_fee'::text AS type,
      mt.loan_app_id,
           mt.id AS installment_table_id,
           CASE
           WHEN (la.dealer_id IS NOT NULL) THEN la.active_date
           ELSE la.paid_out_date
           END AS avail_date
    FROM (installment_table mt
      LEFT JOIN loan_application la ON ((mt.loan_app_id = la.id)))
    WHERE ((mt.admission_fee > (0)::numeric) AND (la.active = true))
    UNION ALL
    SELECT round(mt.guarantee_fee, 2) AS amount,
           (mt.expected_date)::date AS duedate,
           'guarantee_fee'::text AS type,
      mt.loan_app_id,
           mt.id AS installment_table_id,
           CASE
           WHEN (la.dealer_id IS NOT NULL) THEN la.active_date
           ELSE la.paid_out_date
           END AS avail_date
    FROM (installment_table mt
      LEFT JOIN loan_application la ON ((mt.loan_app_id = la.id)))
    WHERE ((mt.guarantee_fee > (0)::numeric) AND (la.active = true))
    UNION ALL
    SELECT round(mt.admin_fee, 2) AS amount,
           (mt.expected_date)::date AS duedate,
           'admin_fee'::text AS type,
      mt.loan_app_id,
           mt.id AS installment_table_id,
           CASE
           WHEN (la.dealer_id IS NOT NULL) THEN la.active_date
           ELSE la.paid_out_date
           END AS avail_date
    FROM (installment_table mt
      LEFT JOIN loan_application la ON ((mt.loan_app_id = la.id)))
    WHERE ((mt.admin_fee > (0)::numeric) AND (la.active = true))
    UNION ALL
    SELECT round(mt.principal, 2) AS amount,
           (mt.expected_date)::date AS duedate,
           'principal'::text AS type,
      mt.loan_app_id,
           mt.id AS installment_table_id,
           CASE
           WHEN (la.dealer_id IS NOT NULL) THEN la.active_date
           ELSE la.paid_out_date
           END AS avail_date
    FROM (installment_table mt
      LEFT JOIN loan_application la ON ((mt.loan_app_id = la.id)))
    WHERE ((mt.principal > (0)::numeric) AND (la.active = true))
    UNION ALL
    SELECT round(mt.restructured, 2) AS amount,
           (mt.expected_date)::date AS duedate,
           'restructured'::text AS type,
      mt.loan_app_id,
           mt.id AS installment_table_id,
           CASE
           WHEN (la.dealer_id IS NOT NULL) THEN la.active_date
           ELSE la.paid_out_date
           END AS avail_date
    FROM (installment_table mt
      LEFT JOIN loan_application la ON ((mt.loan_app_id = la.id)))
    WHERE ((mt.restructured > (0)::numeric) AND (la.active = true))
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
    SELECT round(mt.first_rem_sms, 2) AS amount,
           (mt.first_rem_sms_date)::date AS duedate,
           '1st_reminder_sms_fee'::text AS type,
      mt.loan_app_id,
           mt.id AS installment_table_id,
           (mt.first_rem_sms_date)::date AS avail_date
    FROM installment_table mt
    WHERE (mt.first_rem_sms > (0)::numeric)
    UNION ALL
    SELECT round(mt.second_rem_sms, 2) AS amount,
           (mt.second_rem_sms_date)::date AS duedate,
           '2nd_reminder_sms_fee'::text AS type,
      mt.loan_app_id,
           mt.id AS installment_table_id,
           (mt.second_rem_sms_date)::date AS avail_date
    FROM installment_table mt
    WHERE (mt.second_rem_sms > (0)::numeric)
    UNION ALL
    SELECT round(mt.third_rem_sms, 2) AS amount,
           (mt.third_rem_sms_date)::date AS duedate,
           '3rd_reminder_sms_fee'::text AS type,
      mt.loan_app_id,
           mt.id AS installment_table_id,
           (mt.third_rem_sms_date)::date AS avail_date
    FROM installment_table mt
    WHERE (mt.third_rem_sms > (0)::numeric)
    UNION ALL
    SELECT round(mt.fourth_rem_sms, 2) AS amount,
           (mt.fourth_rem_sms_date)::date AS duedate,
           '4th_reminder_sms_fee'::text AS type,
      mt.loan_app_id,
           mt.id AS installment_table_id,
           (mt.fourth_rem_sms_date)::date AS avail_date
    FROM installment_table mt
    WHERE (mt.fourth_rem_sms > (0)::numeric)
    UNION ALL
    SELECT round(mt.fifth_rem_sms, 2) AS amount,
           (mt.fifth_rem_sms_date)::date AS duedate,
           '5th_reminder_sms_fee'::text AS type,
      mt.loan_app_id,
           mt.id AS installment_table_id,
           (mt.fifth_rem_sms_date)::date AS avail_date
    FROM installment_table mt
    WHERE (mt.fifth_rem_sms > (0)::numeric)
    UNION ALL
    SELECT round(mt.suspension_fee, 2) AS amount,
           (mt.suspended_date)::date AS duedate,
           'suspension_fee'::text AS type,
      mt.loan_app_id,
           mt.id AS installment_table_id,
           (mt.suspended_date)::date AS avail_date
    FROM installment_table mt
    WHERE (mt.suspended_date IS NOT NULL);

CREATE OR REPLACE VIEW v_claims_la_phys AS
  SELECT mt.amount,
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



DROP FUNCTION IF EXISTS get_finance_two(date, date);
create function get_finance_two(date, date) returns TABLE(loan_app_id integer, ref_nr text, first_name text, last_name text, workposition text, active_date date, capital numeric, restructured numeric, interest numeric, commission_fee numeric, guarantee_fee numeric, admin_fee numeric, total numeric, loan_office text, loan_product_id integer, client_id integer)
AS $$
BEGIN
  RETURN QUERY


  WITH financials AS (
      SELECT
          it.loan_app_id AS laid
        , sum(it.principal) AS principal_r1
        , sum(it.restructured) as restructured_r1
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
    , financials.restructured_r1::numeric AS restructured_r1
    , financials.interest_r1::numeric AS interest_r1
    , financials.commission_fee_r1::numeric AS commission_fee_r1
    , financials.guarantee_fee_r1::numeric AS guarantee_fee_r1
    , financials.admin_fee_r1::numeric AS admin_fee_r1
    , (financials.principal_r1 + financials.restructured_r1 + financials.interest_r1 + financials.commission_fee_r1 + financials.guarantee_fee_r1 + financials.admin_fee_r1)::numeric AS total_r1
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
$$
LANGUAGE plpgsql VOLATILE;
