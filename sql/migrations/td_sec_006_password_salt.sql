-- TD-SEC-006: per-user salted password storage (lazy migration on login)
-- Run once on existing databases. Safe to run if column already exists (will error; skip in that case).

ALTER TABLE accounts
ADD COLUMN password_salt VARCHAR(32) NULL;
