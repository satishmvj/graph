-- TITLE: Step 4 - the first GRAPH_TABLE query: one hop, both directions
-- GRAPH_TABLE is a FROM-clause operator. MATCH describes a shape with ( ) for vertices
-- and -[ ]-> for edges; COLUMNS says what each match returns as a row.
SELECT *
  FROM GRAPH_TABLE (bank_graph
         MATCH (a IS account) -[t IS transfer]-> (b IS account)
         WHERE a.account_id = 7
         COLUMNS (a.holder AS sender, t.amount, t.sent_at, b.holder AS receiver))
 ORDER BY sent_at;

-- Reverse the arrow to ask the opposite question: who paid account 25?
SELECT *
  FROM GRAPH_TABLE (bank_graph
         MATCH (a IS account) <-[t IS transfer]- (b IS account)
         WHERE a.account_id = 25
         COLUMNS (b.account_id AS payer, b.holder, t.amount, t.memo))
 ORDER BY payer;

-- With no arrow head, the edge matches in either direction: the 8 payments in plus the
-- 1 payment out, and every account on the other end of one.
SELECT COUNT(*) AS transfers_either_way,
       LISTAGG(other, ',') WITHIN GROUP (ORDER BY other) AS other_accounts
  FROM GRAPH_TABLE (bank_graph
         MATCH (a IS account) -[t IS transfer]- (b IS account)
         WHERE a.account_id = 25
         COLUMNS (b.account_id AS other));
