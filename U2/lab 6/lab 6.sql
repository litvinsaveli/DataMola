-- ad hoc first value, last value

SELECT year,
       month,
       total_amount,
       FIRST_VALUE(total_amount) OVER (
           PARTITION BY dealer, country, year
           ORDER BY total_amount DESC
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
           )                                                          top_sale_value,
       FIRST_VALUE(month) OVER (
           PARTITION BY dealer, country, year
           ORDER BY total_amount DESC
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
           )                                                          top_sale_month,
       LAST_VALUE(month) OVER (PARTITION
           BY dealer, country, year
           ORDER BY total_amount DESC
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) worst_month

FROM monthly_report
WHERE country IN ('United States of America')
ORDER BY year, month
;

-- Ad Hoc SQL RANK, DENSE_RANK, ROWNUM

SELECT *
FROM (SELECT country,
             year,
             month,
             total_amount,
             ROW_NUMBER() OVER (
                 PARTITION BY dealer, country, year
                 ORDER BY total_amount DESC
                 ) sales_rn,
             RANK() OVER (
                 PARTITION BY dealer, country, year
                 ORDER BY total_amount DESC
                 ) sales_rank,
             DENSE_RANK() OVER (PARTITION BY dealer, country, year
                 ORDER BY total_amount DESC
                 ) sales_dense_rank

      FROM monthly_report)
WHERE sales_dense_rank <= 10
ORDER BY year, month;

-- Ad Hoc SQL AGGREAGATE FUNCS (MAX, MIN, AVG)

SELECT year,
       month,
       total_amount,
       ROUND(AVG(total_amount) OVER (
           PARTITION BY dealer, year
           ORDER BY total_amount
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
           ), 5)                                                      avg,
       MAX(total_amount) OVER (PARTITION BY country, year
           ORDER BY total_amount
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) max,
       MIN(total_amount) OVER (PARTITION BY year
           ORDER BY total_amount
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)  min
FROM monthly_report
WHERE country IN ('Belarus')
ORDER BY year, month
;
