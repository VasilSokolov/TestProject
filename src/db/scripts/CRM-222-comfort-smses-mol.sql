INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Cererea Dvs a fost acceptata. Suma credit [amount] mdl, total spre rambursare [payback] mdl, data rambursarii [first_rp]. Daca acceptati, raspundeti DA</p>',
now(), 'Comfort SMS - 1 month accepted', 'rom', 'comfort_accepted_1month_sms', 'sms');
INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Vasha zaiavka byla odobrena. Summa credita [amount] mdl, vsego k vozvratu [payback] mdl, data plateja [first_rp]. V sluchaie soglasia otpravâte DA</p>',
now(), 'Comfort SMS - 1 month accepted', 'rus', 'comfort_accepted_1month_sms', 'sms');
INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Your loan was accepted. Loan amount [amount] mdl, payback amount [payback] mdl, payment date [first_rp]. Please send YES in case of acceptance.</p>',
now(), 'Comfort SMS - 1 month accepted', 'eng', 'comfort_accepted_1month_sms', 'sms');

INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Cererea Dvs a fost acceptata. Suma credit [amount] mdl, spre rambursare [first_payback] mdl la data [first_rp] si [second_payback] mdl la data [second_rp]. Daca acceptati, raspundeti DA</p>',
now(), 'Comfort SMS - 2 months accepted', 'rom', 'comfort_accepted_2month_sms', 'sms');
INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Vasha zaiavka byla odobrena. Summa credita [amount] mdl, k vozvratu [first_payback] mdl do [first_rp] i [second_payback] mdl do [second_rp]. V sluchaie soglasia otpravâte DA</p>',
now(), 'Comfort SMS - 2 months accepted', 'rus', 'comfort_accepted_2month_sms', 'sms');
INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Your loan was accepted. Loan amount [amount] mdl, payback amount [first_payback] mdl up to [first_rp] and [second_payback] mdl up to [second_rp]. Please send YES in case of acceptance.</p>',
now(), 'Comfort SMS - 2 months accepted', 'eng', 'comfort_accepted_2month_sms', 'sms');

INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Suma creditului a fost transferata in contul Dvs [bank_account] din [bank_name]. Nr. contract [ref_nr]</p>',
now(), 'Comfort SMS - Paid out', 'rom', 'comfort_paidout_sms', 'sms');
INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Summa credita byla perevedena na vash schet [bank_account] v [bank_name]. Nr. contracta [ref_nr]</p>',
now(), 'Comfort SMS - Paid out', 'rus', 'comfort_paidout_sms', 'sms');
INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Loan amount was transferred to account no. [bank_account] in [bank_name]. Agreement no. [ref_nr]</p>',
now(), 'Comfort SMS - Paid out', 'eng', 'comfort_paidout_sms', 'sms');

INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Cererea Dvs de credit a fost respinsa. Pentru informatii aditionale apelati 022801500</p>',
now(), 'Comfort SMS - Rejected', 'rom', 'comfort_rejected_sms', 'sms');
INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Vasha zaiavka na poluchenie credita byla otklonena. Dopolnitelnaia informatia po telefonu 022801500</p>',
now(), 'Comfort SMS - Rejected', 'rus', 'comfort_rejected_sms', 'sms');
INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Your loan request was rejected. Please call 022801500 for any additional info.</p>',
now(), 'Comfort SMS - Rejected', 'eng', 'comfort_rejected_sms', 'sms');

INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Aprobarea trebuie sa fie exprimata de pe numarul prin care a fost depusa cererea. Pentru informatii aditionale apelati 022801500.</p>',
now(), 'Comfort SMS - Unmatched phone', 'rom', 'comfort_unmatched_phone_sms', 'sms');
INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Utverzhdenie dolzhno byt otpravleno s togo zhe telefonnogo nomera, otkuda zajavka byla otpravlena. Dopolnitelnaia informatsia po telefonu 022801500.</p>',
now(), 'Comfort SMS - Unmatched phone', 'rus', 'comfort_unmatched_phone_sms', 'sms');
INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Approval must be sent from the same phone number where the loan application was sent from. Please call 022801500 for any additional info.</p>',
now(), 'Comfort SMS - Unmatched phone', 'eng', 'comfort_unmatched_phone_sms', 'sms');

INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Codul IDNP este indicat gresit. Trebuie sa contina 13 cifre, fara spatii si alte simboluri. Pentru suport apelati 022801500</p>',
now(), 'Comfort SMS - Invalid PIN', 'rom', 'comfort_invalid_pin_sms', 'sms');
INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Not valid PIN code</p>',
now(), 'Comfort SMS - Invalid PIN', 'eng', 'comfort_invalid_pin_sms', 'sms');

INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Acest format al sumei nu este permis. Suma trebuie sa fie intre 1000 si 3000 lei, fara spatii si alte simboluri. Pentru suport apelati 022801500</p>',
now(), 'Comfort SMS - Invalid sum', 'rom', 'comfort_invalid_sum_sms', 'sms');
INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Not valid loan amount</p>',
now(), 'Comfort SMS - Invalid sum', 'eng', 'comfort_invalid_sum_sms', 'sms');

INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Suma indicata in cerere este prea mica. Suma minima este 1000. Pentru suport apelati 022801500</p>',
now(), 'Comfort SMS - Sum too small', 'rom', 'comfort_too_small_sum_sms', 'sms');
INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Loan amount too small</p>',
now(), 'Comfort SMS - Sum too small', 'eng', 'comfort_too_small_sum_sms', 'sms');

INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Suma indicata in cerere este prea mare. Suma maxima este 3000. Pentru suport apelati 022801500</p>',
now(), 'Comfort SMS - Sum too large', 'rom', 'comfort_too_big_sum_sms', 'sms');
INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Loan amount too big</p>',
now(), 'Comfort SMS - Sum too large', 'eng', 'comfort_too_big_sum_sms', 'sms');

INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>La momentul de fata nu va putem oferi un imprumut prin SMS. Pentru suport apelati 022801500</p>',
now(), 'Comfort SMS - Not allowed', 'rom', 'comfort_not_allowed_sms', 'sms');
INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Comfort not allowed</p>',
now(), 'Comfort SMS - Not allowed', 'eng', 'comfort_not_allowed_sms', 'sms');

INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Aveti deja o cerere aprobata. Pentru informatii apelati 022801500</p>',
now(), 'Comfort SMS - Already approved loan', 'rom', 'comfort_already_has_approved_loan_sms', 'sms');
INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>You already have one approved application. Please contact us 022500600</p>',
now(), 'Comfort SMS - Already approved loan', 'eng', 'comfort_already_has_approved_loan_sms', 'sms');
