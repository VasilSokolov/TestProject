insert into loan_products (id,"name", admission_fee_perc, apr_threshold, apr_threshold_evening, max_apr, max_interest, max_loan_period, max_principal, min_apr, min_interest, min_loan_period, min_principal,  pm_default, req_id_copy, req_salary_cert, suspension_fee, "type", salary_ratio_regular, salary_ratio_second_active, salary_ratio_unofficial, apr_threshold_evening_guarantee, apr_threshold_guarantee, guarantee_fee_perc, guarantee_max_period, guarantee_product, paid_inst_records_threshold, turnover_threshold, max_suspended_days, official_paid_inst_records_threshold, official_turnover_threshold, salary_cert_limit, official_paid_inst_records_threshold_office, official_turnover_threshold_office, paid_inst_records_threshold_office, turnover_threshold_office, enabled, sort_order, car_loan, max_car_value_perc, guarantee_monthly_max, sms_sign_limit, requires_data_verification, requesting_fix_amount_by_sms_mandatory, checking_links_mandatory, initial_restructured_contribution)
select rownum, "name"||' not_ready',admission_fee_perc, apr_threshold, apr_threshold_evening, max_apr, max_interest, max_loan_period, max_principal, min_apr, min_interest, min_loan_period, min_principal, pm_default, req_id_copy, req_salary_cert, suspension_fee, "type", salary_ratio_regular, salary_ratio_second_active, salary_ratio_unofficial, apr_threshold_evening_guarantee, apr_threshold_guarantee, guarantee_fee_perc, guarantee_max_period, guarantee_product, paid_inst_records_threshold, turnover_threshold, max_suspended_days, official_paid_inst_records_threshold, official_turnover_threshold, salary_cert_limit, official_paid_inst_records_threshold_office, official_turnover_threshold_office, paid_inst_records_threshold_office, turnover_threshold_office, enabled, sort_order_max.sorder+rownum-104, car_loan, max_car_value_perc, guarantee_monthly_max, sms_sign_limit, requires_data_verification, requesting_fix_amount_by_sms_mandatory, checking_links_mandatory, initial_restructured_contribution 
from  (
	select  104 + row_number() OVER (ORDER BY "name") AS rownum, id FROM public.loan_products where "name" like 'Car%'
	and not exists (select * from loan_products where "name" like '% not_ready') order by "name") data1
	inner join loan_products on data1.id=loan_products.id,
	(select max(sort_order) as sorder from loan_products) as sort_order_max;


insert into loan_product_condition (loan_product_id, commission_perc, commission_perc_cash, interest_perc, interest_perc_cash, loan_amount_from, loan_amount_to, "period",  admin_fee_percent)
select dst.id,src.commission_perc, src.commission_perc_cash, src.interest_perc, src.interest_perc_cash, src.loan_amount_from, src.loan_amount_to, src."period", src.admin_fee_percent from loan_products src_lp inner join loan_products dst on src_lp."name"||' not_ready'=dst."name"
inner join loan_product_condition src on src.loan_product_id=src_lp.id
and not exists (select * from loan_product_condition inner join loan_products on loan_products.id=loan_product_condition.loan_product_id where loan_products."name" like '%not_ready');


insert into loan_product_car_value_perc (loan_product_id, car_value_from, car_value_to, max_loan_perc)
select dst.id,src.car_value_from, src.car_value_to, src.max_loan_perc from loan_products src_lp inner join loan_products dst on src_lp."name"||' not_ready'=dst."name"
inner join loan_product_car_value_perc src on src.loan_product_id=src_lp.id
and not exists (select * from loan_product_car_value_perc inner join loan_products on loan_products.id=loan_product_car_value_perc.loan_product_id where loan_products."name" like '%not_ready');


insert into loan_product_fix_amount (loan_product_id, amount)
select dst.id,src.amount from loan_products src_lp inner join loan_products dst on src_lp."name"||' not_ready'=dst."name"
inner join loan_product_fix_amount src on src.loan_product_id=src_lp.id
and not exists (select * from loan_product_fix_amount inner join loan_products on loan_products.id=loan_product_fix_amount.loan_product_id where loan_products."name" like '%not_ready');


insert into loan_product_settings (loan_product_id, allow_cash_release_duration, check_docs_duration, dealer_id, checking_duration, check_score_duration, scoring_duration, notify_client_duration, pay_out_duration, send_precontract_duration, "type", upload_agreement_duration, vip, check_official_duration, check_official_short_duration, check_unofficial_altcontact_duration, check_unofficial_employer_duration, check_unofficial_person_duration, check_balance_duration, deposit_money_duration, issue_card_duration, issue_pin_duration, bonus_task_duration_until_paid_out)
select dst.id,allow_cash_release_duration, check_docs_duration, dealer_id, checking_duration, check_score_duration, scoring_duration, notify_client_duration, pay_out_duration, send_precontract_duration, src."type", upload_agreement_duration, vip, check_official_duration, check_official_short_duration, check_unofficial_altcontact_duration, check_unofficial_employer_duration, check_unofficial_person_duration, check_balance_duration, deposit_money_duration, issue_card_duration, issue_pin_duration, bonus_task_duration_until_paid_out from loan_products src_lp inner join loan_products dst on src_lp."name"||' not_ready'=dst."name"
inner join loan_product_settings src on src.loan_product_id=src_lp.id
and not exists (select * from loan_product_settings src inner join loan_products on loan_products.id=src.loan_product_id where loan_products."name" like '%not_ready');

