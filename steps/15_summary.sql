-- TITLE: Step 15 - what was built: one graph definition over four tables
SELECT l.label_name, e.element_kind, e.object_name,
       (SELECT COUNT(*) FROM user_pg_label_properties p
         WHERE p.graph_name = l.graph_name AND p.label_name = l.label_name) AS properties
  FROM user_pg_element_labels l
  JOIN user_pg_elements e ON e.graph_name = l.graph_name AND e.element_name = l.element_name
 ORDER BY e.element_kind DESC, l.label_name;

-- Vertices and edges, counted through the graph and through the tables.
SELECT 'account vertices' AS item,
       (SELECT COUNT(*) FROM GRAPH_TABLE (bank_graph MATCH (a IS account)
          COLUMNS (a.account_id))) AS through_graph,
       (SELECT COUNT(*) FROM accounts) AS in_table
  FROM dual
UNION ALL
SELECT 'device vertices',
       (SELECT COUNT(*) FROM GRAPH_TABLE (bank_graph MATCH (d IS device)
          COLUMNS (d.device_id))),
       (SELECT COUNT(*) FROM devices)
  FROM dual
UNION ALL
SELECT 'transfer edges',
       (SELECT COUNT(*) FROM GRAPH_TABLE (bank_graph MATCH () -[t IS transfer]-> ()
          COLUMNS (t.transfer_id))),
       (SELECT COUNT(*) FROM transfers)
  FROM dual
UNION ALL
SELECT 'uses edges',
       (SELECT COUNT(*) FROM GRAPH_TABLE (bank_graph MATCH () -[u IS uses]-> ()
          COLUMNS (u.last_seen))),
       (SELECT COUNT(*) FROM logins)
  FROM dual;

SELECT object_type, COUNT(*) AS objects
  FROM user_objects
 WHERE object_type IN ('TABLE', 'INDEX', 'PROPERTY GRAPH')
 GROUP BY object_type
 ORDER BY object_type;
