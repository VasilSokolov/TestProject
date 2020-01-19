DROP FUNCTION IF EXISTS get_defaulted_loanapps_export(date, date, INTEGER);
create function get_defaulted_loanapps_export(date, date, INTEGER) returns TABLE(loanappid integer, firstname text, lastname text, patronymic text, birthdate date, dwellingtype text, companyform text, clientpin text, realaddress text, realtownmunicipality text, realzip text, legaladdress text, legaltownvillage text, legaltownmunicipality text, legalzip text, phonehome text, phonework text, phonegsm text, email text, refnr text, contractprintdate date, incassodate date, terminationdate date, debtamount numeric, referencenumber text, otherdata text, comments text, comments2 text)
AS $$
BEGIN

  RETURN QUERY
  SELECT

    dl.loanappid AS loanappid_res,
    cp.first_name ::text AS firstname_res,
    cp.last_name::text AS lastname_res,
    cp.patronymic::text AS patronymic_res,
    cp.birth_date::date AS birthdate_res,
    cp.dwelling_type::text AS dwellingtype_res,
    ''::text AS companyform_res,
    cp.pin::text AS clientpin_res,
    (coalesce(cp.home_street,'NA') || ', ' || coalesce(cp.home_house_number,'NA') || ' - ' || coalesce(cp.home_apartment,'NA'))::text::text AS realaddress_res,
    cp.home_town::text AS realtownmunicipality_res,
    cp.home_zip::text AS realzip_res,
    (coalesce(cp.home_street,'NA') || ', ' || coalesce(cp.home_house_number,'NA') || ' - ' || coalesce(cp.home_apartment,'NA'))::text AS legaladdress_res,
    cp.home_town::text AS legaltownvillage_res,
    cp.home_town::text AS legaltownmunicipality_res,
    cp.home_zip::text AS legalzip_res,
    cp.phone_home::text AS phonehome_res,
    cp.phone_work::text AS phonework_res,
    (coalesce(cp.gsm,'NA'))::text AS phonegsm_res,
    cp.email::text AS email_res,
    la.ref_nr::text AS refnr_res,
    dl.activedate AS contractprintdate_res,
    dl.collectiondate::date AS incassodate_res,
    la.term_date::date AS terminationdate_res,
    dl.totaldebt AS debtamount_res,
    la.ref_nr::text AS referencenumber_res,
    coalesce(coalesce(cp.birth_date::date, null)::text,'NA') || ', ' ||
    coalesce(cp.marital_status, 'NA') || ', ' ||
    coalesce(cp.education, 'NA') || ', ' ||
    coalesce(cp.position, 'NA') || ', '||
    coalesce(cp.job_income::text, 'NA') || ', '||
    coalesce(em.name, 'NA') || ', ' ||
    coalesce(em.street, 'NA') || ', ' ||
    coalesce(em.house_number, 'NA') ||', '||
    coalesce(em.town::text, 'NA') AS otherdata_res,
    coalesce(cp.alternative_contact, 'NA') || ', ' ||
    coalesce(cp.alternative_contact_relation, 'NA') || ', ' ||
    coalesce(cp.alternative_contact_phone, 'NA') || ', ' ||
    coalesce(cp.position, 'NA') || ', ' ||
    coalesce(coalesce(cp.work_started::date, null)::text,'NA') || ', ' ||
    coalesce(em.reg_code, 'NA') || ', ' ||
    coalesce(em.name, 'NA') || ', ' ||
    coalesce(em.address, 'NA') || ', ' ||
    coalesce(em.phone, 'NA') AS comments_res,
    coalesce(cp.alternative_contact, 'NA') || ', ' ||
    coalesce(cp.alternative_contact_relation, 'NA') || ', ' ||
    coalesce(cp.alternative_contact_phone, 'NA') || ', ' ||
    coalesce(em.phone, 'NA') AS comments2_res
  FROM get_defaulted_loanapps_base($1, $2, now()::date) dl
    LEFT JOIN loan_application la ON dl.loanappid=la.id
    LEFT JOIN client_profile cp ON cp.id=la.client_id
    LEFT JOIN employer em ON em.id=employer_id
    LEFT JOIN
    collection_scheme cs ON la.collection_scheme_id=cs.id
    LEFT JOIN
    collection_company cc ON cs.collection_company_id=cc.id

  WHERE cc.id=$3 AND dl.collectiondate::date >= $1 AND dl.collectiondate::date <= $2

  ORDER BY dl.collectiondate ASC, la.ref_nr ASC;

END;
$$
LANGUAGE plpgsql VOLATILE;
