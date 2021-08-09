drop table dw_sales_fct;
create table dw_sales_fct
(
    sale_id     number(22) not null
        constraint pk_sale_id primary key,
    event_dt    date
        constraint fk_time_id references dw_time
            on delete cascade,
    customer_id number(22)
        constraint fk_customer_surr_id
            references dw_customers_scd
                on delete cascade,

    dealer_id   number(22)
        constraint fk_dealer_id
            references DW_DEALERS
                on delete cascade,
    geo_id      number(22)
        constraint fk_geo_id
            references DW_GEO_LOCATIONS
                on delete cascade,
    product_id  number(22)
        constraint fk_product_id
            references DW_PRODUCTS
                on delete cascade,
    period_id   number(22)
        constraint fk_period_id references DW_GEN_PERIODS
            on delete cascade,
    TOTAL_AMNT  float,
    MAD         float
) tablespace TS_DW_LAYER_DATA_01;

insert into DW_SALES_FCT (SALE_ID, EVENT_DT, CUSTOMER_ID, DEALER_ID, GEO_ID, PRODUCT_ID, PERIOD_ID, TOTAL_AMNT)
select /*+parallel (8) */
    rownum,
    t.TIME_ID,
    c.customer_id,
    d.dealer_id,
    g.geo_id,
    p.product_id,
    pr.period_id,
    c.COUNT * p.PRICE
from DW_CUSTOMERS_SCD c
         left join DW_DEALERS d on (c.COUNTRY = d.COUNTRY)
         left join DW_GEO_LOCATIONS g on (d.COUNTRY = g.COUNTRY_NAME)
         left join DW_PRODUCTS p on (c.PRODUCT_ID = p.PRODUCT_ID)
         left join DW_TIME t on (c.VALID_FROM = t.TIME_ID)
         left join DW_GEN_PERIODS pr on (c.VALID_FROM >= pr.START_DT and c.VALID_FROM <= pr.end_dt)
;

commit;



drop table monthly_report;
create table monthly_report
(
    dealer       varchar(20),
    country      varchar(80),
    year         number(4),
    month        number(2),
    count        number(10),
    total_amount number(22)

) tablespace TS_DW_LAYER_DATA_01;

insert into monthly_report (dealer, country, year, month, count, total_amount)

SELECT 'dealer ' || d.dealer_id as dealer,
       d.COUNTRY                as country,
       t.year_calendar          as year,
       t.month_number           as month,
       sum(c.count)             as count,
       sum(p.price * c.count)   as total_amount
from DW_DEALERS d
         left join DW_CUSTOMERS_SCD c on (d.COUNTRY = c.COUNTRY)
         left join dw_products p on (c.PRODUCT_ID = p.product_id)
         left join dw_time t on (c.VALID_FROM = t.TIME_ID)
group by d.DEALER_ID, YEAR_CALENDAR, MONTH_NUMBER, d.country
order by DEALER_ID, YEAR_CALENDAR, MONTH_NUMBER;


-- adhocing

select dealer, country, year, month, count, total_amount, mad
from monthly_report
where country = 'Belarus'
    model
        partition by (dealer, country)
        dimension by (year, month)
        measures (total_amount,count, 0 mad)
        rules (
        mad[year, month] = round((total_amount[cv(year), cv(month)] - (avg(total_amount)[cv(year), month])) /
                                 total_amount[cv(year), cv(month)], 7)
        )
order by dealer, year, month;
