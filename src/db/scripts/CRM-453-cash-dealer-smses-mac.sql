INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES 
('<p>Vasata aplikacija e odobrena. Vnesete go kodot [code] preku formata koja ja dobivte na mail za da go potpisete Dogovorot</p>',
now(), 'Send signing data sms', 'mac', 'send_signing_data_sms', 'sms');

INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES
('<p>Potpisuvanjeto na Dogovorot e uspesno. Odobreniot iznos kje bide prefrlen na Vasata transakciska smetka</p>',
now(), 'Cash release allowed sms', 'mac', 'cash_release_allowed_sms', 'sms');

INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES
('<p>Iznosot na odobreniot kredit e prefrlen na Vasata smetka [bank_account] vo [bank_name]. Br. na dogovor [ref_nr]</p>',
now(), 'Paidout sms', 'mac', 'paidout_sms', 'sms');

INSERT INTO doc_template (content, created, name, lang, type, template_type) VALUES
('<p>Potpisuvanjeto na Dogovorot br. [ref_nr] e uspesno. Kje ve kontaktiraat od [dealer_name] za dostava na proizvodot!</p>',
now(), 'Dealer loan cash release allowed sms', 'mac', 'dealer_release_allowed_sms', 'sms');
