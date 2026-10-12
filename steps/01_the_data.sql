-- TITLE: Step 1 - the data: four ordinary tables, and questions about connections
SELECT 'ACCOUNTS' AS table_name, COUNT(*) AS row_count FROM accounts  UNION ALL
SELECT 'TRANSFERS',              COUNT(*)              FROM transfers UNION ALL
SELECT 'DEVICES',                COUNT(*)              FROM devices   UNION ALL
SELECT 'LOGINS',                 COUNT(*)              FROM logins;

-- A transfer is a row with two account ids in it. SQL is good at "what did account 7
-- send?" - that is one filter.
SELECT transfer_id, src, dst, amount, sent_at
  FROM transfers
 WHERE src = 7
 ORDER BY sent_at;

-- The questions a fraud team asks are about chains, not rows:
--   * where can money from account 7 end up within three transfers?
--   * does money ever come back to where it started?
--   * which accounts collect many small payments and pass them on?
--   * which accounts share a device with each other?
-- Each one is a join of TRANSFERS with itself an unknown number of times.
