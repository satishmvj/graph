-- TITLE: Step 5 - several hops: a fixed path, then a quantified one
-- Two hops written out: money from 7 that moved on again.
SELECT *
  FROM GRAPH_TABLE (bank_graph
         MATCH (a IS account) -[t1 IS transfer]-> (b IS account)
                              -[t2 IS transfer]-> (c IS account)
         WHERE a.account_id = 7 AND t1.amount > 10000
         COLUMNS (a.account_id AS first, b.account_id AS second, c.account_id AS third,
                  t1.amount AS amount1, t2.amount AS amount2));

-- {1,3} means "between one and three transfer edges". This is the whole of step 2's
-- first recursive query.
SELECT COUNT(*)                   AS paths,
       COUNT(DISTINCT account_id) AS accounts_reached
  FROM GRAPH_TABLE (bank_graph
         MATCH (a IS account) -[t IS transfer]->{1,3} (b IS account)
         WHERE a.account_id = 7
         COLUMNS (b.account_id));

-- Same answer as the recursive WITH, checked both ways: no account in one and not the other.
SELECT COUNT(*) AS differences FROM (
  (SELECT account_id FROM GRAPH_TABLE (bank_graph
            MATCH (a IS account) -[t IS transfer]->{1,3} (b IS account)
            WHERE a.account_id = 7 COLUMNS (b.account_id))
   MINUS
   SELECT account_id FROM (
     WITH reach (account_id, hops) AS (
       SELECT dst, 1 FROM transfers WHERE src = 7
       UNION ALL
       SELECT t.dst, r.hops + 1 FROM reach r JOIN transfers t ON t.src = r.account_id
        WHERE r.hops < 3)
     SELECT account_id FROM reach))
  UNION ALL
  (SELECT account_id FROM (
     WITH reach (account_id, hops) AS (
       SELECT dst, 1 FROM transfers WHERE src = 7
       UNION ALL
       SELECT t.dst, r.hops + 1 FROM reach r JOIN transfers t ON t.src = r.account_id
        WHERE r.hops < 3)
     SELECT account_id FROM reach)
   MINUS
   SELECT account_id FROM GRAPH_TABLE (bank_graph
            MATCH (a IS account) -[t IS transfer]->{1,3} (b IS account)
            WHERE a.account_id = 7 COLUMNS (b.account_id))));
