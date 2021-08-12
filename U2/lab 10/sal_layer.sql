-- prerequisites

DROP TABLESPACE ts_sal_cl_01 INCLUDING CONTENTS AND DATAFILES;
CREATE TABLESPACE ts_sal_cl_01
    DATAFILE '/oracle/u02/oradata/DMORCL19DB/slitvin_db/ts_sal_cl_01.dat'
    SIZE 150 M
    AUTOEXTEND ON NEXT 50 M
    SEGMENT SPACE MANAGEMENT AUTO;

DROP USER sal_cl;
CREATE USER sal_cl IDENTIFIED BY uniquepwd
    DEFAULT TABLESPACE ts_sal_cl_01;

DROP TABLESPACE ts_sal_dw_cl_01 INCLUDING CONTENTS AND DATAFILES;
CREATE TABLESPACE ts_sal_dw_cl_01
    DATAFILE '/oracle/u02/oradata/DMORCL19DB/slitvin_db/ts_sal_dw_cl_01.dat'
    SIZE 150 M
    AUTOEXTEND ON NEXT 50 M
    SEGMENT SPACE MANAGEMENT AUTO;

DROP USER sal_dw_cl;
CREATE USER sal_dw_cl IDENTIFIED BY uniquepwd
    DEFAULT TABLESPACE ts_sal_dw_cl_01;

DROP TABLESPACE ts_sal_01 INCLUDING CONTENTS AND DATAFILES;
CREATE TABLESPACE ts_sal_01
    DATAFILE '/oracle/u02/oradata/DMORCL19DB/slitvin_db/ts_sal_01.dat'
    SIZE 150 M
    AUTOEXTEND ON NEXT 50 M
    SEGMENT SPACE MANAGEMENT AUTO;

DROP USER sal_data;
CREATE USER sal_data IDENTIFIED BY uniquepwd
    DEFAULT TABLESPACE ts_sal_01;

COMMIT;



-- object tablespaces
--//
CREATE TABLESPACE ts_dim_customers_scd_data_01
    DATAFILE '/oracle/u02/oradata/DMORCL19DB/slitvin_db/ts_dim_customers_scd_data_01.dat'
    SIZE 50 M
    AUTOEXTEND ON NEXT 50 M
    SEGMENT SPACE MANAGEMENT AUTO;

-- //
CREATE TABLESPACE ts_dim_dealers_data_01
    DATAFILE '/oracle/u02/oradata/DMORCL19DB/slitvin_db/ts_dim_dealers_data_01.dat'
    SIZE 50 M
    AUTOEXTEND ON NEXT 50 M
    SEGMENT SPACE MANAGEMENT AUTO;

--//
CREATE TABLESPACE ts_dim_gen_periods_data_01
    DATAFILE '/oracle/u02/oradata/DMORCL19DB/slitvin_db/ts_dim_gen_periods_data_01.dat'
    SIZE 50 M
    AUTOEXTEND ON NEXT 50 M
    SEGMENT SPACE MANAGEMENT AUTO;
--//
CREATE TABLESPACE ts_dim_geo_locations_data_01
    DATAFILE '/oracle/u02/oradata/DMORCL19DB/slitvin_db/ts_dim_geo_locations_data_01.dat'
    SIZE 50 M
    AUTOEXTEND ON NEXT 50 M
    SEGMENT SPACE MANAGEMENT AUTO;
--//
CREATE TABLESPACE ts_dim_products_data_01
    DATAFILE '/oracle/u02/oradata/DMORCL19DB/slitvin_db/ts_dim_products_data_01.dat'
    SIZE 50 M
    AUTOEXTEND ON NEXT 50 M
    SEGMENT SPACE MANAGEMENT AUTO;
--//
CREATE TABLESPACE ts_dim_time_data_01
    DATAFILE '/oracle/u02/oradata/DMORCL19DB/slitvin_db/ts_dim_time_data_01.dat'
    SIZE 50 M
    AUTOEXTEND ON NEXT 50 M
    SEGMENT SPACE MANAGEMENT AUTO;
--//
CREATE TABLESPACE ts_fct_sales_mm_data_01
    DATAFILE '/oracle/u02/oradata/DMORCL19DB/slitvin_db/ts_fct_sales_mm_data_01.dat'
    SIZE 50 M
    AUTOEXTEND ON NEXT 50 M
    SEGMENT SPACE MANAGEMENT AUTO;

GRANT ALL PRIVILEGES TO sal_cl ON dw_data;

-- layer objects

