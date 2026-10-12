-- The graph first, then the tables it is defined over.
BEGIN
  FOR g IN (SELECT graph_name FROM user_property_graphs) LOOP
    EXECUTE IMMEDIATE 'DROP PROPERTY GRAPH "' || g.graph_name || '"';
  END LOOP;
  FOR t IN (SELECT table_name FROM user_tables) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE "' || t.table_name || '" CASCADE CONSTRAINTS PURGE';
  END LOOP;
END;
/

SELECT (SELECT COUNT(*) FROM user_tables)          AS tables_left,
       (SELECT COUNT(*) FROM user_property_graphs) AS graphs_left
  FROM dual;
