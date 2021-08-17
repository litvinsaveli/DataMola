-- prerequisites

CREATE TABLESPACE ts_reports_layouts_01
    DATAFILE '/oracle/u02/oradata/DMORCL21DB/slitvin_db/sa_reports_layouts_01.dat'
    SIZE 50 M
    AUTOEXTEND ON NEXT 50 M
    SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE ts_products_layouts_01
    DATAFILE '/oracle/u02/oradata/DMORCL21DB/slitvin_db/sa_reports_products_01.dat'
    SIZE 50 M
    AUTOEXTEND ON NEXT 50 M
    SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE ts_customers_layouts_01
    DATAFILE '/oracle/u02/oradata/DMORCL21DB/slitvin_db/sa_customers_layouts_01.dat'
    SIZE 50 M
    AUTOEXTEND ON NEXT 50 M
    SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE ts_dealers_layouts_01
    DATAFILE '/oracle/u02/oradata/DMORCL21DB/slitvin_db/sa_dealers_layouts_01.dat'
    SIZE 50 M
    AUTOEXTEND ON NEXT 50 M
    SEGMENT SPACE MANAGEMENT AUTO;

CREATE USER sa_reports IDENTIFIED BY uniquepwd
    DEFAULT TABLESPACE ts_reports_layouts_01;

ALTER USER sa_reports QUOTA UNLIMITED ON ts_reports_layouts_01;
ALTER USER sa_reports QUOTA UNLIMITED ON ts_customers_layouts_01;
ALTER USER sa_reports QUOTA UNLIMITED ON ts_products_layouts_01;
ALTER USER sa_reports QUOTA UNLIMITED ON ts_dealers_layouts_01;

-- creating tables and generating data.
DROP TABLE customers;

CREATE TABLE customers
(
    customer_id   number(22)   NOT NULL,
    customer_name varchar(30)  NOT NULL,
    country       varchar(50)  NOT NULL,
    city          varchar(50)  NOT NULL,
    address       varchar(100) NOT NULL,
    product_id    number(22)   NOT NULL,
    count         number(10)   NOT NULL,
    insert_dt     date         NOT NULL,

    CONSTRAINT pk_customer_id PRIMARY KEY (customer_id)

) ORGANIZATION INDEX
    TABLESPACE ts_customers_layouts_01;

DROP SEQUENCE sq_customers;
CREATE SEQUENCE sq_customers;

DROP TRIGGER tr_customers_on_insert;

CREATE OR REPLACE TRIGGER tr_customers_on_insert
    BEFORE INSERT
    ON sa_reports.customers
    FOR EACH ROW
BEGIN
    SELECT sq_customers.nextval
    INTO :NEW.customer_id
    FROM dual;
END;


DROP TABLE products;

CREATE TABLE products
(
    product_id   number(22)   NOT NULL,
    model        varchar(10)  NOT NULL,
    specs        varchar(20)  NOT NULL,
    color        varchar(20)  NOT NULL,
    price        number(10)   NOT NULL,
    product_desc varchar(200) NOT NULL,
    insert_dt    date         NOT NULL,

    CONSTRAINT pk_product_id PRIMARY KEY (product_id)
) ORGANIZATION INDEX
    TABLESPACE ts_products_layouts_01;

DROP SEQUENCE sq_products;
CREATE SEQUENCE sq_products;

DROP TRIGGER tr_products_on_insert;

CREATE OR REPLACE TRIGGER tr_products_on_insert
    BEFORE INSERT
    ON sa_reports.products
    FOR EACH ROW
BEGIN
    SELECT sq_products.nextval
    INTO :NEW.product_id
    FROM dual;
END;


DROP TABLE dealers;
CREATE TABLE dealers
(
    dealer_id number(22)   NOT NULL,
    Country   varchar(50)  NOT NULL,
    City      varchar(50)  NOT NULL,
    Address   varchar(200) NOT NULL,
    Insert_DT date         NOT NULL,
    CONSTRAINT pk_dealer_id PRIMARY KEY (dealer_id)
) ORGANIZATION INDEX
    TABLESPACE ts_dealers_layouts_01;


-- generating data
-- products imported from csv, updates products_desc
UPDATE products
SET product_desc = 'Tesla Model ' || '' || products.model || ' ' || products.specs || ' in ' || products.color
WHERE model IN ('X', 'S', 'Y', '3');

COMMIT;

-- customers recreated using sql expressions

CREATE OR REPLACE FUNCTION get_country RETURN varchar
    IS
    country varchar(100);
BEGIN
    SELECT country_desc
    INTO country
    FROM (SELECT country_desc
          FROM u_dw_references.vl_countries
          ORDER BY dbms_random.value)
    WHERE ROWNUM = 1;
    RETURN country;
END;

CREATE OR REPLACE FUNCTION get_city RETURN varchar
    IS
    city varchar(10);
BEGIN
    SELECT country_code_a2
    INTO city
    FROM (SELECT country_code_a2
          FROM u_dw_references.vl_countries
          ORDER BY dbms_random.value)
    WHERE ROWNUM = 1;
    RETURN city;
END;


INSERT INTO customers (customer_name, country, city, product_id, count, insert_dt)
SELECT ('Customer ' || rn)                customer_name,
       get_country()                      country,
       NVL(get_city(), 'All Cities')      city,
       FLOOR(dbms_random.value(146, 218)) product_id,
       FLOOR(dbms_random.value(1, 4))     count,
       TO_DATE('2021-07-31', 'YYYY-MM-DD') +
       TRUNC(dbms_random.VALUE(0, (TO_DATE('2025-04-01', 'YYYY-MM-DD') - TO_DATE('2021-07-31', 'YYYY-MM-DD') +
                                   1)))   insert_DT
FROM (SELECT ROWNUM rn FROM dual CONNECT BY LEVEL <= 100000);
;
COMMIT;
UPDATE customers
SET address = (country || ' street, building ' || city)
WHERE ROWNUM <= 100001;
COMMIT;


SELECT *
FROM customers
WHERE country = 'United States of America';

-- dealers

ALTER TABLE dealers
    MODIFY Address varchar(100) NULL;
ALTER TABLE dealers
    MODIFY Country varchar(80);
ALTER TABLE dealers
    MODIFY City varchar(80) NULL;

TRUNCATE TABLE dealers;
INSERT INTO dealers (dealer_id, Country, City, Address, Insert_DT)

SELECT ROWNUM          dealer_id,
       country_desc    Country,
       country_code_a2 City,
       country_desc || ' street, buidling ' || country_code_a2,
       SYSDATE

FROM u_dw_references.vl_countries;
COMMIT;

-- periods
DROP TABLE Periods;
CREATE TABLE Periods
(
    PERIOD_NAME varchar2(20),
    START_DT    date,
    END_DT      date,
    INSERT_DT   date
);

INSERT INTO Periods (START_DT, END_DT, INSERT_DT)
SELECT stdate + 30 + rn,
       stdate + 60 + rn,
       TO_DATE(TO_CHAR(SYSDATE, 'YYYY-MM-DD'), 'YYYY-MM-DD')

FROM (SELECT TO_DATE('2015-07-13', 'YYYY-MM-DD') stdate,
             ROWNUM                              rn
      FROM dual
      CONNECT BY LEVEL <= 1000);
COMMIT;

UPDATE Periods
SET PERIOD_NAME = 'Fourth'
WHERE TO_NUMBER(TO_CHAR(START_DT, 'MM')) >= 10;


