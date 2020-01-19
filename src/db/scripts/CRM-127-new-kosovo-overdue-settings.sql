INSERT INTO overdue_process_settings (id, created, delay_days, delay_interest, internal_collection_days, last_updated, last_updated_user, max_delay_days, max_suspended_days, min_delay_debt, min_reminder_debt, min_termination_debt, suspension_fee, valid_from)
VALUES (3, '2018-07-04 00:00:00', 4, 0.60, 40, '2018-07-04 00:00:00', 'risto', 180, 17, 5.00, 5.00, 0.00, 5, '2018-07-06 00:00:00');

INSERT INTO overdue_action (id, action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id)
VALUES (42, '', 0.00, NULL, 'First reminder call', 'call', '2018-07-04 12:00:00', NULL, NULL, 6, 3, true, true, 3);

INSERT INTO overdue_action (id, action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id)
VALUES (43, '', 0.00, NULL, 'Second reminder call', 'call', '2018-07-04 12:00:00', NULL, NULL, 16, 12, true, true, 3);

INSERT INTO overdue_action (id, action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id)
VALUES (44, '', 0.00, NULL, 'Third reminder call', 'call', '2018-07-04 12:00:00', NULL, NULL, 36, 20, false, true, 3);

INSERT INTO overdue_action (id, action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id)
VALUES (45, '', 15.00, 'fix', '1st reminder letter', 'letter', '2018-07-04 12:00:00', NULL, NULL, 10, 9, true, false, 3);

INSERT INTO overdue_action (id, action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id)
VALUES (46, '', 20.00, 'fix', '2nd reminder letter', 'letter', '2018-07-04 12:00:00', NULL, NULL, 20, 18, false, false, 3);

INSERT INTO overdue_action (id, action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id)
VALUES (47, '', 25.00, 'fix', 'Termination alert', 'letter', '2018-07-04 12:00:00', NULL, NULL, 30, 24, false, false, 3);

INSERT INTO overdue_action (id, action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id)
VALUES (48, '', 50.00, 'fix', 'Termination notice', 'letter', '2018-07-04 12:00:00', NULL, NULL, 50, 30, false, false, 3);

INSERT INTO overdue_action (id, action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id)
VALUES (49, '', 0.00, NULL, 'Valid for debt collection', 'other', '2018-07-04 12:00:00', NULL, NULL, 90, 36, false, false, 3);

INSERT INTO overdue_action (id, action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id)
VALUES (50, '', 5.00, 'fix', '5th reminder SMS', 'sms', '2017-09-04 12:00:00', 22, NULL, 41, 28, false, true, 3);

INSERT INTO overdue_action (id, action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id)
VALUES (51, '', 2.00, 'fix', '1st reminder SMS', 'sms', '2018-07-04 12:00:00', 18, NULL, 4, 2, true, true, 3);

INSERT INTO overdue_action (id, action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id)
VALUES (52, '', 2.00, 'fix', '2nd reminder SMS', 'sms', '2018-07-04 12:00:00', 19, NULL, 14, 6, true, true, 3);

INSERT INTO overdue_action (id, action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id)
VALUES (53, '', 2.00, 'fix', '3rd reminder SMS', 'sms', '2018-07-04 12:00:00', 20, NULL, 24, 15, false, true, 3);

INSERT INTO overdue_action (id, action_desc, action_fee, action_fee_unit, action_name, action_type, created, doc_template_id, doc_template_secondary_id, overdue_days, reminder_type, skip_for_suspended, soft_process_action, overdue_settings_id)
VALUES (54, '', 2.00, 'fix', '4th reminder SMS', 'sms', '2018-07-04 12:00:00', 21, NULL, 34, 21, false, true, 3);