-- new Schema and default tablespace
CREATE TABLESPACE ts_geo_references_01
DATAFILE '/oracle/u02/oradata/DMORCL21DB/slitvin_db/ts_geo_references_01.dat'
SIZE 20M
 AUTOEXTEND ON
    NEXT 20M
    MAXSIZE 60M
 SEGMENT SPACE MANAGEMENT AUTO;

create user SB_MBackUp identified by uniquepwd
default tablespace ts_geo_references_01;

alter user SB_MBACKUP quota unlimited on ts_geo_references_01;
grant all privileges to SB_MBACKUP;


-- denormalized table task 1.
drop table geo_ref;
create table geo_ref as
    select lpad(' ', level * 2 - 1, ' ') || child_geo_id cid,
           parent_geo_id,
           link_type_id,
           decode (level, 1, 'ROOT', 2, 'BRANCH', 3, 'LEAF') id_type,
           decode ((
               select count(*) from U_DW_REFERENCES.T_GEO_OBJECT_LINKS obj
               where obj.parent_geo_id = obj2.child_geo_id),
               0, NULL,
               (SELECT count(*) from U_DW_REFERENCES.T_GEO_OBJECT_LINKS obj
                   where obj.PARENT_GEO_ID = obj2.child_geo_id)
               ) cnt_level,
           sys_connect_by_path(parent_geo_id, ':') path
            from U_DW_REFERENCES.T_GEO_OBJECT_LINKS obj2
        connect by prior CHILD_GEO_ID = PARENT_GEO_ID
    order siblings by CHILD_GEO_ID
;

select * from geo_ref;



-- denormalized table products task 2. Main query

select * from (select lpad(' ', level*2,' ') || t.MODEL parent, t.SPECS child, t.MODEL_RELATION,
       CONNECT_BY_ROOT t.MODEL as root,
       decode(level, 1, 'Model', 2, 'Specs', 3, 'Color') as lvl, sys_connect_by_path(t.MODEL,':') path
from products_test t
start with t.MODEL_RELATION >= 0 and t.MODEL_RELATION < 10
connect by prior t.SPECS = t.MODEL
order siblings by t.MODEL_RELATION)
where root = 'Tesla';

-- I'm not sure whether i used this code to create tables or another one, but i hope this one will work.
--                                               |
--                                               |
--                                               ↓
-- #######################################################################################################

    drop table products_test;
    create table PRODUCTS_TEST
(
    MODEL          VARCHAR2(20),
    SPECS          VARCHAR2(20),
    MODEL_RELATION NUMBER
);

insert into products_test (model, specs)
select distinct decode(grouping(SPECS), 1, 'all specs', specs) model,
                     decode(grouping(color), 1, 'all colors', color) specs
    from SA_REPORTS.PRODUCTS
    group by cube(specs, color)
    having grouping_id(specs, color ) <1
    order by model;

commit;

merge into products_test using
(with t as (
    select model,
           specs
       from products_test),
x as (select t.model model, t.specs specs, dense_rank() over (order by length(model)) as model_relations from t)
    select * from x) y

    ON (products_test.MODEL = y.model and products_test.SPECS = y.specs)

when matched then
    update set products_test.MODEL_RELATION = y.model_relations;

commit;

