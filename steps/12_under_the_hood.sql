-- TITLE: Step 12 - under the hood: a graph query is a join
-- The two-hop pattern from step 5. The plan has no graph operator, and not even the
-- ACCOUNTS table: only account ids are needed, TRANSFERS holds them, and the foreign
-- keys guarantee the accounts exist - so the query is TRANSFERS joined to itself.
EXPLAIN PLAN FOR
SELECT *
  FROM GRAPH_TABLE (bank_graph
         MATCH (a IS account) -[t1 IS transfer]-> (b IS account)
                              -[t2 IS transfer]-> (c IS account)
         WHERE a.account_id = 7
         COLUMNS (c.account_id));

SELECT plan_table_output FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, NULL, 'BASIC'));

-- A quantified pattern is expanded into one branch per path length, combined with
-- UNION ALL. For {1,3} the plan combines branches and reads TRANSFERS several times.
EXPLAIN PLAN FOR
SELECT *
  FROM GRAPH_TABLE (bank_graph
         MATCH (a IS account) -[t IS transfer]->{1,3} (b IS account)
         WHERE a.account_id = 7
         COLUMNS (b.account_id));

SELECT COUNT(*) AS plan_lines,
       SUM(CASE WHEN operation = 'UNION-ALL' THEN 1 ELSE 0 END) AS union_all_ops,
       SUM(CASE WHEN object_name = 'TRANSFERS' THEN 1 ELSE 0 END) AS transfers_accesses
  FROM plan_table
 WHERE plan_id = (SELECT MAX(plan_id) FROM plan_table);
