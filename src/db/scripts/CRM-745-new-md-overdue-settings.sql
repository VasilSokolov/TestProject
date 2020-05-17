SELECT pg_catalog.setval('overdue_process_settings_id_seq', 6, false);
INSERT INTO overdue_process_settings (created, last_updated, last_updated_user, max_suspended_days, valid_from, delay_days, delay_interest, internal_collection_days, max_delay_days, min_delay_debt, min_reminder_debt, min_termination_debt, suspension_fee, delay_interest_source)
	VALUES ('2019-02-12 12:00:00', '2019-02-12 12:00:00', 'risto', 17, '2019-02-12 00:00:00', 4, 0.60, 60, 180, 50.00, 50.00, 0.00, 65, 'PRIMARY');

SELECT pg_catalog.setval('overdue_action_id_seq', 68, false);
INSERT INTO overdue_action (action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id, alternate_delay_days)
	VALUES ('', 0.00, NULL, '1st reminder SMS', 'sms', '2019-02-12 12:00:00', 117, 118, 2, 2, true, true, 6, NULL);
INSERT INTO overdue_action (action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id, alternate_delay_days)
	VALUES ('', 0.00, NULL, '2nd reminder SMS', 'sms', '2019-02-12 12:00:00', 119, 120, 11, 6, true, true, 6, NULL);
INSERT INTO overdue_action (action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id, alternate_delay_days)
	VALUES ('', 0.00, NULL, '3rd reminder SMS', 'sms', '2019-02-12 12:00:00', 121, 122, 21, 15, true, true, 6, NULL);
INSERT INTO overdue_action (action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id, alternate_delay_days)
	VALUES ('', 0.00, NULL, '4th reminder SMS', 'sms', '2019-02-12 12:00:00', 123, 124, 31, 21, false, true, 6, NULL);
INSERT INTO overdue_action (action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id, alternate_delay_days)
	VALUES ('', 0.00, NULL, 'First reminder call', 'call', '2019-02-12 12:00:00', NULL, NULL, 8, 3, true, true, 6, NULL);
INSERT INTO overdue_action (action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id, alternate_delay_days)
	VALUES ('', 0.00, NULL, 'Second reminder call', 'call', '2019-02-12 12:00:00', NULL, NULL, 17, 12, true, true, 6, NULL);
INSERT INTO overdue_action (action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id, alternate_delay_days)
	VALUES ('', 0.00, NULL, 'Third reminder call', 'call', '2019-02-12 12:00:00', NULL, NULL, 33, 20, false, true, 6, NULL);
INSERT INTO overdue_action (action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id, alternate_delay_days)
	VALUES ('', 200.00, 'fix', '1st reminder letter', 'letter', '2019-02-12 12:00:00', 71, 71, 10, 9, true, false, 6, NULL);
INSERT INTO overdue_action (action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id, alternate_delay_days)
	VALUES ('', 200.00, 'fix', '2nd reminder letter', 'letter', '2019-02-12 12:00:00', 72, 72, 20, 18, false, false, 6, NULL);
INSERT INTO overdue_action (action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id, alternate_delay_days)
	VALUES ('', 0.00, NULL, 'Valid for debt collection', 'other', '2019-02-12 12:00:00', NULL, NULL, 70, 36, false, false, 6, 60);
INSERT INTO overdue_action (action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id, alternate_delay_days)
	VALUES ('', 0.00, NULL, '5th reminder SMS', 'sms', '2019-02-12 12:00:00', 127, 128, 41, 28, false, true, 6, NULL);
INSERT INTO overdue_action (action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id, alternate_delay_days)
	VALUES ('', 200.00, 'fix', 'Termination alert', 'letter', '2019-02-12 12:00:00', 73, 73, 30, 24, false, false, 6, NULL);
INSERT INTO overdue_action (action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id, alternate_delay_days)
	VALUES ('', 30.00, 'perc', 'Termination notice', 'letter', '2019-02-12 12:00:00', 74, 74, 50, 30, false, false, 6, NULL);


SELECT pg_catalog.setval('overdue_delay_interest_id_seq', 7, false);
INSERT INTO public.overdue_delay_interest(created, debt_from, debt_to, delay_interest_sum, overdue_settings_id)
    VALUES ('2019-02-12 12:00:00', 50.00, 100.00, 10.00, 6);
INSERT INTO public.overdue_delay_interest(created, debt_from, debt_to, delay_interest_sum, overdue_settings_id)
    VALUES ('2019-02-12 12:00:00', 100.00, 150.00, 15.00, 6);
INSERT INTO public.overdue_delay_interest(created, debt_from, debt_to, delay_interest_sum, overdue_settings_id)
    VALUES ('2019-02-12 12:00:00', 150.00, NULL, 20.00, 6);
