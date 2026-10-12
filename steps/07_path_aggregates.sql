-- TITLE: Step 7 - describing a whole path: filters and aggregates over quantified edges
-- Inside a quantified pattern, t is not one transfer but the list of them. A WHERE
-- inside the brackets applies to every edge; aggregates in COLUMNS summarise the list.
SELECT *
  FROM GRAPH_TABLE (bank_graph
         MATCH (a IS account) -[t IS transfer WHERE t.amount > 10000]->{1,3} (b IS account)
         WHERE a.account_id = 7
         COLUMNS (COUNT(t.transfer_id)                      AS hops,
                  LISTAGG(t.transfer_id, ' > ')             AS transfers,
                  SUM(t.amount)                             AS total_moved,
                  b.account_id                              AS ends_at))
 ORDER BY hops;

-- A path can revisit an account. With the ring in the data, a longer bound walks round
-- it again: {1,6} gives six paths from account 7, and hop 3 and hop 6 are back at 7.
SELECT hops, ends_at, transfers
  FROM GRAPH_TABLE (bank_graph
         MATCH (a IS account) -[t IS transfer WHERE t.amount > 10000]->{1,6} (b IS account)
         WHERE a.account_id = 7
         COLUMNS (COUNT(t.transfer_id) AS hops, b.account_id AS ends_at,
                  LISTAGG(t.transfer_id, ' > ') AS transfers))
 ORDER BY hops;
