INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Kredia juaj eshte aprovuar. Shuma e kredise [amount] eur, Kesti [payback] eur, Data e pageses [first_rp]. Dergo PO nese pranoni.</p>',
now(), 'Comfort SMS - 1 month accepted', 'alb', 'comfort_accepted_1month_sms', 'sms');

INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Kredia juaj eshte aprovuar. Shuma e kredise [amount] eur, Kesti i pare [first_payback] eur deri me [first_rp] dhe Kesti i dyte [second_payback] eur deri me [second_rp]. Dergo PO nese pranoni.</p>',
now(), 'Comfort SMS - 2 months accepted', 'alb', 'comfort_accepted_2month_sms', 'sms');

INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Shuma kredise u transferua ne numrin e llogarise. [bank_account] ne [bank_name]. Kontrata nr. [ref_nr]</p>',
now(), 'Comfort SMS - Paid out', 'alb', 'comfort_paidout_sms', 'sms');

INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Kerkesa juaj per kredi u refuzua. Ju lutem telefononi 038406080 per cdo informacion shtese.</p>',
now(), 'Comfort SMS - Rejected', 'alb', 'comfort_rejected_sms', 'sms');

INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Aprovimi duhet derguar nga i njejti numer telefoni nga ku keni derguar aplikimin. Ju lutem telefononi 038406080 per me shume informacion</p>',
now(), 'Comfort SMS - Unmatched phone', 'alb', 'comfort_unmatched_phone_sms', 'sms');

INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Numer personal i gabuar</p>',
now(), 'Comfort SMS - Invalid PIN', 'alb', 'comfort_invalid_pin_sms', 'sms');

INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Shume e gabuar</p>',
now(), 'Comfort SMS - Invalid sum', 'alb', 'comfort_invalid_sum_sms', 'sms');

INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Shuma e kredise me e vogel se shuma e lejuar</p>',
now(), 'Comfort SMS - Sum too small', 'alb', 'comfort_too_small_sum_sms', 'sms');

INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Shuma e kredise me e madhe se shuma e lejuar</p>',
now(), 'Comfort SMS - Sum too large', 'alb', 'comfort_too_big_sum_sms', 'sms');

INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Kredia comfort nuk mund te lejohet</p>',
now(), 'Comfort SMS - Not allowed', 'alb', 'comfort_not_allowed_sms', 'sms');

INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Ju keni dhe nje aplikim tjeter per kredi te aprovuar. Ju lutem na kontaktoni ne 042239111</p>',
now(), 'Comfort SMS - Already approved loan', 'alb', 'comfort_already_has_approved_loan_sms', 'sms');
