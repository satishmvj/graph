-- TITLE: Step 14 - when the tables change: a dropped column breaks the graph
-- MEMO is a property of the TRANSFER label. Dropping the column succeeds...
ALTER TABLE transfers DROP COLUMN memo;

-- ...the graph's own dictionary view has no status column, so it looks the same...
SELECT graph_name, graph_mode FROM user_property_graphs;

-- ...but USER_OBJECTS does record the damage.
SELECT object_name, object_type, status FROM user_objects WHERE object_name = 'BANK_GRAPH';

-- Every query on the graph now fails, even one that never mentions MEMO.
SELECT COUNT(*)
  FROM GRAPH_TABLE (bank_graph
         MATCH (a IS account) -[t IS transfer]-> (b IS account)
         COLUMNS (t.amount));

-- The fix is to redefine the graph without the column. CREATE OR REPLACE keeps the name.
CREATE OR REPLACE PROPERTY GRAPH bank_graph
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
      LABEL transfer PROPERTIES (transfer_id, amount, sent_at),
    logins KEY (login_id)
      SOURCE      KEY (account_id) REFERENCES accounts (account_id)
      DESTINATION KEY (device_id)  REFERENCES devices (device_id)
      LABEL uses PROPERTIES (last_seen)
  );

SELECT COUNT(*) AS transfer_edges
  FROM GRAPH_TABLE (bank_graph
         MATCH (a IS account) -[t IS transfer]-> (b IS account)
         COLUMNS (t.amount));
