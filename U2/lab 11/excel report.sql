CREATE TABLE adhoc
AS
SELECT 'dealer ' || d.dealer_id AS dealer,
       d.country                AS country,
       t.year_calendar          AS year,
       t.month_number           AS month,
       SUM(c.count)             AS count,
       SUM(p.price * c.count)   AS total_amount

FROM sales_fct         f,
     dim_dealers       d,
     dim_time          t,
     dim_customers_scd c,
     dim_products      p
WHERE f.DEALER_ID = d.DEALER_ID
  AND f.TIME_ID = t.TIME_ID
  AND f.CUSTOMER_ID = c.customer_surr_id
  AND f.PRODUCT_ID = p.PRODUCT_ID

GROUP BY d.dealer_id, year_calendar, month_number, d.country
ORDER BY d.dealer_id, year_calendar, month_number;

SELECT *
FROM adhoc;


CREATE MATERIALIZED VIEW montly_reports
    REFRESH ON DEMAND
AS
SELECT dealer, country, year, month, count, total_amount, mad
FROM adhoc
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

GRANT SELECT ON montly_reports TO PUBLIC;