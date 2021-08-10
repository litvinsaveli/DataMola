create user dw_data identified by uniquepwd;


drop tablespace ts_dw_layer_data_01 including contents and datafiles;

CREATE TABLESPACE ts_dw_layer_data_01
    DATAFILE '/oracle/u02/oradata/DMORCL19DB/slitvin_db/ts_dw_layer_data_01.dat'
    SIZE 50 M
    AUTOEXTEND ON NEXT 50 M
    SEGMENT SPACE MANAGEMENT AUTO;


--------------------------
--    TABLE DEALERS     --
--------------------------
drop table DW_DEALERS;
create table DW_DEALERS
(
    dealer_id number(22) primary key not null,
    country   varchar2(80)           not null,
    city      varchar2(80)           null,
    address   varchar2(100)          not null,
    insert_dt date,
    update_dt date
) tablespace TS_DW_LAYER_DATA_01;
--------------------------
--    TABLE PRODUCTS    --
--------------------------
drop table DW_PRODUCTS;
create table DW_PRODUCTS
(
    product_id   number(22)    not null,
    model        varchar2(10)  not null,
    specs        varchar2(20)  not null,
    color        varchar2(20)  not null,
    price        number(10)    null,
    product_desc varchar2(200) null,
    insert_dt    date,
    update_dt    date,
    constraint pk_product_id primary key (product_id)
) tablespace TS_DW_LAYER_DATA_01;

--------------------------
-- TABLE CUSTOMERS SCD2 --
--------------------------

drop table DW_CUSTOMERS_SCD cascade constraints;
create table DW_CUSTOMERS_SCD
(
    customer_surr_id number(22)                 not null,
    customer_id      number(22)                 not null,
    customer_name    varchar2(30)               not null,
    country          varchar2(80)               not null ,
    city             varchar2(50)               not null,
    address          varchar2(100)              not null,
    product_id       number(22)                 null,
    count            number(10),
    valid_from       date                       not null,
    valid_to         date        default null,
    is_active        varchar2(5) default 'True' not null,
    insert_dt        date,
    update_dt        date,
    constraint pk_dw_customers_scd primary key (customer_surr_id)
) tablespace TS_DW_LAYER_DATA_01;

create unique index idx_customers_scd on DW_CUSTOMERS_SCD (valid_to, is_active);


drop sequence sq_dw_dim_customers;
create sequence sq_dw_dim_customers;


create or replace trigger DW_CUSTOMERS_ON_INSERT
    before insert
    on DW_CUSTOMERS_SCD
    for each row
declare
    integrity_error          exception;
    errno                    integer;
    errmsg                   char(200);

    begin
    IF :new.customer_surr_id IS NOT NULL THEN
      raise_application_error ( -20000
                              , 'Geo_id have to be ''NULL''. New Values will be generated by triger.' );
    END IF;

    select sq_dw_dim_customers.nextval
        into :new.customer_surr_id
    from dual;

    exception
    when integrity_error then
       raise_application_error(errno, errmsg);

    end;

commit;

---------------------------
--  TABLE GEO_LOCATIONS  --
---------------------------
drop table DW_GEO_LOCATIONS;
create table DW_GEO_LOCATIONS
(
    geo_id          number(22) primary key not null,
    country_id      number(22)             not null,
    country_name    varchar2(80)           not null,
    country_code_a2 char(2)                null,
    country_code_a3 char(3)                null,
    region_id       number(22)             not null,
    region_code     number(22)             null,
    region_name     varchar2(80)           not null,
    insert_dt       date,
    update_dt       date
) tablespace TS_DW_LAYER_DATA_01;
commit;

-- additional setting
alter user dw_data quota unlimited on ts_dw_layer_data_01;
create user DW_CL identified by uniquepwd;
grant all privileges to DW_CL;






