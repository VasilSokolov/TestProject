INSERT INTO loan_products
(id, admission_fee_perc, apr_threshold, max_apr, max_interest, max_loan_period, max_principal, min_apr, min_interest, min_loan_period, min_principal, name, pm_default, req_id_copy, req_salary_cert, suspension_fee, type, salary_ratio_regular, salary_ratio_second_active, salary_ratio_unofficial, apr_threshold_guarantee, guarantee_fee_perc, guarantee_max_period, guarantee_product, paid_inst_records_threshold, turnover_threshold, max_suspended_days, official_paid_inst_records_threshold, official_turnover_threshold, salary_cert_limit, official_paid_inst_records_threshold_office, official_turnover_threshold_office, paid_inst_records_threshold_office, turnover_threshold_office, enabled, sort_order, car_loan, max_car_value_perc, apr_threshold_evening, apr_threshold_evening_guarantee, guarantee_monthly_max, sms_sign_limit, requires_data_verification, requesting_fix_amount_by_sms_mandatory)
VALUES
  (106, 38, null, 300, 16, 15, 150000, 70.21, 0, 1, 5000, 'Fidel Dealer', false, true, false, 500, 'regular', 45, 60, 45, null, 0.25, 999, true, 4, 0, 17, 4, 0, 50000.1, 4, 0, 4, 0, false, 2, false, 0, null, null, 200, null, false, false);


INSERT INTO loan_product_settings
(allow_cash_release_duration, check_docs_duration, dealer_id, checking_duration, check_score_duration, scoring_duration, notify_client_duration, pay_out_duration, send_precontract_duration, type, upload_agreement_duration, vip, loan_product_id, check_official_duration, check_official_short_duration, check_unofficial_altcontact_duration, check_unofficial_employer_duration, check_unofficial_person_duration, check_balance_duration, deposit_money_duration, issue_card_duration, issue_pin_duration, bonus_task_duration_until_paid_out)
VALUES
  (null, null, 1, null, null, null, null, null, null, 'dealer', null, false, 106, null, null, null, null, null, null, null, null, null, 30);
INSERT INTO loan_product_settings
(allow_cash_release_duration, check_docs_duration, dealer_id, checking_duration, check_score_duration, scoring_duration, notify_client_duration, pay_out_duration, send_precontract_duration, type, upload_agreement_duration, vip, loan_product_id, check_official_duration, check_official_short_duration, check_unofficial_altcontact_duration, check_unofficial_employer_duration, check_unofficial_person_duration, check_balance_duration, deposit_money_duration, issue_card_duration, issue_pin_duration, bonus_task_duration_until_paid_out)
VALUES
  (30, null, null, 45, 30, 15, 15, 60, null, 'general', 15, false, 106, null, null, null, null, null, null, null, null, null, 30);


