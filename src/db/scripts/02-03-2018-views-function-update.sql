DROP VIEW IF EXISTS v_paidout;
CREATE OR REPLACE VIEW v_paidout AS

  WITH loan_payment AS (
      SELECT sum(paym.sum), paym.payment_date AS payment_date, paym.bank, paym.type::text AS type, paym.loan_app_id FROM payment paym WHERE (paym.type='loan') GROUP by paym.loan_app_id, paym.bank, paym.payment_date, paym.type
  ),
      cons_payment AS (
        SELECT sum(paym.sum), paym.consolidated_payment_id AS consolidated_payment_id, paym.payment_date AS payment_date, paym.bank, paym.type::text AS type, paym.loan_app_id FROM payment paym WHERE (paym.type='dealer') GROUP by paym.loan_app_id, paym.bank, paym.payment_date, paym.type, paym.consolidated_payment_id
    ),
      refinance_payment AS (
        SELECT sum(sum), payment_date AS payment_date, bank, 'refinance'::text AS type, loan_app_id FROM payment WHERE (type='refinance') GROUP by loan_app_id, bank, payment_date
    ),
      restructure_payment AS (
        SELECT sum(sum), payment_date AS payment_date, bank, 'restructure'::text AS type, loan_app_id FROM payment WHERE (type='restructure') GROUP by loan_app_id, bank, payment_date
    ),
      overpayment AS (
        SELECT * FROM payment WHERE type='overpayment'
    )

  (SELECT la.id AS loan_app_id, la.amount::numeric AS la_amount, coalesce(p1.payment_date, p2.payment_date)::date AS payment_date, coalesce(p1.sum, 0.00)::numeric AS bank_sum, coalesce(p2.sum, 0.00)::numeric AS crm_sum,
          (coalesce(p1.sum,0.00)::numeric + coalesce(p2.sum,0.00)::numeric)::numeric AS total, coalesce(p1.bank,'crm') AS bank, la.loan_office AS loan_office, coalesce(p1.type,'loan') AS type
   FROM loan_application la
     LEFT OUTER JOIN loan_payment p1 ON p1.loan_app_id=la.id
     LEFT OUTER JOIN refinance_payment p2 ON p2.loan_app_id=la.id
   WHERE la.active=TRUE AND (p1.sum>0 OR p2.sum>0)
  )
  UNION ALL
  (SELECT la.id AS loan_app_id, la.amount::numeric AS la_amount, coalesce(p1.payment_date, p2.payment_date)::date AS payment_date, coalesce(p1.sum, 0.00)::numeric AS bank_sum, coalesce(p2.sum, 0.00)::numeric AS crm_sum,
          (coalesce(p1.sum,0.00)::numeric + coalesce(p2.sum,0.00)::numeric)::numeric AS total, coalesce(p1.bank,'crm_restructured') AS bank, la.loan_office AS loan_office, coalesce(p1.type,'restructure') AS type
   FROM loan_application la
     LEFT OUTER JOIN loan_payment p1 ON p1.loan_app_id=la.id
     LEFT OUTER JOIN restructure_payment p2 ON p2.loan_app_id=la.id
   WHERE la.active=TRUE AND (p1.sum>0 OR p2.sum>0)
  )
  UNION ALL
  (SELECT la.id AS loan_app_id, la.amount::numeric AS la_amount, p1.payment_date::date AS payment_date, coalesce(p1.sum, 0.00)::numeric AS bank_sum,(0.00)::numeric AS crm_sum,
          (coalesce(p1.sum,0.00))::numeric AS total, coalesce(p1.bank,'crm') AS bank, la.loan_office AS loan_office, coalesce(p1.type,'loan') AS type
   FROM loan_application la
     LEFT OUTER JOIN overpayment p1 ON p1.loan_app_id=la.id
   WHERE la.active=TRUE  AND (p1.sum>0)
  )
  UNION ALL
  (SELECT la.id AS loan_app_id, la.amount::numeric AS la_amount, p1.payment_date::date AS payment_date, coalesce(p1.sum, 0.00)::numeric AS bank_sum,(0.00)::numeric AS crm_sum,
          (coalesce(p1.sum,0.00))::numeric AS total, coalesce(p2.bank,'crm') AS bank, la.loan_office AS loan_office, coalesce(p1.type,'dealer') AS type
   FROM loan_application la
     LEFT OUTER JOIN cons_payment p1 ON p1.loan_app_id=la.id
     LEFT OUTER JOIN consolidated_payment p2 ON p1.consolidated_payment_id=p2.id
   WHERE la.active=TRUE  AND (p1.sum>0)
  )