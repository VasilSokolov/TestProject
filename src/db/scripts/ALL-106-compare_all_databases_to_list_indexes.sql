CREATE INDEX IF NOT EXISTS act_idx_exe_procdef ON act_ru_execution USING btree (proc_def_id_);
CREATE INDEX IF NOT EXISTS idx_assignee ON task_data USING btree (assignee);
CREATE INDEX IF NOT EXISTS idx_task_id ON task_data USING btree (task_id);
CREATE INDEX IF NOT EXISTS index_campaign_client_pin ON campaign_client USING btree (client_pin);
CREATE INDEX IF NOT EXISTS index_client_aftersale_data_pin ON client_aftersale_data USING btree (client_pin);
CREATE INDEX IF NOT EXISTS index_client_history_loan_app_id ON client_history USING btree (loan_app_id);
CREATE INDEX IF NOT EXISTS index_client_profile_id ON client_profile USING btree (id);
CREATE INDEX IF NOT EXISTS index_loan_application_client_id ON loan_application USING btree (client_id);
CREATE INDEX IF NOT EXISTS index_loan_application_dealer_id ON loan_application USING btree (dealer_id);
CREATE INDEX IF NOT EXISTS index_loan_status_loan_app_id ON loan_status USING btree (loan_app_id);
CREATE INDEX IF NOT EXISTS index_repayments_user ON repayments USING btree (user_name);
CREATE INDEX IF NOT EXISTS index_submitted_loan_application_loan_app_id ON submitted_loan USING btree (loan_app_id);
CREATE INDEX IF NOT EXISTS index_taskhist_id ON act_hi_taskinst USING btree (id_);
CREATE INDEX IF NOT EXISTS loan_app_data_check_loan_app_id ON loan_app_data_check USING btree (loan_app_id);
CREATE INDEX IF NOT EXISTS loan_status_composite ON loan_status USING btree (loan_app_id, status);
CREATE INDEX IF NOT EXISTS loan_status_generated ON loan_status USING btree (generated);
CREATE INDEX IF NOT EXISTS loan_status_loan_app_id ON loan_status USING btree (loan_app_id);
CREATE INDEX IF NOT EXISTS loan_status_status ON loan_status USING btree (status);
CREATE UNIQUE INDEX IF NOT EXISTS act_hi_procinst_proc_def_id__business_key__key ON act_hi_procinst USING btree (proc_def_id_, business_key_);
CREATE UNIQUE INDEX IF NOT EXISTS act_hi_procinst_proc_def_id__key ON act_hi_procinst USING btree (proc_def_id_, business_key_);
CREATE UNIQUE INDEX IF NOT EXISTS act_ru_execution_proc_def_id__business_key__key ON act_ru_execution USING btree (proc_def_id_, business_key_);
CREATE UNIQUE INDEX IF NOT EXISTS act_ru_execution_proc_def_id__key ON act_ru_execution USING btree (proc_def_id_, business_key_);
CREATE UNIQUE INDEX IF NOT EXISTS loan_product_settings_loan_product_id_type_dealer_id_key ON loan_product_settings USING btree (loan_product_id, type, dealer_id);
CREATE UNIQUE INDEX IF NOT EXISTS loan_products_sort_order_uindex ON loan_products USING btree (sort_order);
CREATE UNIQUE INDEX IF NOT EXISTS pk_task_data ON task_data USING btree (id);
CREATE UNIQUE INDEX IF NOT EXISTS task_data_pkey ON task_data USING btree (id);