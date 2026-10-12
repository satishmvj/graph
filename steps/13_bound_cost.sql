-- TITLE: Step 13 - the price of a large bound: compile time, and no unbounded paths
-- An upper bound is mandatory. "One or more" and "zero or more" are both refused.
SELECT COUNT(*)
  FROM GRAPH_TABLE (bank_graph
         MATCH (a IS account) -[t IS transfer]->{1,} (b IS account)
         WHERE a.account_id = 7 COLUMNS (b.account_id));

SELECT COUNT(*)
  FROM GRAPH_TABLE (bank_graph
         MATCH (a IS account) -[t IS transfer]->* (b IS account)
         WHERE a.account_id = 7 COLUMNS (b.account_id));

-- Because each length becomes its own branch, the bound drives the compile time. The
-- same query at six bounds, only on the ring's large transfers, so the result stays
-- small. Watch the Elapsed lines, not the counts. The run id in each comment makes the
-- text new, so every one is compiled from scratch.
SELECT /* bound 5, run {RUN_ID} */ COUNT(*) AS paths
  FROM GRAPH_TABLE (bank_graph
         MATCH (a IS account) -[t IS transfer WHERE t.amount > 40000]->{1,5} (b IS account)
         WHERE a.account_id = 7 COLUMNS (b.account_id));

SELECT /* bound 10, run {RUN_ID} */ COUNT(*) AS paths
  FROM GRAPH_TABLE (bank_graph
         MATCH (a IS account) -[t IS transfer WHERE t.amount > 40000]->{1,10} (b IS account)
         WHERE a.account_id = 7 COLUMNS (b.account_id));

SELECT /* bound 15, run {RUN_ID} */ COUNT(*) AS paths
  FROM GRAPH_TABLE (bank_graph
         MATCH (a IS account) -[t IS transfer WHERE t.amount > 40000]->{1,15} (b IS account)
         WHERE a.account_id = 7 COLUMNS (b.account_id));

SELECT /* bound 20, run {RUN_ID} */ COUNT(*) AS paths
  FROM GRAPH_TABLE (bank_graph
         MATCH (a IS account) -[t IS transfer WHERE t.amount > 40000]->{1,20} (b IS account)
         WHERE a.account_id = 7 COLUMNS (b.account_id));

SELECT /* bound 25, run {RUN_ID} */ COUNT(*) AS paths
  FROM GRAPH_TABLE (bank_graph
         MATCH (a IS account) -[t IS transfer WHERE t.amount > 40000]->{1,25} (b IS account)
         WHERE a.account_id = 7 COLUMNS (b.account_id));

SELECT /* bound 30, run {RUN_ID} */ COUNT(*) AS paths
  FROM GRAPH_TABLE (bank_graph
         MATCH (a IS account) -[t IS transfer WHERE t.amount > 40000]->{1,30} (b IS account)
         WHERE a.account_id = 7 COLUMNS (b.account_id));

-- The bound-30 query again, with identical text: the cursor is reused, so this time
-- there is nothing to compile. The difference from the run above is compile time.
SELECT /* bound 30, run {RUN_ID} */ COUNT(*) AS paths
  FROM GRAPH_TABLE (bank_graph
         MATCH (a IS account) -[t IS transfer WHERE t.amount > 40000]->{1,30} (b IS account)
         WHERE a.account_id = 7 COLUMNS (b.account_id));
