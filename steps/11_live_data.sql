-- TITLE: Step 11 - the graph is the tables: new rows are new edges, immediately
-- Account 30 received the mule's money. Where can large money from it go?
SELECT COUNT(*) AS paths_from_30
  FROM GRAPH_TABLE (bank_graph
         MATCH (a IS account) -[t IS transfer WHERE t.amount > 10000]->{1,3} (b IS account)
         WHERE a.account_id = 30
         COLUMNS (b.account_id));

-- A new payment is an ordinary INSERT into TRANSFERS. There is no graph to load,
-- rebuild or refresh.
INSERT INTO transfers VALUES (931, 30, 7, 70000, TIMESTAMP '2026-09-14 09:00:00', 'loan');
COMMIT;

-- The same query now finds it - and follows it into the ring from step 6.
SELECT hops, ends_at, transfers
  FROM GRAPH_TABLE (bank_graph
         MATCH (a IS account) -[t IS transfer WHERE t.amount > 10000]->{1,3} (b IS account)
         WHERE a.account_id = 30
         COLUMNS (COUNT(t.transfer_id) AS hops, b.account_id AS ends_at,
                  LISTAGG(t.transfer_id, ' > ') AS transfers))
 ORDER BY hops;
