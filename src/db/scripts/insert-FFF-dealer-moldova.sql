INSERT INTO loan_products (id, admission_fee_perc, max_interest, max_loan_period, max_principal, min_interest, min_loan_period, min_principal, name, requires_identity_files, TYPE, suspension_fee, apr_threshold, req_id_copy, req_salary_cert, min_apr, max_apr, pm_default, salary_ratio_regular, salary_ratio_second_active, salary_ratio_unofficial, guarantee_fee_perc, guarantee_max_period, guarantee_product, apr_threshold_guarantee, paid_inst_records_threshold, turnover_threshold, official_paid_inst_records_threshold, official_turnover_threshold, max_suspended_days, salary_cert_limit, official_paid_inst_records_threshold_office, official_turnover_threshold_office, paid_inst_records_threshold_office, turnover_threshold_office, enabled, sort_order, car_loan, max_car_value_perc, apr_threshold_evening, apr_threshold_evening_guarantee, closed_loans_archival_threshold_years, defaulted_loans_archival_threshold_years, dept_collection_days, first_call_days, first_letter_days, first_letter_fee, first_sms_days, first_sms_text, fourth_call_days, invitation_text, payment_sms_days, preclaim_days, second_call_days, second_letter_days, second_letter_fee, second_sms_days, second_sms_text, term_alert_letter_days, term_alert_letter_fee, term_letter_days, term_letter_days_max, term_letter_fee_perc, term_sms_days, thankyou_notice, third_call_days, third_letter_days, third_letter_fee, third_sms_days, guarantee_monthly_max, sms_sign_limit, requires_data_verification, requesting_fix_amount_by_sms_mandatory)
VALUES (26,
  0,
  0,
  1,
  5000,
  0,
  1,
  500,
  'FFF Dealer',
  FALSE,
  'dealer',
  65,
  NULL,
  TRUE,
  FALSE,
  0,
  0,
  FALSE,
  70,
  60,
  50,
  NULL,
  NULL,
  FALSE,
  NULL,
  2,
  0,
  0,
  0,
  17,
  NULL,
  0,
  0,
  2,
  0,
  false,
  null,
  FALSE,
  0,
  NULL,
  NULL,
  3,
  5,
  70,
  5,
  10,
  200,
  8,
  'Field not used',
  33,
  NULL,
  2,
  NULL,
  13,
  20,
  200,
  18,
  'Field not used',
  30,
  200,
  50,
  50,
  30,
  38,
  NULL,
  22,
  NULL,
  NULL,
  27,
  NULL,
  NULL,
  FALSE,
  FALSE);

INSERT INTO public.loan_product_settings ( check_docs_duration, checking_duration, scoring_duration, notify_client_duration, pay_out_duration, upload_agreement_duration, vip, loan_product_id, send_precontract_duration, allow_cash_release_duration, dealer_id, TYPE, check_score_duration, check_official_duration, check_official_short_duration, check_unofficial_altcontact_duration, check_unofficial_employer_duration, check_unofficial_person_duration, check_balance_duration, deposit_money_duration, issue_card_duration, issue_pin_duration, bonus_task_duration_until_paid_out)
VALUES (
  30240,
  20,
  5,
  2,
  120,
  NULL,
  FALSE,
  26,
  NULL,
  NULL,
  NULL,
  'general',
  15,
  22,
  22,
  8,
  7,
  7,
  NULL,
  NULL,
  NULL,
  NULL,
  30);
