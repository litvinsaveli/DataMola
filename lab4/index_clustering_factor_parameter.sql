-- step 1
CREATE TABLE t2 AS
 SELECT TRUNC( rownum / 100 ) id, rpad( rownum,100 ) t_pad
   FROM dual
  CONNECT BY rownum < 100000;

CREATE INDEX t2_idx1 ON t2
  ( id );

-- step 2
CREATE TABLE t1 AS
 SELECT MOD( rownum, 100 ) id, rpad( rownum,100 ) t_pad
   FROM dual
  CONNECT BY rownum < 100000;

-- step 3
CREATE INDEX t1_idx1 ON t1
  ( id );

-- step 4
EXEC dbms_stats.gather_table_stats( USER,'t1',method_opt=>'FOR ALL COLUMNS SIZE 1',CASCADE=>TRUE );
EXEC dbms_stats.gather_table_stats( USER,'t2',method_opt=>'FOR ALL COLUMNS SIZE 1',CASCADE=>TRUE );

-- step 5
SELECT t.table_name||'.'||i.index_name idx_name,
        i.clustering_factor,
        t.blocks,
        t.num_rows
   FROM user_indexes i, user_tables t
  WHERE i.table_name = t.table_name
    AND t.table_name  IN( 'T1','T2' );


