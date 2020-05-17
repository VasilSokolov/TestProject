create table product_group_limit(
  id serial NOT NULL,
  amount numeric not null,
  primary key (id)
);

create table product_group_limit_products(

  id serial NOT NULL,
  loan_product_id integer NOT NULL references loan_products(id),
  group_limit_id integer NOT NULL references product_group_limit(id),
  primary key (id)
);
