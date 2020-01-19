DO
$do$
DECLARE
  arow record;
BEGIN
  FOR arow IN
  select * from country_configuration
  LOOP
    INSERT INTO property (type, country_config_id, boolean_value, long_value)
      VALUES(CASE WHEN arow.boolean_value is not null THEN 'boolean' ELSE 'long' END, arow.id, arow.boolean_value, arow.long_value);
  END LOOP;
END
$do$
