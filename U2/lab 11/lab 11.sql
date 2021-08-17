SELECT 'dealer ' || d.dealer_id AS dealer,
       d.country                AS country,
       t.year_calendar          AS year,
       t.month_number           AS month,
       SUM(c.count)             AS count,
       SUM(p.price * c.count)   AS total_amount
FROM dw_data.dw_dealers                     d
         LEFT JOIN dw_data.dw_customers_scd c
                   ON (d.country = c.country)
         LEFT JOIN dw_data.dw_products      p
                   ON (c.product_id = p.product_id)
         LEFT JOIN dw_data.dw_time          t
                   ON (c.valid_from = t.time_id)
GROUP BY d.dealer_id, year_calendar, month_number, d.country
ORDER BY dealer_id, year_calendar, month_number;

WITH tsales AS (
    SELECT c.customer_name,
           c.customer_id,
           c.country,
           c.product_id,
           c.count                    orders,
           c.insert_dt                transaction_date,
           TO_CHAR(c.insert_dt, 'MM') month,
           D.city                     dealer_city,
           D.country                  dealer_country,
           P.model || ' ' || P.specs  model_name,
           (c.count * P.price)        revenue

    FROM sa_layer.customers         c
             JOIN sa_layer.dealers  D
                  ON c.country = D.country
             JOIN sa_layer.products P
                  ON c.product_id = P.product_id
    WHERE c.insert_dt BETWEEN TO_DATE('2022-01-01', 'YYYY-MM-DD') AND TO_DATE('2023-01-01', 'YYYY-MM-DD')
      AND D.country = 'Belarus'
)
SELECT DECODE(GROUPING(month), 1, 'all months', month)             AS month,
       DECODE(GROUPING(model_name), 1, 'all models', model_name)   AS model_name,
       DECODE(GROUPING(dealer_city), 1, 'all_cities', dealer_city) AS geo_id,
       SUM(revenue),
       SUM(orders)

FROM tsales
GROUP BY GROUPING SETS ( (month, model_name, dealer_city), ( month, dealer_city), ( model_name, dealer_city), ( month,
                          model_name) )
HAVING GROUPING_ID(model_name, dealer_city) < 1;

