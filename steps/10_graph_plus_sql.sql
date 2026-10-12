-- TITLE: Step 10 - graph results inside ordinary SQL: one risk list from three patterns
-- Each GRAPH_TABLE is just a row source, so the three findings combine with UNION,
-- GROUP BY and a join back to ACCOUNTS like any other query.
WITH ring AS (
  SELECT account_id, 'ring' AS signal
    FROM GRAPH_TABLE (bank_graph
           MATCH (a IS account) -[t1 IS transfer]-> (b IS account)
                                -[t2 IS transfer]-> (c IS account)
                                -[t3 IS transfer]-> (a)
           WHERE t1.amount > 10000 AND t2.amount > 10000 AND t3.amount > 10000
           COLUMNS (a.account_id))
), mule AS (
  SELECT account_id, 'fan-in' AS signal
    FROM GRAPH_TABLE (bank_graph
           MATCH (p IS account) -[i IS transfer]-> (m IS account)
           WHERE i.amount BETWEEN 9000 AND 9999
           COLUMNS (m.account_id))
   GROUP BY account_id
  HAVING COUNT(*) >= 5
), shared AS (
  SELECT DISTINCT account_id, 'shared device' AS signal
    FROM GRAPH_TABLE (bank_graph
           MATCH (a IS account) -[IS uses]-> (d IS device) <-[IS uses]- (b IS account)
           WHERE a.account_id <> b.account_id
           COLUMNS (a.account_id))
)
SELECT s.account_id, a.holder, a.city, a.kind,
       COUNT(*)                                  AS signals,
       LISTAGG(s.signal, ', ') WITHIN GROUP (ORDER BY s.signal) AS why
  FROM (SELECT * FROM ring UNION SELECT * FROM mule UNION SELECT * FROM shared) s
  JOIN accounts a ON a.account_id = s.account_id
 GROUP BY s.account_id, a.holder, a.city, a.kind
 ORDER BY signals DESC, s.account_id;
