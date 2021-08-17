DROP TABLE SA_PRODUCTS_DATA;
-- products SA level
CREATE TABLE SA_PRODUCTS_DATA
(
    model_name varchar(10) NOT NULL,
    specs_name varchar(25),
    color_name varchar(25),
    price      numeric(10),
    insert_dt  date        NOT NULL
) TABLESPACE ts_sa_products_data_001
;
DROP TABLE SA_CUSTOMERS_DATA;
-- customers SA_LEVEL

CREATE TABLE SA_CUSTOMERS_DATA
(
    FIRST_NAME varchar(20),
    LAST_NAME  varchar(20),
    COUNTRY    varchar(20),
    CITY       varchar(25),
    ADDRESS    varchar(50),
    ZIP_CODE   number(10),
    EMAIL      varchar(30),
    PHONE      varchar(20),
    AGE        number(3, 1),
    INSERT_DT  date
) TABLESPACE ts_sa_customers_data_001;


DROP TABLE sa_geo_data;
-- geo sa level

CREATE TABLE sa_geo_data
(

    COUNTRY_NAME varchar(20),
    REGIO_NAME   varchar(20),
    CITY_NAME    varchar(25),
    INSERT_DT    date
) TABLESPACE ts_sa_customers_data_001;

DROP TABLE sa_dealers_data;
-- dealers data sa level
CREATE TABLE sa_dealers_data
(
    COUNTRY varchar(20) NOT NULL,
    REGION  varchar(20),
    CITY    varchar(25),
    ADDRESS varchar(50),
    PHONE   varchar(20)
) TABLESPACE ts_sa_products_data_001;

DROP TABLE sa_periods_data;
-- peridos sa level
CREATE TABLE sa_periods_data
(
    PERIOD_NAME varchar2(20),
    START_DT    date,
    END_DT      date,
    INSERT_DT   date
) TABLESPACE ts_sa_customers_data_001;