--------------------------
--    TABLE DEALERS     --
--------------------------
DROP TABLE DIM_DEALERS;
CREATE TABLE DIM_DEALERS
(
    dealer_id number(22) PRIMARY KEY NOT NULL,
    country   varchar2(80)           NOT NULL,
    city      varchar2(80)           NULL,
    address   varchar2(100)          NOT NULL,
    insert_dt date,
    update_dt date
) TABLESPACE ts_dim_dealers_data_01;
--------------------------
--    TABLE PRODUCTS    --
--------------------------
DROP TABLE DIM_PRODUCTS;
CREATE TABLE DIM_PRODUCTS
(
    product_id   number(22)    NOT NULL,
    model        varchar2(10)  NOT NULL,
    specs        varchar2(20)  NOT NULL,
    color        varchar2(20)  NOT NULL,
    price        float         NULL,
    product_desc varchar2(200) NULL,
    insert_dt    date,
    update_dt    date,
    CONSTRAINT pk_product_id PRIMARY KEY (product_id)
) TABLESPACE ts_dim_products_data_01;

--------------------------
-- TABLE CUSTOMERS SCD2 --
--------------------------

DROP TABLE DIM_CUSTOMERS_SCD CASCADE CONSTRAINTS;
CREATE TABLE DIM_CUSTOMERS_SCD
(
    customer_surr_id number(22)                 NOT NULL,
    customer_id      number(22)                 NOT NULL,
    customer_name    varchar2(30)               NOT NULL,
    country          varchar2(80)               NOT NULL,
    city             varchar2(50)               NOT NULL,
    address          varchar2(100)              NOT NULL,
    product_id       number(22)                 NULL,
    count            number(10),
    valid_from       date                       NOT NULL,
    valid_to         date        DEFAULT NULL,
    is_active        varchar2(5) DEFAULT 'True' NOT NULL,
    insert_dt        date,
    update_dt        date,
    CONSTRAINT pk_dw_customers_scd PRIMARY KEY (customer_surr_id)
) TABLESPACE ts_dim_customers_scd_data_01;



---------------------------
--  TABLE GEO_LOCATIONS  --
---------------------------
DROP TABLE DIM_GEO_LOCATIONS;
CREATE TABLE DIM_GEO_LOCATIONS
(
    geo_id          number(22) PRIMARY KEY NOT NULL,
    country_id      number(22)             NOT NULL,
    country_name    varchar2(80)           NOT NULL,
    country_code_a2 char(2)                NULL,
    country_code_a3 char(3)                NULL,
    region_id       number(22)             NOT NULL,
    region_code     number(22)             NULL,
    region_name     varchar2(80)           NOT NULL,
    insert_dt       date,
    update_dt       date
) TABLESPACE ts_dim_geo_locations_data_01;
COMMIT;

-------------------------
--  TABLE GEN PERIODS  --
-------------------------

DROP TABLE DIM_GEN_PERIODS CASCADE CONSTRAINTS;
CREATE TABLE DIM_GEN_PERIODS
(
    period_id    number(22) NOT NULL
        PRIMARY KEY,
    end_dt       date,
    update_dt    date,
    quartel_name varchar2(30),
    insert_dt    date,
    start_dt     date,
    period_name  varchar2(30)

) TABLESPACE ts_dim_gen_periods_data_01;


------------------
--  TABLE TIME  --
------------------
DROP TABLE DIM_TIME;
CREATE TABLE DIM_TIME
(
    time_id          date NOT NULL,
    day_number_week  number(1),
    week_number      number(2),
    month_days_cnt   number(3),
    quarter_days_cnt number(3),
    year_calendar    number(4),
    day_number_year  number(3),
    week_end_dt      date,
    month_number     number(2),
    quarter_begin_dt date,
    quarter_number   number(1),
    day_number_month number(2),
    day_name         varchar2(30),
    month_name       varchar2(30),
    quarter_end_dt   date,
    year_days_cnt    number(3),
    CONSTRAINT pk_dim_time
        PRIMARY KEY (time_id)
) TABLESPACE ts_dim_time_data_01;

------------------------
--  TABLE SALES FACT  --
------------------------

DROP TABLE sales_fct;
CREATE TABLE sales_fct
(
    event_dt     number(10),
    dealer_id    number(22)
        CONSTRAINT fk_dealer_id
            REFERENCES DIM_DEALERS
                ON DELETE CASCADE,
    customer_id  number(22)
        CONSTRAINT fk_customer_surr_id
            REFERENCES DIM_CUSTOMERS_SCD
                ON DELETE CASCADE,
    geo_id       number(22)
        CONSTRAINT fk_geo_id
            REFERENCES DIM_GEO_LOCATIONS
                ON DELETE CASCADE,
    product_id   number(22)
        CONSTRAINT fk_product_id
            REFERENCES DIM_PRODUCTS
                ON DELETE CASCADE,
    time_id      date
        CONSTRAINT fk_time_id
            REFERENCES DIM_TIME
                ON DELETE CASCADE,
    period_id    number(22)
        CONSTRAINT fk_period_id
            REFERENCES DIM_GEN_PERIODS
                ON DELETE CASCADE,
    total_amount float,
    insert_dt    date,
    update_dt    date
) TABLESPACE ts_fct_sales_mm_data_01;








