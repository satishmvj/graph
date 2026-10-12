-- TITLE: Step 8 - the mule: many small payments in, one large payment out
-- GRAPH_TABLE returns rows, so everything SQL can do with rows is available. First,
-- accounts receiving from five or more different payers within a single day.
SELECT receiver, day, COUNT(DISTINCT payer) AS payers, SUM(amount) AS received
  FROM GRAPH_TABLE (bank_graph
         MATCH (p IS account) -[t IS transfer]-> (m IS account)
         COLUMNS (m.account_id AS receiver, p.account_id AS payer,
                  TRUNC(t.sent_at) AS day, t.amount))
 GROUP BY receiver, day
HAVING COUNT(DISTINCT payer) >= 5
 ORDER BY payers DESC;

-- Every one of those payments was just under 10,000 - a common reporting threshold.
-- The two-hop shape finds where the money went next, and only if it left afterwards.
SELECT mule, COUNT(*) AS inbound, SUM(in_amount) AS collected,
       MAX(out_to) AS forwarded_to, MAX(out_amount) AS forwarded,
       MAX(out_at) AS forwarded_at
  FROM GRAPH_TABLE (bank_graph
         MATCH (p IS account) -[i IS transfer]-> (m IS account)
                              -[o IS transfer]-> (d IS account)
         WHERE i.amount BETWEEN 9000 AND 9999
           AND o.sent_at > i.sent_at
           AND o.amount > 50000
         COLUMNS (m.account_id AS mule, i.amount AS in_amount, d.account_id AS out_to,
                  o.amount AS out_amount, o.sent_at AS out_at))
 GROUP BY mule;
