SELECT pg_catalog.setval('overdue_process_settings_id_seq', 2, true);
INSERT INTO public.overdue_process_settings (created, delay_days, delay_interest, internal_collection_days, last_updated, last_updated_user, max_delay_days, max_suspended_days, min_delay_debt, min_reminder_debt, min_termination_debt, suspension_fee, valid_from, delay_interest_source)
  VALUES ('2019-02-12 12:00:00.000', 4, 0.03, 60, '2019-02-12 12:00:00.000', 'risto', 180, 17, 350.00, 350.00, 0.00, 300, '2019-02-12 00:00:00.000', 'PRIMARY');

SELECT pg_catalog.setval('overdue_action_id_seq', 29, false);
INSERT INTO public.overdue_action (action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id, alternate_delay_days)
  VALUES ('', 900.00, 'fix', '1st reminder letter', 'letter', '2019-02-12 12:00:00.000', NULL, NULL, 10, 9, true, false, 3, NULL);
INSERT INTO public.overdue_action (action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id, alternate_delay_days)
  VALUES ('', 1200.00, 'fix', '2nd reminder letter', 'letter', '2019-02-12 12:00:00.000', NULL, NULL, 20, 18, false, false, 3, NULL);
INSERT INTO public.overdue_action (action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id, alternate_delay_days)
  VALUES ('', 1500.00, 'fix', 'Termination alert', 'letter', '2019-02-12 12:00:00.000', NULL, NULL, 30, 24, false, false, 3, NULL);
INSERT INTO public.overdue_action (action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id, alternate_delay_days)
  VALUES ('', 4800.00, 'fix', 'Termination notice', 'letter', '2019-02-12 12:00:00.000', NULL, NULL, 50, 30, false, false, 3, NULL);
INSERT INTO public.overdue_action (action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id, alternate_delay_days)
  VALUES ('', 300.00, 'fix', '1st reminder SMS', 'sms', '2019-02-12 12:00:00.000', 1, NULL, 4, 2, true, true, 3, NULL);
INSERT INTO public.overdue_action (action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id, alternate_delay_days)
  VALUES ('', 300.00, 'fix', '5th reminder SMS', 'sms', '2017-09-04 12:00:00.000', 5, NULL, 41, 28, false, true, 3, NULL);
INSERT INTO public.overdue_action (action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id, alternate_delay_days)
  VALUES ('', 300.00, 'fix', '2nd reminder SMS', 'sms', '2019-02-12 12:00:00.000', 2, NULL, 14, 6, true, true, 3, NULL);
INSERT INTO public.overdue_action (action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id, alternate_delay_days)
  VALUES ('', 300.00, 'fix', '3rd reminder SMS', 'sms', '2019-02-12 12:00:00.000', 3, NULL, 24, 15, true, true, 3, NULL);
INSERT INTO public.overdue_action (action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id, alternate_delay_days)
  VALUES ('', 300.00, 'fix', '4th reminder SMS', 'sms', '2019-02-12 12:00:00.000', 4, NULL, 34, 21, false, true, 3, NULL);
INSERT INTO public.overdue_action (action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id, alternate_delay_days)
  VALUES ('', 0.00, NULL, 'First reminder call', 'call', '2019-02-12 12:00:00.000', NULL, NULL, 6, 3, true, true, 3, NULL);
INSERT INTO public.overdue_action (action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id, alternate_delay_days)
  VALUES ('', 0.00, NULL, 'Second reminder call', 'call', '2019-02-12 12:00:00.000', NULL, NULL, 16, 12, true, true, 3, NULL);
INSERT INTO public.overdue_action (action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id, alternate_delay_days)
  VALUES ('', 0.00, NULL, 'Third reminder call', 'call', '2019-02-12 12:00:00.000', NULL, NULL, 36, 20, false, true, 3, NULL);
INSERT INTO public.overdue_action (action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id, alternate_delay_days)
  VALUES ('', 0.00, NULL, 'Valid for debt collection', 'other', '2019-02-12 12:00:00.000', NULL, NULL, 51, 36, false, false, 3, NULL);