-- TITLE: Step 9 - two kinds of vertex: accounts that share a device
-- Accounts and devices are different vertex tables, joined by the USES edge. Two
-- accounts pointing at the same device is a V shape.
SELECT *
  FROM GRAPH_TABLE (bank_graph
         MATCH (a IS account) -[IS uses]-> (d IS device) <-[IS uses]- (b IS account)
         WHERE a.account_id < b.account_id
         COLUMNS (d.model AS device, a.account_id AS account_a, b.account_id AS account_b))
 ORDER BY device, account_a, account_b;

-- Combining shapes: a shared device AND a large transfer between the same two accounts.
-- The ring from step 6 and the mule from step 8 both show up; nothing else does.
SELECT *
  FROM GRAPH_TABLE (bank_graph
         MATCH (a IS account) -[IS uses]-> (d IS device) <-[IS uses]- (b IS account),
               (a) -[t IS transfer]-> (b)
         WHERE t.amount > 10000
         COLUMNS (d.model AS device, a.account_id AS sender, b.account_id AS receiver,
                  t.amount))
 ORDER BY sender;
