ALTER TABLE "country_configuration" ALTER COLUMN "boolean_value" DROP DEFAULT;

ALTER TABLE "country_configuration" ADD COLUMN "long_value" BIGINT;

INSERT INTO "country_configuration" ("property", "property_group", "boolean_value") VALUES ('auto_refund_enabled', 'auto_refund', TRUE);

INSERT INTO "country_configuration" ("property", "property_group", "long_value") VALUES ('auto_refund_during_days', 'auto_refund', 17);
