
INSERT INTO loan_products (id, admission_fee_perc, apr_threshold, apr_threshold_evening,   dept_collection_days, first_call_days,
                           first_letter_days, first_letter_fee, first_sms_days, first_sms_text, fourth_call_days, invitation_text,
                           max_apr, max_interest, max_loan_period, max_principal, min_apr, min_interest, min_loan_period, min_principal,
                           name, pm_default, preclaim_days, req_id_copy, req_salary_cert,
                           second_call_days, second_letter_days, second_letter_fee, second_sms_days, second_sms_text, suspension_fee,
                           term_alert_letter_days, term_alert_letter_fee, term_letter_days, term_letter_days_max, term_letter_fee_perc,
                           thankyou_notice, third_call_days, third_letter_days, third_letter_fee, type, salary_ratio_regular,
                           salary_ratio_second_active, salary_ratio_unofficial, apr_threshold_evening_guarantee, apr_threshold_guarantee,
                           guarantee_fee_perc, guarantee_max_period, guarantee_product, closed_loans_archival_threshold_years,
                           defaulted_loans_archival_threshold_years,  paid_inst_records_threshold, turnover_threshold,
                           max_suspended_days, official_paid_inst_records_threshold, official_turnover_threshold, salary_cert_limit,
                           official_paid_inst_records_threshold_office, official_turnover_threshold_office, paid_inst_records_threshold_office,
                           turnover_threshold_office, term_sms_days, third_sms_days, enabled, sort_order, payment_sms_days,
                           car_loan, max_car_value_perc, guarantee_monthly_max, sms_sign_limit, requires_data_verification)
VALUES
  (100, 0, 90, 90, 70,
        8, 13, 1500, 11, 'Field not used',
        40, NULL, 145, 0, 1, 200, 0,
            0, 1, 50,
            'FFF for 1 month', TRUE, NULL, TRUE, FALSE, 17, 26,
                               1500, 24, 'Field not used', 500, 37,
                                                                1500, 50, 50, 30, NULL, 27,
                                                                NULL, NULL, 'regular', 40, 40, 40,
                                                                                       90, 90, 0.4, NULL, false,
                                                                                       3, 5,  4,
                                                                                              0, 17, 4, 0, NULL,
                                                                                              4, 0, 5, 0,
    50, 28, FALSE, 9, 2,  FALSE,
    0, NULL, NULL, FALSE);

INSERT INTO loan_product_settings (allow_cash_release_duration, check_docs_duration, dealer_id, checking_duration, check_score_duration, scoring_duration, notify_client_duration, pay_out_duration, send_precontract_duration, type, upload_agreement_duration, vip, loan_product_id, check_official_duration, check_official_short_duration, check_unofficial_altcontact_duration, check_unofficial_employer_duration, check_unofficial_person_duration, check_balance_duration, deposit_money_duration, issue_card_duration, issue_pin_duration, bonus_task_duration_until_paid_out)
VALUES (
  30, null, null, 45, 60,
      15, 15, 60, null, 'general',
      15, false, 100, null, null,
          null, null, null,
          null, null, null, null, 30);

INSERT INTO loan_product_condition (commission_perc, commission_perc_cash, interest_perc, interest_perc_cash, loan_amount_from, loan_amount_to, period, loan_product_id)
VALUES (10, 10, 8, 8, 50,
        200.01, 1, 100);