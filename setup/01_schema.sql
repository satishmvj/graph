-- TITLE: Setup - a small bank: accounts, transfers, devices and logins
-- Ordinary relational tables. The property graph in step 3 is defined over them and
-- stores nothing of its own.
ALTER SESSION DISABLE PARALLEL DML;

CREATE TABLE accounts (
  account_id  NUMBER        PRIMARY KEY,
  holder      VARCHAR2(40)  NOT NULL,
  city        VARCHAR2(20)  NOT NULL,
  kind        VARCHAR2(10)  NOT NULL
);

CREATE TABLE transfers (
  transfer_id NUMBER        PRIMARY KEY,
  src         NUMBER        NOT NULL REFERENCES accounts,
  dst         NUMBER        NOT NULL REFERENCES accounts,
  amount      NUMBER(12,2)  NOT NULL,
  sent_at     DATE          NOT NULL,
  memo        VARCHAR2(30)
);

CREATE TABLE devices (
  device_id   NUMBER        PRIMARY KEY,
  model       VARCHAR2(30)  NOT NULL
);

CREATE TABLE logins (
  login_id    NUMBER        PRIMARY KEY,
  account_id  NUMBER        NOT NULL REFERENCES accounts,
  device_id   NUMBER        NOT NULL REFERENCES devices,
  last_seen   DATE          NOT NULL
);

-- 30 accounts. 1-24 are everyday customers; 25-30 matter later.
INSERT INTO accounts
SELECT level,
       INITCAP(CASE MOD(level, 6) WHEN 0 THEN 'anil' WHEN 1 THEN 'bina' WHEN 2 THEN 'chetan'
                                  WHEN 3 THEN 'divya' WHEN 4 THEN 'eshan' ELSE 'farah' END)
         || ' ' || TO_CHAR(level, 'FM00'),
       CASE MOD(level, 3) WHEN 0 THEN 'Mumbai' WHEN 1 THEN 'Pune' ELSE 'Delhi' END,
       CASE WHEN level IN (25, 30) THEN 'BUSINESS' ELSE 'PERSONAL' END
  FROM dual CONNECT BY level <= 30;

-- Everyday transfers among accounts 1-24, all under 1,000.
INSERT INTO transfers (transfer_id, src, dst, amount, sent_at)
SELECT n, MOD(n * 7, 24) + 1, MOD(n * 11 + 3, 24) + 1, MOD(n * 37, 900) + 100,
       DATE '2026-09-01' + n / 12
  FROM (SELECT level AS n FROM dual CONNECT BY level <= 130)
 WHERE MOD(n * 7, 24) <> MOD(n * 11 + 3, 24);

-- Pattern 1 - a ring: large amounts go 7 -> 13 -> 21 -> 7, one hour apart.
INSERT INTO transfers VALUES (901,  7, 13, 50000, TIMESTAMP '2026-09-10 10:00:00', 'invoice 1');
INSERT INTO transfers VALUES (902, 13, 21, 49000, TIMESTAMP '2026-09-10 11:00:00', 'invoice 2');
INSERT INTO transfers VALUES (903, 21,  7, 48000, TIMESTAMP '2026-09-10 12:00:00', 'invoice 3');

-- Pattern 2 - a mule: eight accounts each send 9,500 to account 25 on one day,
-- and the next day account 25 forwards 75,000 to account 30.
INSERT INTO transfers
SELECT 910 + level, level, 25, 9500,
       TIMESTAMP '2026-09-12 09:00:00' + NUMTODSINTERVAL(level * 20, 'MINUTE'), 'gift'
  FROM dual CONNECT BY level <= 8;
INSERT INTO transfers VALUES (930, 25, 30, 75000, TIMESTAMP '2026-09-13 10:00:00', 'supplier');

-- Every account logs in from its own phone...
INSERT INTO devices SELECT 100 + level, 'Phone ' || level FROM dual CONNECT BY level <= 30;
INSERT INTO logins
SELECT level, level, 100 + level, DATE '2026-09-14' FROM dual CONNECT BY level <= 30;

-- Pattern 3 - ...but 7, 13 and 21 also use one shared tablet, and 25 and 30 one laptop.
INSERT INTO devices VALUES (900, 'Shared tablet');
INSERT INTO devices VALUES (901, 'Shared laptop');
INSERT INTO logins VALUES (41,  7, 900, DATE '2026-09-10');
INSERT INTO logins VALUES (42, 13, 900, DATE '2026-09-10');
INSERT INTO logins VALUES (43, 21, 900, DATE '2026-09-10');
INSERT INTO logins VALUES (44, 25, 901, DATE '2026-09-13');
INSERT INTO logins VALUES (45, 30, 901, DATE '2026-09-13');

COMMIT;

BEGIN
  DBMS_STATS.GATHER_SCHEMA_STATS(USER);
END;
/

SELECT (SELECT COUNT(*) FROM accounts)  AS accounts,
       (SELECT COUNT(*) FROM transfers) AS transfers,
       (SELECT COUNT(*) FROM devices)   AS devices,
       (SELECT COUNT(*) FROM logins)    AS logins
  FROM dual;
