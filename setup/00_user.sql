-- Run as ADMIN, once.
DROP USER graphdemo CASCADE;

CREATE USER graphdemo IDENTIFIED BY "Gr7#Property2026Zz" QUOTA UNLIMITED ON DATA;
GRANT CONNECT, RESOURCE TO graphdemo;
-- A property graph is its own object type with its own privilege.
GRANT CREATE PROPERTY GRAPH TO graphdemo;
GRANT SELECT ANY DICTIONARY TO graphdemo;