INSERT INTO loan_product_condition (commission_perc, commission_perc_cash, interest_perc, interest_perc_cash, loan_amount_from, loan_amount_to, period, loan_product_id)
VALUES (32, 32, 16, 16, null, null, 11, 106);
INSERT INTO loan_product_condition (commission_perc, commission_perc_cash, interest_perc, interest_perc_cash, loan_amount_from, loan_amount_to, period, loan_product_id)
VALUES (33, 33, 16, 16, null, null, 12, 106);
INSERT INTO loan_product_condition (commission_perc, commission_perc_cash, interest_perc, interest_perc_cash, loan_amount_from, loan_amount_to, period, loan_product_id)
VALUES (10, 10, 16, 16, null, null, 1, 106);
INSERT INTO loan_product_condition (commission_perc, commission_perc_cash, interest_perc, interest_perc_cash, loan_amount_from, loan_amount_to, period, loan_product_id)
VALUES (14.3, 14.3, 16, 16, null, null, 2, 106);
INSERT INTO loan_product_condition (commission_perc, commission_perc_cash, interest_perc, interest_perc_cash, loan_amount_from, loan_amount_to, period, loan_product_id)
VALUES (18.8, 18.8, 16, 16, null, null, 3, 106);
INSERT INTO loan_product_condition (commission_perc, commission_perc_cash, interest_perc, interest_perc_cash, loan_amount_from, loan_amount_to, period, loan_product_id)
VALUES (21, 21, 16, 16, null, null, 4, 106);
INSERT INTO loan_product_condition (commission_perc, commission_perc_cash, interest_perc, interest_perc_cash, loan_amount_from, loan_amount_to, period, loan_product_id)
VALUES (23, 23, 16, 16, null, null, 5, 106);
INSERT INTO loan_product_condition (commission_perc, commission_perc_cash, interest_perc, interest_perc_cash, loan_amount_from, loan_amount_to, period, loan_product_id)
VALUES (24.3, 24.3, 16, 16, null, null, 6, 106);
INSERT INTO loan_product_condition (commission_perc, commission_perc_cash, interest_perc, interest_perc_cash, loan_amount_from, loan_amount_to, period, loan_product_id)
VALUES (27, 27, 16, 16, null, null, 7, 106);
INSERT INTO loan_product_condition (commission_perc, commission_perc_cash, interest_perc, interest_perc_cash, loan_amount_from, loan_amount_to, period, loan_product_id)
VALUES (28, 28, 16, 16, null, null, 8, 106);
INSERT INTO loan_product_condition (commission_perc, commission_perc_cash, interest_perc, interest_perc_cash, loan_amount_from, loan_amount_to, period, loan_product_id)
VALUES (29, 29, 16, 16, null, null, 9, 106);
INSERT INTO loan_product_condition (commission_perc, commission_perc_cash, interest_perc, interest_perc_cash, loan_amount_from, loan_amount_to, period, loan_product_id)
VALUES (30, 30, 16, 16, null, null, 10, 106);
INSERT INTO loan_product_condition (commission_perc, commission_perc_cash, interest_perc, interest_perc_cash, loan_amount_from, loan_amount_to, period, loan_product_id)
VALUES (39, 39, 8, 8, null, null, 13, 106);
INSERT INTO loan_product_condition (commission_perc, commission_perc_cash, interest_perc, interest_perc_cash, loan_amount_from, loan_amount_to, period, loan_product_id)
VALUES (37, 37, 16, 16, null, null, 14, 106);
INSERT INTO loan_product_condition (commission_perc, commission_perc_cash, interest_perc, interest_perc_cash, loan_amount_from, loan_amount_to, period, loan_product_id)
VALUES (38, 38, 16, 16, null, null, 15, 106);

INSERT INTO doc_template_loan_product (loan_product_id, template_id) VALUES (106, 22);
INSERT INTO doc_template_loan_product (loan_product_id, template_id) VALUES (106, 31);
INSERT INTO doc_template_loan_product (loan_product_id, template_id) VALUES (106, 15);
INSERT INTO doc_template_loan_product (loan_product_id, template_id) VALUES (106, 17);
INSERT INTO doc_template_loan_product (loan_product_id, template_id) VALUES (106, 2);
INSERT INTO doc_template_loan_product (loan_product_id, template_id) VALUES (106, 24);
INSERT INTO doc_template_loan_product (loan_product_id, template_id) VALUES (106, 25);
INSERT INTO doc_template_loan_product (loan_product_id, template_id) VALUES (106, 26);
INSERT INTO doc_template_loan_product (loan_product_id, template_id) VALUES (106, 18);
INSERT INTO doc_template_loan_product (loan_product_id, template_id) VALUES (106, 27);
INSERT INTO doc_template_loan_product (loan_product_id, template_id) VALUES (106, 16);
INSERT INTO doc_template_loan_product (loan_product_id, template_id) VALUES (106, 19);
INSERT INTO doc_template_loan_product (loan_product_id, template_id) VALUES (106, 20);
INSERT INTO doc_template_loan_product (loan_product_id, template_id) VALUES (106, 23);
INSERT INTO doc_template_loan_product (loan_product_id, template_id) VALUES (106, 21);
INSERT INTO doc_template_loan_product (loan_product_id, template_id) VALUES (106, 30);
INSERT INTO doc_template_loan_product (loan_product_id, template_id) VALUES (106, 3);
INSERT INTO doc_template_loan_product (loan_product_id, template_id) VALUES (106, 28);
INSERT INTO doc_template_loan_product (loan_product_id, template_id) VALUES (106, 4);
INSERT INTO doc_template_loan_product (loan_product_id, template_id) VALUES (106, 5);
INSERT INTO doc_template_loan_product (loan_product_id, template_id) VALUES (106, 6);
INSERT INTO doc_template_loan_product (loan_product_id, template_id) VALUES (106, 45);
