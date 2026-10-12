-- TITLE: Step 2 - the relational way: recursive WITH for "within three transfers"
-- Recursive subquery factoring can walk a chain. It works, and it needs a hop counter,
-- a join back to itself, and care with cycles.
WITH reach (account_id, hops, path) AS (
  SELECT dst, 1, '7>' || dst
    FROM transfers
   WHERE src = 7
  UNION ALL
  SELECT t.dst, r.hops + 1, r.path || '>' || t.dst
    FROM reach r
    JOIN transfers t ON t.src = r.account_id
   WHERE r.hops < 3
)
SELECT COUNT(*)                   AS paths,
       COUNT(DISTINCT account_id) AS accounts_reached
  FROM reach;

-- The ring question - "a chain of large transfers that returns to its start" - is a
-- second recursive query, with a CYCLE clause and a filter repeated in both branches.
WITH chain (start_id, account_id, hops, path) AS (
  SELECT src, dst, 1, src || '>' || dst
    FROM transfers WHERE amount > 10000
  UNION ALL
  SELECT c.start_id, t.dst, c.hops + 1, c.path || '>' || t.dst
    FROM chain c
    JOIN transfers t ON t.src = c.account_id AND t.amount > 10000
   WHERE c.hops < 3
) CYCLE account_id SET is_cycle TO 'Y' DEFAULT 'N'
SELECT start_id, path, hops, is_cycle
  FROM chain
 WHERE account_id = start_id
 ORDER BY start_id;
