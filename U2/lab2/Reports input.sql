
-- prerequisites

CREATE TABLESPACE ts_reports_layouts_01
DATAFILE '/oracle/u02/oradata/DMORCL21DB/slitvin_db/sa_reports_layouts_01.dat'
SIZE 50M
 AUTOEXTEND ON NEXT 50M
 SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE ts_products_layouts_01
DATAFILE '/oracle/u02/oradata/DMORCL21DB/slitvin_db/sa_reports_products_01.dat'
SIZE 50M
 AUTOEXTEND ON NEXT 50M
 SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE ts_customers_layouts_01
DATAFILE '/oracle/u02/oradata/DMORCL21DB/slitvin_db/sa_customers_layouts_01.dat'
SIZE 50M
 AUTOEXTEND ON NEXT 50M
 SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE ts_dealers_layouts_01
DATAFILE '/oracle/u02/oradata/DMORCL21DB/slitvin_db/sa_dealers_layouts_01.dat'
SIZE 50M
 AUTOEXTEND ON NEXT 50M
 SEGMENT SPACE MANAGEMENT AUTO;

create user sa_reports identified by uniquepwd
default tablespace ts_reports_layouts_01;

alter user sa_reports quota unlimited on ts_reports_layouts_01;
alter user sa_reports quota unlimited on ts_customers_layouts_01;
alter user sa_reports quota unlimited on ts_products_layouts_01;
alter user sa_reports quota unlimited on ts_dealers_layouts_01;


-- creating tables and generating data.
drop table customers;

create table customers (
    customer_id number(22) not null,
    customer_name varchar(30) not null,
    country varchar (50) not null,
    city varchar (50) not null,
    address varchar(100) not null,
    product_id number(22) not null,
    count number(10) not null,
    insert_dt date not null,

        constraint pk_customer_id primary key (customer_id)

) organization index
tablespace ts_customers_layouts_01;

drop sequence sq_customers;
create sequence sq_customers;

drop trigger tr_customers_on_insert;

CREATE OR REPLACE TRIGGER tr_customers_on_insert
  BEFORE INSERT ON sa_reports.customers
  FOR EACH ROW
BEGIN
  SELECT sq_customers.nextval
  INTO :new.customer_id
  FROM dual;
END;


drop table products;

create table products (
    product_id number(22) not null,
    model varchar (10) not null,
    specs varchar (20) not null,
    color varchar (20) not null,
    price number (10) not null,
    product_desc varchar (200) not null,
    insert_dt date not null,

    constraint pk_product_id primary key (product_id)
) organization index
tablespace ts_products_layouts_01;

drop sequence sq_products;
create sequence sq_products;

drop trigger tr_products_on_insert;

CREATE OR REPLACE TRIGGER tr_products_on_insert
  BEFORE INSERT ON sa_reports.products
  FOR EACH ROW
BEGIN
  SELECT sq_products.nextval
  INTO :new.product_id
  FROM dual;
END;


drop table dealers;
create table dealers (
    dealer_id number (22) not null ,
    Country varchar(50) not null ,
    City varchar(50) not null ,
    Address varchar(200) not null ,
    Insert_DT date not null ,
    constraint pk_dealer_id primary key (dealer_id)
) organization index
tablespace ts_dealers_layouts_01;


-- generating data
-- products imported from csv, updates products_desc
update PRODUCTS
set product_desc = 'Tesla Model ' ||''|| products.model ||' '|| products.specs ||' in '|| products.color
where model in ('X', 'S', 'Y', '3');

commit;

-- customers recreated using sql expressions

create or replace function get_country return varchar
IS country varchar(100);
begin
    select
           country_desc
    into country
    from ( SELECT country_desc FROM u_dw_references.vl_countries
        ORDER BY dbms_random.value )
        where rownum = 1;
    return country;
    end;

create or replace function get_city return varchar
IS city varchar(10);
begin
    select
           country_code_a2
    into city
    from (select country_code_a2 from U_DW_REFERENCES.VL_COUNTRIES
        order by DBMS_RANDOM.VALUE)
        where rownum = 1
    ;
    return city;
end;


insert into customers (customer_name, country, city, product_id, count, insert_dt)
select
        ('Customer ' || rn) customer_name ,
        get_country() country,
        NVL(get_city(), 'All Cities')  city,
        floor(DBMS_RANDOM.VALUE(146,218)) product_id,
        floor(DBMS_RANDOM.VALUE(1 , 4)) count,
        to_date ('2021-07-31', 'YYYY-MM-DD') +
        trunc(dbms_random.value(0, (to_date ('2025-04-01', 'YYYY-MM-DD') - to_date ('2021-07-31', 'YYYY-MM-DD') + 1))) insert_DT
    from (select ROWNUM rn from dual connect by level <= 100000) ;
;
commit;
update customers
set address = (country ||' street, building '|| city)
where rownum <= 100001;
commit;


select * from customers
where country = 'United States of America';


-- dealers

alter table dealers
modify address varchar (100) null;
alter table dealers
modify country varchar(80);
alter table dealers
modify city varchar (80) null;

truncate table dealers;
insert into dealers (dealer_id,Country, City, Address, Insert_DT)

select rownum dealer_id,
       COUNTRY_DESC Country,
       COUNTRY_CODE_A2 City,
       COUNTRY_DESC ||' street, buidling '|| COUNTRY_CODE_A2,
       sysdate

    from U_DW_REFERENCES.VL_COUNTRIES;
commit;

-- periods
drop table Periods;
create table Periods
(
    PERIOD_NAME VARCHAR2(20),
    START_DT    DATE,
    END_DT      DATE,
    INSERT_DT   DATE
);

insert into Periods (START_DT, END_DT, INSERT_DT)
select
    stdate + 30 + rn,
    stdate + 60 + rn,
    to_date(to_char(sysdate, 'YYYY-MM-DD'), 'YYYY-MM-DD')

FROM
(select to_date('2015-07-13', 'YYYY-MM-DD') stdate,
        ROWNUM rn
from dual
connect by level <= 1000);
commit;

update periods
set PERIOD_NAME = 'Fourth'
where  to_number(to_char(start_dt, 'MM')) >= 10;


