INSERT INTO public.loan_products (id, admission_fee_perc, apr_threshold, max_apr, max_interest, max_loan_period, max_principal, min_apr, min_interest, min_loan_period, min_principal, name, pm_default, req_id_copy, req_salary_cert, suspension_fee, type, salary_ratio_regular, salary_ratio_second_active, salary_ratio_unofficial, apr_threshold_guarantee, guarantee_fee_perc, guarantee_max_period, guarantee_product, paid_inst_records_threshold, turnover_threshold, max_suspended_days, official_paid_inst_records_threshold, official_turnover_threshold, salary_cert_limit, official_paid_inst_records_threshold_office, official_turnover_threshold_office, paid_inst_records_threshold_office, turnover_threshold_office, enabled, sort_order, car_loan, max_car_value_perc, apr_threshold_evening, apr_threshold_evening_guarantee, guarantee_monthly_max, sms_sign_limit, requires_data_verification, requesting_fix_amount_by_sms_mandatory)
VALUES (107, 8.6, NULL, 119.49, 15, 12, 40000, 50.53, 15, 1, 5000, 'Happy Neptun', 'false', 'true', 'false', 500, 'dealer', 45, 50, 45, NULL, NULL, NULL, 'false', 3, 0, 17, 3, 0, 100000.01, 5, 0, 5, 0, 'true', null, 'false', 0, NULL, NULL, NULL, NULL, 'false', 'false');


INSERT INTO public.loan_product_settings (allow_cash_release_duration, check_docs_duration, dealer_id, checking_duration, check_score_duration, scoring_duration, notify_client_duration, pay_out_duration, send_precontract_duration, type, upload_agreement_duration, vip, loan_product_id, check_official_duration, check_official_short_duration, check_unofficial_altcontact_duration, check_unofficial_employer_duration, check_unofficial_person_duration, check_balance_duration, deposit_money_duration, issue_card_duration, issue_pin_duration, bonus_task_duration_until_paid_out)
VALUES (NULL, 720, NULL, 20, 15, 5, 5, 10080, NULL, 'vip', NULL, 'true', 107, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 30);
INSERT INTO public.loan_product_settings (allow_cash_release_duration, check_docs_duration, dealer_id, checking_duration, check_score_duration, scoring_duration, notify_client_duration, pay_out_duration, send_precontract_duration, type, upload_agreement_duration, vip, loan_product_id, check_official_duration, check_official_short_duration, check_unofficial_altcontact_duration, check_unofficial_employer_duration, check_unofficial_person_duration, check_balance_duration, deposit_money_duration, issue_card_duration, issue_pin_duration, bonus_task_duration_until_paid_out)
VALUES (NULL, 1440, NULL, 30, 15, 15, 15, 10080, NULL, 'general', NULL, 'false', 107, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 30);

INSERT INTO public.doc_template_loan_product (loan_product_id, template_id) VALUES (107, 22);
INSERT INTO public.doc_template_loan_product (loan_product_id, template_id) VALUES (107, 31);
INSERT INTO public.doc_template_loan_product (loan_product_id, template_id) VALUES (107, 15);
INSERT INTO public.doc_template_loan_product (loan_product_id, template_id) VALUES (107, 16);
INSERT INTO public.doc_template_loan_product (loan_product_id, template_id) VALUES (107, 2);
INSERT INTO public.doc_template_loan_product (loan_product_id, template_id) VALUES (107, 24);
INSERT INTO public.doc_template_loan_product (loan_product_id, template_id) VALUES (107, 25);
INSERT INTO public.doc_template_loan_product (loan_product_id, template_id) VALUES (107, 26);
INSERT INTO public.doc_template_loan_product (loan_product_id, template_id) VALUES (107, 27);
INSERT INTO public.doc_template_loan_product (loan_product_id, template_id) VALUES (107, 19);
INSERT INTO public.doc_template_loan_product (loan_product_id, template_id) VALUES (107, 17);
INSERT INTO public.doc_template_loan_product (loan_product_id, template_id) VALUES (107, 21);
INSERT INTO public.doc_template_loan_product (loan_product_id, template_id) VALUES (107, 30);
INSERT INTO public.doc_template_loan_product (loan_product_id, template_id) VALUES (107, 28);
INSERT INTO public.doc_template_loan_product (loan_product_id, template_id) VALUES (107, 3);
INSERT INTO public.doc_template_loan_product (loan_product_id, template_id) VALUES (107, 4);
INSERT INTO public.doc_template_loan_product (loan_product_id, template_id) VALUES (107, 5);
INSERT INTO public.doc_template_loan_product (loan_product_id, template_id) VALUES (107, 6);
INSERT INTO public.doc_template_loan_product (loan_product_id, template_id) VALUES (107, 18);
INSERT INTO public.doc_template_loan_product (loan_product_id, template_id) VALUES (107, 45);
INSERT INTO public.doc_template_loan_product (loan_product_id, template_id) VALUES (107, 20);
INSERT INTO public.doc_template_loan_product (loan_product_id, template_id) VALUES (107, 23);
