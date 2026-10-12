-- TITLE: Step 6 - finding the ring: a pattern that ends where it starts
-- Reusing the variable a at the end of the pattern means "the same vertex". That is
-- the entire ring condition.
SELECT *
  FROM GRAPH_TABLE (bank_graph
         MATCH (a IS account) -[t1 IS transfer]-> (b IS account)
                              -[t2 IS transfer]-> (c IS account)
                              -[t3 IS transfer]-> (a)
         WHERE t1.amount > 10000 AND t2.amount > 10000 AND t3.amount > 10000
         COLUMNS (a.account_id AS a, b.account_id AS b, c.account_id AS c,
                  t1.amount AS amt1, t2.amount AS amt2, t3.amount AS amt3));

-- One ring, three rows: each account is a valid starting point. Asking for the
-- smallest id first keeps one row per ring...
SELECT *
  FROM GRAPH_TABLE (bank_graph
         MATCH (a IS account) -[t1 IS transfer]-> (b IS account)
                              -[t2 IS transfer]-> (c IS account)
                              -[t3 IS transfer]-> (a)
         WHERE t1.amount > 10000 AND t2.amount > 10000 AND t3.amount > 10000
           AND a.account_id < b.account_id AND a.account_id < c.account_id
         COLUMNS (a.account_id AS a, b.account_id AS b, c.account_id AS c));

-- ...and a condition across edges makes it a money flow rather than three unrelated
-- payments: each transfer after the one before, each one a little smaller.
SELECT *
  FROM GRAPH_TABLE (bank_graph
         MATCH (a IS account) -[t1 IS transfer]-> (b IS account)
                              -[t2 IS transfer]-> (c IS account)
                              -[t3 IS transfer]-> (a)
         WHERE t1.sent_at < t2.sent_at AND t2.sent_at < t3.sent_at
           AND t2.amount BETWEEN t1.amount * 0.9 AND t1.amount
           AND t3.amount BETWEEN t2.amount * 0.9 AND t2.amount
         COLUMNS (a.holder AS started_with, t1.sent_at AS first_leg, t3.sent_at AS last_leg,
                  t1.amount - t3.amount AS skimmed));

-- Without an amount filter, the everyday transfers form rings too - which is why the
-- filter is the real work of a ring search.
SELECT COUNT(*) AS three_hop_rings_any_amount
  FROM GRAPH_TABLE (bank_graph
         MATCH (a IS account) -[t1 IS transfer]-> (b IS account)
                              -[t2 IS transfer]-> (c IS account)
                              -[t3 IS transfer]-> (a)
         COLUMNS (a.account_id));
