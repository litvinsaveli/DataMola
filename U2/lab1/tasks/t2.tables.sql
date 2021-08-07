CREATE TABLESPACE ts_references_idx_01
    DATAFILE '/oracle/u02/oradata/DMORCL21DB/esolomevic_db/db_qpt_references_idx_01.dat'
    SIZE 50 M
    AUTOEXTEND ON NEXT 50 M
    SEGMENT SPACE MANAGEMENT AUTO;

create user sa_layer identified by sapwd;

drop table SA_PRODUCTS_DATA;
-- products SA level
create table SA_PRODUCTS_DATA
(
    model_name varchar(10) not null,
    specs_name varchar(25),
    color_name varchar(25),
    price      numeric(10),
    insert_dt  date        not null
) tablespace ts_sa_products_data_01
;
drop table SA_CUSTOMERS_DATA;
-- customers SA_LEVEL

create table SA_CUSTOMERS_DATA (
                                   FIRST_NAME VARCHAR(20),
                                   LAST_NAME  VARCHAR(20),
                                   COUNTRY    VARCHAR(20),
                                   CITY       VARCHAR(25),
                                   ADDRESS    VARCHAR(50),
                                   ZIP_CODE   NUMBER(10),
                                   EMAIL      VARCHAR(30),
                                   PHONE      VARCHAR(20),
                                   AGE        NUMBER(3, 1),
                                   INSERT_DT  DATE
) tablespace ts_sa_customers_data_01;


drop table sa_geo_data;
-- geo sa level

create table sa_geo_data
(

    COUNTRY_NAME VARCHAR(20),
    REGIO_NAME   VARCHAR(20),
    CITY_NAME    VARCHAR(25),
    INSERT_DT    DATE
) tablespace ts_sa_customers_data_01;

drop table sa_dealers_data;
-- dealers data sa level
create table sa_dealers_data
(
    COUNTRY VARCHAR(20) not null,
    REGION  VARCHAR(20),
    CITY    VARCHAR(25),
    ADDRESS VARCHAR(50),
    PHONE   VARCHAR(20)
) tablespace ts_sa_products_data_01;

drop table sa_periods_data;
-- peridos sa level
create table sa_periods_data
(
    PERIOD_NAME VARCHAR2(20),
    START_DT    DATE,
    END_DT      DATE,
    INSERT_DT   DATE
) tablespace ts_sa_customers_data_01;