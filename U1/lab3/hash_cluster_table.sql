-- step 1
drop cluster emp_dept_cluster;
drop table emp_hash;
drop table dept_hash;



CREATE cluster emp_dept_cluster(deptno NUMBER(2))
size 8192
hashkeys 1000;

-- step 2

CREATE TABLE dept_hash cluster emp_dept_cluster (deptno) as select deptno, dname, loc from scott.dept;
alter table dept_hash add constraint pk_deptno primary key (deptno);

exec dbms_stats.gather_table_stats(user, 'dept_hash', cascade=>True);

--step 3
create table emp_hash (
    empno NUMBER PRIMARY KEY
  , ename VARCHAR2( 10 )
  , job   VARCHAR2( 9 )
  , mgr   NUMBER
  , hiredate DATE
  , sal    NUMBER
  , comm   NUMBER
  , deptno NUMBER( 2 ) REFERENCES dept_hash( deptno )
)
cluster emp_dept_cluster (deptno);

exec dbms_stats.gather_table_stats(user, 'emp_hash', cascade=>True);

INSERT INTO emp_hash ( empno, ename, job, mgr, hiredate, sal, comm, deptno )
 SELECT rownum, ename, job, mgr, hiredate, sal, comm, deptno
   FROM scott.emp
      
commit;

-- step 4
SELECT *
   FROM
  (
     SELECT dept_blk, emp_blk, CASE WHEN dept_blk <> emp_blk THEN '*' END flag, deptno
       FROM
      (
         SELECT dbms_rowid.rowid_block_number( dept_hash.rowid ) dept_blk, dbms_rowid.rowid_block_number( emp_hash.rowid ) emp_blk, dept_hash.deptno
           FROM emp_hash, dept_hash
          WHERE emp_hash.deptno = dept_hash.deptno
      )
  )
ORDER BY deptno;


