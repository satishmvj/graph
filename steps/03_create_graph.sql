-- TITLE: Step 3 - CREATE PROPERTY GRAPH: naming the vertices and edges in the tables
-- A property graph says which tables are things (vertices) and which are connections
-- (edges), and which columns join them. It copies no data.
CREATE PROPERTY GRAPH bank_graph
  VERTEX TABLES (
    accounts KEY (account_id)
      LABEL account PROPERTIES (account_id, holder, city, kind),
    devices  KEY (device_id)
      LABEL device  PROPERTIES (device_id, model)
  )
  EDGE TABLES (
    transfers KEY (transfer_id)
      SOURCE      KEY (src)        REFERENCES accounts (account_id)
      DESTINATION KEY (dst)        REFERENCES accounts (account_id)
      LABEL transfer PROPERTIES (transfer_id, amount, sent_at, memo),
    logins KEY (login_id)
      SOURCE      KEY (account_id) REFERENCES accounts (account_id)
      DESTINATION KEY (device_id)  REFERENCES devices (device_id)
      LABEL uses PROPERTIES (last_seen)
  );

-- The graph is a dictionary object, like a view.
SELECT graph_name, graph_mode, allows_mixed_types, inmemory FROM user_property_graphs;

SELECT element_name, element_kind, object_name FROM user_pg_elements ORDER BY element_kind DESC, element_name;

SELECT edge_tab_name, edge_end, edge_col_name, vertex_tab_name, vertex_col_name
  FROM user_pg_edge_relationships
 ORDER BY edge_tab_name, edge_end DESC;

SELECT label_name, property_name, data_type
  FROM user_pg_label_properties
 ORDER BY label_name, property_order;

-- No segment was created: all storage still belongs to the four tables and their indexes.
SELECT segment_type, COUNT(*) AS segments FROM user_segments GROUP BY segment_type ORDER BY 1;
