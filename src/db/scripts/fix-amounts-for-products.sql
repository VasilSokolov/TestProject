create table loan_product_fix_amount(

  id serial NOT NULL,
  loan_product_id integer NOT NULL references loan_products(id),
  amount numeric not null,
  primary key (id)
);

alter table loan_products add column requesting_fix_amount_by_sms_mandatory boolean default false;