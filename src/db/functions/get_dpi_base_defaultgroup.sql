DROP FUNCTION IF EXISTS get_dpi_base_defaultgroup(date, date, date);
create function get_dpi_base_defaultgroup(date, date, date)
  returns TABLE(
    loanappid integer,
    loanproduct text,
    loanproductid integer,
    refnr text,
    firstname text,
    lastname text,
    office text,
    incassocompany text,
    loanperiod integer,
    activedate date,
    defaulteddate date,
    collectiondate date,
    termdebt numeric,
    collectdebt numeric,
    paymentdate date,
    paymentsum numeric,
    sincedefault integer,
    sincecollection integer,
    collectioncompanyid integer,
    availabledefaulted integer,
    availablecollected integer)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    dl.loanappid AS r_loanappid,
    dl.loanproduct AS r_loanproduct,
    dl.loanproductid AS r_loanproductid,
    dl.refnr AS r_refnr,
    dl.firstname AS r_firstname,
    dl.lastname AS r_lastname,
    dl.office AS r_office,
    dl.incassocompany AS r_incassocompany,
    dl.loanperiod AS r_loanperiod,
    dl.activedate::date AS r_activedate,
    dl.defaulteddate::date AS r_defaulteddate,
    dl.collectiondate::date AS r_collectiondate,
    dl.totaldebt AS r_termdebt,
    clb.totaldebt AS r_collectdebt,
    rp.payment_date::date AS r_paymentdate,

    coalesce(rp.sum, 0::numeric) AS r_paymentsum,
    DATE_PART('day', rp.payment_date - dl.defaulteddate)::integer AS since_default,
    DATE_PART('day', rp.payment_date - dl.collectiondate)::integer AS since_collection,
    cs.collection_company_id AS r_collectioncompanyid,
    coalesce(($3 - dl.defaulteddate), -1)::integer AS available_defaulted,
    coalesce(($3 - dl.collectiondate), -1)::integer AS r_availablecollected

  FROM get_defaulted_loanapps_base('2008-01-01', '2200-01-01', $3) dl
    LEFT JOIN get_indebtcollection_loanapps_base('2008-01-01', '2200-01-01', $3) clb ON clb.loanappid = dl.loanappid
    LEFT JOIN repayments rp ON dl.loanappid=rp.loan_app_id
    LEFT JOIN loan_application la ON la.id=dl.loanappid
    LEFT JOIN collection_scheme cs ON la.collection_scheme_id=cs.id
  WHERE
    --(rp.payment_date >= dl.defaulteddate OR rp.payment_date IS NULL) AND
    dl.defaulteddate >= $1 AND dl.defaulteddate <=$2;
END;
$$;
