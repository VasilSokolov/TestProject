ALTER TABLE loan_task ADD COLUMN on_hold BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE loan_task ADD COLUMN on_hold_time_left BIGINT;
