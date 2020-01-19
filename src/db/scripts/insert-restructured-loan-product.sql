INSERT INTO public.loan_products (id, admission_fee_perc, max_interest, max_loan_period, max_principal, min_interest, min_loan_period, min_principal, name,           type,           suspension_fee, apr_threshold, req_id_copy, req_salary_cert, min_apr, max_apr, pm_default, salary_ratio_regular, salary_ratio_second_active, salary_ratio_unofficial, guarantee_fee_perc, guarantee_max_period, guarantee_product, apr_threshold_guarantee, paid_inst_records_threshold, turnover_threshold, official_paid_inst_records_threshold, official_turnover_threshold, max_suspended_days, salary_cert_limit, official_paid_inst_records_threshold_office, official_turnover_threshold_office, paid_inst_records_threshold_office, turnover_threshold_office, enabled, car_loan, max_car_value_perc, apr_threshold_evening, apr_threshold_evening_guarantee, guarantee_monthly_max, sms_sign_limit, requires_data_verification, delay_interest)
VALUES (50, 33.5,               19,           14,               1000000,      7,            2,               1000,          'Restructured', 'restructured', 65,             88,            false,        false,           60,      220,     false,      50,                   60,                         50,                      0.45,               null,                    false,             89,                      2,                           0,                  1,                                    0,                           17,                 null,              3,                                           0,                                  3,                                  0,                         false        , false,    0,                  88,                    88,                              null, null, false, 0);
INSERT INTO public.loan_product_settings (check_docs_duration, checking_duration, scoring_duration, notify_client_duration, pay_out_duration, upload_agreement_duration, vip, loan_product_id, send_precontract_duration, allow_cash_release_duration, dealer_id, type, check_score_duration, check_official_duration, check_official_short_duration, check_unofficial_altcontact_duration, check_unofficial_employer_duration, check_unofficial_person_duration, check_balance_duration, deposit_money_duration, issue_card_duration, issue_pin_duration, bonus_task_duration_until_paid_out) VALUES (NULL, 25, 5, 15, 120, 15, 'false', 50, NULL, 15, NULL, 'general', 27, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 30);
INSERT INTO public.loan_product_condition (commission_perc, commission_perc_cash, interest_perc, interest_perc_cash, loan_amount_from, loan_amount_to, period, loan_product_id) VALUES (23.5, 23.5, 19, 19, null, null, 2, 50);
INSERT INTO public.loan_product_condition (commission_perc, commission_perc_cash, interest_perc, interest_perc_cash, loan_amount_from, loan_amount_to, period, loan_product_id) VALUES (25, 25, 19, 19, null, null, 3, 50);
INSERT INTO public.loan_product_condition (commission_perc, commission_perc_cash, interest_perc, interest_perc_cash, loan_amount_from, loan_amount_to, period, loan_product_id) VALUES (25, 25, 19, 19, null, null, 4, 50);
INSERT INTO public.loan_product_condition (commission_perc, commission_perc_cash, interest_perc, interest_perc_cash, loan_amount_from, loan_amount_to, period, loan_product_id) VALUES (27, 27, 19, 19, null, null, 5, 50);
INSERT INTO public.loan_product_condition (commission_perc, commission_perc_cash, interest_perc, interest_perc_cash, loan_amount_from, loan_amount_to, period, loan_product_id) VALUES (28, 28, 19, 19, null, null, 6, 50);
INSERT INTO public.loan_product_condition (commission_perc, commission_perc_cash, interest_perc, interest_perc_cash, loan_amount_from, loan_amount_to, period, loan_product_id) VALUES (29, 29, 19, 19, null, null, 7, 50);
INSERT INTO public.loan_product_condition (commission_perc, commission_perc_cash, interest_perc, interest_perc_cash, loan_amount_from, loan_amount_to, period, loan_product_id) VALUES (29.5, 29.5, 19, 19, null, null, 8, 50);
INSERT INTO public.loan_product_condition (commission_perc, commission_perc_cash, interest_perc, interest_perc_cash, loan_amount_from, loan_amount_to, period, loan_product_id) VALUES (30, 30, 19, 19, null, null, 9, 50);
INSERT INTO public.loan_product_condition (commission_perc, commission_perc_cash, interest_perc, interest_perc_cash, loan_amount_from, loan_amount_to, period, loan_product_id) VALUES (30.5, 30.5, 19, 19, null, null, 10, 50);
INSERT INTO public.loan_product_condition (commission_perc, commission_perc_cash, interest_perc, interest_perc_cash, loan_amount_from, loan_amount_to, period, loan_product_id) VALUES (37, 37, 19, 19, null, null, 14, 50);
INSERT INTO public.loan_product_condition (commission_perc, commission_perc_cash, interest_perc, interest_perc_cash, loan_amount_from, loan_amount_to, period, loan_product_id) VALUES (31, 31, 19, 19, null, null, 11, 50);
INSERT INTO public.loan_product_condition (commission_perc, commission_perc_cash, interest_perc, interest_perc_cash, loan_amount_from, loan_amount_to, period, loan_product_id) VALUES (32, 32, 19, 19, null, null, 12, 50);
INSERT INTO public.loan_product_condition (commission_perc, commission_perc_cash, interest_perc, interest_perc_cash, loan_amount_from, loan_amount_to, period, loan_product_id) VALUES (34.5, 34.5, 19, 19, null, null, 13, 50);
