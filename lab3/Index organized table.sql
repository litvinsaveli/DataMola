-- step 1

CREATE TABLE emp AS
SELECT object_id empno,
object_name ename,
created hiredate,
owner job
FROM all_objects;

--step 2
alter table emp add constraint emp_pk primary key(empno);

-- step 3
exec dbms_stats.gather_table_stats( user, 'EMP', cascade=>true ); 


-- step 4 
CREATE TABLE heap_addresses 
  ( 
    empno REFERENCES emp(empno) ON DELETE CASCADE 
  , addr_type VARCHAR2(10) 
  , street    VARCHAR2(20) 
  , city      VARCHAR2(20) 
  , state     VARCHAR2(2) 
  , zip       NUMBER 
  , PRIMARY KEY (empno,addr_type) 
  );
  
-- step 5
CREATE TABLE iot_addresses 
  ( 
    empno REFERENCES emp(empno) ON DELETE CASCADE 
  , addr_type VARCHAR2(10) 
  , street    VARCHAR2(20) 
  , city      VARCHAR2(20) 
  , state     VARCHAR2(2) 
  , zip       NUMBER 
  , PRIMARY KEY (empno,addr_type) 
  ) 

  ORGANIZATION INDEX; 

-- step 6
INSERT INTO heap_addresses 
SELECT empno, 'WORK' , '123 main street' , 'Washington' , 'DC' , 20123 FROM emp; 

INSERT INTO iot_addresses 
SELECT empno , 'WORK' , '123 main street' , 'Washington' , 'DC' , 20123 FROM emp; 

INSERT INTO heap_addresses 
SELECT empno, 'HOME' , '123 main street' , 'Washington' , 'DC' , 20123 FROM emp; 

INSERT INTO iot_addresses 
SELECT empno, 'HOME' , '123 main street' , 'Washington' , 'DC' , 20123 FROM emp; 

INSERT INTO heap_addresses 
SELECT empno, 'PREV' , '123 main street' , 'Washington' , 'DC' , 20123 FROM emp; 

INSERT INTO iot_addresses 
SELECT empno, 'PREV' , '123 main street' , 'Washington' , 'DC' , 20123 FROM emp; 

INSERT INTO heap_addresses 
SELECT empno, 'SCHOOL' , '123 main street' , 'Washington' , 'DC' , 20123 FROM emp; 

INSERT INTO iot_addresses 
SELECT empno, 'SCHOOL' , '123 main street' , 'Washington' , 'DC' , 20123 FROM emp; 

Commit; 

-- step 7

exec dbms_stats.gather_table_stats( 'Saveli', 'HEAP_ADDRESSES' ); 

exec dbms_stats.gather_table_stats( 'Saveli', 'IOT_ADDRESSES' ); 

-- step 8

SELECT *
   FROM emp ,
        heap_addresses
  WHERE emp.empno = heap_addresses.empno
  AND emp.empno   = 42;
  
SELECT * 
   FROM emp , 
        iot_addresses 
  WHERE emp.empno = iot_addresses.empno 
  AND emp.empno   = 42;  

-- step 9
drop table emp;
drop table heap_addresses;
drop table iot_addresses;

select * from user_constraints where table_name = 'tablnam';