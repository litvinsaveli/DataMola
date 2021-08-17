DROP TABLE DW_DEALERS;
CREATE TABLE DW_DEALERS
(
    dealer_id number(22) PRIMARY KEY NOT NULL,
    country   varchar2(80)           NOT NULL,
    city      varchar2(80)           NULL,
    address   varchar2(100)          NOT NULL,
    insert_dt date,
    update_dt date
) TABLESPACE ts_dw_data_01;

DROP TABLE DW_PRODUCTS;
CREATE TABLE DW_PRODUCTS
(
    product_id   number(22)    NOT NULL,
    model        varchar2(10)  NOT NULL,
    specs        varchar2(20)  NOT NULL,
    color        varchar2(20)  NOT NULL,
    price        number(10)    NULL,
    product_desc varchar2(200) NULL,
    insert_dt    date,
    update_dt    date,
    CONSTRAINT pk_product_id PRIMARY KEY (product_id)
) TABLESPACE ts_dw_data_01;

DROP TABLE DW_CUSTOMERS;
CREATE TABLE DW_CUSTOMERS
(
    customer_id   number(22) PRIMARY KEY NOT NULL,
    customer_name varchar2(30)           NOT NULL,
    country       varchar2(80)           NOT NULL,
    city          varchar2(50)           NOT NULL,
    address       varchar2(100)          NOT NULL,
    product_id    number(22)             NULL,
    count         number(10),
    insert_dt     date,
    update_dt     date
) TABLESPACE ts_dw_data_01;

DROP TABLE DW_GEO_LOCATIONS;
CREATE TABLE DW_GEO_LOCATIONS
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
) TABLESPACE ts_dw_data_01;
COMMIT;

-- additional setting
GRANT ALL PRIVILEGES TO dw_cl;

-- triggers
DROP SEQUENCE sq_dw_dim_products;
CREATE SEQUENCE sq_dw_dim_products;

DROP TRIGGER TR_PRODUCTS_ON_INSERT;
CREATE TRIGGER TR_PRODUCTS_ON_INSERT
    BEFORE INSERT
    ON DW_PRODUCTS
    FOR EACH ROW
BEGIN
    SELECT sq_dw_dim_products.nextval
    INTO :NEW.product_id
    FROM dual;
END;


DROP SEQUENCE sq_dw_dim_customers;
CREATE SEQUENCE sq_dw_dim_customers;

DROP TRIGGER TR_customers_ON_INSERT;
CREATE TRIGGER TR_customers_ON_INSERT
    BEFORE INSERT
    ON DW_CUSTOMERS
    FOR EACH ROW
BEGIN
    SELECT sq_dw_dim_customers.nextval
    INTO :NEW.customer_id
    FROM dual;
END;




