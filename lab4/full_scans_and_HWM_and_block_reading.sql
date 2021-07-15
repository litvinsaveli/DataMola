-- step 1
drop table t2;

create table t2 as select trunc (rownum / 100) id, rpad (rownum, 100) t_pad
from dual
connect by rownum < 100000;

-- step 2

create index t2_idx1 ON t2 (id); 

-- step 3

-- block count:
select blocks from user_segments where segment_name = 'T2';

-- used block count
select count (distinct (dbms_rowid.rowid_block_number(rowid))) block_ct 
from t2;

-- explain plan
SET autotrace on;
SELECT COUNT( * )
FROM t2;

-- step 4

delete from t2;
commit;
-- step 5

-- block count:
select blocks from user_segments where segment_name = 'T2';

-- used block count
select count (distinct (dbms_rowid.rowid_block_number(rowid))) block_ct 
from t2;

-- explain plan
SET autotrace on;
SELECT COUNT( * )
FROM t2;


-- step 6

insert into t2 values (1, '1');
commit;

-- step 7

-- block count:
select blocks from user_segments where segment_name = 'T2';

-- used block count
select count (distinct (dbms_rowid.rowid_block_number(rowid))) block_ct 
from t2;

-- explain plan
SET autotrace on;
SELECT COUNT( * )
FROM t2;
commit;

-- step 8
truncate table t2;

-- block count
select blocks from user_segments where segment_name = 'T2';

-- used block count
select count (distinct (dbms_rowid.rowid_block_number(rowid))) block_ct 
from t2;

-- explain plan
SET autotrace on;
SELECT COUNT( * )
FROM t2;
commit;