WITH a AS (SELECT 'dealer ' || d.dealer_id AS dealer,
                  d.country                AS country,
                  t.year_calendar          AS year,
                  t.month_number           AS month,
                  SUM(c.count)             AS count,
                  SUM(p.price * c.count)   AS total_amount
           FROM sales_fct         f,
                dim_dealers       d,
                dim_customers_scd c,
                dim_geo_locations g,
                dim_products      p,
                dim_time          t,
                dim_gen_periods   gp
           WHERE f.geo_id = g.geo_id
             AND f.product_id = p.product_id
             AND f.time_id = t.time_id
             AND f.period_id = gp.period_id
             AND f.customer_id = c.customer_surr_id
             AND f.DEALER_ID = d.DEALER_ID
           GROUP BY d.dealer_id, year_calendar, month_number, d.country
           ORDER BY dealer, year_calendar, month_number)

SELECT dealer, country, year, month, count, total_amount, mad
FROM a
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
