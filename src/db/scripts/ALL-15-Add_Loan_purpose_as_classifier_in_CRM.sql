INSERT INTO "classifier" ("type", "key", "value") VALUES
  ('loan_purpose', 'pc', 'PC'),
  ('loan_purpose', 'mobile_phone', 'Mobile phone'),
  ('loan_purpose', 'white_good', 'White good'),
  ('loan_purpose', 'tv', 'TV'),
  ('loan_purpose', 'furniture', 'Furniture'),
  ('loan_purpose', 'holiday_and_travel', 'Holiday and Travel '),
  ('loan_purpose', 'electrical_tools', 'Electrical tools '),
  ('loan_purpose', 'construction_materials', 'Construction materials'),
  ('loan_purpose', 'jewellery', 'Jewellery'),
  ('loan_purpose', 'insurance', 'Insurance'),
  ('loan_purpose', 'household_needs', 'Household needs'),
  ('loan_purpose', 'personal_needs', 'Personal needs'),
  ('loan_purpose', 'until_paycheck', 'Until paycheck'),
  ('loan_purpose', 'renovation', 'Renovation'),
  ('loan_purpose', 'closing_debts', 'Closing debts'),
  ('loan_purpose', 'refinance_in_other_mfi_or_bank', 'Refinance in other MFI or Bank'),
  ('loan_purpose', 'wedding', 'Wedding'),
  ('loan_purpose', 'health_expenses', 'Health expenses'),
  ('loan_purpose', 'car_expenses', 'Car expenses'),
  ('loan_purpose', 'other', 'Other');

ALTER TABLE "loan_application" ADD COLUMN "other_purpose" VARCHAR(255);

UPDATE "loan_application" SET "other_purpose" = "purpose";

UPDATE "loan_application" SET "other_purpose" = NULL WHERE "other_purpose" = '';

UPDATE "loan_application" SET "purpose" = 'other' WHERE "other_purpose" = "purpose" AND "other_purpose" IS NOT NULL;

UPDATE "loan_application" SET "purpose" = NULL WHERE "purpose" = '';
