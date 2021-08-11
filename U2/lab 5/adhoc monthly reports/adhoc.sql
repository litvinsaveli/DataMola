DROP TABLE dw_sales_fct CASCADE CONSTRAINTS;
CREATE TABLE dw_sales_fct
(
    sale_id     number(22) NOT NULL
        CONSTRAINT pk_sale_id PRIMARY KEY,
    event_dt    varchar(10),

    customer_id number(22)
        CONSTRAINT fk_customer_surr_id
            REFERENCES dw_customers_scd
                ON DELETE CASCADE,

    dealer_id   number(22)
        CONSTRAINT fk_dealer_id
            REFERENCES dw_dealers
                ON DELETE CASCADE,
    geo_id      number(22)
        CONSTRAINT fk_geo_id
            REFERENCES dw_geo_locations
                ON DELETE CASCADE,
    product_id  number(22)
        CONSTRAINT fk_product_id
            REFERENCES dw_products
                ON DELETE CASCADE,
    time_id     date
        CONSTRAINT fk_time_id
            REFERENCES dw_time
                ON DELETE CASCADE,
    period_id   number(22)
        CONSTRAINT fk_period_id REFERENCES dw_gen_periods
            ON DELETE CASCADE,
    TOTAL_AMNT  float,
    MAD         float
) TABLESPACE ts_dw_layer_data_01;

INSERT INTO dw_sales_fct (sale_id, event_dt, customer_id, dealer_id, geo_id, product_id, period_id, TOTAL_AMNT)
SELECT /*+parallel (8) */
    ROWNUM,
    t.time_id,
    c.customer_surr_id,
    d.dealer_id,
    g.geo_id,
    p.product_id,
    pr.period_id,
    c.count * p.price
FROM dw_customers_scd               c
         LEFT JOIN dw_dealers       d
                   ON (c.country = d.country)
         LEFT JOIN dw_geo_locations g
                   ON (d.country = g.country_name)
         LEFT JOIN dw_products      p
                   ON (c.product_id = p.product_id)
         LEFT JOIN dw_time          t
                   ON (c.valid_from = t.time_id)
         LEFT JOIN dw_gen_periods   pr
                   ON (c.valid_from >= pr.start_dt AND c.valid_from <= pr.end_dt)
;

COMMIT;



DROP TABLE monthly_report;
CREATE TABLE monthly_report
(
    dealer       varchar(20),
    country      varchar(80),
    year         number(4),
    month        number(2),
    count        number(10),
    total_amount number(22)

) TABLESPACE ts_dw_layer_data_01;

INSERT INTO monthly_report (dealer, country, year, month, count, total_amount)

SELECT 'dealer ' || d.dealer_id AS dealer,
       d.country                AS country,
       t.year_calendar          AS year,
       t.month_number           AS month,
       SUM(c.count)             AS count,
       SUM(p.price * c.count)   AS total_amount
FROM dw_dealers                     d
         LEFT JOIN dw_customers_scd c
                   ON (d.country = c.country)
         LEFT JOIN dw_products      p
                   ON (c.product_id = p.product_id)
         LEFT JOIN dw_time          t
                   ON (c.valid_from = t.time_id)
GROUP BY d.dealer_id, year_calendar, month_number, d.country
ORDER BY dealer_id, year_calendar, month_number;

-- adhocing

SELECT dealer, country, year, month, count, total_amount, mad
FROM monthly_report
WHERE country = 'Belarus'
    MODEL
        PARTITION BY (dealer, country)
        DIMENSION BY (year, month)
        MEASURES (total_amount,count, 0 mad)
        RULES (
        mad[year, month] = ROUND((total_amount[CV(year), CV(month)] - (AVG(total_amount)[cv(YEAR), MONTH])) /
                                 total_amount[CV(year), CV(month)], 7)
        )
ORDER BY dealer, year, month;
