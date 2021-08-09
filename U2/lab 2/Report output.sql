-- daily report

with tsales as (
    select
        c.customer_name,
        c.customer_id,
        c.country,
        c.PRODUCT_ID,
        c.COUNT orders,
        c.INSERT_DT transaction_date,
        d.city dealer_city,
        d.COUNTRY dealer_country,
        p.MODEL ||' '|| p.SPECS model_name,
        (c.COUNT * p.PRICE) revenue



    from sa_reports.CUSTOMERS c
    join DEALERS D on c.COUNTRY = D.COUNTRY
    join PRODUCTS P on c.PRODUCT_ID = P.PRODUCT_ID
    where c.INSERT_DT >= to_date('2022-01-01', 'YYYY-MM-DD')
    and c.INSERT_DT <= (to_date('2022-02-01', 'YYYY-MM-DD')) and d.COUNTRY = 'Belarus'

)
select
       distinct
       transaction_date event_dt,
       decode (grouping (model_name), 1, 'all models', model_name) as model_name,
       decode ( grouping ( dealer_city ), 1, 'all_cities', dealer_city ) as geo_id,
       sum(revenue),
       sum(orders)

from tsales
group by transaction_date, cube(model_name, dealer_city, revenue)
HAVING grouping_id (model_name, dealer_city) < 1
order by transaction_date desc;
;

-- monthly


with tsales as (
    select
        c.customer_name,
        c.customer_id,
        c.country,
        c.PRODUCT_ID,
        c.COUNT orders,
        c.INSERT_DT transaction_date,
        to_char(c.INSERT_DT, 'MM') month,
        d.city dealer_city,
        d.COUNTRY dealer_country,
        p.MODEL ||' '|| p.SPECS model_name,
        (c.COUNT * p.PRICE) revenue



    from sa_reports.CUSTOMERS c
    join DEALERS D on c.COUNTRY = D.COUNTRY
    join PRODUCTS P on c.PRODUCT_ID = P.PRODUCT_ID
    where c.INSERT_DT between to_date('2022-01-01', 'YYYY-MM-DD') and to_date('2023-01-01', 'YYYY-MM-DD')
    and d.COUNTRY = 'Belarus'

)
select

       decode(grouping(month), 1, 'all months', month) as month,
       decode (grouping (model_name), 1, 'all models', model_name) as model_name,
       decode ( grouping ( dealer_city ), 1, 'all_cities', dealer_city ) as geo_id,
       sum(revenue),
       sum(orders)

from tsales
group by grouping sets ( (month, model_name, dealer_city), (month, dealer_city), ( model_name, dealer_city), (month, model_name) )
HAVING grouping_id (model_name, dealer_city) < 1
;




-- roll up time
with tsales as (
    select
        c.customer_name,
        c.customer_id,
        c.country,
        c.PRODUCT_ID,
        c.COUNT orders,
        c.INSERT_DT transaction_date,
        to_char(c.INSERT_DT, 'MM') month,
        d.city dealer_city,
        d.COUNTRY dealer_country,
        p.MODEL ||' '|| p.SPECS model_name,
        (c.COUNT * p.PRICE) revenue



    from sa_reports.CUSTOMERS c
    join DEALERS D on c.COUNTRY = D.COUNTRY
    join PRODUCTS P on c.PRODUCT_ID = P.PRODUCT_ID
    where c.INSERT_DT between to_date('2022-01-01', 'YYYY-MM-DD') and to_date('2025-01-01', 'YYYY-MM-DD')
    and d.COUNTRY = 'Belarus'

)
SELECT
       DECODE ( GROUPING_ID ( TRUNC ( transaction_date
                                      , 'Year' )
                              , TRUNC ( transaction_date
                                      , 'Q' )
                              , TRUNC ( transaction_date
                                      , 'Month' )
                              , TRUNC ( transaction_date
                                      , 'DD' ) )
                , 7, 'Total for year'
                , 15, 'GRANT TOTAL'
                , TRUNC ( transaction_date
                        , 'Year' ) )
            AS year
       , DECODE ( GROUPING_ID ( TRUNC ( transaction_date
                                      , 'Year' )
                              , TRUNC ( transaction_date
                                      , 'Q' )
                              , TRUNC ( transaction_date
                                      , 'Month' )
                              , TRUNC ( transaction_date
                                      , 'DD' ) )
                , 3, 'Total for quarter'
                , TRUNC (transaction_date
                        , 'Q' ) )
            AS quarter
       , DECODE ( GROUPING_ID ( TRUNC ( transaction_date
                                      , 'Year' )
                              , TRUNC ( transaction_date
                                      , 'Q' )
                              , TRUNC ( transaction_date
                                      , 'Month' )
                              , TRUNC ( transaction_date
                                      , 'DD' ) )
                , 1, 'Total for month'
                , TRUNC ( transaction_date
                        , 'Month' ) )
            AS month
       , DECODE ( GROUPING_ID ( TRUNC ( transaction_date
                                      , 'Year' )
                              , TRUNC ( transaction_date
                                      , 'Q' )
                              , TRUNC ( transaction_date
                                      , 'Month' )
                              , TRUNC ( transaction_date
                                      , 'DD' ) )
                , 15, ''
                , TRUNC ( transaction_date
                        , 'DD' ) )
            AS day
       , sum (orders) orders
       ,sum(revenue) revenue
    FROM tsales
    GROUP BY ROLLUP ( TRUNC ( transaction_date
                        , 'Year' ), TRUNC ( transaction_date
                                          , 'Q' ), TRUNC (transaction_date
                                                         , 'Month' ), TRUNC ( transaction_date
                                                                            , 'DD' ) );